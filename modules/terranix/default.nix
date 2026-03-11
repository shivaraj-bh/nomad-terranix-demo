{ config, lib, ... }:
{
  provider.nomad = {
    address = "http://localhost:4646";
    region = "global";
  };
  resource.nomad_job.app = {
    jobspec = ''''${file("${./job.json}")}'';
    json = true;
  };
}
