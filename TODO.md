# TODO:

- [x]: fix hosts file with tailscale log issues

- [x]: reinstall k3s
  - ~~Use traefik but disable servicelb~~

- [x]: setup letsencrypt with traefik

- [x]: commit the code

- [ ]: document architecture and reasons why

- [ ]: fix user setup to allow linode to use `root` and pis to use `pi`
  - Perhaps a separate execution

- [ ]: tailscale has a manual step to auth in browser, see if it can be automated
  - Or simply open everything in a browser window
  - This means you can't have the vpn IPs before you've registered
