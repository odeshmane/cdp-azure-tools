# cdp-azure-quickstart

![CDP Landing Page](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/screenshot6.png?raw=true)

If you've reached the above landing page for the first time, you've come to the right place! In this quickstart, we're going to walkthrough step by step how to connect CDP to your Azure subscription so that you can begin to provision clusters and workloads. 

In order to complete this quickstart, you'll need access to two things.  

  1. The CDP console (if you've reached the above screen, you're good to go there)
  2. The Azure console
  3. Azure Cloud shell

#### Step 1. Creating a CDP Credential

  - In the CDP Console, the first thing we're going to do is create our CDP Credential.  The CDP credential is the mechanism that allows CDP to create resources inside your Cloud Account.  
    1. From the CDP Home Screen, click the **Management Console** icon. 
    2. On the left side navigation plane, go to **Environments**
    3. From there, in the top left choose **Shared Resources**, then **Credentials**
    4. Click on the **Create Credential** button on the top right.

![CDP Credential Page](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/crednetial.png?raw=true)

## Azure AD App create

Login to Azure portal and open "cloud shell" 

![Azure Cloud shell](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/screenshot1.png?raw=true)

Get subscription ID and Tenant ID by running the command below.

#1
```az account list|jq '.[]|{"name": .name, "subscriptionId": .id, "tenantId": .tenantId, "state": .state}'```

The output of this command is as below:

![SubscriptionID and TenantID](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/screenshot2.png?raw=true)

Create an app in Azure AD and assign 'Contributor' role at subscription level

#2
```az ad sp create-for-rbac --name http://cloudbreak-app --role Contributor --scopes /subscriptions/{subscriptionId}```
Note: Replace subscriptionId with the subscriptionId from #1

The output of this command is as below:
![Output after app create](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/screenshot3.png?raw=true)

## Azure quickstart template

ARM template that deploys essential Azure resources for Cloudera CDP environment.

Click ' Deploy to Azure' (#3) and login to your subscription to create essential resources for CDP deployment in your subscription. These resources include VNet, ADLS Gen2, 4 User Managed Identities. Provide envName on the screen. (refer the screenshot below).

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcegganesh84%2Fcdp-azure-tools%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fcegganesh84%2Fcdp-azure-tools%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

![Deploy To Azure](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/screenshot4.png?raw=true)
---

**Azure RM templates does not support role assignments at a scope other than resource group. So the
following role assignments need to be performed via CLI or UI.**

Have below details ready before running the commands below and replace them as appropriate.

subscriptionId - generated from #1
objectID - For all managed identities created in #3. envName-Assumer-objectID, envName-DataAccess-objectID, envName-Logger-objectID, envName-RangerAudit-objectID
Note: envName is the value you used for Environment Name in #3. 
(Refer the screenshot below for sample envName-Assumer-objectID)

![objectID](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/screenshot5.png?raw=true)


## Assumer identity role assignment

```bash
# Assign Managed Identity Operator role to the assumerIdentity principal at subscription scope
az role assignment create --assignee <envName-Assumer-objectID> --role 'f1a07417-d97a-45cb-824c-7a7467783830' --scope '/subscriptions/<subscriptionId>'
# Assign Virtual Machine Contributor role to the assumerIdentity principal at subscription scope
az role assignment create --assignee <envName-Assumer-objectID> --role '9980e02c-c2be-4d73-94e8-173b1dc7cf3c' --scope '/subscriptions/<subscriptionId>'
```

## Fine grained logger/dataAccess/ranger identity role assignment

```bash
# Assign Storage Blob Data Contributor role to the loggerIdentity principal at logs filesystem scope
az role assignment create --assignee <envName-Logger-objectID> --role 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' --scope "/subscriptions/<subscriptionId>/resourceGroups/<rg-name>/providers/Microsoft.Storage/storageAccounts/<sa-name>/blobServices/default/containers/logs"
```

```bash
# Assign Storage Blob Data Owner role to the dataAccessIdentity principal at logs/data filesystem scope
az role assignment create --assignee <envName-DataAccess-objectID> --role 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' --scope "/subscriptions/<subscriptionId>/resourceGroups/<rg-name>/providers/Microsoft.Storage/storageAccounts/<sa-name>/blobServices/default/containers/data"
az role assignment create --assignee <envName-DataAccess-objectID> --role 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' --scope "/subscriptions/<subscriptionId>/resourceGroups/<rg-name>/providers/Microsoft.Storage/storageAccounts/<sa-name>/blobServices/default/containers/logs"
```

```bash
# Assign Storage Blob Data Contributor role to the rangerIdentity principal at data filesystem scope
az role assignment create --assignee <envName-RangerAudit-objectID> --role 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' --scope "/subscriptions/<subscriptionId>/resourceGroups/<rg-name>/providers/Microsoft.Storage/storageAccounts/<sa-name>/blobServices/default/containers/data"
```

---

# Changelog

1.1st cut instructions [04/14/2020]
