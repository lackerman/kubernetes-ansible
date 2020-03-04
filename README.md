# RPi K3s cluster playbook

## manual steps

- [setup the Raspberry Pi sd cards][setup_sd_card]
  > Make sure to use the [Raspbian Buster image][raspbian_buster]
  - enable `ssh` before booting the RPis
    - Add a file called `ssh` to the `boot` partition which should
      be mounted after re-inserting the SD card into your card reader.
      > In the case of Mac, open a terminal and enter `touch /Volumes/boot/ssh`

## ansible helper commands

This playbook sets up a k3s cluster on the specified hosts. 

In order to validate the playbook, execute the following:
```shell script
ansible-playbook -i hosts site.yml --check -K
```

To run the playbook, execute:
```shell script
ansible-playbook -i hosts site.yml -K
```

You can supply extra variables at execution by calling providing the `--extra-vars`
flag when executing `ansible-playbook`. For example:
```shell script
ansible-playbook -i hosts site.yml \
    --extra-vars "cluster_secret=$(openssl rand -base64 32)"
    -K
```

Execute a specific task? Then use tags. For example
the command below will execute all the plays in common because
the role was tagged as `common`
```shell script
ansible-playbook -i hosts site.yml -K --tags "common"
```

### Setup certs

https://certbot.eff.org/instructions

[setup_sd_card]: https://garywoodfine.com/how-to-create-raspbian-sd-card-ubuntu/
[raspbian_buster]: https://www.raspberrypi.org/downloads/raspbian/

