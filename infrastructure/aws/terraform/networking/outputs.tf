output "subnetIds" {
    value = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
}

output "vpcId" {
    value = aws_vpc.main.id
}