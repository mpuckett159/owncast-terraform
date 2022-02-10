owncast-terraform

Variables to set:
 * do_token = bearer token for your DigitalOcean account
 * owncast_server_url = the url you're using for the Owncast server

The owncast_server_url will need to have been registered with whoever your domain registrar is to point to your floating IP that is configured in the do_owncast.tf file. You should also create a floating IP for yourself in DigitalOcean to re-use so you can spin droplets up and down as you need without having to wait for DNS to propogate or anything.

The config file I'm using is specifying a rather large sized droplet so be sure you don't forget about it. Running it for 2-3 hours for a movie should be fine, probably coming out to $2-5 a session depending on how many people you are streaming to due to data egress fees. I don't have any hard numbers right now. I've tested this config for up to 4 viewers, hope to have more numbers soon.

Not required but I would also recommend setting up a firewall rule for this server like so:
 * 22 TCP (SSH)
 * 80 TCP (HTTP)
 * 443 TCP (HTTPS)
 * 1935 TCP (RTMP, what OBS streams on)

Then add a tag rule for it, and just make sure the name matches in the Terraform config.

Building GUI:
You will need to have go installed to build this GUI application.

```bash
cd ./owncast-terraform-gui
go build
```

This builds a simple GUI so you can simply click deploy or destroy and it will run the terraform for you. I haven't figure out how to get it to stop popping up terminal windows yet but I think it's not possible.

The stream key will be output at the end of the run for easy copy/paste into OBS or whatever you're using.

I've only done this on Windows, no idea how this works on Mac.