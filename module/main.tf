terraform {
  required_version = "1.1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
  }
}


data "aws_region" "this" {}

data "aws_ami" "this" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_iam_policy_document" "terminate_self" {
  statement {
    actions   = ["ec2:TerminateInstances"]
    resources = ["*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
  }
}


locals {
  userdata_script = base64encode(templatefile("./userdata.tmpl",
    {
      connections = var.connections
      timeout     = var.timeout
      method      = var.method
      duration    = var.duration
      website     = var.website
      region      = data.aws_region.this.name
    }

  ))
}


resource "aws_launch_template" "this" {
  update_default_version = true
  credit_specification {
    cpu_credits = "standard"
  }
  image_id = data.aws_ami.this.image_id
  instance_market_options {
    market_type = "spot"
  }
  instance_type = var.instance_type
  user_data     = local.userdata_script

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  network_interfaces {
    associate_public_ip_address = true
  }
}

resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_role_policy" "terminate_self" {
  policy = data.aws_iam_policy_document.terminate_self.json
  role   = aws_iam_role.this.id
}

# uncomment for debugging purposes to access the instance using Instance Connect
#resource "aws_iam_role_policy_attachment" "ssm" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#  role       = aws_iam_role.this.name
#}

resource "aws_instance" "this" {
  count = var.in_count
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  iam_instance_profile = aws_iam_instance_profile.this.name
}
