owncast-terraform

Variables to set:
 * do_token = bearer token for your DigitalOcean account
 * owncast_server_url = the url you're using for the Owncast server

The owncast_server_url will need to have been registered with whoever your domain registrar is to point to your floating IP that is configured in the do_owncast.tf file. You should also create a floating IP for yourself in DigitalOcean to re-use so you can spin droplets up and down as you need without having to wait for DNS to propogate or anything.

The config file I'm using is specifying a rather large sized droplet so be sure you don't forget about it. Running it for 2-3 hours for a movie should be fine, probably coming out to $2-5 a session depending on how many people you are streaming to due to data egress fees. I don't have any hard numbers right now. I've tested this config for up to 4 viewers, hope to have more numbers soon.
