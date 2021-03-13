# Set provider requirements
terraform {
    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
            version = "~>2.6.0"
        }
    }
}

# Set do_token
variable "do_token" {
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

# Create droplet with userdata stored in cloud-config.yaml file
resource "digitalocean_droplet" "owncast" {
  name               = "owncast-droplet"
  size               = "s-1vcpu-1gb"
  image              = 72401866
  region             = "sfo3"
  ipv6               = false
  private_networking = true
  user_data          = templatefile(
      "${path.module}/cloud-config.yaml", 
      {
          ssh_key = file(pathexpand("~/.ssh/id_rsa.pub")),
          caddyfile  = base64encode(file("${path.module}/Caddyfile")),
          owncast_config = base64encode(templatefile(
              "${path.module}/owncast-config.yaml",
              {
                  stream_key = random_string.stream_key.result
              }
          )),
          docker_compose = base64encode(file("${path.module}/docker-compose.yaml"))
      }
    )
}

# Assign floating IP to new droplet
resource "digitalocean_floating_ip_assignment" "pub_ip" {
  ip_address = "164.90.247.66"
  droplet_id = digitalocean_droplet.owncast.id
}

# output stream_key to user to send on to whoever
output "stream_key" {
    value = random_string.stream_key.result
}