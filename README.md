<center>
    <img src="helium-logo.png" title="Helium" alt="Helium logo" width="120" />
    <h1>⚛️ Helium Browser Nix Flake</h1>
    <p>
        🔒 Private, fast, and honest web browser based on Chromium
        <br>
        📦 Packaged as a Nix flake with NixOS module, Home Manager module, and overlay support
    </p>
    <p>
        <a href="https://helium.computer/">🌐 helium.computer</a> ·
        <a href="https://github.com/imputnet/helium">📦 Helium Source</a> ·
        <a href="https://github.com/imputnet/helium-linux/releases">⬇️ Releases</a> ·
        <a href="https://github.com/oxcl/nix-flake-helium-browser">📦 This Flake</a>
    </p>
    <p>
        🌐 <strong>English</strong> ·
        <a href="README.ru.md">Русский</a> ·
        <a href="README.zh.md">中文</a>
    </p>
</center>

---

## ✨ How it Works

This flake **does NOT build Helium from source**. Instead, it:

1. 📥 Downloads pre-built `.deb` packages from [imputnet/helium-linux releases](https://github.com/imputnet/helium-linux/releases)
2. 📦 Extracts the `.deb` using `dpkg` and `ar`
3. 🔧 Patches the ELF binaries with `patchelf` to use Nix libraries
4. 🎁 Wraps the browser with `wrapGAppsHook` for proper GTK/desktop integration
5. 📝 Installs desktop files and icons for system integration

This approach is similar to how [Vivaldi](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/vivaldi/default.nix) and [Brave](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/brave/default.nix) are packaged in nixpkgs.

---

## 🎯 Features

- ✅ **NixOS Module** - Declarative system-wide configuration with `programs.helium`
- ✅ **Home Manager Module** - User-level configuration
- ✅ **Overlay** - Expose `pkgs.helium` in your Nixpkgs instance
- ✅ **Flags Support** - Declarative command-line flags via `programs.helium.flags`
- ✅ **Policies Support** - Full Chrome Enterprise policy support via `/etc/chromium/policies/managed/`
- ✅ **Multi-Arch** - Supports both `x86_64-linux` and `aarch64-linux`
- ✅ **Wayland Ready** - Includes `--ozone-platform-hint=auto` for native Wayland support

---

## 📂 Repository Structure

```
├── flake.nix                  # Flake definition with all outputs
├── helium.nix                  # Package derivation (repackages .deb)
├── overlay.nix                 # Nixpkgs overlay
├── LICENSE                     # GPL-3.0 License
├── README.md                   # This file (English)
├── README.ru.md                # Russian translation
├── README.zh.md                # Chinese translation
├── helium-logo.png            # Helium logo
└── modules/
    ├── nixos/
    │   └── default.nix        # NixOS module
    └── home-manager/
        └── default.nix        # Home Manager module
```

---

## 🚀 Quick Start

### Prerequisites

- **Nix** with flakes enabled (NixOS 22.05+ or enable `nix-command` and `flakes` experimental features)
- **Linux** (x86_64 or aarch64)

### Clone & Build

```bash
# Clone the repository
git clone https://github.com/oxcl/nix-flake-helium-browser.git
cd nix-flake-helium-browser

# Build Helium
nix build

# Run directly
nix run .

# Open a shell with helium
nix shell .
```

---

## 📦 Flake Outputs

### Packages

```bash
# Build the package
nix build .#helium

# Run via app
nix run .
```

### Apps

```bash
nix run .
```

---

## 🔧 Using the Overlay

The overlay exposes `pkgs.helium` in your Nixpkgs instance:

### In a flake-based configuration (`flake.nix`):

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        helium-flake.url = "github:oxcl/nix-flake-helium-browser";
    helium-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, helium-flake, ... }: {
    nixosConfigurations.my-system = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [ helium-flake.overlays.default ];
          environment.systemPackages = [ pkgs.helium ];
        }
      ];
    };
  };
}
```

### In a traditional `configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import (fetchTarball "https://github.com/oxcl/nix-flake-helium-browser/archive/main.tar.gz")).overlays.default
  ];

  environment.systemPackages = [ pkgs.helium ];
}
```

---

## 🖥️ Using the NixOS Module

The NixOS module provides declarative configuration under `programs.helium` with **full policies support**:

```nix
{ config, pkgs, ... }:

