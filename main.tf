#Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = var.vpc_tags
}

# Create a public subnet
resource "aws_subnet" "public" {
  count = 1
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_public_subnets_cidr[0]  # Use the first (and only) CIDR block in the list
  availability_zone       = var.vpc_public_subnets_az   # Use the first availability zone in the list
  map_public_ip_on_launch =  var.pub_map_public_ip_on_launch # Enable public IPs for instances in this subnet
  tags = var.pub_sub_tag
}

# Create private subnet1
resource "aws_subnet" "private1" {
  count             = 1
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_private_subnet1_cidr
  availability_zone = var.vpc_private_subnets_az
  map_public_ip_on_launch = var.pri_map_public_ip_on_launch
  tags = var.pri_sub_tag
}

# Create private subnet2
resource "aws_subnet" "private2" {
  count             = 1
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_private_subnet2_cidr
  availability_zone = var.vpc_private_subnets_az
  map_public_ip_on_launch = var.pri_map_public_ip_on_launch
  tags = var.pri_sub_tag
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = var.igw_description
}

# Create a NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = var.nat_description
}

# Create an Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags     = var.eip_description
}


# Create a route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.pub_route_table_cidr
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = var.pub_route-tags
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public.id
}

# Create a route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = var.pri_route-tags
}

# Create a route in each private route table pointing to the NAT Gateway
resource "aws_route" "private" {
  route_table_id       = aws_route_table.private.id
  destination_cidr_block = var.destination_cidr_block
  nat_gateway_id       = aws_nat_gateway.nat.id
}

#Associate private subnets with their respective private route tables
resource "aws_route_table_association" "private" {
  count        = 2
  subnet_id    = aws_subnet.private1[0].id
  route_table_id = aws_route_table.private.id

}
resource "aws_route_table_association" "private2" {
  subnet_id    = aws_subnet.private2[0].id
  route_table_id = aws_route_table.private.id
}

