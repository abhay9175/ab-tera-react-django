# Outputs for convenience
output "vpc_id" {
    value = aws_vpc.main.id
}
output "internet_gateway_id" {
    value = aws_internet_gateway.gw.id
}

output "nat_gateway_id" {
    value = aws_nat_gateway.nat.id
}

output "elastic_ip" {
    value = aws_eip.nat.public_ip
}

output "public_route_table_id" {
    value = aws_route_table.public.id
}

output "public_instance_id" {
    value = aws_instance.public_instance.id
}

output "private_instance1_id" {
    value = aws_instance.private_instance1[0].id
}

# output "private_instance2_id" {
#     value = aws_instance.private_instance2[0].id
# }

output "react_django_security_group_id" {
    value = aws_security_group.react_django.id
}

output "public_subnet_id" {
    value = aws_subnet.public[0].id
}

output "private_subnet_ids" {
    value = concat(
    aws_subnet.private1[*].id,
    aws_subnet.private2[*].id
    )
}

output "public_ip" {
    value = aws_instance.public_instance.public_ip
}

output "private_ips" {
    value = concat(
    aws_instance.private_instance1[*].private_ip,
    # aws_instance.private_instance2[*].private_ip
    )
}

# Output the open ports for the security group
output "open_ports" {
    value = aws_security_group.react_django.ingress[*].from_port
}

# Output the availability zones of the public and private instances
output "public_instance_az" {
    value = aws_instance.public_instance.availability_zone
}

output "private_instance1_az" {
    value = aws_instance.private_instance1[0].availability_zone
}

# output "private_instance2_az" {
#     value = aws_instance.private_instance2[0].availability_zone
# }

# Output the route table ID for the public route table


# Output the public key used for the instances
output "public_key" {
    value = tls_private_key.private_key.public_key_openssh
}

# Output the private key used for the instances
output "private_key" {
    value = tls_private_key.private_key.private_key_pem
    sensitive   = true
}

# output "instance_cpu_core_count" {
#     description = "Number of CPU cores for the EC2 instance"
#     value       = aws_instance.public_instance.cpu_core_count
# }

# output "instance_cpu_threads_per_core" {
#     description = "Number of threads per CPU core for the EC2 instance"
#     value       = aws_instance.public_instance.cpu_threads_per_core
# }

# output "private_instance1_cpu_core_count" {
#     description = "Number of CPU cores for the first private EC2 instance"
#     value       = aws_instance.private_instance1[0].cpu_core_count
# }

# output "private_instance1_cpu_threads_per_core" {
#     description = "Number of threads per CPU core for the first private EC2 instance"
#     value       = aws_instance.private_instance1[0].cpu_threads_per_core
# }

# output "private_instance2_cpu_core_count" {
#     description = "Number of CPU cores for the second private EC2 instance"
#     value       = aws_instance.private_instance2[0].cpu_core_count
# }

# output "private_instance2_cpu_threads_per_core" {
#     description = "Number of threads per CPU core for the second private EC2 instance"
#     value       = aws_instance.private_instance2[0].cpu_threads_per_core
# }