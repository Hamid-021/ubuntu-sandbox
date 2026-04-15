# Ubuntu Sandbox

Linux training env for interns. Ubuntu 22.04

## Build & Run

```
docker build -t ubuntu-sandbox:22.04 .
docker run -d -p 2222:22 ubuntu-sandbox:22.04
```

## Login

```
ssh yourname@localhost -p 2222
ssh yourname@<ip> -p 2222
```

First login will ask for registration. Confirm username, set password. Account gets created.

## Audit Log

Sessions logged to `/var/log/audit/sessions.log`

View logs:
```
docker exec <container> cat /var/log/audit/sessions.log
```

Shows login, registration, logout times.

## What's Installed

- openssh, sudo
- git, python3, python3-pip
- curl, wget
- build-essential
- net-tools, iputils-ping
- tree, htop

No vim, nano, vi.

## Dirs

- `/shared` - shared folder (1777 perms)
- `/var/log/audit/` - session logs
- Each user gets home directory automatically

[My Docker Hub](https://app.docker.com/accounts/rootusr7)

