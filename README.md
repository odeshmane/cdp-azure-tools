# cdp-azure-quickstart

#### Step 1. Verifying access to CDP console
![CDP Landing Page](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/screenshot6.png?raw=true)

If you've reached the above landing page for the first time, you've come to the right place! In this quickstart, we're going to walkthrough step by step how to connect CDP to your Azure subscription so that you can begin to provision clusters and workloads. 

In order to complete this quickstart, you'll need access to two things.  

  1. The CDP console (if you've reached the above screen, you're good to go there)
  2. The Azure console
  3. Azure Cloud shell

#### Step 2.  How to create Azure AD App create

Login to Azure portal and open "cloud shell" 

![Azure Cloud shell](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/azure-shell.png?raw=true)

Get subscription ID and Tenant ID by running the command below.

#1
```az account list|jq '.[]|{"name": .name, "subscriptionId": .id, "tenantId": .tenantId, "state": .state}'```

The output of this command is as below:

![SubscriptionID and TenantID](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/sub-tenant-ID.png?raw=true)

Please note down SubscriptionID and TenantID -> You will need these values later.

Create an app in Azure AD and assign 'Contributor' role at subscription level

#2
```az ad sp create-for-rbac --name http://cloudbreak-app --role Contributor --scopes /subscriptions/{subscriptionId}```
Note: Replace subscriptionId with the subscriptionId from #1

The output of this command is as below:
![Output after app create](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/app-output.png?raw=true)

#### Step 3. Creating a CDP Credential

  - In the CDP Console, the first thing we're going to do is create our CDP Credential.  The CDP credential is the mechanism that allows CDP to create resources inside your Cloud Account.  
    1. From the CDP Home Screen, click the **Management Console** icon. 
    2. On the left side navigation plane, go to **Environments**
    3. From there, in the top left choose **Shared Resources**, then **Credentials**
    4. Click on the **Create Credential** button on the top right.

![CDP Credential Page](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/credential.png?raw=true)

- Provide the different values catured for subscriptionID, TenantID, AppID, Password in the steps above and click Create.

![CDP Credential Page](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/create-app1.png?raw=true)

## Azure quickstart template

ARM template that deploys essential Azure resources for Cloudera CDP environment.

Click ' Deploy to Azure' (#3) and login to your subscription to create essential resources for CDP deployment in your subscription. These resources include VNet, ADLS Gen2, 4 User Managed Identities. Provide envName on the screen. (refer the screenshot below).

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcegganesh84%2Fcdp-azure-tools%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fcegganesh84%2Fcdp-azure-tools%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

![Deploy To Azure](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/deployment.png?raw=true)

The Environment name that you provide is referred as <envName> going forward.

This step is going to create resources with the names as below, please note down these values as you will need them later.

Resource group: <rg-name> - Resource Group name that you provided when creating a new one in this step.
Storage Account: <sa-name> - Environment name that you provided in this step.
vnet: <vnet-name> - Environment name that you provied in this step.
4 Managed Identities: <envName-AssumerIdentity> , <envName-DataAccessIdentity> , <envName-LoggerIdentity> , <envName-RangerIdentity>
---

**Azure RM templates does not support role assignments at a scope other than resource group. So the
following role assignments need to be performed via CLI or UI.**

Be ready with the values for below resources.

subscriptionId, rg-name, sa-name - All of these values you already noted down above.
Get objectID value for all managed identities created in #3. envName-AssumerIdentity , envName-DataAccessIdentity , envName-LoggerIdentity , envName-RangerIdentity
Note: envName is the value you used for Environment Name in #3. 
(Refer the screenshot below for fetching objectID for envName-AssumerIdentity. Similarly, you can get it for other identities)

![objectID](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/objectID.png?raw=true)

## Fine grained logger/dataAccess/ranger identity role assignment

- Download the script from ![script](https://raw.githubusercontent.com/odeshmane/cdp-azure-tools/master/azure_msi_role_assign.sh)

- Create a new file in Azure shell with the same name and copy the content of this script in there.

- Replace the values in the script.

- Run the script on Azure shell ***sh azure_msi_role_assign.sh***

![Role Assignment](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/role-assignment.png?raw=true)


---

# Changelog

1.1st cut instructions [04/14/2020]
