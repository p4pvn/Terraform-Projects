provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.${count.index * 4}.0/24"
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
}

resource "aws_security_group" "public_http_sg" {
  name        = "PublicHTTPSecurityGroup"
  description = "Open to Public for HTTP traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2instance1" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet[0].id
  key_name      = "key-pair-name"
  security_groups = [aws_security_group.public_http_sg.name]

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = 10
    delete_on_termination = true
  }
}

resource "aws_s3_bucket" "bucket1" {
  bucket = "example-bucket1"
  acl    = "private"
}

resource "aws_iam_user" "iamuser1" {
  name = "example-user1"
}

resource "aws_iam_group" "iamgroup1" {
  name = "example-group1"
}

resource "aws_iam_policy" "iampolicy1" {
  name        = "example-policy1"
  description = "Policy to list S3 buckets"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:ListBucket",
        Effect   = "Allow",
        Resource = aws_s3_bucket.bucket1.arn,
      },
    ],
  })
}

resource "aws_iam_user_group_membership" "iamusertogroup1" {
  user  = aws_iam_user.iamuser1.name
  groups = [aws_iam_group.iamgroup1.name]
}

resource "aws_iam_user_policy_attachment" "iamusertopolicy1" {
  policy_arn = aws_iam_policy.iampolicy1.arn
  user       = aws_iam_user.iamuser1.name
}
