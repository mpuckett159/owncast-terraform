# Set provider requirements
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~>2.6.0"
    }
  }
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

# Set up bucket for stream content distribution
resource "digitalocean_spaces_bucket" "owncast-files" {
  name   = "${do_bucket_name}"
  region = "${do_regions}"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://${owncast_server_fqdn}"]
  }
}

# Build config file from variables/inputs/config files
# I wanted to try and make it simpler to follow/read not sure if I did it.
locals {
  ssh_key_local = file(pathexpand("~/.ssh/id_rsa.pub"))
  caddyfile_local = templatefile(
    "${path.module}/Caddyfile",
    {
      server_url = var.owncast_server_fqdn
    }
  )
  owncast_config_local = templatefile(
    "${path.module}/owncast-config.yaml",
    {
      stream_key       = random_string.stream_key.result,
      do_spaces_token  = var.do_spaces_token,
      do_spaces_secret = var.do_spaces_secret,
      do_region        = digitalocean_spaces_bucket.owncast-files.region,
      do_bucket_name   = digitalocean_spaces_bucket.owncast-files.name
    }
  )
  docker_compose_local = file("${path.module}/docker-compose.yaml")
  user_data_local = templatefile(
    "${path.module}/cloud-config.yaml",
    {
      ssh_key        = local.ssh_key_local,
      caddyfile      = base64encode(local.caddyfile_local),
      owncast_config = base64encode(local.owncast_config_local),
      docker_compose = base64encode(local.docker_compose_local)
    }
  )
}

# Tag for Droplet so the firewall rules are applied
resource "digitalocean_tag" "owncast_tag" {
  name = "Owncast"
}

# Create droplet with userdata stored in cloud-config.yaml file
resource "digitalocean_droplet" "owncast" {
  name               = "${do_droplet_name}"
  size               = "${do_droplet_size}"
  image              = 72401866
  region             = "${do_region}"
  ipv6               = false
  private_networking = true
  user_data          = local.user_data_local
  tags               = [digitalocean_tag.owncast_tag.id]
}

# Assign floating IP to new droplet
resource "digitalocean_floating_ip_assignment" "pub_ip" {
  ip_address = "${do_floating_ip}"
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