variable "website" {
  type = string
}
variable "connections" {
  type    = string
  default = "5000"
}
variable "timeout" {
  type    = string
  default = "10"
}
variable "method" {
  type    = string
  default = "GET"
}
variable "duration" {
  type    = string
  default = "3600"
}
variable "in_count" {
  type    = number
  default = 10
}
variable "instance_type" {
  type    = string
  default = "t3a.micro"
}
