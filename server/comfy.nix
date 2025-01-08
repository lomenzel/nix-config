{
  config,
  pkgs,
  secrets,
  nix-ai-stuff,
  ...
}:
{

  systemd.services.comfy = {
    description = "ComfyUI";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${nix-ai-stuff.comfyui}/bin/comfyui";
      WorkingDirectory = "/mnt/snd/ai/comfy";
    };
  };

  services.nginx.virtualHosts."image.ai.menzel.lol" = {
    locations."/" = {
      proxyPass = "http://localhost:8188";
      proxyWebsockets = true;
    };
  };
}
