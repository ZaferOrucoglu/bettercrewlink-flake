{
  description = "Nix flake for BetterCrewLink";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = nixpkgs.legacyPackages;
    in
    {
      packages = forAllSystems (system: {
        bettercrewlink = pkgsFor.${system}.callPackage ./package.nix { };
        default = self.packages.${system}.bettercrewlink;
      });

      apps = forAllSystems (system: {
        bettercrewlink = {
          type = "app";
          program = "${self.packages.${system}.bettercrewlink}/bin/bettercrewlink";
          meta = {
            description = "BetterCrewLink";
          };
        };
        default = self.apps.${system}.bettercrewlink;
      });

      overlays.default = final: prev: {
        bettercrewlink = self.packages.${final.system}.bettercrewlink;
      };

      nixosModules.default = { pkgs, ... }: {
        environment.systemPackages = [
          self.packages.${pkgs.stdenv.hostPlatform.system}.bettercrewlink
        ];
      };
    };
}
