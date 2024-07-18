resource "aws_ssm_parameter" "ingress_alb_listener_arn" {
  name  = "/${var.project_name}/${var.environment}/ingress_alb_listener_arn"
  type  = "String"
  value = aws_lb_listener.http.arn
}

resource "aws_ssm_parameter" "ingress_alb_listener_arn_https" {
  name  = "/${var.project_name}/${var.environment}/ingress_alb_listener_arn_https"
  type  = "String"
  value = aws_lb_listener.https.arn
}