{
  description = "Helium Browser - Private, fast, and honest web browser";

  inputs.nixpkgs.url = "github:numtide/nixpkgs-unfree?ref=nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          helium = pkgs.callPackage ./helium.nix { widevine-cdm = null; };
          helium-wv = pkgs.callPackage ./helium.nix { widevine-cdm = pkgs.widevine-cdm; };
          default = self.packages.${system}.helium;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.helium}/bin/helium";
        };
      });

      overlays.default = import ./overlay.nix;

      nixosModules.default = import ./modules/nixos;

      homeModules.default = import ./modules/home-manager;
    };
}
