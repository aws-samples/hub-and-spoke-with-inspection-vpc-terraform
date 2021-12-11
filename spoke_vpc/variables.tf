# --- spoke_vpc_routes/variables.tf ---
variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "transit_gateway_attach_subnets" {
  type        = list(string)
  description = "List of TGW Attachment Subnet IDs"
}

variable "transit_gateway_default_route_table_association" {
  type        = string
  description = "Transit Gateway Default Route Table Association ID"
  default     = "false"
}

variable "transit_gateway_default_route_table_propagation" {
  type        = string
  description = "Transit Gateway Default Route Table Propogation"
  default     = "false"
}

variable "name" {
  type        = string
  description = "Name of the spoke VPC"
}

variable "spoke_transit_gateway_route_table_id" {
  type        = string
  description = "Spoke Route Table ID"
}

variable "intra_route_table_id" {
  description = "Intra Route Table ID"
}

variable "private_route_table_id" {
  description = "Private Route Table ID"
}

variable "public_route_table_id" {
  description = "value of public route table id"
}
