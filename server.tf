resource "aws_vpc" "carlcloud" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "carl-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.carlcloud.id

  tags = {
    Name = "carl-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.carlcloud.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.carlcloud.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for Frontend (if needed for EC2/ALB)
resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Allow HTTP and HTTPS for frontend"
  vpc_id      = aws_vpc.carlcloud.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-sg"
  }
}

# Security Group for Backend (e.g., API)
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Allow traffic from frontend"
  vpc_id      = aws_vpc.carlcloud.id

  ingress {
    from_port       = 3000  # or your API port
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}

output "vpc_id" {
  value = aws_vpc.carlcloud.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "frontend_sg_id" {
  value = aws_security_group.frontend_sg.id
}

output "backend_sg_id" {
  value = aws_security_group.backend_sg.id
}

resource "aws_instance" "be_pub" {
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]  # Add this line

  tags = {
    Name = "backend-pub"
  }
}

resource "aws_instance" "fe_pub" {
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]  # Add this line

  tags = {
    Name = "frontend-pub"
  }
}