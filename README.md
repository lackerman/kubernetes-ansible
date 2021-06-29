# RPi K8s cluster playbook

This playbook sets up a k8s cluster on the specified hosts.

## prerequisites

- Public key already setup in the default `$HOME/.ssh` folder, named `id_rsa.pub`
    - use `ssh-keygen` to setup a new public-private key pair if you haven't already
- make sure to set the variables in [group_vars/all](group_vars/all) to use either
  the default ubuntu or Raspberry Pi OS user and config files.

## manual steps

- [setup the Raspberry Pi sd cards][setup_sd_card]
  > This playbook currently supports [Raspbian Buster image][raspbian_buster] and [Ubuntu 20.04][ubuntu2004]
  - enable `ssh` before booting the RPis
    - Add a file called `ssh` to the `boot` partition (Raspbian) or `system-boot` (Ubuntu)
      which should be mounted after re-inserting the SD card into your card reader.
      > In the case of Mac, open a terminal and enter `touch /Volumes/boot/ssh`
      > For an ubuntu disk, use the [disk_setup.sh](disk_setup.sh) file

## running the ansible scripts

### prerequisites

Start by setting up some "secret" variables
```shell script
cat >> .secret <<EOF
# Email used by cert-manager to to notify you
# if there were issues registering the certificate
email: <enter-email>
domain: <enter-domain>
git_username: <enter-github-username>
git_token: <enter-github-token>
grafana_cloud_loki_username: <grafana-cloud-loki-username>
grafana_cloud_loki_password: <grafana-cloud-loki-password>
grafana_cloud_prom_username: <grafana-cloud-prom-username>
grafana_cloud_prom_password: <grafana-cloud-prom-password>
grafana_cloud_tempo_username: <grafana-cloud-tempo-username>
grafana_cloud_tempo_password: <grafana-cloud-tempo-password>
EOF
```

### validate the playbook

> Using the [disk_setup.sh](disk_setup.sh) script listed, ubuntu
> is already setup to use public key auth. However, for Raspberry Pi OS
> (Raspbian) you need to specify the password when connecting. In order
> to do this you will need to install paramiko using `pip install paramiko`
> on the host machine.

```shell script
# Raspberry Pi OS
ansible-playbook -i hosts site.yml --check --ask-pass
# Ubuntu
ansible-playbook -i hosts site.yml --check
```

### first run

For Raspberry Pi OS, the playbook has to be executed twice. On the first
run ansible will setup a user, based on the current `USER` environment
variable, thereafter, it uses public keys for ssh (based on the default
`$HOME/.ssh/id_rsa.pub` key).
> I could not get paramiko to reset the ssh connection (to swap from
> password-based auth to public-private key auth) without throwing
> an error. As a result, the playbook has to be executed twice
> to get it setup.
  
```shell script
ansible-playbook -i hosts site.yml -c paramiko --ask-pass
# This should fail with the following error
ERROR! Unexpected Exception, this is probably a bug: 'Connection' object has no attribute 'ssh'
```

For subsequent runs, or when setting up Ubuntu, you can simply execute
```shell script
ansible-playbook -i hosts site.yml
```

### supplying extra variables

You can supply extra variables at execution by calling providing the `--extra-vars`
flag when executing `ansible-playbook`. For example:
```shell script
ansible-playbook -i hosts site.yml --extra-vars "my_custom_var=my_custom_value"
```

### execute specific plays or tasks

If you want to execute specific plays or tasks, then use tags.
For example the command below will execute all the plays in
common because the role was tagged as `common`
```shell script
ansible-playbook -i hosts site.yml --tags "common"
# Or as a specific user with a become password
ansible-playbook -i hosts site.yml --tags "common" --user ubuntu --ask-become-pass
```

### execute playbook with different user or private key

```shell script
ansible-playbook -i hosts -u root --private-key="<>" site.yml 
```

### debugging

For debugging use the `-vvv` flag to print verbose messages during execution. 

Print all facts
```shell script
ansible -i hosts <hosts: all, knode0, etc> -m setup
```

### setup certs

https://certbot.eff.org/instructions


[setup_sd_card]: https://garywoodfine.com/how-to-create-raspbian-sd-card-ubuntu/
[raspbian_buster]: https://www.raspberrypi.org/downloads/raspbian/
[ubuntu2004]: https://ubuntu.com/download/server/arm
