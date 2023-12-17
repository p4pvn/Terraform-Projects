variable "instance"{
     type = string
     default = "t2.micro"
     sensitive = true
}

# Default type is string
variable "ami"{
     default = "ami-0230bd60aa48260c6"
}

# Declaring list for multiple values
variable "instancetype"{
    type = list
    default = ["t2.micro","t2.large"]
}
