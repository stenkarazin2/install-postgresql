variable "zone" {
  type = string
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "image_id1" {
  type = string
}

variable "image_id2" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "bootdisk_size" {
  type = number
  default=3
}

variable "service_account_id" {
  type = string
}

variable "yc_token" {
  type = string
}