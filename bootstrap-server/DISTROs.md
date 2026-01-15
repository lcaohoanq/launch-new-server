# Template LXC

## Debian 12

Name: **debian-12-standard_12.12-1_amd64.tar.zst**

- Already install OpennSSH server, can ssh directly
  
```zsh
❯ nmap 192.168.88.107
Starting Nmap 7.95 ( https://nmap.org ) at 2026-01-15 09:21 +07
Nmap scan report for debian12-experiment.lan (192.168.88.107)
Host is up (0.010s latency).
Not shown: 999 closed tcp ports (conn-refused)
PORT   STATE SERVICE
22/tcp open  ssh

Nmap done: 1 IP address (1 host up) scanned in 0.17 seconds
```

- SSH service name is `ssh`
- Firewall is `ufw`

## Centos 9

Name: **centos-9-stream-default_20240828_amd64.tar.xz**

- Need to **install OpenSSH server manually**. Before install, i check with nmap and not found any port open

```zsh
❯ nmap 192.168.77.177
Starting Nmap 7.95 ( https://nmap.org ) at 2026-01-15 09:19 +07
Note: Host seems down. If it is really up, but blocking our ping probes, try -Pn
Nmap done: 1 IP address (0 hosts up) scanned in 3.02 seconds
```

```zsh
yum –y install openssh-server openssh-clients
systemctl enable sshd
systemctl start sshd
systemctl status sshd
```

- Ater install, check with nmap again, found port 22 open

```zsh
❯ nmap 192.168.88.177
Starting Nmap 7.95 ( https://nmap.org ) at 2026-01-15 09:22 +07
Nmap scan report for centos.lan (192.168.88.177)
Host is up (0.0060s latency).
Not shown: 999 closed tcp ports (conn-refused)
PORT   STATE SERVICE
22/tcp open  ssh

Nmap done: 1 IP address (1 host up) scanned in 0.14 seconds
```

Ping check with ansible:

```zsh
❯ ansible servers -m ping -i inventory
debian12 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
centos9 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

- SSH service name is `sshd`
- Firewall is `firewalld`

## Ubuntu 24.04

Name: **ubuntu-24.04-standard_24.04-2_amd64.tar.zst**

## Alpine 3.22

Name: **alpine-3.22-default_20250617_amd64.tar.xz**
