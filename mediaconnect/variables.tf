variable "whitelist_cidr_address" {
    type = string
    description = "the ip address of the ingress source"
}

variable "prefix" {
    type = string
    description = "will be applied where possible"
}
