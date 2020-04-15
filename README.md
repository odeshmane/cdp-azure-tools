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


#### Step 3: Azure quickstart template

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

#### Step 4: Fine grained logger/dataAccess/ranger identity role assignment
**Azure RM templates does not support role assignments at a scope other than resource group. So the
following role assignments need to be performed via CLI or UI.**

Be ready with the values for below resources.

subscriptionId, rg-name, sa-name - All of these values you already noted down above.
Get objectID value for all managed identities created in #3. envName-AssumerIdentity , envName-DataAccessIdentity , envName-LoggerIdentity , envName-RangerIdentity
Note: envName is the value you used for Environment Name in #3. 
(Refer the screenshot below for fetching objectID for envName-AssumerIdentity. Similarly, you can get it for other identities)

![objectID](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/objectID.png?raw=true)

- Download the script from ![script](https://raw.githubusercontent.com/odeshmane/cdp-azure-tools/master/azure_msi_role_assign.sh)

- Create a new file in Azure shell with the same name and copy the content of this script in there.

- Replace the values in the script.

- Run the script on Azure shell ***sh azure_msi_role_assign.sh***

![Role Assignment](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/role-assignment.png?raw=true)

#### Step 5. Creating a CDP Credential

  - In the CDP Console, the first thing we're going to do is create our CDP Credential.  The CDP credential is the mechanism that allows CDP to create resources inside your Cloud Account.  
    1. From the CDP Home Screen, click the **Management Console** icon. 
    2. On the left side navigation plane, go to **Environments**
    3. From there, in the top left choose **Shared Resources**, then **Credentials**
    4. Click on the **Create Credential** button on the top right.

![CDP Credential Page](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/credential.png?raw=true)

- Provide the different values catured for subscriptionID, TenantID, AppID, Password in the steps above and click Create.

![CDP Credential Page](https://github.com/odeshmane/cdp-azure-tools/blob/master/screenshots/create-app1.png?raw=true)
---

#### Step 6. Registering CDP Environment.
- Head back to the CDP Management console for the final steps in creating the credntial. 
  1. Give your CDP Credentail a name and descriptino.  The name can be any valid name. 
  2. Paste the *role ARN* you copied from the AWS management console, and paste it into the **Cross-account Role ARN**

![Paste Role ARN](https://github.com/tonyHuinker/cdp-aws-quickstart/blob/master/screenshots/pasterolearn.png?raw=true)


#### Step 2. Creating a CDP Environment 

  - We'll want to create specific IAM roles and Policys for CDP to operate in a secure manner.  For background info, a description of what we're building and why can found [here](https://docs.cloudera.com/management-console/cloud/environments/topics/mc-idbroker-minimum-setup.html).  For this quickstart, we'll be using Cloudformation to set all of this up for you.
      - Download the provided Cloudformation template [here](https://raw.githubusercontent.com/tonyHuinker/cdp-aws-quickstart/master/cloudformation/setup.json) 



- In the *AWS Console*, we're now going to deploy our Cloudformation template.  
     1. In *AWS Services*, search for **Cloudformation**
     2. Click **Create Stack** in the top right
     3. Choose **template is ready**, and **upload a template file** ![Create Stack](https://github.com/tonyHuinker/cdp-aws-quickstart/blob/master/screenshots/createstack.png?raw=true). 

     4. Select the template file you just downloaded.
     5. Click **Next**
     6. Enter your stack name.  This can be any valid name.  Below you should change
        - S3BucketName - choose an unused bucket name, CDP will be creating the bucket for you
        - AWSAccount - your 12 digit AWS account ID (can be found [here](https://console.aws.amazon.com/billing/home?#/account). 
        - prefix - a short prefix of your choosing to add to the names of the IAM resources we'll be creating. 
         
        ![parsed](https://github.com/tonyHuinker/cdp-aws-quickstart/blob/master/screenshots/stackparsed.png?raw=true).  

	 7. Click **Next**. 
     8. At the *Configure Stack Options8 page, click **Next**
     9. At the bottom of *Review page*, under capabilities, we need to click the checkbox next to **I acknowledge that AWS Cloudformation might create IAM resources with custom names**, as that is exactly what we will be doing.
       ![Ackknowledge](https://github.com/tonyHuinker/cdp-aws-quickstart/blob/master/screenshots/ack.png?raw=true).  

     10. Click **Create stack**



- One last thing, in the *AWS Console*, we'll want to create an SSH Key in the region of your choice.  If there is already an SSH key in your perferred region you'd like to use, you can skip these steps.  
   1. In *AWS Services*, search for **EC2**
   2. Double check you are in your preferred region in the top right corner. 
   3. On the left hand navigation bar, choose **Key Pairs**
   4. On the top right, choose "Create Key Pair**
   5. Provide *Name* and choose **pem** format.  The name can be any valid name.

- Back in the *CDP Management Console*
    1. Navigate to **Environments**
    2. Click **Register Environment**
    3. Provide an environment name and description.  The name can be any valid name. 
    4. Choose *amazon* as the Cloud Provider
    5. Under *Amazon Web Services Credential*, chose the credential we created earlier. 
    6. Click **Next**
    7. Under *Data Lake Settings*, give your new Data Lake a name.  The name can be any valid name. Choose the latest Data Lake Version
    8. Choose *Light Duty* for Data Lake scale. 
    9. Click **Next**
    10. Choose your desired **region**, this should be the same region you created an SSH Key in above. 
    11. Under *select network* choose **Create New Network**
    12. Under *Security Access Settings* choose **Create New Security Groups**
        ![Region](https://github.com/tonyHuinker/cdp-aws-quickstart/blob/master/screenshots/regionnetwork.png?raw=true). 
        
    13. Under *SSH Settings*, choose the SSH key created earlier. 
    14. Under *Logs - Storage and Audit*, choose the Instance Profile we mentioned to save earlier, titled **prefix-log-access-instance-profile**, for logs location base choose **S3BucketName/logs**, and for *Ranger Audit Role* choose **prefix-ranger-audit-role**
        ![logs](https://github.com/tonyHuinker/cdp-aws-quickstart/blob/master/screenshots/logs.png?raw=true).
    15.  Under *Data Access*, choose the **prefix-data-access-instance-profile**, for *Storage Location Base* choose **S3Bucketname**. 
        ![data](https://github.com/tonyHuinker/cdp-aws-quickstart/blob/master/screenshots/data.png?raw=true).
    16. (optional) Provide any tags you'd like these resources to be tagged with. 
    17. Under *Enable S3 Guard*, enter **prefix-dynamodb-table**
       ![dynamo](https://github.com/tonyHuinker/cdp-aws-quickstart/blob/master/screenshots/dynamo.png?raw=true).
    18. Click **Register Environment**

# Changelog

1.1st cut instructions [04/14/2020]
