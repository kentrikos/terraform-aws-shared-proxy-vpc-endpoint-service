# FIXME: map function is deprecated and will be removed in future versions of TF (https://www.terraform.io/docs/configuration/functions/map.html)

locals {
  common_tag = "${map(
     "${var.common_tag["key"]}", "${var.common_tag["value"]}"
   )}"
}

resource "aws_lb_target_group" "this" {
  port        = "${var.target_port}"
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = "${var.nlb_tg_vpc}"

  tags = "${merge(
                          local.common_tag, 
                          map(
                            "target_hostname",
                            "${var.target_hostname}"
                          )
                        )
                  }"

  lifecycle {
    create_before_destroy = true
  }
}

data "external" "dns_resolver" {
  program = ["bash", "${path.module}/helpers/tf_dns_resolver_helper.sh"]

  query = {
    dns_name      = "${var.target_hostname}"
    dns_server_ip = "${var.dns_server_ip}"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn  = "${aws_lb_target_group.this.arn}"
  target_id         = "${var.target_hostname}"
  target_id         = "${data.external.dns_resolver.result.ip}"
  availability_zone = "all"
}

resource "aws_lb_listener" "nlb" {
  load_balancer_arn = "${var.nlb_arn}"
  protocol          = "TCP"
  port              = "${var.nlb_listener_port}"

  default_action {
    target_group_arn = "${aws_lb_target_group.this.arn}"
    type             = "forward"
  }
}
