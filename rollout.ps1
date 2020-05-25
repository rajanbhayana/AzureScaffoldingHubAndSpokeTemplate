$hub = [SubscriptionDetails]::new("","","","","")
$preProd = [SubscriptionDetails]::new("","","","","")
$prod = [SubscriptionDetails]::new("","","","","")
$nonProd = [SubscriptionDetails]::new("","","","","")

Class SubscriptionDetails
{
    [String]$_subscriptionId
    [string]$_resourceGroup
    [String]$_spnUser
    [string]$_spnPassword
    [String]$_tenantId
    SubscriptionDetails([String]$SubscriptionId,[string]$ResourceGroup,[String]$SpnUser,[string]$SpnPassword,[String]$tenantId)
    {
        $this._subscriptionId = $SubscriptionId
        $this._resourceGroup = $ResourceGroup
        $this._spnUser = $SpnUser
        $this._spnPassword = $SpnPassword
        $this._tenantId = $tenantId
    }
}

<# Login #>
Function Login($subscriptionDetails) {
    $psCred = New-Object System.Management.Automation.PSCredential($subscriptionDetails._spnUser , (ConvertTo-SecureString $subscriptionDetails._spnPassword -AsPlainText -Force) )
    Connect-AzAccount -Credential $psCred -TenantId $subscriptionDetails._tenantId  -ServicePrincipal 
}

Function Logout(){
    Disconnect-AzAccount
} 

<# rollout nonprod #>
Login($nonProd)
New-AzResourceGroupDeployment -ResourceGroupName $nonProd._resourceGroup -TemplateFile nonprod/azureDeploy_nonprod_vnet.json -verbose
$nonProdVnetObject = Get-AzVirtualNetwork -ResourceGroupName $nonProd._resourceGroup
Logout 

<# rollout preprod #>
Login($preProd) 
New-AzResourceGroupDeployment -ResourceGroupName $preProd._resourceGroup -TemplateFile preprod/azureDeploy_preprod_vnet.json -verbose
$preProdVnetObject = Get-AzVirtualNetwork -ResourceGroupName $preProd._resourceGroup
Logout

<# rollout prod #>
Login($prod)
New-AzResourceGroupDeployment -ResourceGroupName $Prod._resourceGroup -TemplateFile prod/azureDeploy_prod_vnet.json -verbose
$prodVnetObject = Get-AzVirtualNetwork -ResourceGroupName $prod._resourceGroup
Logout

<# rollout hub #>
Login($hub)
New-AzResourceGroupDeployment -ResourceGroupName $hub._resourceGroup -TemplateFile hub/azureDeploy_hub.json -verbose
<# peering hub with other networks #>
$hubVnetObject = Get-AzVirtualNetwork -ResourceGroupName $hub._resourceGroup
Add-AzVirtualNetworkPeering -Name ($hubVnetObject.name + "to" + $prodVnetObject.name) -VirtualNetwork $hubVnetObject -RemoteVirtualNetworkId $prodVnetObject.Id -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name ($hubVnetObject.name + "to" + $preProdVnetObject.name) -VirtualNetwork $hubVnetObject -RemoteVirtualNetworkId $preProdVnetObject.Id -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name ($hubVnetObject.name + "to" + $nonProdVnetObject.name) -VirtualNetwork $hubVnetObject -RemoteVirtualNetworkId $nonProdVnetObject.Id -AllowGatewayTransit
Logout

<# peering other networks with hub#>
<# rollout nonprod #>
Login($nonProd)
Add-AzVirtualNetworkPeering -Name $hub.name -VirtualNetwork $nonProdVnetObject -RemoteVirtualNetworkId $hubVnetObject.Id -UseRemoteGateways
Logout

<# rollout preprod #>
Login($preProd)
Add-AzVirtualNetworkPeering -Name $hub.name -VirtualNetwork $preProdVnetObject -RemoteVirtualNetworkId $hubVnetObject.Id -UseRemoteGateways
Logout

<# rollout prod #>
Login($prod)
Add-AzVirtualNetworkPeering -Name $hub.name -VirtualNetwork $prodVnetObject -RemoteVirtualNetworkId $hubVnetObject.Id -UseRemoteGateways
Logout
