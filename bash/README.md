# Bash

## Server aliases

### Setup for simple user

1. `$ curl -o ~/.server_aliases "https://raw.github.com/Svyatov/dotfiles/master/bash/.server_aliases"`
2. `$ echo ". ~/.server_aliases" >> "~/.bashrc"`
3. `$ source ~/.bashrc`

-- or by one command --

```shell
curl -o ~/.server_aliases "https://raw.github.com/Svyatov/dotfiles/master/bash/.server_aliases" && echo ". ~/.server_aliases" >> ~/.bashrc && source ~/.bashrc
```

### Setup for admin user (has sudo rights, but not root)

1. `$ curl -o ~/.server_aliases "https://raw.github.com/Svyatov/dotfiles/master/bash/.server_aliases"`
2. `$ curl -o ~/.server_admin_aliases "https://raw.github.com/Svyatov/dotfiles/master/bash/.server_admin_aliases"`
3. `$ echo ". ~/.server_admin_aliases" >> ~/.bashrc`
4. `$ source ~/.bashrc`

-- or by one command --
```shell
curl -o ~/.server_aliases "https://raw.github.com/Svyatov/dotfiles/master/bash/.server_aliases" && curl -o ~/.server_admin_aliases "https://raw.github.com/Svyatov/dotfiles/master/bash/.server_admin_aliases" && echo ". ~/.server_admin_aliases" >> ~/.bashrc && source ~/.bashrc
```

### Updating server aliases

* for simple user: `$ sa_update`
* for admin user: `$ saa_update`
