{
  perSystem = { pkgs, config, ... }: {
    devShells.default = pkgs.mkShell {
      inputsFrom = [
        config.terranix.terranixConfigurations.default.result.devShell
      ];
    };
  };
}
