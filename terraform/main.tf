provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# VPC Resources

resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "snekisnek"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidr_blocks)
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "private" {
  count                  = length(var.private_subnet_cidr_blocks)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default[count.index].id


}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Tier = "Private"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Tier = "Public"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT resources

resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidr_blocks)
  vpc   = true
}

resource "aws_nat_gateway" "default" {
  depends_on    = [aws_internet_gateway.default]
  count         = length(var.public_subnet_cidr_blocks)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.private[count.index].id
}

# Security groups


resource "aws_security_group" "allow_http_instances_backend" {
  name = "allow_http_instances_backend"
  vpc_id = aws_vpc.default.id
  description = "http from backend LB to backend instances"

  ingress {
    description = "Http from Backend LB to backend instances"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.allow_https_backend_lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_https_backend_lb" {
  name = "allow_https_backend_lb"
  vpc_id = aws_vpc.default.id
  description = "Allow https from Frontend instances to backend LB"

  ingress {
    description = "HTTPS from Frontend Nodes"
    from_port = 443
    to_port = 443
    protocol = "https"
    cidr_blocks = ["0.0.0.0/0"] # this is needed in order for application to work, problem is in the way that application was designed.
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http_instances" {
  name   = "allow_http_instances_frontend"
  vpc_id = aws_vpc.default.id
  description = "Allow HTTP from Frontend LB to frontend instances"

  ingress {
    description = "HTTP from LB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_https_lb.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_https_lb" {
  name   = "allow_https_lb"
  vpc_id = aws_vpc.default.id
  description = "Allow https on frontend LB "

  ingress {
    description = "HTTPs from everywhere"
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
}

## Autoscaling Frontend

# Launch configuration
module "SnakeFE" {
  source = "./modules/FE"
  security-group-ids = [aws_security_group.allow_http_instances.id]
}

resource "aws_autoscaling_attachment" "frontend_attachment" {
  autoscaling_group_name = aws_autoscaling_group.frontend.id
  alb_target_group_arn = aws_lb_target_group.frontend.arn
}

#Target group

resource "aws_lb_target_group" "frontend" {
  name ="frontend-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.default.id
}

#Autoscaling group Frontend
data "aws_subnet_ids" "public" {
  vpc_id = aws_vpc.default.id
  
  tags = {
    Tier = "Public"
  }
}



resource "aws_autoscaling_group" "frontend" {
  name = "frontend"
  max_size = 3
  min_size = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 2
  force_delete = true
  launch_configuration = module.SnakeFE.test
  vpc_zone_identifier = data.aws_subnet_ids.public.ids
  target_group_arns = [aws_lb_target_group.frontend.arn]

  tag {
    key = "Name"
    value = "Frontend"
    propagate_at_launch = true
  }
}

resource "aws_lb" "frontend_lb" {
  name = "frontend-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.allow_https_lb.id]
  subnets = data.aws_subnet_ids.public.ids
}

resource "aws_lb_listener" "frontend_lb_listener" {
  load_balancer_arn = aws_lb.frontend_lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:eu-central-1:853965937421:certificate/47ae570f-da48-4b65-b6ce-8f3e6e6020e8"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

## Autoscaling Backend

# Launch configuration Backend
module "SnakeBE" {
  source = "./modules/BE"
  security-group-ids = [aws_security_group.allow_http_instances_backend.id]
}

resource "aws_autoscaling_attachment" "backend_attachment" {
  autoscaling_group_name = aws_autoscaling_group.backend.id
  alb_target_group_arn = aws_lb_target_group.backend.arn
}

#Target group Backend

resource "aws_lb_target_group" "backend" {
  name ="backend-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.default.id
}

#Autoscaling group Backend
data "aws_subnet_ids" "private" {
  vpc_id = aws_vpc.default.id
  
  tags = {
    Tier = "Private"
  }
}

resource "aws_autoscaling_group" "backend" {
  name = "backend"
  max_size = 3
  min_size = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 2
  force_delete = true
  launch_configuration = module.SnakeBE.testbe
  vpc_zone_identifier = data.aws_subnet_ids.private.ids
  target_group_arns = [aws_lb_target_group.backend.arn]

  tag {
    key = "Name"
    value = "Backend"
    propagate_at_launch = true
  }
}
# This exact configration is needed for this LB because of the way application was desinged/ any other configuration leads to backend being unreachable.
resource "aws_lb" "backend_lb" {
  name = "backend-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.allow_https_backend_lb.id]
  subnets = data.aws_subnet_ids.public.ids
}

resource "aws_lb_listener" "backend_lb_listener" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:eu-central-1:853965937421:certificate/47ae570f-da48-4b65-b6ce-8f3e6e6020e8"
  

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

resource "aws_route53_record" "domain_do_backend_lb" {
  zone_id = var.snek-zone
  name = "internal.snekisnek.rocks"
  type = "A"

  alias {
    name = aws_lb.backend_lb.dns_name
    zone_id = aws_lb.backend_lb.zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "domain_to_frontend_lb" {
  zone_id = var.snek-zone
  name = "snekisnek.rocks"
  type = "A"

  alias {
    name = aws_lb.frontend_lb.dns_name
    zone_id = aws_lb.frontend_lb.zone_id
    evaluate_target_health = true
  }

}







