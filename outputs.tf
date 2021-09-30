# output stream_key to user to send on to whoever asked for the server to be set up
output "stream_key" {
  value = random_string.stream_key.result
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