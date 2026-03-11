# nomad-terranix-demo

terranix module: <https://github.com/shivaraj-bh/nomad-terranix-demo/blob/master/modules/terranix/default.nix>

## Getting Started

Deploy a nomad server with:

```nix
{ lib, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
   "nomad"
  ];
  services.nomad = {
    enable = true;

    settings = {
      datacenter = "dc1";
      server = {
        enabled = true;
        bootstrap_expect = 1;
      };
      client = {
        enabled = true;
        servers = [ "localhost" ];
      };
      plugin.raw_exec.config.enabled = true;
      ui = {
        enabled = true;
      };
    };
  };
}
```

Deploy a job with terraform:

```sh
nix develop
apply
```


