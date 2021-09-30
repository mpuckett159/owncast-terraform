# Set do_token
variable "do_token" {
  type = string
}

# Set owncast server URL
variable "owncast_server_url" {
  type = string
}

# Set stream key length
variable "owncast_stream_key" {
  type = number
  default = 64
}

# Set ssh public key path
variable "ssh_key_path" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}