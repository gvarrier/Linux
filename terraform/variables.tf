variable "regions" {
  default = ["GRA11","SBG5"]
  type    = list
}
variable "nbr_backend" {
  type = number
  default = 3
}
variable "instance_name" {
type = string
default = "eductive26"
}
variable "image_name" {
type = string
default = "Debian 11"
}
variable "flavor_name" {
type = string
default = "s1-2"
}
variable "vlan_id" {
  type    = number
  default = 26
}
variable "service_name" {
  type = string
  default = ""
}
variable "vlan_dhcp_start" {
  type = string
  default = "192.168.26.100"
}
variable "vlan_dhcp_end" {
  type = string
  default = "192.168.26.200"
}
variable "vlan_dhcp_network" {
  type = string
  default = "192.168.26.0/24"
}
