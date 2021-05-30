variable "do_token" {
  type        = string
  description = "Authentication token used to connect to DigitalOcean."
}

variable "owncast_server_fqdn" {
  type        = string
  description = "Owncast server FQDN, e.g. owncast-server.domain.com"
}

variable "do_spaces_token" {
  type        = string
  description = "Authentication token for DigitalOcean Spaces access."
}

variable "do_spaces_secret" {
  type        = string
  description = "Authentication token secret for DigitalOcean Spaces access."
}

variable "do_bucket_name" {
  type        = string
  description = "Name of DigitalOcean Spaces bucket to be created to stream content to."
}

variable "do_region" {
  type        = string
  description = "DigitalOcean region to create everything in."
}

variable "do_droplet_name" {
  type        = string
  description = "Name to create the new droplet with."
}

variable "do_droplet_size" {
  type        = string
  description = "Size slug for the droplet. This can be gotten from the DigitalOcean API docs at https://developers.digitalocean.com/documentation/v2/#list-all-sizes"
}

variable "do_floating_ip" {
  type        = string
  description = "IP address that gets assigned to the owncast droplet."
}