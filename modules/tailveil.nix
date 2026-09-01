{
  pkgs,
  config,
  lib,
  ...
}: let
  tailveil =
    (import (pkgs.fetchFromGitLab {
      owner = "SuperTeece";
      repo = "tailveil";
      rev = "eb24348abf149d12143a5b7e25e6f48320ba6ddc";
      hash = "sha256-gaFObqOfLza2tLjKb+81bdfEJl4JhLwn+OmZf2hP14c=";
    })).packages.${
      pkgs.hostPlatform.system
    }.default;
  nodes-txt = pkgs.writeText "nodes.txt" (
    builtins.concatStringsSep "\n" (
      map ({
        name,
        value,
      }: "${name},${value.id},${value.ip-address}") (lib.attrsToList config.services.tailveil.nodes)
    )
  );
  acls = pkgs.writeText "acls.hujson" (
    builtins.toJSON {
      Hosts = lib.mapAttrs (_: value: value.ip-address) config.services.tailveil.nodes;
      Groups = {};
      TagOwners = {};
      ACLs =
        map (rule: {
          Action = rule.action;
          Users = rule.users;
          Ports = rule.ports;
        })
        config.services.tailveil.acls;
    }
  );
in {
  options.services.tailveil = with pkgs.lib.types; {
    enable = lib.mkOption {
      type = bool;
      default = true;
      description = "Enables the tailveil VPN over veilid";
    };
    nodes = lib.mkOption {
      type = attrsOf (submodule {
        options = {
          ip-address = lib.mkOption {
            type = str;
          };
          id = lib.mkOption {
            type = str;
          };
        };
      });
      description = "nodes that land in the nodes.txt";
    };
    key = lib.mkOption {
      type = path;
    };
    acls = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          action = lib.mkOption {
            type = lib.types.enum ["accept"];
            default = "accept";
            description = "Action to take for matching traffic.";
          };

          users = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = ["*"];
            example = ["laptop" "desktop"];
            description = ''
              Source identifiers (hostnames from `nodes`, IPs, or `*`).
            '';
          };

          ports = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = ["*:*"];
            example = ["*:22" "laptop:80,443" "*:60000-61000"];
            description = ''
              Target host and port specification patterns (e.g. `*:22`, `desktop:80,443`, `*:*`).
            '';
          };
        };
      });
      default = [
        {
          action = "accept";
          users = ["*"];
          ports = ["*:*"];
        }
      ];
      description = "Access Control List rules for Tailveil.";
      example = [
        {
          action = "accept";
          users = ["laptop"];
          ports = ["*:22"];
        }
      ];
    };
    dataDir = lib.mkOption {
      type = path;
      default = "/var/lib/tailveil";
    };
    package = lib.mkOption {
      type = package;
      default = tailveil;
    };
  };
  config = lib.mkIf config.services.tailveil.enable {
    systemd.services.tailveil = {
      description = "Tailveil VPN over Veilid, managed by nixos module";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "start-tailveil" ''
          ${config.services.tailveil.package}/bin/tailveil-client start \
            --key ${config.services.tailveil.key} \
            --path ${config.services.tailveil.dataDir} \
            --acl ${acls} --nodes-txt ${nodes-txt}
        '';
      };
    };
  };
}
