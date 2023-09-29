Aws_profile = "terraform-user"
Aws_region = "ap-south-1"
vpc_cidr_block = "10.0.0.0/16"
  vpc_tags = {
  Name = "MainVPC"
}
vpc_public_subnets_cidr  = ["10.0.1.0/24"]
vpc_public_subnets_az    = "ap-south-1a"
vpc_private_subnet1_cidr = "10.0.2.0/24"
vpc_private_subnet2_cidr = "10.0.3.0/24"
vpc_private_subnets_az   = "ap-south-1b"
pub_sub_tag = {
  Name = "publicsubnet"
}
pri_sub_tag = {
  Name = "PrivateSubnet"
}
pub_map_public_ip_on_launch = true
pri_map_public_ip_on_launch = false
igw_description = {
  Name = "MainIGW"
}
eip_description = {
  Name = "EIP"
}
nat_description = {
  Name = "NATGateway"
}
pub_route_table_cidr = "0.0.0.0/0"
destination_cidr_block = "0.0.0.0/0"

pub_route-tags = {
    Name = "PublicRouteTable"
  }
  
pri_route-tags = {
    Name = "PrivateRouteTable"
  }

#SECURITY GROUP TFVARS
aws_sg_name            = "React-django"
aws_sg_description     = "dev sg"
sg_ports               = [22, 80, 443, 8000, 3000]
sg_ingress_description = "SSH from VPC"
#Instance
key_name   = "my-key-pair"
instance_type = "t2.micro"
image_id = "ami-0f5ee92e2d63afc18"