# Create a security group for React-django app
resource "aws_security_group" "react_django" {
  name_prefix = var.aws_sg_name
  description = var.aws_sg_description
  vpc_id      = aws_vpc.main.id

dynamic "ingress" {
    for_each = var.sg_ports
    iterator = port
    content {
      description = var.sg_ingress_description
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create a private key and key pair for EC2 instances
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh
  #Store the private key in a local file
  provisioner "local-exec" {
  command = "echo '${tls_private_key.private_key.private_key_pem}' > demo.pem && chmod 400 demo.pem"
  }
  provisioner "local-exec" {
  when = destroy
    command = "rm -f demo.pem"
  }
}

# Create an EC2 instance in the public subnet
resource "aws_instance" "public_instance" {
  ami                    = var.image_id # Replace with your desired AMI ID for the public instance
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  associate_public_ip_address = true # Enable a public IP for this instance
  key_name               = aws_key_pair.generated_key.key_name # Associate with the key pair
  vpc_security_group_ids = [aws_security_group.react_django.id] # Attach the security group
  user_data              = file("react.sh")

  provisioner "remote-exec" {
    inline = [
      # "ls -l /home/ubuntu/my-git-repo/reactfrontend/src/",  # Debugging command
      # Wait for the completion of the git clone command (adjust the path as needed)
      "until [ -f /home/ubuntu/my-git-repo/reactfrontend/src/App.js ]; do sleep 5; done",
      # Use the file provisioner to copy the app.js file to a temporary directory
      "sudo cp /home/ubuntu/my-git-repo/reactfrontend/src/App.js /tmp/App.js",
      # Replace the old IP address in the file with the private IP address
      "sudo sed -i 's/43.205.39.113/${aws_instance.private_instance1[0].private_ip}/g' /tmp/App.js",
      # Move the modified file back to its original location
      "sudo mv /tmp/App.js /home/ubuntu/my-git-repo/reactfrontend/src/App.js",
      # Store the public ip in the file named public_ip
      "echo '${aws_instance.public_instance.public_ip}' > /tmp/public_ip",
      # Create a fike demo.pem
      "touch /home/ubuntu/demo.pem",
      # Now copy the private key into that file
      "echo '${tls_private_key.private_key.private_key_pem}' > /home/ubuntu/demo.pem",
      # Change permission
      "chmod 644 /home/ubuntu/demo.pem",
      # We need to use scp to transfer public_ip file for that we need this cmd
      "sudo scp -o StrictHostKeyChecking=no -i /home/ubuntu/demo.pem /tmp/public_ip ubuntu@${aws_instance.private_instance1[0].private_ip}:/tmp/public_ip",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" # Update with your instance's SSH user
      private_key = tls_private_key.private_key.private_key_pem
      host        = self.public_ip
    }
  }
tags = {
    Name = "bastion host"
  }
}

# Create two EC2 instances in the private subnets
resource "aws_instance" "private_instance1" {
  count         = 1
  ami           = var.image_id # Replace with your desired AMI ID for the private instances
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private1[count.index].id
  key_name      = aws_key_pair.generated_key.key_name # Associate with the key pair
  vpc_security_group_ids = [aws_security_group.react_django.id] # Attach the security group
  
  user_data = count.index == 0 ? file("django.sh") : null

  tags = {
    Name = "backend"
  }
}
  

# # Add another provisioner to configure the private instance
# resource "null_resource" "configure_private_instance" {
#   triggers = {
#     public_instance_ip = aws_instance.public_instance.public_ip
#   }


  # provisioner "remote-exec" {
  #   inline = [
  #     # "ls -l /home/ubuntu/my-git-repo/reactfrontend/src/",  # Debugging command
  #     # Wait for the completion of the git clone command (adjust the path as needed)
  #     "until [ -f /home/ubuntu/my-git-repo/djangobackend/djangobackend/settings.py ]; do sleep 5; done",
  #     # Use the file provisioner to copy the app.js file to a temporary directory
  #     "sudo cp /home/ubuntu/my-git-repo/djangobackend/djangobackend/settings.py /tmp/settings.py",
  #     # Replace the old IP address in the file with the private IP address
  #     "sudo sed -i 's/43.205.39.113/${aws_instance.public_instance.private_ip}/g' /tmp/settings.py",
  #     # Replace the old IP address in your CORS_ALLOWED_ORIGINS line
  #     "sed -i 's|http://43.205.39.113:3000|${aws_instance.public_instance.public_ip}:3000|' /tmp/settings.py",
  #     # Move the modified file back to its original location
  #     "sudo mv /tmp/App.js /home/ubuntu/my-git-repo/djangobackend/djangobackend/settings.py",
  #   ]

  # provisioner "remote-exec" {
  #   inline = [
  #     # Wait for the completion of the public IP address file creation (adjust the path as needed)
  #     "until [ -f /tmp/public_ip.txt ]; do sleep 5; done",
  #     # Retrieve the public IP address from the file
  #     "public_ip=$(cat /tmp/public_ip.txt)",
  #     # Use the public IP address as needed in your application
  #     "echo 'Public IP address of the public instance: $public_ip'",
  #     # Replace the old IP address in your application configuration file
  #     "sed -i 's/43.205.39.113/${aws_instance.public_instance.public_ip}/g' /djangobackend/djangobackend/settings.py",
  #     # Replace the old IP address in your CORS_ALLOWED_ORIGINS line
  #     "sed -i 's|http://43.205.39.113:3000|${aws_instance.public_instance.public_ip}:3000|' /djangobackend/djangobackend/settings.py",
  #     # ... other commands to configure your private instance ...
  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"  # Update with your instance's SSH user
  #     private_key = tls_private_key.private_key.private_key_pem
  #     host        = aws_instance.private_instance1[0].private_ip # Use the private IP address of the private instance
  #   }
  # }
# }

# resource "aws_instance" "private_instance2" {
#   count         = 1
#   ami           = var.image_id # Replace with your desired AMI ID for the private instances
#   instance_type = var.instance_type
#   subnet_id     = aws_subnet.private2[count.index].id
#   key_name      = aws_key_pair.generated_key.key_name # Associate with the key pair
#   vpc_security_group_ids = [aws_security_group.react_django.id] # Attach the security group
# }
