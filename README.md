# Ubuntu Sandbox 22.04

Linux basics training environment for interns.

## Build

```bash
docker build -t ubuntu-sandbox:22.04 .
```

## Run

```bash
docker run -d -p 2222:22 ubuntu-sandbox:22.04
```

## First Login

```bash
ssh yourname@localhost -p 2222
```

On first login:
1. SSH asks for password (any password)
2. Container shows registration form
3. Confirm username and set password
4. User account auto-created
5. You're logged in to bash

## Audit Logging

All sessions logged to `/var/log/audit/sessions.log`
- Login time
- Registration event
- Logout time

View logs:
```bash
docker exec <container_id> cat /var/log/audit/sessions.log
```

## Features

- Ubuntu 22.04
- SSH with password auth (PermitRootLogin disabled)
- Auto-register on first login
- Audit logging for all sessions
- User home directories auto-created
- Shared `/shared` directory
- Essential tools: python3, git, build-essential, etc.
