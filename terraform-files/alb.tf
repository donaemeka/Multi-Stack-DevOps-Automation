# Application Load Balancer
resource "aws_lb" "voting-applications-alb" {
  name               = "voting-applications-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.ALB_public_subnet_1.id, aws_subnet.ALB_public_subnet.id]

  tags = {
    Name = "voting-applications-alb"
  }
}

# Target Group for Port 80
resource "aws_lb_target_group" "frontend-80-tg" {
  name     = "frontend-80-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.voting_app_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "frontend-80-tg"
  }
}

# Target Group for Port 81
resource "aws_lb_target_group" "frontend-81-tg" {
  name     = "frontend-81-tg"
  port     = 81
  protocol = "HTTP"
  vpc_id   = aws_vpc.voting_app_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "frontend-81-tg"
  }
}

# Attach frontend instance to both target groups
resource "aws_lb_target_group_attachment" "frontend-80" {
  target_group_arn = aws_lb_target_group.frontend-80-tg.arn
  target_id        = aws_instance.frontend_instance_anaka.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "frontend-81" {
  target_group_arn = aws_lb_target_group.frontend-81-tg.arn
  target_id        = aws_instance.frontend_instance_anaka.id
  port             = 81
}

# Listener for Port 80
resource "aws_lb_listener" "http-80" {
  load_balancer_arn = aws_lb.voting-applications-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend-80-tg.arn
  }
}