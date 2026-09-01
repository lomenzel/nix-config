{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs_22,
  nodePackages,
  python3,
  wasm-bindgen-cli,
  pkg-config,
  rustc,
  cargo,
  emscripten,
  lld,
  bash,
  binaryen,
  libsecret,
  electron,
  git,
  wasm-pack,
  napi-rs-cli, # <--- ADD NATIVE NAPI-CLI
  jq,
  rustPlatform,
}:
let
  tuta-wasm-pack = rustPlatform.buildRustPackage (finalAttrs: {
    pname = "tuta-wasm-pack";
    version = "b1e0e98";
    src = fetchFromGitHub {
      owner = "tutao";
      repo = "wasm-pack";
      rev = "69f8269704aaccd8294edbb33e819687dfc227bf";
      hash = "sha256-UVZoXMJm8XYYWPs2ouNZXJbUyA5hA6Gkf+7v7d7qVPo=";
    };
    cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

    checkPhase = "";
    doCheck = false;
  });
in

buildNpmPackage (finalAttrs: {
  pname = "tutanota-desktop";
  version = "352.260618.0";

  src = fetchFromGitHub {
    owner = "tutao";
    repo = "tutanota";
    rev = "tutanota-release-${finalAttrs.version}";
    hash = "sha256-iEwcuj+49aoKmScoo8xDCPCXZ553V+hxMQdMdzjSTGs=";
    fetchSubmodules = true;
  };

  # Revert this back to your original, clean, unmodified hash!
  npmDepsHash = "sha256-K3X5lIMMdn8LcaoxDmBiqxRqVEEP9V6rSbHlVfXuBUM=";

  # Main workspace dependencies
  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${finalAttrs.src}/Cargo.lock";
    outputHashes = {
      "uniffi-0.27.1" = "sha256-3IH/e5DOPl2O3mJVKj9Ar60rRvSdDt4JUZ6SFEaiwcc=";
    };
  };

  # Nested submodule dependencies (needed for @signalapp/sqlcipher native module)
  signalFts5CargoDeps = rustPlatform.importCargoLock {
    lockFile = "${finalAttrs.src}/libs/Signal-FTS5-Extension/Cargo.lock";
  };

  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];
  forceGitDeps = true;

  nodejs = nodejs_22;
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postPatch = ''
        # Clean up root package.json (no Napi CLI injection needed!)
        ${jq}/bin/jq 'del(
          .dependencies["@indutny/simple-windows-notifications"],
          .devDependencies["@indutny/simple-windows-notifications"],
          .scripts.preinstall,
          .dependencies["wasm-pack"],
          .devDependencies["wasm-pack"]
        )' package.json > package.json.tmp
        mv package.json.tmp package.json

        # wasm-pack virtual workspace workaround
        cat <<EOF >> Cargo.toml

    [package]
    name = "tutanota-dummy-root"
    version = "0.0.0"

    [lib]
    crate-type = ["cdylib", "rlib"]
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
    lld
    makeWrapper
    git
    wasm-bindgen-cli
    napi-rs-cli # <--- NATIVE NAPI-CLI COMPILER
    jq
  ];

  buildInputs = [
    libsecret
  ];
  
  preBuild = ''
    # Mock @indutny/simple-windows-notifications since we deleted it from package.json
    mkdir -p node_modules/@indutny/simple-windows-notifications/dist
    cat > node_modules/@indutny/simple-windows-notifications/package.json <<EOF
    {
      "name": "@indutny/simple-windows-notifications",
      "version": "1.0.0",
      "main": "dist/index.js",
      "types": "dist/index.d.ts"
    }
    EOF
    echo "module.exports = { Notifier: class { show() {} remove() {} }, sendDummyKeystroke: () => {} };" > node_modules/@indutny/simple-windows-notifications/dist/index.js
    
    # Write robust dummy type declarations for tsc
    cat > node_modules/@indutny/simple-windows-notifications/dist/index.d.ts <<EOF
    export class Notifier {
      constructor(options?: any);
      show(toastXml: string, options: any): void;
      remove(options: any): void;
    }
    export function sendDummyKeystroke(): void;
    EOF

    # Create dummy wasm-pack package so npx doesn't try to download it
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

    # Point directly to the tuta-wasm-pack we compiled natively
    cat > node_modules/wasm-pack/bin/wasm-pack <<EOF
    #!${bash}/bin/bash
    exec "${tuta-wasm-pack}/bin/wasm-pack" "\$@"
    EOF

    chmod +x node_modules/wasm-pack/bin/wasm-pack
    ln -sf ../wasm-pack/bin/wasm-pack node_modules/.bin/wasm-pack

    # Build the native mimimi module natively using Nixpkgs' napi-rs-cli
    echo "Building native mimimi addon..."
    pushd src/app-kit/mimimi
    napi build \
      --platform \
      --js binding.js \
      --dts binding.d.ts \
      --target x86_64-unknown-linux-gnu \
      --release \
      --features javascript \
      napi-out
    popd

    # Stub out make.js so the main builder skips rebuilding it
    echo "process.exit(0);" > src/app-kit/mimimi/make.js

    # Setup writable Emscripten cache directory
    export EM_CACHE=$(mktemp -d)
    if [ -d "${emscripten}/share/emscripten/cache" ]; then
      cp -Lr "${emscripten}/share/emscripten/cache/." "$EM_CACHE/"
    fi
    chmod u+rwX -R "$EM_CACHE"

    # Merge Signal-FTS5-Extension dependencies into the global cargo vendor dir
    echo "Merging Signal-FTS5-Extension Cargo dependencies..."
    chmod -R +w $NIX_BUILD_TOP/cargo-vendor-dir
    cp -rn $signalFts5CargoDeps/. $NIX_BUILD_TOP/cargo-vendor-dir/

    # Patch @signalapp/sqlcipher to use the local Signal-FTS5-Extension submodule
    chmod +w node_modules/@signalapp/sqlcipher/deps/extension/Cargo.toml
    sed -i 's|signal-tokenizer = {.*}|signal-tokenizer = { path = "/build/source/libs/Signal-FTS5-Extension" }|' node_modules/@signalapp/sqlcipher/deps/extension/Cargo.toml

    # Remove nested Cargo.lock so cargo resolves successfully using only our merged vendor directory
    rm -f node_modules/@signalapp/sqlcipher/deps/extension/Cargo.lock
  '';
  
  buildPhase = ''
    runHook preBuild
    export ELECTRON_BUILDER_CACHE=$(mktemp -d)
    node desktop --custom-desktop-release --unpacked
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/tuta $out/bin
    if [ -d "build/desktop/linux-unpacked/resources" ]; then
      cp -r build/desktop/linux-unpacked/resources/* $out/share/tuta/
    else
      cp -r build/desktop/* $out/share/tuta/
    fi

    makeWrapper ${electron}/bin/electron $out/bin/tuta \
      --add-flags $out/share/tuta/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
    runHook postInstall
  '';

  passthru = {
    inherit tuta-wasm-pack;
  };

  meta = with lib; {
    description = "Tuta official desktop client";
    homepage = "https://tuta.com";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
})