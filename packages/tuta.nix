{ lib
, buildNpmPackage
, fetchFromGitHub
, makeWrapper
, nodejs_22
, nodePackages
, python3
, pkg-config
, rustc
, cargo
, emscripten
, binaryen
, libsecret
, electron
, git
, wasm-pack
, jq
, rustPlatform
}:

buildNpmPackage (finalAttrs: {
  pname = "tuta";
  version = "352.260618.0";

  src = fetchFromGitHub {
    owner = "tutao";
    repo = "tutanota";
    rev = "tutanota-release-${finalAttrs.version}";
    hash = "sha256-iEwcuj+49aoKmScoo8xDCPCXZ553V+hxMQdMdzjSTGs=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-K3X5lIMMdn8LcaoxDmBiqxRqVEEP9V6rSbHlVfXuBUM=";

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${finalAttrs.src}/Cargo.lock";
    outputHashes = {
      "uniffi-0.27.1" = "sha256-3IH/e5DOPl2O3mJVKj9Ar60rRvSdDt4JUZ6SFEaiwcc=";
    };
  };

  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];
  forceGitDeps = true;

  # Node 22 is required per package.json engines
  nodejs = nodejs_22;

  # Avoid downloading electron prebuilt binary during npm install
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postPatch = ''
    # Remove Windows-only dependency from package.json to avoid forceGitDeps errors
    # Disable preinstall script which tries to setup git hooks
    # Remove custom wasm-pack git dependency so we use the system one
    jq 'del(.dependencies["@indutny/simple-windows-notifications"], .devDependencies["@indutny/simple-windows-notifications"], .scripts.preinstall, .dependencies["wasm-pack"], .devDependencies["wasm-pack"])' package.json > package.json.tmp
    mv package.json.tmp package.json

    # wasm-pack 0.13.1 has a known bug where it fails to parse virtual workspaces because it
    # strictly expects a `[package]` table in the root Cargo.toml. We inject a dummy package
    # and a dummy source file to bypass this parser bug.
    cat <<EOF >> Cargo.toml

[package]
name = "tutanota-dummy-root"
version = "0.0.0"
EOF
    mkdir -p src
    touch src/lib.rs
  '';

  nativeBuildInputs = [
    python3
    pkg-config
    rustc
    cargo
    rustPlatform.cargoSetupHook
    emscripten
    binaryen
    makeWrapper
    git
    wasm-pack
    jq
  ];

  buildInputs = [
    libsecret
  ];

  preBuild = ''
    # Provide a dummy built file for the windows-only notification library
    if [ -d node_modules/@indutny/simple-windows-notifications ]; then
      mkdir -p node_modules/@indutny/simple-windows-notifications/dist
      echo "module.exports = {};" > node_modules/@indutny/simple-windows-notifications/dist/index.js
      echo "export {};" > node_modules/@indutny/simple-windows-notifications/dist/index.d.ts
    fi

    # Create a dummy wasm-pack package to trick npx into using the system binary.
    # Because we removed wasm-pack from package.json, npx attempts to download it.
    mkdir -p node_modules/wasm-pack/bin node_modules/.bin
    cat > node_modules/wasm-pack/package.json <<EOF
    {
      "name": "wasm-pack",
      "version": "0.13.1",
      "bin": {
        "wasm-pack": "bin/wasm-pack"
      }
    }
    EOF
    cat > node_modules/wasm-pack/bin/wasm-pack <<EOF
    #!/bin/sh
    exec wasm-pack "\$@"
    EOF
    chmod +x node_modules/wasm-pack/bin/wasm-pack
    ln -sf ../wasm-pack/bin/wasm-pack node_modules/.bin/wasm-pack
  '';

  # The build script expects to run `node desktop --custom-desktop-release --unpacked`
  # electron-builder might try to download the electron binary during this phase. 
  # We setup a dummy cache directory to avoid writing to read-only paths if it tries.
  buildPhase = ''
    runHook preBuild
    
    export ELECTRON_BUILDER_CACHE=$(mktemp -d)
    
    # Run the desktop build script
    node desktop --custom-desktop-release --unpacked
    
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/share/tuta $out/bin
    
    # The --unpacked output usually lands in build/desktop/linux-unpacked.
    # We copy the 'resources' folder which contains the actual app code (usually app.asar).
    # Since we are using the system electron, we only need the app resources, not the 
    # downloaded electron executable.
    
    if [ -d "build/desktop/linux-unpacked/resources" ]; then
      cp -r build/desktop/linux-unpacked/resources/* $out/share/tuta/
    else
      # Fallback if structure is different
      cp -r build/desktop/* $out/share/tuta/
    fi
    
    # Wrap the system electron with the app resources
    makeWrapper ${electron}/bin/electron $out/bin/tuta \
      --add-flags $out/share/tuta/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
      
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tuta official desktop client";
    homepage = "https://tuta.com";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
)