package main
import rego.v1


# Rule 1 : opne public NACL
deny contains msg if {
    some resource in input.resource_changes
    resource.type == "aws_network_acl_rule"
    resource.name == "public_inbound"
    resource.change.after.egress == false
    resource.change.after.rule_action == "allow"
    resource.change.after.cidr_block == "0.0.0.0/0"

    msg = sprintf("Public NACL rule allows all inbound traffic from 0.0.0.0/0 in resource %v", [resource.name])
}


#Rule 2: deny if no nat gateway created for private subnets

has_nat_gateway if{
  some resource in input.resource_changes
  resource.type =="aws_nat_gateway"
  resource.change.actions[_] == "create"

}

deny contains msg if{
  not has_nat_gateway
  msg := "No NAT Gateway is being created. Check if `enable_nat_gateway = true` is set."

}


#Rule 3: if no eip assign to nat gateway

no_eip if{
  some resource in input.resource_changes
  resource.type == "aws_eip"
  resource.name == "nat"
  resource.change.actions[_] == "create"
}

deny contains msg if{
  not no_eip
  msg := "No Elastic IP is being created for NAT Gateway."
}