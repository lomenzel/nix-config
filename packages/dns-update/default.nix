{ writeShellScriptBin, python313 }:
writeShellScriptBin "dns-update" ''
  ${
    python313.withPackages (
      ps: with ps; [
        inwx-domrobot
        dnspython
      ]
    )
  }/bin/python ${./main.py}
''
