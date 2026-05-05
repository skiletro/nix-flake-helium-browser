{ config, lib, pkgs, ... }:

let
  cfg = config.programs.helium;

  packageWithFlags = cfg.package.override { inherit (cfg) flags; };
in
{
  options.programs.helium = {
    enable = lib.mkEnableOption "Helium Browser";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The Helium package to use.";
      default = pkgs.callPackage ../../helium.nix { };
      defaultText = "The helium package from this flake";
    };

    flags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--disable-gpu" "--ozone-platform-hint=auto" ];
      description = ''
        Additional command-line flags passed to Helium.

        These are added directly to the wrapped binary, so they will always be applied.
        For user-specific flags, consider using {file}`~/.config/helium-browser-flags.conf` instead.
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
        Policies to write to /etc/chromium/policies/managed/helium-nixos.json.
        Also written to /etc/helium/policies/managed/helium-nixos.json for future compatibility.

        Policy list: https://cloud.google.com/docs/chrome-enterprise/policies/
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ packageWithFlags ];

    environment.etc = lib.optionalAttrs (cfg.policies != { }) {
      "chromium/policies/managed/helium-nixos.json" = {
        text = builtins.toJSON cfg.policies;
      };
      "helium/policies/managed/helium-nixos.json" = {
        text = builtins.toJSON cfg.policies;
      };
    };
  };
}
