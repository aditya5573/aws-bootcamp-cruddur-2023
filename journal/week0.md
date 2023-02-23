# Week 0 — Billing and Architecture

## Team To Do Checklist:
   
| TASK | COMPLETED |
|  --- |    ---    |
| Watched Live - Streamed Video | :heavy_check_mark: |
| Watched Chirag's - Spend Considerations   | :heavy_check_mark: |
| Watched Ashish's - Security Considerations | :heavy_check_mark: |
| Recreate Conceptual Diagram in Lucid Charts or on a Napkin | :heavy_check_mark: |
| Recreate Logical Architectual Diagram in Lucid Charts | -- |
| Create an Admin User | :heavy_check_mark: |
| Use CloudShell | :heavy_check_mark: |
| Generate AWS Credentials | :heavy_check_mark: |
| Installed AWS CLI | :heavy_check_mark: |
| Create a Billing Alarm | :heavy_check_mark: |
| Create a Budget | :heavy_check_mark: |

## Getting the AWS CLI Working

##

### Install AWS CLI

- Install the AWS CLI when Gitpod enviroment lanuches.
- Set AWS CLI to use partial autoprompt mode to make it easier to debug CLI commands.
- The bash commands using is the same as the [AWS CLI Install Instructions]https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


Update our `.gitpod.yml` to include the following task.

```sh
tasks:
  - name: aws-cli
    env:
      AWS_CLI_AUTO_PROMPT: on-partial
    init: |
      cd /workspace
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      cd $THEIA_WORKSPACE_ROOT
```

Run these commands indivually to perform the install manually

### Create a new User and Generate AWS Credentials

