{
  pkgs,
  config,
  lib,
  ...
}:
let
  tailveil =
    (import (
      pkgs.fetchFromGitLab {
        owner = "SuperTeece";
        repo = "tailveil";
        rev = "eb24348abf149d12143a5b7e25e6f48320ba6ddc";
        hash = "sha256-gaFObqOfLza2tLjKb+81bdfEJl4JhLwn+OmZf2hP14c=";
      }
    )).packages.${pkgs.hostPlatform.system}.default;

  nodes-txt = pkgs.writeText "nodes.txt" (
    builtins.concatStringsSep "\n" (
      map (
        {
          name,
          value,
        }:
        "${name},${value.id},${value.ip-address}"
      ) (lib.attrsToList config.services.tailveil.nodes)
    )
  );

  acls = pkgs.writeText "acls.hujson" (
    builtins.toJSON {
      Hosts = lib.mapAttrs (_: value: value.ip-address) config.services.tailveil.nodes;
      Groups = { };
      TagOwners = { };
      ACLs = map (rule: {
        Action = rule.action;
        Users = rule.users;
        Ports = rule.ports;
      }) config.services.tailveil.acls;
    }
  );
in
{
  options.services.tailveil = with pkgs.lib.types; {
    enable = lib.mkOption {
      type = bool;
      default = true;
      description = "Enables the tailveil VPN over veilid";
    };
    interfaceName = lib.mkOption {
      type = str;
      default = "tailveil0";
      description = "Interface name created by Tailveil";
    };
    mtu = lib.mkOption {
      type = int;
      default = 1280;
      description = "MTU size for the Tailveil TUN interface";
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
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            action = lib.mkOption {
              type = lib.types.enum [ "accept" ];
              default = "accept";
              description = "Action to take for matching traffic.";
            };
            users = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ "*" ];
            };
            ports = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ "*:*" ];
            };
          };
        }
      );
      default = [
        {
          action = "accept";
          users = [ "*" ];
          ports = [ "*:*" ];
        }
      ];
      description = "Access Control List rules for Tailveil.";
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
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = pkgs.writeShellScript "tailveil-start" ''
          ${config.services.tailveil.package}/bin/tailveil-client start \
                    --key ${config.services.tailveil.key} \
                    --path ${config.services.tailveil.dataDir} \
                    --acl ${acls} --nodes-txt ${nodes-txt}
        '';

        # ExecStartPost = pkgs.writeShellScript "set-tailveil-mtu" ''
        #   for i in $(seq 1 100); do
        #     if ${pkgs.iproute2}/bin/ip link show dev ${config.services.tailveil.interfaceName} >/dev/null 2>&1; then
        #       ${pkgs.iproute2}/bin/ip link set dev ${config.services.tailveil.interfaceName} mtu ${toString config.services.tailveil.mtu}
        #       exit 0
        #     fi
        #     sleep 0.2
        #   done
        #   echo "Interface ${config.services.tailveil.interfaceName} did not appear in time" >&2
        #   exit 1
        # '';
      };
    };

    # Optional but highly recommended: Clamp TCP MSS automatically on all interfaces
    networking.firewall.extraCommands = ''
      iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu || true
    '';
    networking.firewall.trustedInterfaces = [ "tailveil0" ];
  };
}
