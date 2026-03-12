{ inputs, ... }:
{
  perSystem = { pkgs, config, lib, ... }:
    let
      tfConfig = inputs.terranix.lib.terranixConfiguration {
        inherit pkgs;
        modules = [
          ../../modules/terranix
          { provider.nomad.address = lib.mkForce "http://server:4646"; }
        ];
      };
      tfScripts = config.terranix.terranixConfigurations.default.result.scripts;
    in
    {
      # VM fails to boot successfully on `aarch64-linux`
      checks = lib.mkIf (pkgs.stdenv.isLinux && !pkgs.stdenv.isAarch64) {
        integration = pkgs.testers.runNixOSTest (import ../../tests/integration.nix {
          inherit inputs tfScripts tfConfig;
        });
      };
    };
}
