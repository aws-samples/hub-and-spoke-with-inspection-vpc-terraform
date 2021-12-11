# --- tgw/variables.tf ---

variable "default_route_table_association" {
  type        = string
  description = "Transit Gateway Default Route Table Association"
  default     = "disable"
}

variable "default_route_table_propagation" {
  type        = string
  description = "Transit Gateway Default Route Progation"
  default     = "disable"
}

variable "dns_support" {
  type        = string
  description = "Transit Gateway DNS Support"
  default     = "enable"
}

variable "tags" {
  type        = map(string)
  description = "Transit Gateway Tags"
  default = {
    Name = "terraform-transit-gateway"
  }
}

variable "spoke_transit_gateway_default_route_attachment" {
  description = "value of the default route attachment for the spoke transit gateway"
}

variable "inspection_vpc_id" {
  description = "value of the VPC ID for the VPC to be used for inspection"
}

variable "inspection_vpc_attachment_subnets" {
  description = "value of the subnets to be used for inspection"
}

variable "inspection_vpc_attachment" {
  description = "value of the VPC attachment for the VPC to be used for inspection"
}

variable "spoke_vpc_attachments" {
  description = "value of the VPC attachments for the VPCs to be used for the spoke transit gateway"
}

variable "spoke_vpc_map" {
  description = "Map of Spoke VPCs"
}
