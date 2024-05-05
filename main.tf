# remote privions
###################
provider "aws" {
  region = "your-region"
}

variable "instance_id" {
  description = "EC2 instance ID where scripts will be executed"
}

resource "aws_ssm_association" "run_commands" {
  name                   = "execute-commands"
  targets {
    key    = "InstanceIds"
    values = [var.instance_id]
  }

  parameters = {
    commands = [
      "echo 'Running script on the existing EC2 instance'",
      // Add your script commands here
    ]
  }

  // Specify the instance ID as a dependency
  depends_on = [aws_instance.ec2_instance]
}

###############################

provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "aws_vpc" "sandpit" {
  cidr_block = "10.0.0.0/16"
  # Add any other desired parameters
}

resource "aws_subnet" "sandpit_subnet" {
  vpc_id     = aws_vpc.sandpit.id
  cidr_block = "10.0.0.0/24"
  # Add any other desired parameters
}

resource "aws_security_group" "sandpit_security_group" {
  vpc_id = aws_vpc.sandpit.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add any other desired inbound or outbound rules
}

resource "aws_iam_role" "sandpit_role" {
  name = "sandpit-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
  # Add any other desired parameters
}

resource "aws_instance" "sandpit_instance" {
  ami           = "ami-04cb4ca688797756f"  # Replace with your desired AMI ID in us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sandpit_subnet.id
  vpc_security_group_ids = [aws_security_group.sandpit_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.sandpit_instance_profile.name
  # Add any other desired parameters
}

resource "aws_iam_instance_profile" "sandpit_instance_profile" {
  name = "sandpit-instance-profile"
  role = aws_iam_role.sandpit_role.name
}

resource "aws_iam_role_policy_attachment" "sandpit_attachment" {
  role       = aws_iam_role.sandpit_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"  # Replace with your desired policy ARN
}
