# Set provider requirements
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~>2.12.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create stream key
resource "random_string" "stream_key" {
  length  = var.owncast_stream_key
  special = false
  number  = true
  lower   = true
  upper   = true
}

# Build config file from variables/inputs/config files
# I wanted to try and make it simpler to follow/read not sure if I did it.
locals {
  ssh_key_local = file(pathexpand(var.ssh_key_path))
  caddyfile_local = templatefile(
    "${path.module}/assets/Caddyfile",
    {
      server_url = var.owncast_server_url
    }
  )
  docker_compose_local = file("${path.module}/assets/docker-compose.yaml")
  user_data_local = templatefile(
    "${path.module}/assets/cloud-config.yaml",
    {
      ssh_key        = local.ssh_key_local,
      caddyfile      = base64encode(local.caddyfile_local),
      docker_compose = base64encode(local.docker_compose_local),
      server_url     = var.owncast_server_url,
      stream_key     = random_string.stream_key.result,
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
  user_data          = local.user_data_local
  tags               = [digitalocean_tag.owncast_tag.id]
}

# Assign floating IP to new droplet
resource "digitalocean_floating_ip_assignment" "pub_ip" {
  ip_address = "164.90.247.66"
  droplet_id = digitalocean_droplet.owncast.id
}