{
  imports = [
    (import (fetchTarball "https://github.com/oxcl/nix-flake-helium-browser/archive/main.tar.gz")).nixosModules.default
    # Or if using flakes: inputs.helium-flake.nixosModules.default
  ];

  programs.helium = {
    enable = true;

    # Optional: override the package
    # package = pkgs.helium;

    # 🚩 Flags - Command-line arguments always passed to Helium
    flags = [
      "--disable-gpu"
      "--ozone-platform-hint=auto"
    ];

    # 🎯 Policies - Written to /etc/chromium/policies/managed/helium-nixos.json
    # Also written to /etc/helium/policies/managed/ for future compatibility
    policies = {
      "BrowserSignin" = 0;
      "PasswordManagerEnabled" = false;
      "SyncDisabled" = true;
      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [ "en-US" ];
    };
  };
}
```

### Available Options (NixOS Module)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `programs.helium.enable` | `bool` | `false` | Install Helium system-wide |
| `programs.helium.package` | `package` | `pkgs.helium` | The Helium package to use |
| `programs.helium.flags` | `list of str` | `[]` | Command-line flags added to the wrapper |
| `programs.helium.policies` | `attrs` | `{}` | Policies written to `/etc/chromium/policies/managed/` |

### 📋 Policy Documentation

Helium (being Chromium-based) reads policies from `/etc/chromium/policies/managed/` on Linux. This flake writes policies to both:
- `/etc/chromium/policies/managed/helium-nixos.json` (current Chromium path)
- `/etc/helium/policies/managed/helium-nixos.json` (future Helium path)

See the [Chrome Enterprise Policy List](https://cloud.google.com/docs/chrome-enterprise/policies/) for all available policies.

**Common policies:**
```nix
{
  "BrowserSignin" = 0;                                    # Disable browser signin
  "PasswordManagerEnabled" = false;                        # Disable password manager
  "SyncDisabled" = true;                                  # Disable sync
  "HomepageLocation" = "https://nixos.org";             # Set homepage
  "DefaultSearchProviderEnabled" = true;
  "DefaultSearchProviderSearchURL" = "https://search.nixos.org/?q={searchTerms}";
  "ExtensionInstallForcelist" = [                          # Pre-install extensions
    "cjpalhdlnbpafiamejdnhcphjbkeiagm"                   # uBlock Origin
  ];
}
```

---

## 🏠 Using the Home Manager Module

For user-level configuration:

```nix
{ config, pkgs, ... }:

{
  imports = [
    (import (fetchTarball "https://github.com/oxcl/nix-flake-helium-browser/archive/main.tar.gz")).homeModules.default
    # Or if using flakes: inputs.helium-flake.homeModules.default
  ];

  programs.helium = {
    enable = true;

    # Optional: override the package
    # package = pkgs.helium;

    # 🚩 Flags - Command-line arguments always passed to Helium
    flags = [
      "--enable-features=TouchpadOverscrollHistoryNavigation"
      "--start-maximized"
    ];

    # Optional: user policies (best-effort, use NixOS module for critical policies)
    policies = {
      "BrowserSignin" = 0;
    };
  };
}
```

### Available Options (Home Manager Module)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `programs.helium.enable` | `bool` | `false` | Enable Helium for user |
| `programs.helium.package` | `package` | `pkgs.helium` | The Helium package to use |
| `programs.helium.flags` | `list of str` | `[]` | Command-line flags added to the wrapper |
| `programs.helium.policies` | `attrs` | `{}` | User policies written to `~/.config/helium/policies/managed/nixos.json` |

> **⚠️ Note:** User-level policies may not be reliably read by Chromium-based browsers. For critical policies, use the **NixOS module** instead.

---

## 🚩 Persistent Flags

### Declarative flags via Nix (Recommended)

Flags can be set declaratively in your NixOS or Home Manager configuration. These are baked into the wrapped binary:

```nix
programs.helium = {
  enable = true;
  flags = [
    "--disable-gpu"
    "--ozone-platform-hint=auto"
    "--start-maximized"
  ];
};
```

### Configuration file flags

Helium also supports persistent flags via configuration files (a feature added by Linux distro packagers). These are read by the upstream wrapper script and are useful for per-user flags you don't want managed by Nix:

#### System-wide flags
Create `/etc/helium-flags.conf`:
```
# Disable hardware acceleration
--disable-gpu

# Enable Wayland
--ozone-platform-hint=auto
```

#### User flags
Create `~/.config/helium-flags.conf`:
```
# Enable touchpad swipe navigation
--enable-features=TouchpadOverscrollHistoryNavigation

# Start maximized
--start-maximized
```

**Format:** One flag per line, `#` for comments. The file is read by Helium's wrapper script.

---

## 📄 License

This flake packaging is licensed under **GPL-3.0** (see [LICENSE](LICENSE)).

Helium Browser is also licensed under GPL-3.0 - see [imputnet/helium](https://github.com/imputnet/helium).

---

## 🔗 Links

- [🌐 Helium Website](https://helium.computer)
- [📦 Helium GitHub](https://github.com/imputnet/helium)
- [🐧 Helium Linux GitHub](https://github.com/imputnet/helium-linux)
- [📋 Chrome Enterprise Policies](https://cloud.google.com/docs/chrome-enterprise/policies/)
- [📚 Chromium Policy Documentation](https://www.chromium.org/administrators/)
- [❓ Helium Issues](https://github.com/imputnet/helium/issues)