- Go to (IAM Users Console](https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-1#/users) tripathiaditya create a new user
- `Enable console access` for the user
- Create a new `Admin` Group and apply `AdministratorAccess`
- Create the user and go find and click into the user
- Click on `Security Credentials` and `Create Access Key`
- Choose AWS CLI Access
- Download the CSV with the credentials

### Set Env Vars

We will set these credentials for the current bash terminal
```
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION=ca-canada-1
```

We'll tell Gitpod to remember these credentials if we relaunch our workspaces
```
gp env AWS_ACCESS_KEY_ID=""
gp env AWS_SECRET_ACCESS_KEY=""
gp env AWS_DEFAULT_REGION=ca-canada-1
```

### Check that the AWS CLI is working and you are the expected user

```sh
aws sts get-caller-identity
```

You should see something like this:
```json
{
    "UserId": "AIFBZRJIQN2ONP4ET4EK4",
    "Account": "655602346534",
    "Arn": "arn:aws:iam::655602346534:user/tripathiaditya"
}
```

## Enable Billing 

We need to turn on Billing Alerts to recieve alerts...


- In your Root Account go to the [Billing Page](https://console.aws.amazon.com/billing/)
- Under `Billing Preferences` Choose `Receive Billing Alerts`
- Save Preferences


## Creating a Billing Alarm

### Create SNS Topic

- We need an SNS topic before we create an alarm.
- The SNS topic is what will delivery us an alert when we get overbilled
- [aws sns create-topic](https://docs.aws.amazon.com/cli/latest/reference/sns/create-topic.html)

We'll create a SNS Topic
```sh
aws sns create-topic --name billing-alarm
```
which will return a TopicARN

We'll create a subscription supply the TopicARN and our Email
```sh
aws sns subscribe \
    --topic-arn TopicARN \
    --protocol email \
    --notification-endpoint your@email.com
```

Check your email and confirm the subscription

#### Create Alarm

- [aws cloudwatch put-metric-alarm](https://docs.aws.amazon.com/cli/latest/reference/cloudwatch/put-metric-alarm.html)
- [Create an Alarm via AWS CLI](https://aws.amazon.com/premiumsupport/knowledge-center/cloudwatch-estimatedcharges-alarm/)
- We need to update the configuration json script with the TopicARN we generated earlier
- We are just a json file because --metrics is is required for expressions and so its easier to us a JSON file.

```sh
aws cloudwatch put-metric-alarm --cli-input-json file://aws/json/alarm_config.json
```

Result:
![Screenshot (501)](https://user-images.githubusercontent.com/81632787/220967108-2a0feed2-6f27-4bf6-9352-a21972f03efd.png)

## Create an AWS Budget



Get your AWS Account ID
```sh
aws sts get-caller-identity --query Account --output text
```

- Supply your AWS Account ID
- Update the json files
- This is another case with AWS CLI its just much easier to json files due to lots of nested json

```sh
aws budgets create-budget \
    --account-id AccountID \
    --budget file://aws/json/budget.json \
    --notifications-with-subscribers file://aws/json/budget-notifications-with-subscribers.json
```

![Screenshot (502)](https://user-images.githubusercontent.com/81632787/220976945-2e22ff8c-16c6-4155-9943-4bbd5736cac0.png)

[aws budgets create-budget](https://docs.aws.amazon.com/cli/latest/reference/budgets/create-budget.html)

    ```
     {
        "Budget": {
            "BudgetName": "Example Tag Budget",
            "BudgetLimit": {
                "Amount": "1.0",
                "Unit": "USD"
            },
            "CostFilters": {},
            "CostTypes": {
                "IncludeTax": true,
                "IncludeSubscription": true,
                "UseBlended": false,
                "IncludeRefund": false,
                "IncludeCredit": false,
                "IncludeUpfront": true,
                "IncludeRecurring": true,
                "IncludeOtherSubscription": true,
                "IncludeSupport": true,
                "IncludeDiscount": true,
                "UseAmortized": false
            },
            "TimeUnit": "MONTHLY",
            "TimePeriod": {
                "Start": "2023-02-01T01:00:00+01:00",
                "End": "2087-06-15T02:00:00+02:00"
            },
            "CalculatedSpend": {
                "ActualSpend": {
                    "Amount": "0.0",
                    "Unit": "USD"
                }
            },
            "BudgetType": "COST",
            "LastUpdatedTime": "2023-02-12T11:16:49.153000+01:00"
        }
    }
    ```

    ```
    {
        "Budget": {
            "BudgetName": "My AWS Bootcamp Budget",
            "BudgetLimit": {
                "Amount": "1.0",
                "Unit": "USD"
            },
            "CostFilters": {},
            "CostTypes": {
                "IncludeTax": true,
                "IncludeSubscription": true,
                "UseBlended": false,
                "IncludeRefund": false,
                "IncludeCredit": false,
                "IncludeUpfront": true,
                "IncludeRecurring": true,
                "IncludeOtherSubscription": true,
                "IncludeSupport": true,
                "IncludeDiscount": true,
                "UseAmortized": false
            },
            "TimeUnit": "MONTHLY",
            "TimePeriod": {
                "Start": "2023-02-01T01:00:00+01:00",
                "End": "2087-06-15T02:00:00+02:00"
            },
            "CalculatedSpend": {
                "ActualSpend": {
                    "Amount": "0.0",
                    "Unit": "USD"
                }
            },
            "BudgetType": "COST",
            "LastUpdatedTime": "2023-02-12T11:17:45.444000+01:00"
        }
    }    
    ```

## Generating AWS Credentials

![Screenshot (503)](https://user-images.githubusercontent.com/81632787/220972493-4840e2d0-68a5-4757-ae18-2aa3842ef364.png)


## Using CloudShell

![Screenshot (504)](https://user-images.githubusercontent.com/81632787/220973936-9f954af3-e24c-463e-8837-e674db52b3f5.png)

 To add configuration to the [gitpod environments](https://www.gitpod.io/docs/configure/projects/environment-variables) (persistent throught sessions):

    ```
    # setting the persistent gitpod environment values
    gp env AWS_ACCESS_KEY_ID="key_id"
    gp env AWS_SECRET_ACCESS_KEY="secret_access_key"
    gp env AWS_DEFAULT_REGION="eu-central-1"
    # importing them to the local session 
    eval $(gp env -e)
    # listing current bash env
    env | grep AWS
    aws sts get-caller-identity
    ```

 This is a one time action. 

 **NOTE:** This might impose security risk, as the CLI keys are not expirable by default. Needs further investigation on best practice for expiration.
 
 ## Conceptual Diagram
 
 (https://lucid.app/lucidchart/9d284976-7a3a-4102-837b-de77afe261f9/edit?viewport_loc=-3%2C33%2C1807%2C793%2C0_0&invitationId=inv_6c376e7d-8bc5-4818-98dc-1be56dd3eb1c)
 ![Napkin Design](https://user-images.githubusercontent.com/81632787/220995692-881360b0-d13b-426a-bbb7-f436c6a0fcc9.png)

## Logical Diagram

https://lucid.app/lucidchart/23a6652c-ab54-4c2d-8b0d-f2ad73c1535b/edit?viewport_loc=-4507%2C-1171%2C2724%2C1195%2C0_0&invitationId=inv_fb010971-da9e-45df-bf27-87c5197adf44
![Architectural Design](https://user-images.githubusercontent.com/81632787/220995935-8f965dc8-61d5-4462-8454-e64cdf61866b.png)
