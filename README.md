ARM validation status - 
nonprod - [![Build Status](https://dev.azure.com/rajanbhayana/AzureScaffoldingHubAndSpokeTemplate/_apis/build/status/nonprod%20-%20AzureScaffoldingHubAndSpokeTemplate-CI?branchName=master)](https://dev.azure.com/rajanbhayana/AzureScaffoldingHubAndSpokeTemplate/_build/latest?definitionId=10&branchName=master)

preprod - [![Build Status](https://dev.azure.com/rajanbhayana/AzureScaffoldingHubAndSpokeTemplate/_apis/build/status/preprod%20-%20AzureScaffoldingHubAndSpokeTemplate-CI?branchName=master)](https://dev.azure.com/rajanbhayana/AzureScaffoldingHubAndSpokeTemplate/_build/latest?definitionId=11&branchName=master)

prod - [![Build Status](https://dev.azure.com/rajanbhayana/AzureScaffoldingHubAndSpokeTemplate/_apis/build/status/prod%20-%20AzureScaffoldingHubAndSpokeTemplate-CI?branchName=master)](https://dev.azure.com/rajanbhayana/AzureScaffoldingHubAndSpokeTemplate/_build/latest?definitionId=12&branchName=master)

hub - [![Build Status](https://dev.azure.com/rajanbhayana/AzureScaffoldingHubAndSpokeTemplate/_apis/build/status/hub-AzureScaffoldingHubAndSpokeTemplate-CI?branchName=master)](https://dev.azure.com/rajanbhayana/AzureScaffoldingHubAndSpokeTemplate/_build/latest?definitionId=13&branchName=master)

# AzureScaffoldingTemplate

This Azure Scaffolding template deploys a ready and secure Azure environment ready for deployment of resources. 
As part of this scaffold environment, a hub and spoke architecture is deployed, as referenced by the architecture diagram below. The hub subscription, encapsulated by a virtual network, is the sole point of connectivity between the on-premises network and the spoke subscriptions. The spoke subscriptions, also encapsulated as individual virtual networks are peered to the hub via virtual network peering. As such, all ingress and egress network traffic travels via the hub and this isolates the spoke workloads to only have connectivity via the hub. 
The hub and spoke architecture is split into the four subscriptions as seen in following diagram:

![Architecture Image](https://github.com/rajanbhayana/AzureScaffoldingHubAndSpokeTemplate/raw/master/image1.png)  

- Hub subscription: Central hub subscription that is connected to the on-premises network and spoke subscription (production, pre-production & non-production)
- Production subscription: Contains all resources for running a production environment    
- Pre-production subscription: Contains all resources for running a pre-production environment    
- Non-production subscription: Contains all resources for running a non-production environment with a Developement zone, Test/UAT zone & Sandbox zone.

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



# Deployment of Environment: 
There are 4 ARM templates available in this repository. One each for hub, and prod, nonprod and preprod spokes. There are two different methods to roll out these templates in your subscriptions - both methods requires subscriptions, resource group and SPN created prior to commencing the roll out process. You will also have to decide if you want to deploy all 4 environments using 4 different subscriptions, or wants to deploy only 3 environmentsand (e.g. Hub, Prod, nonprod) or follow different approach.

Once you've made decision on environments deployment, for each subscription we need to create SPN and give enough rights on the resource groups to rollout the ARM templates (Contributor should do to start with). SPNs are non interactive logins to azure, that help in automation and scripts rollout. For example, you decide to have 4 subscriptions, with one resource group for the four environments, you can go ahead and create SPN and give them rights by following the details here - https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-4.1.0

On how to create subscriptions and resource groups, follow here - https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/ and here - https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal

Once you have created SPNs, you should note down the appID (username), Password and TenantId somewhere securely as they would be used in the next steps. 

## Methods to deploy these templates

1. Setup azure devops pipelines to deploy resources to the resource groups (Recommended): 
    In order to do that, you need to follow two steps below for each environment. You can also explore other options, such as, enable continous integration/deployment, which will make sure all the changes are validated and deployed straight away.

Assumption: You already have a azure devops account, if not, you need to create a azure devops account which is free to start with and would be sufficient to accomplish this task. You need to setup a connection to the resource group. Please follow these instructions- https://azuredevopslabs.com/labs/devopsserver/azureserviceprincipal/

Once you have made the connections to subscriptions, you can dpeloy the ARM templates to each environment you have a connection for by using the details here - https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/add-template-to-azure-pipelines

Note: Use the rollout.ps1 script to setup peering. Make sure to comment out lines 35, 41, 47 and 53. They are for hub and spoke deployment and that has already been done using pipelines above.

2. Use PowerShell script 'rollout.ps1': If you don't want to use Azure DevOps and wants to test the deployment using script, use PowerShell script "rollout.ps1". Update the first 4 lines with subscriptionID, resource group, username, password and tenantID for all the environments. This script will rollout hub, spokes and setup peering among virtual networks. It will deploy resources under each of the target subscriptions first and then runs virtual network peering AZ PS commands to create the virtual peerings between the hub and spoke vNets.

Parameters: All resource parameters in the ARM template files have been specified following standard conventions and defined in the parameters section at the top of each file. Any parameter values can be modified by updating it's value in this section. Parameter value details are covered in the attached Azure Scaffold_Parameters_v01.docx file which you can use as a reference point.


# Roadmap
- Additional services beyond the base templates that may be helpful
- Move vnet peering to ARM templates
