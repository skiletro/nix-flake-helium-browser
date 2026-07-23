# nix-flake-helium-browser

## Quick Start

```bash
git clone https://github.com/skiletro/nix-flake-helium-browser.git
cd nix-flake-helium-browser
nix build
nix run .
```

## NixOS Module

```nix
{ inputs, ... }: {
  imports = [ inputs.helium-flake.nixosModules.default ];

  programs.helium = {
    enable = true;
    flags = [ "--ozone-platform-hint=auto" ];
    policies = {
      "BrowserSignin" = 0;
      "PasswordManagerEnabled" = false;
      "SyncDisabled" = true;
    };
  };
}
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `programs.helium.enable` | `bool` | `false` | Install Helium system-wide |
| `programs.helium.package` | `package` | `pkgs.helium` | The Helium package to use |
| `programs.helium.flags` | `list of str` | `[]` | Command-line flags added to the wrapper |
| `programs.helium.policies` | `attrs` | `{}` | Policies written to `/etc/chromium/policies/managed/` |

### Policies

Policies are written to `/etc/chromium/policies/managed/helium-nixos.json` and `/etc/helium/policies/managed/helium-nixos.json`.

See the [Chrome Enterprise Policy List](https://cloud.google.com/docs/chrome-enterprise/policies/) for all available policies.

## Home Manager Module

```nix
{ inputs, ... }: {
  imports = [ inputs.helium-flake.homeModules.default ];

  programs.helium = {
    enable = true;
    flags = [ "--enable-features=TouchpadOverscrollHistoryNavigation" ];
  };
}
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `programs.helium.enable` | `bool` | `false` | Enable Helium for user |
| `programs.helium.package` | `package` | `pkgs.helium` | The Helium package to use |
| `programs.helium.flags` | `list of str` | `[]` | Command-line flags added to the wrapper |
| `programs.helium.policies` | `attrs` | `{}` | User policies written to `~/.config/helium/policies/managed/nixos.json` |

> User-level policies may not work reliably. Use the **NixOS module** for critical policies.

## Persistent Flags

Declarative (bakes flags into the wrapper):
```nix
programs.helium.flags = [ "--ozone-platform-hint=auto" ];
```

Config file (read by wrapper script at runtime):
- System: `/etc/helium-flags.conf`
- User: `~/.config/helium-flags.conf`

One flag per line, `#` for comments.

## License

GPL-3.0. See [LICENSE](LICENSE).

## Links

- [Helium Website](https://helium.computer)
- [Helium GitHub](https://github.com/imputnet/helium)
- [Helium Linux GitHub](https://github.com/imputnet/helium-linux)
