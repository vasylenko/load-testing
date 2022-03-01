# Load testing environment

This Terraform project allows you to bootstrap a fleet of AWS EC2 Spot instances to test your readiness to the High Load.

## How it works

Instances are bootstrapped with user-data that runs bombardier container with provided parameters. 

Once test is finished, the instance is destroying itself so not to waste your money.

You can specify either a single website or a list of websites in a format `'["website","another-website"]'`

Required bombardier parameters (the website and others) are passed through TF vars as CLI arguments. See example below.

## Prerequisites

You must have `awscli` installed and have a configured named profile to use it for the project.

## Example Usage

Assuming that you have local awscli profile named `testing`

Single website, e.g., you need to test your QA environment `qa.web.site`

```shell
terraform apply -var aws_profile_name=testing -var aws_account_id=YOUR_AWS_ACCOUNT_ID -var list='["qa.web.site"]' 
```

Multiple websites, e.g., you need to test several deployment tiers `foo.website and bar.website`.
```shell
terraform apply -var aws_profile_name=testing -var aws_account_id=YOUR_AWS_ACCOUNT_ID -var list='["foo.website","bar.website"]' 
```


#### Possible Improvements
- use `aws_spot_fleet_request` https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_fleet_request
