variable "enter_path_to_public_key"       {
  type = string
  default = "key.pub"
}
variable "project"       {
  type    = string
  default = "my-day01-project"
}
variable "api_key"       {
  type    = string
}
variable "app_key"       {
  type    = string
}
variable "api_url"       {
  type    = string
  default = "https://api.datadoghq.eu/"
}