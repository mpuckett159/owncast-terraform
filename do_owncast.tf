# Set provider requirements
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~>2.6.0"
    }
  }
}

# Set do_token
variable "do_token" {
  type = string
}

# Set owncast server URL
variable "owncast_server_url" {
  type = string
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create stream key
resource "random_string" "stream_key" {
  length  = 64
  special = false
  number  = true
  lower   = true
  upper   = true
}

# Build config file from variables/inputs/config files
# I wanted to try and make it simpler to follow/read not sure if I did it.
locals {
  ssh_key_local = file(pathexpand("~/.ssh/id_rsa.pub"))
  caddyfile_local = templatefile(
    "${path.module}/Caddyfile",
    {
      server_url = var.owncast_server_url
    }
  )
  docker_compose_local = file("${path.module}/docker-compose.yaml")
  user_data_local = templatefile(
    "${path.module}/cloud-config.yaml",
    {
      ssh_key        = local.ssh_key_local,
      caddyfile      = base64encode(local.caddyfile_local),
      docker_compose = base64encode(local.docker_compose_local),
      server_url     = var.owncast_server_url
      stream_key     = random_string.stream_key.result
    }
  )
}

# Tag for Droplet so the firewall rules are applied
resource "digitalocean_tag" "owncast_tag" {
  name = "Owncast"
}

# Image to use
data "digitalocean_images" "docker" {
  filter {
    key    = "distribution"
    values = ["Ubuntu"]
  }
  filter {
    key      = "name"
    values   = ["Docker"]
    match_by = "substring"
  }
  filter {
    key    = "regions"
    values = ["sfo1"]
  }
  sort {
    key       = "created"
    direction = "desc"
  }
}

# Create droplet with userdata stored in cloud-config.yaml file
resource "digitalocean_droplet" "owncast" {
  name               = "owncast-droplet"
  size               = "c-4"
  image              = element(tolist(data.digitalocean_images.docker.images), 0).id
  region             = "sfo3"
  ipv6               = false
  private_networking = true
  user_data          = local.user_data_local
  tags               = [digitalocean_tag.owncast_tag.id]
}

# Assign floating IP to new droplet
resource "digitalocean_floating_ip_assignment" "pub_ip" {
  ip_address = "164.90.247.66"
  droplet_id = digitalocean_droplet.owncast.id
}

# # output locals for testing
# output "ssh_key_local_test" {
#     value = local.ssh_key_local
# }

# output "caddyfile_local_test" {
#     value = local.caddyfile_local
# }

# output "owncast_config_local_test" {
#     value = local.owncast_config_local
# }

# output "docker_compose_local_test" {
#     value = local.docker_compose_local
# }

# # output user_data template
# output "user_data_template" {
#     value = local.user_data_local
# }

# output stream_key to user to send on to whoever asked for the server to be set up
output "stream_key" {
  value = random_string.stream_key.result
}