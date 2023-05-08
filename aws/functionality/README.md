# AWS Functionality

## Contents
- [AWS Functionality](#aws-functionality)
  - [Contents](#contents)
  - [What do I get?](#what-do-i-get)
  - [How do I run it?](#how-do-i-run-it)
    - [Prerequisistes](#prerequisistes)
    - [Authentication](#authentication)
    - [RunMe](#runme)
    - [CleanMeUp](#cleanmeup)
  - [How do I access my instances once they've been deployed?](#how-do-i-access-my-instances-once-theyve-been-deployed)
  - [What can I do?](#what-can-i-do)
  - [I'm having issues, what do I do?](#im-having-issues-what-do-i-do)


## What do I get?
This code will deploy the following in us-east1 (N.Virginia):
- S3 bucket (for configuration)
- SSH keypair (for access without SSM)
- Lightbits cluster:
  - Instances: i3en.6xlarge
  - Count: 3
- Client VM:
  - Instance: m5.xlarge
  - Count: 1
- Internet Gateway for external internet access
- Security Group for the client
- IAM Instance Profile for the client to use SSM and access the config s3 bucket
- A bunch of FIO scripts on the client

## How do I run it?

### Prerequisistes
Follow the [instructions](../../README.md) to install git & terraform, then clone this repo.

### Authentication
We will authentication with AWS, so you'll need credentials! Since I don't want to give any away, the credentials file you'll need isn't in this repo!
- Create a credentials file under:
    pov_templates -> aws -> credentials
- Log into the AWS console and choose your account
- Choose the user that you want to impersonate (ps-soe sounds good), then click on "Command line or programmatic access"
- Scroll down to "Option 2: Manually add a profile to your AWS credentials file (Short-term credentials)" and copy the whole contents into the credentials file you just created
- It should look something like:
```
[ACCOUNTNUMBER_ps-soe]
aws_access_key_id=TESTKEYETC
aws_secret_access_key=somerandomstring9087321nklnsad
aws_session_token=someRandomTokenExamplekandolandew908ue32jiolkwoadhs89aydsaiokdnxmknc?sadmsadlsadmxnjkhe98h
```
- If you're not using the same credentials/account I did: `XXXXXXXXX_ps-soe`, then you'll need to change the file at `pov_templates -> aws -> functionality -> provider` to reflect the new info. If should look something like this:
```
provider "aws" {
    region = var.region[0]
    shared_credentials_files = ["${path.module}/../credentials"]
    profile = "ACCOUNTNUMBER_ps-soe"
}
```

> **_NOTE:_**  These credentials will only last for a few hours, so if you get an error from terraform complaining that your credentials have timed out, just repeat the above process

### RunMe
Running this deployment is ezpz:
- Change directory to pov_templates -> aws -> functionality
- Run: `terraform init`
- Run: `terraform apply`
- Type: `yes`
- Watch all your resources deploy and track it inside the AWS console
  
> **_NOTE:_** This will take about 45 mins, so grab a coffee or tea! If it fails, check out the error message and try to run `terraform apply` again. Sometimes it works the second or third time.

### CleanMeUp
When you're done, follow the below steps to delete all your resources:
- Change directory to pov_templates -> aws -> functionality
- Run: `terraform destroy`
- Type: `yes`
- Watch all your hard work get deleted

## How do I access my instances once they've been deployed?
To access your instances, use AWS SSM -> it's already set up. If you really want to, you can SSH into the boxes - there's a private key in the tfstate file, but that's advanced. I'd recommend SSM.

## What can I do?
The client comes preconfigured with all the tools you'll need to demo functionality including being connected to the Lighbits cluster and having a small volume to run FIO against.

There is a directory on the client here: `/home/ubuntu/fio_scripts` which contains a bunch of FIO scripts that you can play with.

> **_NOTE:_**  If you're using SSM, you'll have to be true root to access that directory. Run: `sudo su` to navigate to and use those scripts.

## I'm having issues, what do I do?
Contact me: felix@lightbitslabs.com for help