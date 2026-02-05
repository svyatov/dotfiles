# Server Shell Configuration

Lightweight shell configurations for remote and server environments. Two tiers: base (all users) and admin (sudo users).

## Features

- **Dynamic color prompt** - Changes color by privilege level (green=user, magenta=sudo, red=root)
- **Directory jump system** - Persistent bookmarks stored as symlinks
- **Safe alias system** - Prevents accidentally shadowing existing commands
- **Package manager aliases** - Auto-detects APT, DNF, or YUM
- **System administration shortcuts** - Services, configs, logs
- **Server vim config** - Sensible defaults applied to all vim commands

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/svyatov/dotfiles/master/servers/install.sh | bash
```

The installer will:
- Download configuration files to `~/.config/svyatov/`
- Ask if you want admin aliases (if you have sudo access)
- Configure your `.bashrc` automatically

After installation, run `source ~/.bashrc` or start a new shell.

## Command Reference

### Navigation & Files

| Alias | Command | Description |
|-------|---------|-------------|
| `l` | `ls -laGh` | List all files with details |
| `h` | `cd ~` | Go to home directory |
| `u` | `cd ..` | Go up one directory |
| `b` | `cd -` | Go to previous directory |
| `q` | `exit` | Exit shell |
| `c` | `clear` | Clear screen |
| `cl` | `clear && l` | Clear and list |
| `v` | `vim -u ~/.config/svyatov/vimrc` | Open vim with server config |
| `sv` | `sudo vim -u ~/.config/svyatov/vimrc` | Sudo vim with server config |
| `duo` | `du . --max-depth=1 -h \| sort -h` | Disk usage sorted by size |
| `dum` | `duo \| tail` | Top disk usage |

### Jump System (Directory Bookmarks)

| Command | Description |
|---------|-------------|
| `j <name>` | Jump to bookmark |
| `ja <name>` | Add current directory as bookmark |
| `jd <name>` | Delete bookmark |
| `jl` | List all bookmarks |
| `jb` | Jump back to previous location |

Bookmarks are stored as symlinks in `~/.config/svyatov/jump_shortcuts/`.

**Example:**
```bash
cd /var/www/myproject
ja proj          # Create bookmark
cd /tmp          # Go somewhere else
j proj           # Jump back to /var/www/myproject
jb               # Return to /tmp
```

### Functions

| Function | Description |
|----------|-------------|
| `mkcd <dir>` | Create directory and cd into it |
| `lt [path]` | List files sorted by time (newest last) |
| `psgrep <pattern>` | Search running processes |
| `hgrep <pattern>` | Search command history |

### Shell Management

| Alias | Description |
|-------|-------------|
| `vb` | Edit ~/.bashrc |
| `sb` | Source ~/.bashrc |
| `vsa` | Edit ~/.config/svyatov/aliases |
| `ssa` | Source ~/.config/svyatov/aliases |
| `shrl` | Reload shell (`exec $SHELL -l`) |
| `ct` | Edit crontab |

### Admin Commands

*Available when using admin aliases*

#### Package Management (Auto-detects APT/DNF/YUM)

| Alias | APT | DNF/YUM | Description |
|-------|-----|---------|-------------|
| `agi <pkg>` | `apt-get install -y` | `dnf/yum install -y` | Install package |
| `agu` | `apt-get update` | `dnf/yum check-update` | Update package list |
| `agg` | `apt-get upgrade -uV` | `dnf/yum upgrade -y` | Upgrade packages |
| `agr <pkg>` | `apt-get remove` | `dnf/yum remove` | Remove package |
| `acf <term>` | `apt-cache search` | `dnf/yum search` | Search packages |
| `acs <pkg>` | `apt-cache show` | `dnf/yum info` | Show package info |

**APT-only aliases:**

| Alias | Command | Description |
|-------|---------|-------------|
| `agdu` | `apt-get dist-upgrade` | Distribution upgrade |
| `aguu` | `agu && agg` | Update and upgrade |
| `addrepo` | `add-apt-repository` | Add repository |
| `agp <pkg>` | `apt-get purge` | Purge package (remove + configs) |
| `agcl <pkg>` | `apt-get changelog` | Show package changelog |
| `agc` | `apt-get clean` | Clean package cache |
| `agar` | `apt-get autoremove` | Remove unused packages |

#### System Administration

| Alias | Description |
|-------|-------------|
| `s` | Run command with sudo (auto-detects if needed) |
| `r` | Switch to root (`s su -`) |
| `n` | Show network connections (`netstat -tulpen`) |
| `ne` | Show external network connections only |
| `i` | Show iptables rules |
| `t` | Attach or create tmux session |
| `ssr <cmd>` | Service management via systemctl (or legacy service) |

#### Config Directory Shortcuts

| Alias | Directory |
|-------|-----------|
| `lgrt` | `/etc/logrotate.d` |
| `logs` | `/var/log` |

#### User Management

| Alias | Description |
|-------|-------------|
| `au` | Add user |
| `aunop` | Add user without password |

#### UFW (Uncomplicated Firewall)

*Only available when UFW is installed*

| Alias | Command | Description |
|-------|---------|-------------|
| `ufs` | `ufw status verbose` | Show firewall status |
| `ufe` | `ufw enable` | Enable firewall |
| `ufd` | `ufw disable` | Disable firewall |
| `ufap <port>` | `ufw allow <port>` | Allow port |
| `ufaf <ip>` | `ufw allow from <ip>` | Allow from IP address |
| `ufdp <port>` | `ufw deny <port>` | Deny port |
| `ufdel <num>` | `ufw delete <num>` | Delete rule by number |
| `ufr` | `ufw reload` | Reload firewall rules |
| `ufn` | `ufw status numbered` | Show numbered rule list |

#### Docker

*Only available when Docker is installed*

| Alias | Command | Description |
|-------|---------|-------------|
| `dk` | `docker` | Docker command |
| `dkps` | `docker ps` | List running containers |
| `dkpsa` | `docker ps -a` | List all containers |
| `dki` | `docker images` | List images |
| `dkl` | `docker logs` | Show container logs |
| `dklf` | `docker logs -f` | Follow container logs |
| `dkx` | `docker exec -it` | Execute interactive command |
| `dkr` | `docker run -it --rm` | Run interactive, auto-remove |
| `dkst` | `docker stop` | Stop container |
| `dkrm` | `docker rm` | Remove container |
| `dkrmi` | `docker rmi` | Remove image |
| `dkpr` | `docker system prune -f` | Prune unused data |
| `dkpra` | `docker system prune -af` | Prune all unused (including images) |

#### Docker Compose

*Only available when Docker Compose is installed (v1 or v2)*

| Alias | Command | Description |
|-------|---------|-------------|
| `dcp` | `docker compose` | Docker Compose command |
| `dcup` | `docker compose up -d` | Start services (detached) |
| `dcdn` | `docker compose down` | Stop and remove services |
| `dcr` | `docker compose restart` | Restart services |
| `dcl` | `docker compose logs` | Show logs |
| `dclf` | `docker compose logs -f` | Follow logs |
| `dcps` | `docker compose ps` | List services |
| `dcx` | `docker compose exec` | Execute command in service |
| `dcb` | `docker compose build` | Build services |
| `dcpl` | `docker compose pull` | Pull service images |

#### Kernel Management

| Command | Description |
|---------|-------------|
| `remove-old-kernels` | Remove old kernel packages (with confirmation) |
| `change-default-editor` | Change system default editor |

### Admin Shell Management

| Alias | Description |
|-------|-------------|
| `vsaa` | Edit ~/.config/svyatov/admin_aliases |
| `ssaa` | Source ~/.config/svyatov/admin_aliases |

## Customization

### Adding Your Own Aliases

Edit your local aliases file:

```bash
vim ~/.bashrc  # Add at the end, after sourcing svyatov aliases
```

Or create a separate file and source it from `.bashrc`.

### Modifying the Prompt

The prompt color changes based on privilege level. Edit the color variables at the top of `~/.config/svyatov/aliases`:

```bash
ROOT_COLOR=$LIGHT_RED       # Red for root
SUDO_COLOR=$LIGHT_MAGENTA   # Magenta for sudo users
USER_COLOR=$GREEN           # Green for regular users
```

### Safe Alias System

Use `safe_alias` instead of `alias` to prevent overwriting existing commands:

```bash
safe_alias myalias 'my command'           # Only creates if 'myalias' doesn't exist
safe_alias myalias 'my command' 'override' # Forces creation
```

## Updating

Update to the latest version:

```bash
update_svyatov_config
```

This command auto-detects whether you have admin access and downloads the appropriate files.

## Troubleshooting

### Alias 'l' Not Working

**Problem:** `Unable to create alias: l is aliased to 'ls -CF'`

**Cause:** Ubuntu/Debian's default `.bashrc` defines `alias l='ls -CF'` which conflicts with ours.

**Solution:** The install command automatically comments out the conflicting alias. If you installed manually, run:

```bash
sed -i.bak 's/^alias l=/#alias l=/' ~/.bashrc
source ~/.bashrc
```

### Jump Shortcuts Not Completing

**Problem:** Tab completion for `j` or `jd` doesn't show available shortcuts.

**Solution:** Ensure the jump shortcuts directory exists:

```bash
mkdir -p ~/.config/svyatov/jump_shortcuts
```

### Package Manager Aliases Not Working

**Problem:** Package manager aliases like `agi` don't work.

**Cause:** Either the package manager isn't installed or you're using the wrong distro's commands.

**Solution:** The admin aliases auto-detect your package manager. Check which one is active:

```bash
type agi  # Shows what 'agi' is aliased to
```

If no package manager was detected, the aliases won't be created.

### Prompt Not Changing Color

**Problem:** Prompt stays the same color regardless of privileges.

**Cause:** The prompt is set when aliases are sourced.

**Solution:** Reload the shell after gaining/losing sudo access:

```bash
shrl  # or: exec $SHELL -l
```

### Command Not Found After Installing Alias

**Problem:** New alias works, but original command is not found.

**Cause:** You may have used `safe_alias` on an existing command name.

**Solution:** Check what the alias points to:

```bash
type <alias_name>
alias <alias_name>
```

To use the original command, escape it: `\command` or use full path `/usr/bin/command`.

## Files

| File | Description |
|------|-------------|
| `~/.config/svyatov/aliases` | Base aliases, functions, prompt, jump system |
| `~/.config/svyatov/admin_aliases` | Admin extensions (sources aliases) |
| `~/.config/svyatov/vimrc` | Minimal vim config for servers |
| `~/.config/svyatov/jump_shortcuts/` | Directory bookmark symlinks |
| `~/.config/svyatov/README.md` | Pointer to this documentation |
