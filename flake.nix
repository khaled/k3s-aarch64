{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    os = system: hostSystem:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({
            modulesPath,
            pkgs,
            lib,
            ...
          }: {
            imports = [
              "${modulesPath}/virtualisation/qemu-vm.nix"
            ];
            environment.systemPackages = with pkgs; [fd k9s];
            virtualisation.host.pkgs = nixpkgs.legacyPackages.${hostSystem};
            virtualisation.graphics = false;
            virtualisation.diskSize = 2048;
            services.getty.autologinUser = "root";
            users.users.root.initialPassword = "root";
            services.k3s.enable = true;
          })
        ];
      };
  in {
    packages.aarch64-darwin.default = (os "aarch64-linux" "aarch64-darwin").config.system.build.vm;
    packages.aarch64-linux.default = (os "aarch64-linux" "aarch64-linux").config.system.build.vm;
    packages.x86_64-linux.default = (os "x86_64-linux" "x86_64-linux").config.system.build.vm;
  };
}
