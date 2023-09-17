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
resource "aws_instance" "sandpit_instance" {
  ami           = "ami-04cb4ca688797756f"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sandpit_subnet.id
  vpc_security_group_ids = [aws_security_group.sandpit_security_group.id]
  iam_instance_profile = aws_iam_role.sandpit_role.name
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

resource "aws_iam_role" "sandpit_role" {
  name = "sandpit-role"
  # Add any other desired parameters
}
