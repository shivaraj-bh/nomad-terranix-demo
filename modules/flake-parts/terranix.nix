{ inputs, ... }:
{
  imports = [
    inputs.terranix.flakeModule
  ];
  perSystem = { pkgs, lib, ... }: {
    nixpkgs = {
      config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "terraform"
        "nomad"
      ];
    };
    terranix = {
      # Imported using `pkgs.mkShell.inputsFrom` in `devShells.default`
      exportDevShells = false;
      terranixConfigurations.default = {
        terraformWrapper.package = pkgs.terraform.withPlugins (p: [ p.hashicorp_nomad ]);
        modules = [ ../../modules/terranix ];
        workdir = "tf-default-workdir";
      };
    };
  };
}
