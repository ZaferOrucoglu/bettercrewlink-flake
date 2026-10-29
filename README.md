# BetterCrewLink Flake

Nix flake for [BetterCrewLink](https://github.com/OhMyGuus/BetterCrewLink) (proximity voice chat for Among Us).

Includes an automated GitHub Action that checks daily for new upstream releases, updates the derivation hash, and verifies the build.

## Usage

### Direct Run
```bash
nix run github:ZaferOrucoglu/bettercrewlink-flake
```

### In NixOS Configuration (`flake.nix`)

Add as an input:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bettercrewlink.url = "github:ZaferOrucoglu/bettercrewlink-flake";
  };

  outputs = { self, nixpkgs, bettercrewlink, ... }@inputs: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            bettercrewlink.packages.${pkgs.system}.default
          ];
        })
      ];
    };
  };
}
```

### Overlay
You can also use `bettercrewlink.overlays.default` to add `pkgs.bettercrewlink` to your nixpkgs instance.
