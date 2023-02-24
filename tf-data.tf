data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "cloudinit_config" "jenkins" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "jenkins"
    content = templatefile("scripts/jenkins-install.sh",

      {
        JENKINS_URL           = var.JENKINS_URL
        DEVICE                = var.INSTANCE_DEVICE_NAME
        JENKINS_PORT          = var.JENKINS_PORT
        AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
        AWS_REGION            = var.AWS_REGION
    })
  }
}