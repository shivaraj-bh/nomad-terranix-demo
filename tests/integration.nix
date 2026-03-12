# NixOS VM test to verify:
# 1. Nomad server starts successfully
# 2. A client VM can deploy a job via terraform
{ inputs, tfScripts, tfConfig }:
{ pkgs, lib, ... }:
{
  name = "nomad-terranix-integration-test";

  nodes = {
    server = {
      services.nomad = {
        enable = true;
        dropPrivileges = false;
        settings = {
          server = {
            enabled = true;
            bootstrap_expect = 1;
          };
          client = {
            enabled = true;
          };
          bind_addr = "0.0.0.0";
          plugin.raw_exec.config.enabled = true;
        };
      };
      networking.firewall.allowedTCPPorts = [ 4646 4647 4648 ];
    };

    client = {
      environment.systemPackages = [ pkgs.curl ];
    };
  };

  testScript = ''
    start_all()

    server.wait_for_unit("nomad.service")
    server.wait_for_open_port(4646)

    # Wait for Nomad server to elect a leader
    server.wait_until_succeeds("nomad server members | grep alive", timeout=30)
    # Wait for a client node to be ready
    server.wait_until_succeeds("nomad node status | grep ready", timeout=30)

    # Verify client VM can reach the Nomad API
    client.wait_until_succeeds("curl -sf http://server:4646/v1/status/leader", timeout=30)

    with subtest("terraform apply deploys nomad job"):
      client.succeed("ln -s ${tfConfig} config.tf.json")
      client.succeed("${lib.getExe tfScripts.init}")
      client.succeed("${lib.getExe tfScripts.apply} -auto-approve")
      # client.succeed("mkdir -p /tmp/tf-workdir")
      # client.succeed("cp ''${terraformConfig} /tmp/tf-workdir/config.tf.json")
      # client.succeed("cd /tmp/tf-workdir && terraform init")
      # client.succeed("cd /tmp/tf-workdir && terraform apply -auto-approve")

    with subtest("nomad job is running"):
      server.wait_until_succeeds("nomad job status foo | grep running", timeout=30)
  '';
}
