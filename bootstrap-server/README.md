# What does this Ansbile playbook do

- Attempt to connect via SSH with `root` user
- Create new user `hoang`, not using `root` user for next SSH
- SSH only key-based, toggle options
- Hardening SSH, no password, no root
- Install, config firewall with ufw
- Install, config fail2ban prevent brute-force

# How can run this

First we need to ssh on our server

```zsh
ssh root@ip
```

If success, then we continue to `ping` from Ansible

```zsh
ansible debian12 -m ping -i inventory
```

If success, receive the **pong**

```zsh
❯ ansible debian12 -m ping -i inventory
debian12 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

If not (in most case), the server default option are disabled the root login SSH, or password login, so we need to manually access to the Server by using console/web panel....

In server we create

```zsh
mkdir -p /root/.ssh
nano /root/.ssh/authorized_keys
```

Then copy `~/.ssh/id_ed25519.pub` into authorized_keys folder

After that set Permission

```zsh
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
```

Finally test ssh using root from local machine again

If success, then we continue to test by using Ansible ping pong, it should work!

Run with dry mode first 

```zsh
ansible-playbook -i inventory site.yml --check
```

If everything look good, run for real

```zsh
ansible-playbook -i inventory site.yml
```
