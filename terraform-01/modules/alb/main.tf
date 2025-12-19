resource "aws_lb" "lb_main" {
  name               = "lb-main"
  load_balancer_type = "application"
  internal           = false
  subnets            = tolist(var.subnets)
  security_groups    = var.sg_ids

  tags = {
    Environment = var.env
  }
}

resource "aws_lb_target_group" "tg_lb_main" {
  name             = "tg-lb-main"
  port             = 80
  protocol         = "HTTP"
  protocol_version = "HTTP1"
  vpc_id           = var.vpc_id
}

resource "aws_lb_target_group_attachment" "att_tg_lb_main" {
  count            = length(var.target_ids)
  target_group_arn = aws_lb_target_group.tg_lb_main.arn
  target_id        = tolist(var.target_ids)[count.index]
  port             = 80
}

resource "aws_lb_listener" "listener_lb_main" {
  load_balancer_arn = aws_lb.lb_main.arn
  port              = 80
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_lb_main.arn
  }

  tags = {
    Environment = var.env
    Name        = "Listener LB Main"
  }
}
