locals {
  common_tag = {
    lookup(var.common_tag, "key", null) = lookup(var.common_tag, "value", null)
  }
  csv_data = csvdecode(file("${path.module}/csv_input.csv"))
  nlb_listener_port = {
    for listener in local.csv_data : listener.nlb_listener_port => listener
  }
}

resource "aws_lb_target_group" "this" {
  for_each = { for hostname in local.csv_data : hostname.target_hostname => hostname }
  port        = each.value.target_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.nlb_tg_vpc

  tags = merge(
    local.common_tag,
    {
      "target_hostname" = each.value.target_hostname
    },
  )
  lifecycle {
    create_before_destroy = true
  }
}

data "external" "dns_resolver" {
  for_each = { for hostname in local.csv_data : hostname.target_hostname => hostname }
  program = ["bash", "${path.module}/helpers/tf_dns_resolver_helper.sh"]

  query = {
    dns_name      = each.value.target_hostname
    dns_server_ip = var.dns_server_ip
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for pair in setproduct(keys(aws_lb_target_group.this), keys(data.external.dns_resolver)) :
    "${pair[0]}:${pair[1]}" => {
       target_group_arn = aws_lb_target_group.this[pair[0]]
       target_id        = pair[1]
    }
  }
  target_group_arn  = each.value.target_group_arn.arn
  target_id         = each.value.target_id
  availability_zone = "all"
}

resource "aws_lb_listener" "nlb" {
  for_each = { 
    for pair in setproduct(keys(aws_lb_target_group.this), keys(local.nlb_listener_port)) :
     "${pair[0]}:${pair[1]}" => {
       target_group_arn = pair[0]
       port             = pair[1]
     }
  }
  load_balancer_arn = var.nlb_arn
  protocol          = "TCP"
  port              = each.value.port

  default_action {
    target_group_arn = each.value.target_group_arn
    type             = "forward"
  }
}

resource "aws_network_acl_rule" "nacl_rule" {
  count          = var.enable_nacl ? 1 : 0
  network_acl_id = var.nacl_id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = var.nacl_rule_number
  from_port      = 1024
  to_port        = 65535
  cidr_block     = var.nacl_rule_cidr
}