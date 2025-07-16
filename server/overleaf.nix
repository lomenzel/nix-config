# copied and ajusted from https://github.com/Yeshey/nixOS-Config/blob/main/modules/nixos/toHost/overleaf.nix

{
  config,
  lib,
  pkgs,
  ...
}:

# Made with help by claude
let
  cfg = config.services.overleaf;
  
  overleafRepo = pkgs.fetchFromGitHub {
    owner = "overleaf";
    repo = "overleaf";
    rev = "9720413218e6749760bb0c2d5f9d392b98ac2e5a";
    sha256 = "sha256-C53Tw82vc/EV6snSgNNeY2qwzESiidm/fUznia++mXo=";
  };

  toolkitRepo = pkgs.fetchFromGitHub {
    owner = "overleaf";
    repo = "toolkit";
    rev = "89df4ac80b2153b46a9df6a14e66dc098f840807";
    sha256 = "sha256-B8xSPmk8A7znTBCGbZm646/P92SBc+xB3gAjotp+zUg=";
  };

  # Script to copy repos, build images, and prepare environment
  buildImagesScript = pkgs.writeShellScriptBin "build-overleaf-images" ''
    #!${pkgs.bash}/bin/bash
    set -e
    
    echo "Setting up Overleaf repositories and building images..."
    
    # Create directories
    mkdir -p ${cfg.dataDir}/repos
    
    # Copy repositories if not already present
    if [ ! -d "${cfg.dataDir}/repos/overleaf" ]; then
      echo "Copying Overleaf repository..."
      cp -r ${overleafRepo} ${cfg.dataDir}/repos/overleaf
      chmod -R u+w ${cfg.dataDir}/repos/overleaf
    fi
    
    if [ ! -d "${cfg.dataDir}/repos/toolkit" ]; then
      echo "Copying Toolkit repository..."
      cp -r ${toolkitRepo} ${cfg.dataDir}/repos/toolkit
      chmod -R u+w ${cfg.dataDir}/repos/toolkit
    fi
    
    # Set up build environment
    export MONOREPO_REVISION="${builtins.substring 0 40 overleafRepo.rev}"
    export BRANCH_NAME="main"
    export OVERLEAF_BASE_BRANCH="sharelatex/sharelatex-base:$BRANCH_NAME"
    export OVERLEAF_BASE_LATEST="sharelatex/sharelatex-base"
    export OVERLEAF_BASE_TAG="sharelatex/sharelatex-base:$BRANCH_NAME-$MONOREPO_REVISION"
    export OVERLEAF_BRANCH="sharelatex/sharelatex:$BRANCH_NAME"
    export OVERLEAF_LATEST="sharelatex/sharelatex"
    export OVERLEAF_TAG="sharelatex/sharelatex:$BRANCH_NAME-$MONOREPO_REVISION"
    
    # Ensure .dockerignore exists
    if [ ! -f ${cfg.dataDir}/repos/overleaf/.dockerignore ]; then
      touch ${cfg.dataDir}/repos/overleaf/.dockerignore
    fi
    
    # Build base image if it doesn't exist
    if ! ${pkgs.docker}/bin/docker images | grep -q "sharelatex/sharelatex-base:main"; then
      echo "Building base image..."
      cp ${cfg.dataDir}/repos/overleaf/server-ce/.dockerignore ${cfg.dataDir}/repos/overleaf/ || touch ${cfg.dataDir}/repos/overleaf/.dockerignore
      ${pkgs.docker}/bin/docker build \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --progress=plain \
        --file ${cfg.dataDir}/repos/overleaf/server-ce/Dockerfile-base \
        --pull \
        --tag $OVERLEAF_BASE_TAG \
        --tag $OVERLEAF_BASE_BRANCH \
        ${cfg.dataDir}/repos/overleaf
    else
      echo "Base image already exists, skipping build"
    fi
    
    # Build community image if it doesn't exist
    if ! ${pkgs.docker}/bin/docker images | grep -q "sharelatex/sharelatex:main"; then
      echo "Building community image..."
      ${pkgs.docker}/bin/docker build \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --progress=plain \
        --build-arg OVERLEAF_BASE_TAG=$OVERLEAF_BASE_TAG \
        --build-arg MONOREPO_REVISION=$MONOREPO_REVISION \
        --file ${cfg.dataDir}/repos/overleaf/server-ce/Dockerfile \
        --tag $OVERLEAF_TAG \
        --tag $OVERLEAF_BRANCH \
        ${cfg.dataDir}/repos/overleaf
    else
      echo "Community image already exists, skipping build"
    fi
    
    # Tag for toolkit
    if ! ${pkgs.docker}/bin/docker images | grep -q "sharelatex/sharelatex:5.4.0"; then
      echo "Tagging image for toolkit..."
      ${pkgs.docker}/bin/docker tag sharelatex/sharelatex:main sharelatex/sharelatex:5.4.0
    fi
    
    echo "Docker images built successfully"
  '';

  # Setup toolkit config script
  setupToolkitScript = pkgs.writeShellScriptBin "setup-overleaf-toolkit" ''
    #!${pkgs.bash}/bin/bash
    set -e
    
    echo "Setting up Overleaf toolkit..."
    
    # Create directories
    mkdir -p ${cfg.dataDir}
    mkdir -p ${cfg.dataDir}/toolkit
    mkdir -p ${cfg.dataDir}/overleaf-data
    mkdir -p ${cfg.dataDir}/overleaf-data/mongo
    mkdir -p ${cfg.dataDir}/overleaf-data/redis
    
    # Copy toolkit files if not already present
    if [ ! -d "${cfg.dataDir}/toolkit/bin" ]; then
      echo "Copying toolkit files..."
      cp -r ${cfg.dataDir}/repos/toolkit/* ${cfg.dataDir}/toolkit/
      chmod -R u+w ${cfg.dataDir}/toolkit
    fi
    
    # Ensure toolkit config file exists
    mkdir -p ${cfg.dataDir}/toolkit/config
    cat > ${cfg.dataDir}/toolkit/config/overleaf.rc <<EOF
# Main Overleaf configuration
PROJECT_NAME=overleaf
OVERLEAF_PORT=${cfg.port}
OVERLEAF_DATA_PATH=${cfg.dataDir}/overleaf-data
OVERLEAF_LISTEN_IP=0.0.0.0

# MongoDB configuration 
MONGO_ENABLED=true
MONGO_IMAGE=mongo
MONGO_VERSION=6.0
MONGO_DATA_PATH=${cfg.dataDir}/overleaf-data/mongo

# Redis configuration
REDIS_ENABLED=true
REDIS_DATA_PATH=${cfg.dataDir}/overleaf-data/redis
REDIS_IMAGE=redis:6.2
REDIS_AOF_PERSISTENCE=true
EOF

    # Create variables.env file
    cat > ${cfg.dataDir}/toolkit/config/variables.env <<EOF
#### variables.env ####
OVERLEAF_APP_NAME="Overleaf"

ENABLED_LINKED_FILE_TYPES=project_file,project_output_file

# Enables Thumbnail generation using ImageMagick
ENABLE_CONVERSIONS=true

# Disables email confirmation requirement
EMAIL_CONFIRMATION_DISABLED=true

# Allow accessing via IP address
SITE_URL=http://127.0.0.1:${cfg.port}
BASE_URL=http://127.0.0.1:${cfg.port}
# Disable strict host matching if needed
RESTRICT_INVITES_TO_EXISTING_ACCOUNTS=false

EOF

    # Ensure version file exists
    echo "5.4.0" > ${cfg.dataDir}/toolkit/config/version
    
    # Make toolkit scripts executable
    chmod +x ${cfg.dataDir}/toolkit/bin/up
    chmod +x ${cfg.dataDir}/toolkit/bin/docker-compose
    
    echo "Toolkit setup completed successfully"
  '';

  # Script to start Overleaf service
  startOverleafScript = pkgs.writeShellScriptBin "start-overleaf" ''
    #!${pkgs.bash}/bin/bash
    set -e
    
    cd ${cfg.dataDir}/toolkit
    
    # Check if there are existing containers that need to be stopped
    if ${pkgs.docker}/bin/docker ps -a | grep -q "sharelatex"; then
      echo "Stopping existing Overleaf containers..."
      ./bin/docker-compose down || true
    fi
    
    # Start Overleaf using toolkit
    echo "Starting Overleaf..."
    exec ./bin/up
  '';

  # Required packages for scripts
  requiredPkgs = with pkgs; [
    bash
    coreutils
    docker
    docker-compose
    git
    gnugrep
    gnutar
    gzip
    gnused
    findutils
    gawk
    nettools
    procps
    which
    gnumake
    hostname
  ];

in
{
  options.services.overleaf = {
    enable = lib.mkEnableOption "Overleaf Service";
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/overleaf";
      description = "Path to store Overleaf persistent data";
    };
    port = lib.mkOption {
      type = lib.types.str;
      default = "8093";
      description = "Host port to expose Overleaf web interface";
    };
    forceBuild = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Force rebuilding Docker images even if they exist";
    };
  };

  config = lib.mkIf (config.services.overleaf.enable && cfg.enable) {
    # Enable Docker
    virtualisation.docker.enable = true;
    
    # Directory setup service
    systemd.services.overleaf-dir-setup = {
      description = "Setup Overleaf directories";
      wantedBy = [ "multi-user.target" ];
      before = [ "overleaf-build.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      script = ''
        #!${pkgs.bash}/bin/bash
        mkdir -p ${cfg.dataDir}
        mkdir -p ${cfg.dataDir}/repos
        mkdir -p ${cfg.dataDir}/overleaf-data
        mkdir -p ${cfg.dataDir}/overleaf-data/mongo
        mkdir -p ${cfg.dataDir}/overleaf-data/redis
      '';
    };

    # Build Docker images
    systemd.services.overleaf-build = {
      description = "Build Overleaf Docker images";
      requires = [ "docker.service" "overleaf-dir-setup.service" ];
      after = [ "docker.service" "overleaf-dir-setup.service" ];
      wantedBy = [ "multi-user.target" ];
      before = [ "overleaf-setup.service" ];
      path = requiredPkgs;
      environment = lib.optionalAttrs cfg.forceBuild {
        FORCE_BUILD = "true";
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
        TimeoutStartSec = "120min"; # Building might take a long time
      };
      script = "${buildImagesScript}/bin/build-overleaf-images";
    };

    # Setup Overleaf toolkit
    systemd.services.overleaf-setup = {
      description = "Setup Overleaf toolkit";
      requires = [ "overleaf-build.service" ];
      after = [ "overleaf-build.service" ];
      wantedBy = [ "multi-user.target" ];
      before = [ "overleaf.service" ];
      path = requiredPkgs;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      script = "${setupToolkitScript}/bin/setup-overleaf-toolkit";
    };

    # Run Overleaf service
    systemd.services.overleaf = {
      description = "Overleaf Service";
      requires = [ "docker.service" "overleaf-setup.service" ];
      after = [ "docker.service" "overleaf-setup.service" ];
      wantedBy = [ "multi-user.target" ];
      path = requiredPkgs;
      serviceConfig = {
        Type = "simple";
        User = "root";
        Restart = "on-failure";
        RestartSec = "10s";
        WorkingDirectory = "${cfg.dataDir}/toolkit";
        ExecStart = "${startOverleafScript}/bin/start-overleaf";
      };
      preStop = ''
        #!${pkgs.bash}/bin/bash
        cd ${cfg.dataDir}/toolkit
        ./bin/docker-compose down || true
      '';
    };

/*
    # Add tools to the system environment
    environment.systemPackages = [ 
      buildImagesScript
      setupToolkitScript
      startOverleafScript
      pkgs.docker-compose
    ] ++ requiredPkgs;
*/

    # Firewall configuration
 #   networking.firewall.allowedTCPPorts = [ (lib.toInt cfg.port) ];
    
    # Create a directory in /etc for overleaf specific configs
    environment.etc."overleaf/REVISION".text = overleafRepo.rev;
  };
}