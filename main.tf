provider "aws" {
region     = "us-east-1"
access_key = "enter-access-key-here"
secret_key = "enter-your-secret-key-here"         # this user should have permission to create resources
}

resource "aws_instance" "web-server-dev" {
  ami           = "ami-0230bd60aa48260c6"         #copied from console
  instance_type = "t2.large"
  count         = var.test-dev-prod == "dev" ? 2 : 0          #if dev has been enter, create 2 resources else 0
  key_name      = "aws-key-pair"
  security_groups = [aws_security_group.public_http_sg.name]
  tags = {
    Name = "webserver-dev"
  }
}

resource "aws_instance" "web-server-prod" {
  ami           = "ami-0230bd60aa48260c6"  #copied from console
  instance_type = "t2.large"
  count         = var.test-dev-prod == "prod" ? 4 : 0          #if dev has been enter, create 4 resources else 0
  key_name      = "aws-key-pair"
  security_groups = [aws_security_group.public_http_sg.name]
  tags = {
    Name = "webserver-prod"
  }
}

resource "aws_instance" "web-server-test" {
  ami           = "ami-0230bd60aa48260d7"  #copied from console
  instance_type = "t2.micro"
  count         = var.test-dev-prod == "test"  ? 1 : 0          #if dev has been enter, create 1 resources else 0
  key_name      = "aws-key-pair"
  security_groups = [aws_security_group.public_http_sg.name]
  tags = {
    Name = "webserver-test"
  }
}

#creating S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "terra-created-bucket-india"
}

#defining access control list for s3 bucket
resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.bucket
  acl = "public-read"
}

resource "aws_security_group" "public_http_sg" {
  name        = "PublicHTTPSecurityGroup"
  description = "Open to Public for HTTP traffic"

  ingress {                               #incoming traffic rules
    from_port   = 80                      #only http port is allowed
    to_port     = 80                      #only http port is allowed
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {                               #outgoing traffic rules
    from_port   = 0                      #all ports are allowed
    to_port     = 0                      #all ports are allowed
    protocol    = "-1"                   #any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "test-dev-prod"{
   type = string
}

resource "aws_key_pair" "key" {
  key_name   = "aws-key-pair"
  public_key = "paste your key here"               # add public key here using command "ssh keygen"
