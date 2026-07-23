{ config, lib, pkgs, ... }:

let
  cfg = config.programs.helium;

  configDir = "${config.xdg.configHome}/helium";

  heliumPkg = if cfg.withWidevine then pkgs.helium-wv else cfg.package;

  packageWithFlags = heliumPkg.override { inherit (cfg) flags; };
in
{
  options.programs.helium = {
    enable = lib.mkEnableOption "Helium Browser";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The Helium package to use.";
      default = pkgs.callPackage ../../helium.nix { widevine-cdm = null; };
      defaultText = "The helium package from this flake";
    };

    withWidevine = lib.mkEnableOption "Widevine DRM support (uses helium-wv package)";

    flags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--enable-features=TouchpadOverscrollHistoryNavigation" "--start-maximized" ];
      description = ''
        Additional command-line flags passed to Helium.

        These are added directly to the wrapped binary, so they will always be applied.
        For user-specific flags that you don't want managed by Nix, consider using {file}`~/.config/helium-browser-flags.conf` instead.
      '';
    };

    policies = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      example = lib.literalExpression ''
        {
          "BrowserSignin" = 0;
          "PasswordManagerEnabled" = false;
        }
      '';
      description = ''
        User policies written to {file}`~/.config/helium/policies/managed/nixos.json`.

        Note: Chromium-based browsers may not read user-level policies reliably.
        For critical policies, use the NixOS module instead.

        Policy list: https://cloud.google.com/docs/chrome-enterprise/policies/
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ packageWithFlags ];

    home.file = lib.optionalAttrs (cfg.policies != { }) {
      "${configDir}/policies/managed/nixos.json" = {
        text = builtins.toJSON cfg.policies;
      };
    };
  };
}
