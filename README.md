# Ubuntu Sandbox

Linux training for interns on Ubuntu 22.04

## Build & Run

```
docker build -t ubuntu-sandbox:latest .
docker run -d -p 2222:22 ubuntu-sandbox:latest
```

## Login

Pre-created users:

| User | Password |
|------|----------|
| intern1 | intern123 |
| intern2 | intern123 |
| intern3 | intern123 |

```
ssh intern1@localhost -p 2222
```

## Installed Tools

- openssh, sudo, git
- python3, python3-pip
- curl, wget, build-essential
- net-tools, iputils-ping, tree, htop

No vim, nano, vi

## Audit Logs

Login/logout recorded to `/var/log/audit/sessions.log`

View:
```
docker exec <container-id> cat /var/log/audit/sessions.log
```

## Shared Directory

`/shared` - common workspace (chmod 1777)

## Versioning

Edit `VERSION` file to update. GitHub Actions auto-builds & pushes tags.

Current version: 1.0.0
