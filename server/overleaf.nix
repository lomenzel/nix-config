{
  pkgs,
  config,
  secrets,
  ...
}: {
  virtualisation.oci-containers.overlaf.image = "sharelatex/sharelatex";
}
