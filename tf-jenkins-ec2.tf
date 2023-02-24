resource "aws_instance" "jenkins-instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins-securitygroup.id]
  key_name               = aws_key_pair.mykeypair.key_name
  user_data              = data.cloudinit_config.jenkins.rendered
  iam_instance_profile   = aws_iam_instance_profile.jenkins-role.name

  depends_on = [
    aws_ebs_volume.jenkins-data
  ]
}

resource "aws_ebs_volume" "jenkins-data" {
  availability_zone = "us-east-1a"
  size              = 20
  type              = "gp2"
  tags = {
    Name = "jenkins-data"
  }
}

resource "aws_volume_attachment" "jenkins-data-attachment" {
  device_name  = var.INSTANCE_DEVICE_NAME
  volume_id    = aws_ebs_volume.jenkins-data.id
  instance_id  = aws_instance.jenkins-instance.id
  skip_destroy = true
}

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCt7c2fGpN2f3/SYhB8inEt9c4XQUrAUBAuwg1nF5XhqxMZo59WrEfnSfe6bQOQrU/axQp1+BMKBiMm73Iy2WdgGditZ7IZscvTn43dKRjEBxv7lNMs7Zz5rORM3/E8s7SU2SS1ehbG2NpXaNmBXBPcehraky08dkhll3gShnZ2WlGzt0DgIfMr6smCVXWuWtizhNDktJ4zjHdwbNqA96Q65L0FdapHh474Rckk1TKSl1qQ0LkhAOsZB+nDlMNbpQrcFnLkk5aX1jMsfEY3FunsrcX4aMJFStcK/8DaSrozrgFVHGdYCwLzKFqx2sQhi4kgIXlZKz6fs6oPAGfhAPNkx13WS4JukRHx3wuD4TLYAHRjwcWdawgrZ2ZlcPcCblU52Csff+pQ+Vo5/MJoLcsgA1Zri1e76uqgUU4yPRyCgEUnT3/QzaE1wQX56wZYjfPNzGhvCaoUbLt9/Ke69pxeJvMbd8pdJCgvPQcnWi6hccNI3S9vRxkgTuFae1ElLwk= lbena@LAPTOP-QB0DU4OG"
  lifecycle {
    ignore_changes = [public_key]
  }
}