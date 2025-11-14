
variable "svc_project_id" {
  type = string
}

variable "host_project_id" {
  type    = string
  default = null
}

variable "gke_cluster" {
  type = object({
    name   = string
    region = string
    zones  = list(string)
    vpc = object({
      vpc_name    = string
      vpc_subnet  = string
      vpc_sec_pod = string
      vpc_sec_svc = string
    })
    master_ipv4_cidr_block = string
    master_authorized_networks = list(object({
      cidr_block   = string
      display_name = string
    }))
    node_pool = list(map(any))
  })
}

variable "router" {
  type = object({
    name     = string
    nat_name = string
    network  = string
    region   = string
    subnet   = string
  })
}

variable "configure_ip_masq" {
  type        = bool
  description = "Enables the installation of ip masquerading, which is usually no longer required when using aliasied IP addresses. IP masquerading uses a kubectl call, so when you have a private cluster, you will need access to the API server."
  default     = false
}