$gitrepo="https://github.com/Azure-Samples/app-service-web-dotnet-get-started.git"
$webappname="mywebapp$(Get-Random)"
$location="West US"
$resourcegroup="rtd-webapp"

#Remove Resource Group
Remove-AzureRmResourceGroup -Name $resourcegroup -Force

# Create a resource group.
New-AzureRmResourceGroup -Name $resourcegroup -Location $location

# Create an App Service plan in `Free` tier.
New-AzureRmAppServicePlan -Name $webappname -Location $location `
-ResourceGroupName $resourcegroup -Tier Free

# Create a web app.
New-AzureRmWebApp -Name $webappname -Location $location -AppServicePlan $webappname `
-ResourceGroupName $resourcegroup

# Configure GitHub deployment from your GitHub repo and deploy once.
$PropertiesObject = @{
    repoUrl = "$gitrepo";
    branch = "master";
}

Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $resourcegroup `
-ResourceType Microsoft.Web/sites/config -ResourceName $webappname/web `
-ApiVersion 2015-08-01 -Force

# Get app-level deployment credentials
$xml = [xml](Get-AzureRmWebAppPublishingProfile -Name $webappname -ResourceGroupName $resourcegroup `
-OutputFile null)
$username = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userName").value
$password = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userPWD").value

# Add the Azure remote to your local Git respository and push your code
#### This method saves your password in the git remote. You can use a Git credential manager to secure your password instead.
git remote add azure "https://${username}:$password@$webappname.scm.azurewebsites.net"
git push azure master