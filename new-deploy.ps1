# Replace the following URL with a public GitHub repo URL
$gitrepo="https://github.com/Azure-Samples/app-service-web-dotnet-get-started.git"
$webappname="mywebapp$(Get-Random)"
$location="West US"
$resourcegroup="rtd-webapp2"

#Remove Resource Group
Remove-AzureRmResourceGroup -Name $resourcegroup -Force

# Create a resource group.
New-AzureRmResourceGroup -Name $resourcegroup -Location $location

# Create an App Service plan in Free tier.
New-AzureRmAppServicePlan -Name $webappname -Location $location `
-ResourceGroupName $resourcegroup -Tier Standard

# Create a web app.
New-AzureRmWebApp -Name $webappname -Location $location `
-AppServicePlan $webappname -ResourceGroupName $resourcegroup

# Upgrade App Service plan to Standard tier (minimum required by deployment slots)
Set-AzureRmAppServicePlan -Name $webappname -ResourceGroupName $resourcegroup `
-Tier Standard

#Create a deployment slot with the name "staging".
New-AzureRmWebAppSlot -Name $webappname -ResourceGroupName $resourcegroup `
-Slot staging

# Configure GitHub deployment to the staging slot from your GitHub repo and deploy once.
$PropertiesObject = @{
    repoUrl = "$gitrepo";
    branch = "master";
}
Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $resourcegroup `
-ResourceType Microsoft.Web/sites/slots/sourcecontrols `
-ResourceName $webappname/staging/web -ApiVersion 2015-08-01 -Force

# Swap the verified/warmed up staging slot into production.
Swap-AzureRmWebAppSlot -Name $webappname -ResourceGroupName $resourcegroup `
-SourceSlotName staging -DestinationSlotName production