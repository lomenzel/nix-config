{
  config,
  pkgs,
  secrets,
  inputs,
  ...
}:
{

  # systemd.services.comfy = {
  #   description = "ComfyUI";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     ExecStart = "${nix-ai-stuff.comfyui}/bin/comfyui";
  #     WorkingDirectory = "/mnt/snd/ai/comfy";
  #   };
  # };

  services.comfyui = {
    enable = true;
    home = "/mnt/server/comfyui";
    host = "localhost";
    acceleration = "cuda";
    customNodes = pkgs.comfyui.pkgs;
    models = builtins.attrValues inputs.nixified-ai.models;
  };

  services.nginx.virtualHosts."image.ai.menzel.lol" = {
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.comfyui.port}";
      proxyWebsockets = true;
    };
  };
}
