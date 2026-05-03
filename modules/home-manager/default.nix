{ config, lib, pkgs, ... }:

let
  cfg = config.programs.helium;

  configDir = "${config.xdg.configHome}/helium";
in
{
  options.programs.helium = {
    enable = lib.mkEnableOption "Helium Browser";

    package = lib.mkPackageOption pkgs "helium" { };

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
    home.packages = [ cfg.package ];

    home.file = lib.optionalAttrs (cfg.policies != { }) {
      "${configDir}/policies/managed/nixos.json" = {
        text = builtins.toJSON cfg.policies;
      };
    };
  };
}
