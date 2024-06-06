variable "availability_zone" {
  description = "The availability zones of vswitches."
  # 请跟下文main.tf配置文件中的地域保持一致。
  default     = ["cn-shenzhen-d", "cn-shenzhen-e", "cn-shenzhen-f"]
}

variable "node_vswitch_ids" {
  description = "List of existing node vswitch ids for terway."
  type        = list(string)
  default     = []
}

variable "node_vswitch_cidrs" {
  description = "List of cidr blocks used to create several new vswitches when 'node_vswitch_ids' is not specified."
  type        = list(string)
  default     = ["172.16.0.0/23", "172.16.2.0/23", "172.16.4.0/23"]
}

variable "terway_vswitch_ids" {
  description = "List of existing pod vswitch ids for terway."
  type        = list(string)
  default     = []
}

variable "terway_vswitch_cidrs" {
  description = "List of cidr blocks used to create several new vswitches when 'terway_vswitch_ids' is not specified."
  type        = list(string)
  default     = ["172.16.208.0/20", "172.16.224.0/20", "172.16.240.0/20"]
}

# Node Pool worker_instance_types
variable "worker_instance_types" {
  description = "The ecs instance types used to launch worker nodes."
  default     = ["ecs.g6.2xlarge", "ecs.g6.xlarge"]
}

# Password for Worker nodes
variable "password" {
  description = "The password of ECS instance."
  default     = "Test123456"
}

# Cluster Addons
variable "cluster_addons" {
  type = list(object({
    name   = string
    config = string
  }))

  default = [
    {
      "name"   = "terway-eniip",
      "config" = "",
    },
    {
      "name"   = "csi-plugin",
      "config" = "",
    },
    {
      "name"   = "csi-provisioner",
      "config" = "",
    },
    {
      "name" = "nginx-ingress-controller",
      "config" = "",
      "disabled" = "true",
    }
  ]
}