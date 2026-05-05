<center>
    <img src="helium-logo.png" title="Helium" alt="Логотип Helium" width="120" />
    <h1>⚛️ Helium Browser — Nix Flake</h1>
    <p>
        🔒 Приватный, быстрый и честный веб-браузер на базе Chromium
        <br>
        📦 Упакован как Nix flake с поддержкой модулей NixOS, Home Manager и оверлеев
    </p>
    <p>
        <a href="https://helium.computer/">🌐 helium.computer</a> ·
        <a href="https://github.com/imputnet/helium">📦 Исходный код Helium</a> ·
        <a href="https://github.com/imputnet/helium-linux/releases">⬇️ Релизы</a> ·
        <a href="https://github.com/oxcl/nix-flake-helium-browser">📦 Этот Flake</a>
    </p>
    <p>
        🌐 <a href="README.md">English</a> ·
        <strong>Русский</strong> ·
        <a href="README.zh.md">中文</a>
    </p>
</center>

---

## ✨ Как это работает

Этот flake **НЕ собирает Helium из исходников**. Вместо этого:

1. 📥 Загружает готовые `.deb` пакеты из [релизов imputnet/helium-linux](https://github.com/imputnet/helium-linux/releases)
2. 📦 Извлекает `.deb` с помощью `dpkg` и `ar`
3. 🔧 Патчит ELF-бинарники через `patchelf` для использования Nix-библиотек
4. 🎁 Оборачивает браузер через `wrapGAppsHook` для корректной интеграции с GTK/рабочим столом
5. 📝 Устанавливает desktop-файлы и иконки для системной интеграции

Этот подход аналогичен тому, как [Vivaldi](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/vivaldi/default.nix) и [Brave](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/brave/default.nix) упаковываются в nixpkgs.

---

## 🎯 Возможности

- ✅ **Модуль NixOS** — Декларативная системная конфигурация через `programs.helium`
- ✅ **Модуль Home Manager** — Конфигурация на уровне пользователя
- ✅ **Оверлей** — Предоставляет `pkgs.helium` в вашем экземпляре Nixpkgs
- ✅ **Поддержка флагов** — Декларативные аргументы командной строки через `programs.helium.flags`
- ✅ **Поддержка политик** — Полная поддержка Chrome Enterprise политик через `/etc/chromium/policies/managed/`
- ✅ **Мультиархитектурность** — Поддержка `x86_64-linux` и `aarch64-linux`
- ✅ **Готов к Wayland** — Включает `--ozone-platform-hint=auto` для нативной поддержки Wayland

---

## 📂 Структура репозитория

```
├── flake.nix                  # Определение flake со всеми выходами
├── helium.nix                  # Вывод пакета (переупаковка .deb)
├── overlay.nix                 # Оверлей Nixpkgs
├── LICENSE                     # Лицензия GPL-3.0
├── README.md                   # Документация (английский)
├── README.ru.md                # Документация (русский)
├── README.zh.md                # Документация (китайский)
├── helium-logo.png            # Логотип Helium
└── modules/
    ├── nixos/
    │   └── default.nix        # Модуль NixOS
    └── home-manager/
        └── default.nix        # Модуль Home Manager
```

---

## 🚀 Быстрый старт

### Требования

- **Nix** с включёнными flakes (NixOS 22.05+ или включите экспериментальные функции `nix-command` и `flakes`)
- **Linux** (x86_64 или aarch64)

### Клонирование и сборка

```bash
# Клонировать репозиторий
git clone https://github.com/oxcl/nix-flake-helium-browser.git
cd nix-flake-helium-browser

# Собрать Helium
nix build

# Запустить напрямую
nix run .

# Открыть оболочку с helium
nix shell .
```

---

## 📦 Выходы Flake

### Пакеты

```bash
# Собрать пакет
nix build .#helium

# Запустить через app
nix run .
```

### Приложения

```bash
nix run .
```

---

## 🔧 Использование оверлея

Оверлей предоставляет `pkgs.helium` в вашем экземпляре Nixpkgs:

### В конфигурации на основе flake (`flake.nix`):

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

### В традиционном `configuration.nix`:

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

## 🖥️ Использование модуля NixOS

Модуль NixOS предоставляет декларативную конфигурацию через `programs.helium` с **полной поддержкой политик**:

```nix
{ config, pkgs, ... }:

{
  imports = [
    (import (fetchTarball "https://github.com/oxcl/nix-flake-helium-browser/archive/main.tar.gz")).nixosModules.default
    # Или при использовании flakes: inputs.helium-flake.nixosModules.default
  ];

  programs.helium = {
    enable = true;

    # Опционально: переопределить пакет
    # package = pkgs.helium;

    # 🚩 Флаги — Аргументы командной строки, всегда передаваемые в Helium
    flags = [
      "--disable-gpu"
      "--ozone-platform-hint=auto"
    ];

    # 🎯 Политики — Записываются в /etc/chromium/policies/managed/helium-nixos.json
    # Также записываются в /etc/helium/policies/managed/ для будущей совместимости
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

### Доступные опции (модуль NixOS)

| Опция | Тип | По умолчанию | Описание |
|--------|------|---------|-------------|
| `programs.helium.enable` | `bool` | `false` | Установить Helium системно |
| `programs.helium.package` | `package` | `pkgs.helium` | Используемый пакет Helium |
| `programs.helium.flags` | `list of str` | `[]` | Флаги командной строки, добавляемые в обёртку |
| `programs.helium.policies` | `attrs` | `{}` | Политики, записываемые в `/etc/chromium/policies/managed/` |

### 📋 Документация по политикам

Helium (как браузер на базе Chromium) читает политики из `/etc/chromium/policies/managed/` в Linux. Этот flake записывает политики в оба пути:
- `/etc/chromium/policies/managed/helium-nixos.json` (текущий путь Chromium)
- `/etc/helium/policies/managed/helium-nixos.json` (будущий путь Helium)

Смотрите [список политик Chrome Enterprise](https://cloud.google.com/docs/chrome-enterprise/policies/) для всех доступных политик.

**Распространённые политики:**
```nix
{
  "BrowserSignin" = 0;                                    # Отключить вход в браузер
  "PasswordManagerEnabled" = false;                        # Отключить менеджер паролей
  "SyncDisabled" = true;                                  # Отключить синхронизацию
  "HomepageLocation" = "https://nixos.org";             # Установить домашнюю страницу
  "DefaultSearchProviderEnabled" = true;
  "DefaultSearchProviderSearchURL" = "https://search.nixos.org/?q={searchTerms}";
  "ExtensionInstallForcelist" = [                          # Предустановить расширения
    "cjpalhdlnbpafiamejdnhcphjbkeiagm"                   # uBlock Origin
  ];
}
```

---

## 🏠 Использование модуля Home Manager

Для конфигурации на уровне пользователя:

```nix
{ config, pkgs, ... }:

{
  imports = [
    (import (fetchTarball "https://github.com/oxcl/nix-flake-helium-browser/archive/main.tar.gz")).homeModules.default
    # Или при использовании flakes: inputs.helium-flake.homeModules.default
  ];

  programs.helium = {
    enable = true;

    # Опционально: переопределить пакет
    # package = pkgs.helium;

    # 🚩 Флаги — Аргументы командной строки, всегда передаваемые в Helium
    flags = [
      "--enable-features=TouchpadOverscrollHistoryNavigation"
      "--start-maximized"
    ];

    # Опционально: пользовательские политики (best-effort, для критичных политик используйте модуль NixOS)
    policies = {
      "BrowserSignin" = 0;
    };
  };
}
```

### Доступные опции (модуль Home Manager)

| Опция | Тип | По умолчанию | Описание |
|--------|------|---------|-------------|
| `programs.helium.enable` | `bool` | `false` | Включить Helium для пользователя |
| `programs.helium.package` | `package` | `pkgs.helium` | Используемый пакет Helium |
| `programs.helium.flags` | `list of str` | `[]` | Флаги командной строки, добавляемые в обёртку |
| `programs.helium.policies` | `attrs` | `{}` | Пользовательские политики, записываемые в `~/.config/helium/policies/managed/nixos.json` |

> **⚠️ Примечание:** Пользовательские политики могут не надёжно читаться браузерами на базе Chromium. Для критичных политик используйте **модуль NixOS**.

---

## 🚩 Постоянные флаги

### Декларативные флаги через Nix (Рекомендуется)

Флаги можно задать декларативно в конфигурации NixOS или Home Manager. Они встраиваются в обёрнутый бинарник:

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

### Флаги через конфигурационные файлы

Helium также поддерживает постоянные флаги через конфигурационные файлы (функция, добавленная пакетоделателями Linux дистрибутивов). Они читаются скриптом обёртки upstream и полезны для пользовательских флагов, которые вы не хотите управлять через Nix:

#### Системные флаги
Создайте `/etc/helium-flags.conf`:
```
# Отключить аппаратное ускорение
--disable-gpu

# Включить Wayland
--ozone-platform-hint=auto
```

#### Пользовательские флаги
Создайте `~/.config/helium-flags.conf`:
```
# Включить навигацию свайпом на тачпаде
--enable-features=TouchpadOverscrollHistoryNavigation

# Запускать в развёрнутом виде
--start-maximized
```

**Формат:** Один флаг на строку, `#` для комментариев. Файл читается скриптом обёртки Helium.

---

## 📄 Лицензия

Упаковка этого flake лицензирована под **GPL-3.0** (см. [LICENSE](LICENSE)).

Helium Browser также лицензирован под GPL-3.0 — см. [imputnet/helium](https://github.com/imputnet/helium).

---

## 🔗 Ссылки

- [🌐 Сайт Helium](https://helium.computer)
- [📦 Helium на GitHub](https://github.com/imputnet/helium)
- [🐧 Helium Linux на GitHub](https://github.com/imputnet/helium-linux)
- [📋 Политики Chrome Enterprise](https://cloud.google.com/docs/chrome-enterprise/policies/)
- [📚 Документация по политикам Chromium](https://www.chromium.org/administrators/)
- [❓ Проблемы Helium](https://github.com/imputnet/helium/issues)
