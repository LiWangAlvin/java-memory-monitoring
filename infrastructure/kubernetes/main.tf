#provider, use alicloud
provider "alicloud" {
  region = "cn-shenzhen"
}

variable "k8s_name_prefix" {
  description = "The name prefix used to create managed kubernetes cluster."
  default     = "tf-ack-shenzhen"
}

resource "random_uuid" "this" {}

# 默认资源名称。
locals {
  k8s_name_terway         = substr(join("-", [var.k8s_name_prefix, "terway"]), 0, 63)
  k8s_name_flannel        = substr(join("-", [var.k8s_name_prefix, "flannel"]), 0, 63)
  k8s_name_ask            = substr(join("-", [var.k8s_name_prefix, "ask"]), 0, 63)
  new_vpc_name            = "tf-vpc-172-16"
  new_vsw_name_azD        = "tf-vswitch-azD-172-16-0"
  new_vsw_name_azE        = "tf-vswitch-azE-172-16-2"
  new_vsw_name_azF        = "tf-vswitch-azF-172-16-4"
  nodepool_name           = "default-nodepool"
  managed_nodepool_name   = "managed-node-pool"
  autoscale_nodepool_name = "autoscale-node-pool"
  log_project_name        = "log-for-${local.k8s_name_terway}"
}

# 节点ECS实例配置。将查询满足CPU、Memory要求的ECS实例类型。
data "alicloud_instance_types" "default" {
  cpu_core_count       = 2
  memory_size          = 8
  availability_zone    = var.availability_zone[0]
  kubernetes_node_role = "Worker"
}

// 满足实例规格的AZ。
data "alicloud_zones" "default" {
  available_instance_type = data.alicloud_instance_types.default.instance_types[0].id
}

# 专有网络。
resource "alicloud_vpc" "default" {
  vpc_name   = local.new_vpc_name
  cidr_block = "172.16.0.0/12"
}

# Node交换机。
resource "alicloud_vswitch" "vswitches" {
  count      = length(var.node_vswitch_ids) > 0 ? 0 : length(var.node_vswitch_cidrs)
  vpc_id     = alicloud_vpc.default.id
  cidr_block = element(var.node_vswitch_cidrs, count.index)
  zone_id    = element(var.availability_zone, count.index)
}

# Pod交换机。
resource "alicloud_vswitch" "terway_vswitches" {
  count      = length(var.terway_vswitch_ids) > 0 ? 0 : length(var.terway_vswitch_cidrs)
  vpc_id     = alicloud_vpc.default.id
  cidr_block = element(var.terway_vswitch_cidrs, count.index)
  zone_id    = element(var.availability_zone, count.index)
}

# Kubernetes托管版。
resource "alicloud_cs_managed_kubernetes" "default" {
  # Kubernetes集群名称。
  name = local.k8s_name_terway
  # 创建Pro版集群。
  cluster_spec = "ack.standard"
  version      = "1.28.9-aliyun.1"
  # 节点池所在的vSwitch。指定一个或多个vSwitch的ID，必须在availability_zone指定的区域中。
  worker_vswitch_ids = split(",", join(",", alicloud_vswitch.vswitches.*.id))

  # Pod虚拟交换机。
  pod_vswitch_ids = split(",", join(",", alicloud_vswitch.terway_vswitches.*.id))

  # 是否在创建Kubernetes集群时创建新的NAT网关。默认为true。
  new_nat_gateway = true
  # Pod网络的CIDR块。当cluster_network_type设置为flannel，你必须设定该参数。它不能与VPC CIDR相同，并且不能与VPC中的Kubernetes集群使用的CIDR相同，也不能在创建后进行修改。集群中允许的最大主机数量：256。
  # pod_cidr                  = "10.10.0.0/16"
  # 服务网络的CIDR块。它不能与VPC CIDR相同，不能与VPC中的Kubernetes集群使用的CIDR相同，也不能在创建后进行修改。
  service_cidr = "10.11.0.0/16"
  # 是否为API Server创建Internet负载均衡。默认为false。
  slb_internet_enabled = true

  # Enable Ram Role for ServiceAccount
  enable_rrsa = true

  # 控制平面日志。
  control_plane_log_components = ["apiserver", "kcm", "scheduler", "ccm"]

  # 组件管理。
  dynamic "addons" {
    for_each = var.cluster_addons
    content {
      name   = lookup(addons.value, "name", var.cluster_addons)
      config = lookup(addons.value, "config", var.cluster_addons)
    }
  }
}

# 普通节点池。
resource "alicloud_cs_kubernetes_node_pool" "default" {
  # Kubernetes集群名称。
  cluster_id = alicloud_cs_managed_kubernetes.default.id
  # 节点池名称。
  node_pool_name = local.nodepool_name
  # 节点池所在的vSwitch。指定一个或多个vSwitch的ID，必须在availability_zone指定的区域中。
  vswitch_ids = split(",", join(",", alicloud_vswitch.vswitches.*.id))

  # Worker ECS Type and ChargeType
  # instance_types       = [data.alicloud_instance_types.default.instance_types[0].id]
  instance_types = var.worker_instance_types
  instance_charge_type = "PostPaid"

  # customize worker instance name
  # node_name_mode      = "customized,ack-terway-shenzhen,ip,default"

  #Container Runtime
  runtime_name    = "containerd"
  runtime_version = "1.6.20"

  # 节点池的期望节点数。
  desired_size = 1
  # SSH登录集群节点的密码。
  password = var.password

  # 是否为Kubernetes的节点安装云监控。
  install_cloud_monitor = true

  # 节点的系统磁盘类别。默认为cloud_efficiency。
  system_disk_category = "cloud_efficiency"
  system_disk_size     = 100

  spot_strategy = "SpotAsPriceGo"

  # OS Type
  image_type = "AliyunLinux"

  # 节点数据盘配置。
  data_disks {
    # 节点数据盘种类。
    category = "cloud_essd"
    # 节点数据盘大小。
    size = 120
  }
}


# output "kube_configa" {
#   value =
# }