# 国内下载需要配置镜像：https://developer.hashicorp.com/terraform/cli/config/config-file
# https://help.aliyun.com/document_detail/2584222.html?spm=a2c4g.95841.0.0.5fd66377MtAoJ0

# cat <<EOF > ~/.terraformrc
# provider_installation {
#   network_mirror {
#     url = "https://mirrors.aliyun.com/terraform/"
#     // 限制只有阿里云相关 Provider 从国内镜像源下载
#     include = ["registry.terraform.io/aliyun/alicloud",
#                "registry.terraform.io/hashicorp/alicloud",
#               ]
#   }
#   direct {
#     // 声明除了阿里云相关Provider, 其它Provider保持原有的下载链路
#     exclude = ["registry.terraform.io/aliyun/alicloud",
#                "registry.terraform.io/hashicorp/alicloud",
#               ]
#   }
# }
# EOF

terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.221.0"
    }
  }
}
