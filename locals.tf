locals {
  name_prefix    = coalesce(var.name, var.bastion_launch_template_name)
  security_group = join("", flatten([aws_security_group.bastion_host_security_group[*].id, var.bastion_security_group_id]))

  # Network Load Balancer and target group names must be <= 32 characters.
  nlb_base            = replace(local.name_prefix, "_", "-")
  lb_suffix           = "-lb"
  tg_suffix           = "-lb-target"
  nlb_name_raw        = "${local.nlb_base}${local.lb_suffix}"
  nlb_target_name_raw = "${local.nlb_base}${local.tg_suffix}"

  # Use the full prefix when it fits; otherwise keep the longest possible prefix before the fixed suffix.
  lb_name              = length(local.nlb_name_raw) <= 32 ? local.nlb_name_raw : "${trim(substr(local.nlb_base, 0, 32 - length(local.lb_suffix)), "-")}${local.lb_suffix}"
  lb_target_group_name = length(local.nlb_target_name_raw) <= 32 ? local.nlb_target_name_raw : "${trim(substr(local.nlb_base, 0, 32 - length(local.tg_suffix)), "-")}${local.tg_suffix}"

  tags = merge(tomap({ "Name" = local.name_prefix }), merge(var.tags))

  // the compact() function checks for null values and gets rid of them 
  // the length is a check to ensure we dont have an empty array, as an empty array would throw an error for the cidr_block argument 
  ipv4_cidr_block = length(compact(data.aws_subnet.subnets[*].cidr_block)) == 0 ? null : concat(data.aws_subnet.subnets[*].cidr_block, var.cidrs)
  ipv6_cidr_block = length(compact(data.aws_subnet.subnets[*].ipv6_cidr_block)) == 0 ? null : concat(data.aws_subnet.subnets[*].ipv6_cidr_block, var.ipv6_cidrs)
}

