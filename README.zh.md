<center>
    <img src="helium-logo.png" title="Helium" alt="Helium 标志" width="120" />
    <h1>⚛️ Helium 浏览器 Nix Flake</h1>
    <p>
        🔒 基于 Chromium 的私密、快速且诚实的网络浏览器
        <br>
        📦 打包为 Nix flake，支持 NixOS 模块、Home Manager 模块和 Overlay
    </p>
    <p>
        <a href="https://helium.computer/">🌐 helium.computer</a> ·
        <a href="https://github.com/imputnet/helium">📦 Helium 源码</a> ·
        <a href="https://github.com/imputnet/helium-linux/releases">⬇️ 发行版</a> ·
        <a href="https://github.com/oxcl/nix-flake-helium-browser">📦 本 Flake</a>
    </p>
    <p>
        🌐 <a href="README.md">English</a> ·
        <a href="README.ru.md">Русский</a> ·
        <strong>中文</strong>
    </p>
</center>

---

## ✨ 工作原理

此 flake **不会从源码构建 Helium**。相反，它：

1. 📥 从 [imputnet/helium-linux 发行版](https://github.com/imputnet/helium-linux/releases) 下载预构建的 `.deb` 包
2. 📦 使用 `dpkg` 和 `ar` 提取 `.deb`
3. 🔧 使用 `patchelf` 修补 ELF 二进制文件以使用 Nix 库
4. 🎁 使用 `wrapGAppsHook` 包装浏览器以实现正确的 GTK/桌面集成
5. 📝 安装桌面文件和图标以实现系统集成

这种方法类似于 nixpkgs 中打包 [Vivaldi](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/vivaldi/default.nix) 和 [Brave](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/brave/default.nix) 的方式。

---

## 🎯 功能特性

- ✅ **NixOS 模块** — 通过 `programs.helium` 进行声明式系统级配置
- ✅ **Home Manager 模块** — 用户级配置
- ✅ **Overlay** — 在 Nixpkgs 实例中暴露 `pkgs.helium`
- ✅ **标志支持** — 通过 `programs.helium.flags` 声明式命令行标志
- ✅ **策略支持** — 通过 `/etc/chromium/policies/managed/` 提供完整的 Chrome Enterprise 策略支持
- ✅ **多架构** — 支持 `x86_64-linux` 和 `aarch64-linux`
- ✅ **Wayland 就绪** — 包含 `--ozone-platform-hint=auto` 以支持原生 Wayland

---

## 📂 仓库结构

```
├── flake.nix                  # Flake 定义及所有输出
├── helium.nix                  # 包派生（重新打包 .deb）
├── overlay.nix                 # Nixpkgs overlay
├── LICENSE                     # GPL-3.0 许可证
├── README.md                   # 本文档（英文）
├── README.ru.md                # 本文档（俄文）
├── README.zh.md                # 本文档（中文）
├── helium-logo.png            # Helium 标志
└── modules/
    ├── nixos/
    │   └── default.nix        # NixOS 模块
    └── home-manager/
        └── default.nix        # Home Manager 模块
```

---

## 🚀 快速开始

### 前提条件

- 启用 flakes 功能的 **Nix**（NixOS 22.05+ 或启用 `nix-command` 和 `flakes` 实验性功能）
- **Linux**（x86_64 或 aarch64）

### 克隆与构建

```bash
# 克隆仓库
git clone https://github.com/oxcl/nix-flake-helium-browser.git
cd nix-flake-helium-browser

# 构建 Helium
nix build

# 直接运行
nix run .

# 打开包含 helium 的 shell
nix shell .
```

---

## 📦 Flake 输出

### 包

```bash
# 构建包
nix build .#helium

# 通过 app 运行
nix run .
```

### 应用

```bash
nix run .
```

---

## 🔧 使用 Overlay

Overlay 在您的 Nixpkgs 实例中暴露 `pkgs.helium`：

### 在基于 flake 的配置中（`flake.nix`）：

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

### 在传统 `configuration.nix` 中：

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

## 🖥️ 使用 NixOS 模块

NixOS 模块通过 `programs.helium` 提供声明式配置，并**完全支持策略**：

```nix
{ config, pkgs, ... }:

{
  imports = [
    (import (fetchTarball "https://github.com/oxcl/nix-flake-helium-browser/archive/main.tar.gz")).nixosModules.default
    # 如果使用 flakes：inputs.helium-flake.nixosModules.default
  ];

  programs.helium = {
    enable = true;

    # 可选：覆盖包
    # package = pkgs.helium;

    # 🚩 标志 — 始终传递给 Helium 的命令行参数
    flags = [
      "--disable-gpu"
      "--ozone-platform-hint=auto"
    ];

    # 🎯 策略 — 写入 /etc/chromium/policies/managed/helium-nixos.json
    # 同时写入 /etc/helium/policies/managed/ 以兼容未来版本
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

### 可用选项（NixOS 模块）

| 选项 | 类型 | 默认值 | 描述 |
|--------|------|---------|-------------|
| `programs.helium.enable` | `bool` | `false` | 系统级安装 Helium |
| `programs.helium.package` | `package` | `pkgs.helium` | 使用的 Helium 包 |
| `programs.helium.flags` | `list of str` | `[]` | 添加到包装器的命令行标志 |
| `programs.helium.policies` | `attrs` | `{}` | 写入 `/etc/chromium/policies/managed/` 的策略 |

### 📋 策略文档

Helium（基于 Chromium）在 Linux 上从 `/etc/chromium/policies/managed/` 读取策略。此 flake 将策略写入两个位置：
- `/etc/chromium/policies/managed/helium-nixos.json`（当前 Chromium 路径）
- `/etc/helium/policies/managed/helium-nixos.json`（未来 Helium 路径）

查看 [Chrome Enterprise 策略列表](https://cloud.google.com/docs/chrome-enterprise/policies/) 获取所有可用策略。

**常用策略：**
```nix
{
  "BrowserSignin" = 0;                                    # 禁用浏览器登录
  "PasswordManagerEnabled" = false;                        # 禁用密码管理器
  "SyncDisabled" = true;                                  # 禁用同步
  "HomepageLocation" = "https://nixos.org";             # 设置主页
  "DefaultSearchProviderEnabled" = true;
  "DefaultSearchProviderSearchURL" = "https://search.nixos.org/?q={searchTerms}";
  "ExtensionInstallForcelist" = [                          # 预装扩展
    "cjpalhdlnbpafiamejdnhcphjbkeiagm"                   # uBlock Origin
  ];
}
```

---

## 🏠 使用 Home Manager 模块

用于用户级配置：

```nix
{ config, pkgs, ... }:

{
  imports = [
    (import (fetchTarball "https://github.com/oxcl/nix-flake-helium-browser/archive/main.tar.gz")).homeModules.default
    # 如果使用 flakes：inputs.helium-flake.homeModules.default
  ];

  programs.helium = {
    enable = true;

    # 可选：覆盖包
    # package = pkgs.helium;

    # 🚩 标志 — 始终传递给 Helium 的命令行参数
    flags = [
      "--enable-features=TouchpadOverscrollHistoryNavigation"
      "--start-maximized"
    ];

    # 可选：用户策略（尽力而为，关键策略请使用 NixOS 模块）
    policies = {
      "BrowserSignin" = 0;
    };
  };
}
```

### 可用选项（Home Manager 模块）

| 选项 | 类型 | 默认值 | 描述 |
|--------|------|---------|-------------|
| `programs.helium.enable` | `bool` | `false` | 为用户启用 Helium |
| `programs.helium.package` | `package` | `pkgs.helium` | 使用的 Helium 包 |
| `programs.helium.flags` | `list of str` | `[]` | 添加到包装器的命令行标志 |
| `programs.helium.policies` | `attrs` | `{}` | 用户策略写入 `~/.config/helium/policies/managed/nixos.json` |

> **⚠️ 注意：** 基于 Chromium 的浏览器可能无法可靠读取用户级策略。对于关键策略，请使用 **NixOS 模块**。

---

## 🚩 持久标志

### 通过 Nix 声明式设置标志（推荐）

标志可以在 NixOS 或 Home Manager 配置中以声明方式设置。这些标志会被嵌入到包装后的二进制文件中：

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

### 通过配置文件设置标志

Helium 还支持通过配置文件设置持久标志（由 Linux 发行版打包者添加的功能）。这些标志由上游包装脚本读取，适用于不想通过 Nix 管理的用户级标志：

#### 系统级标志
创建 `/etc/helium-flags.conf`：
```
# 禁用硬件加速
--disable-gpu

# 启用 Wayland
--ozone-platform-hint=auto
```

#### 用户标志
创建 `~/.config/helium-flags.conf`：
```
# 启用触控板滑动导航
--enable-features=TouchpadOverscrollHistoryNavigation

# 启动时最大化
--start-maximized
```

**格式：** 每行一个标志，`#` 用于注释。该文件由 Helium 的包装脚本读取。

---

## 📄 许可证

此 flake 打包采用 **GPL-3.0** 许可证（见 [LICENSE](LICENSE)）。

Helium 浏览器同样采用 GPL-3.0 许可证 — 见 [imputnet/helium](https://github.com/imputnet/helium)。

---

## 🔗 链接

- [🌐 Helium 官网](https://helium.computer)
- [📦 Helium GitHub](https://github.com/imputnet/helium)
- [🐧 Helium Linux GitHub](https://github.com/imputnet/helium-linux)
- [📋 Chrome Enterprise 策略](https://cloud.google.com/docs/chrome-enterprise/policies/)
- [📚 Chromium 策略文档](https://www.chromium.org/administrators/)
- [❓ Helium 问题反馈](https://github.com/imputnet/helium/issues)
