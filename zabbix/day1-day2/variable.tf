variable "mongo_db_password"       {
  type = string
  default = "zap8911"
}
variable "enter_path_to_public_key"       {
  type = string
  default = "key.pub"
}
variable "enter_path_to_private_key"       {
  type = string
  default = "key"
}
variable "project"       {
  type    = string
  default = "my-day01-project"
}

variable "enter_ldap_admin_password"       {
  type = string
  default = "zap8911"
}

variable "public_key_for_user"       {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCdStGycseWwAazUZy+uZgOXWFZ2PTFqNE910tjMQzxFvM3giHw4ZbFilwuFn8YiNydjyT9+MkfOEXCJWr5cYZ+n1FWjgR04OCR2GevkNRSpRFZnMujc20d6rsh9g8kUN3o/hPkvl4bGF0xOiiTkpkGUosWXV40UjT/5iCHUw5onOMsg7BNXICLhi0fq3b9na5rfIFtgO5VqhZgoXz1n6IW+IxWILB7b2gERgculq0JlastWhB7wvKiyiXzLowB4q0DirooOyNMQT5utCoOQgIm4ShfIKiCyz+yCxVFPT/gDBRQ+JV7QB9s/OrL61xj0C4SZ4d14d23U5XHhzjfRyj root@terraform"
}