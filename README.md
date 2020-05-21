# AzureScaffoldingTemplate

This Azure Scaffolding template deploys a ready and secure Azure environment ready for deployment of resources. 
As part of this scaffold environment, a hub and spoke architecture is deployed, as referenced by the architecture diagram in the  "Architecture_v01.vsdx" visio file. The hub subscription, encapsulated by a virtual network, is the sole point of connectivity between the on-premises network and the spoke subscriptions. The spoke subscriptions, also encapsulated as individual virtual networks are peered to the hub via virtual network peering. As such, all ingress and egress network traffic travels via the hub and this isolates the spoke workloads to only have connectivity via the hub. 
The hub and spoke architecutre is split into the four subscriptions as seen in following diagram:

![Architecture Image](https://teststrgacc01.blob.core.windows.net/scaffolding-images/hubspoke-architecture3.PNG)  

-Hub subscription: Central hub subscription that is connected to the on-premises network and spoke subscription (production, pre-production & non-production)
-Production subscription: Contains all resources for running a production environment    
-Pre-production subscription: Contains all resources for running a pre-production environment    
-Non-production subscription: Contains all resources for running a non-production environment with a Developement zone, Test/UAT zone & Sandbox zone.

As part of this scaffolding deployment, the following Azure resources are deployed:
* Virtual networks & Subnets
* Virtual Network Gateway
* Network Security Groups
* NSG Rules
* NAT Gateway
* Azure Firewall
* Application Gateway
* Azure Bastion
* Route Tables
* Recovery Services Vault
* Public IP Addresses
* Express Route Circuit
* Virtual Machines (need to confirm)


# Deployment of Environment: 
There are 4 ARM templates here. One each for hub, and prod,nonprod and preprod spokes. There are 2 ways to roll it out. Both need setup for subscriptions, resource group and SPN beforehand. As a team, you will decide if you want to have one subscription, and 4 resource group (one for each environment), or have 4 subscription with one resource group or something inbetween. 
Once you decide that, for each resource group we need to create SPN and give enough rights on the resource groups to rollout the ARM templates (Contributor should do to start with). SPNs are non interactive logins to azure, that help in automation and scripts rollout. 
So if for example. you decide to have 4 subscriptions, with one resource group for the four environments, you can go ahead and create SPN and give them rights by following the details here - https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-4.1.0

(on how to create subscriptions and resource groups, follow here - https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/ and here - https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal )

once you have created SPNs, you should note down the appID (username), Password and TenantId somewhere securely as they would be used ahead. 

Now to dpeloy these templates there are 2 ways. One is the standard and recommended way to setup azure devops pipelines to deploy resources to the resource groups. 
Inorder to do that, you need to follow the 2 steps below for each environment. You can also play around a bit and enable continous integration/deployment, which will make sure all the changes are validated and deployed straight away. 
First, assuming you have a azure devops account (or just create one, its free to start with and enough for what we are doing here) you need to setup a connection to the resource group. On how to do that, follow the instructions here -
https://azuredevopslabs.com/labs/devopsserver/azureserviceprincipal/

Once you have made the connections to subscriptions, you can dpeloy the ARM templates to each environment you have a connection for by using the details here - https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/add-template-to-azure-pipelines


If you are not that keen and want to quickly test the scripts, use PowerShell file to rollout all 4 environments (coming soon)

