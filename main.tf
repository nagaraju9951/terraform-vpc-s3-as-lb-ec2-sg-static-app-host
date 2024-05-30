# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "main-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Create Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "main-route-table"
  }
}

# Create Subnets
resource "aws_subnet" "main_a" {
  vpc_id             = aws_vpc.main.id
  cidr_block         = var.subnet_cidr_a
  availability_zone  = "ap-south-1a"
  tags = {
    Name = "main-subnet-a"
  }
}

resource "aws_subnet" "main_b" {
  vpc_id             = aws_vpc.main.id
  cidr_block         = var.subnet_cidr_b
  availability_zone  = "ap-south-1b"
  tags = {
    Name = "main-subnet-b"
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "main_a" {
  subnet_id      = aws_subnet.main_a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "main_b" {
  subnet_id      = aws_subnet.main_b.id
  route_table_id = aws_route_table.main.id
}

# Create Security Group
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "main-sg"
  }
}

# Create EC2 Instance
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.main_a.id
  vpc_security_group_ids = [aws_security_group.main.id]
  tags = {
    Name = "web-instance"
  }
}

## Create S3 Bucket
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
  tags = {
    Name = "website-bucket"
  }
}

# Create S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website.bucket

  index_document {
    suffix = "index.html"
  }
}

# Upload index.html to the S3 bucket
resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.website.bucket
  key    = "index.html"
  source = "index.html"  # Assuming index.html is in the same directory as your .tf files
}



# Create Launch Configuration
resource "aws_launch_configuration" "example" {
  name          = "example"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.main.id]
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  desired_capacity     = 2
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.main_a.id, aws_subnet.main_b.id]
  launch_configuration = aws_launch_configuration.example.id

  tag {
    key                 = "Name"
    value               = "autoscaling-group"
    propagate_at_launch = true
  }
}

# Create Load Balancer
resource "aws_lb" "main" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = [aws_subnet.main_a.id, aws_subnet.main_b.id]

  enable_deletion_protection = false
}

# Create Target Group
resource "aws_lb_target_group" "main" {
  name     = "main-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# Create Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Attach Auto Scaling Group to Target Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.example.name
  lb_target_group_arn    = aws_lb_target_group.main.arn
}
