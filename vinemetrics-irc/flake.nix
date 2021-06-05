{
  description = "Vinemetrics Irc";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
  inputs.flake-nimble.url = github:nix-community/flake-nimble/master;

  outputs = { self, nixpkgs, flake-nimble }: 
  with import nixpkgs {
    system = "x86_64-linux";
    overlays = [ flake-nimble.overlay ];
  };
  let
    nimyaml = fetchFromGitHub {
      owner = "flyx";
      repo = "NimYAML";
      rev = "9916c340c1d5fcb18008898d1864f37164439858";
      sha256 = "1wkwnqxq9mzhqn5ayw33zxfhfk6gph3rkbbchw0yh3ll4h6bm987";
    };
  in rec {
    defaultPackage.x86_64-linux = stdenv.mkDerivation rec {
      name = "vinemetrics-irc";
      src = self;
      buildInputs = [ nimblePackages.irc ];
      nimFlags = "--path:${nimyaml}";
      preHook = ''
        export HOME="$NIX_BUILD_TOP"
        nim () {
          args=()
          for arg in "$@"; do
            args+=( "$arg" )
          done
          ${nim}/bin/nim $nimFlags ''${args[@]}
        }

        build () {
          nim c src/vinemetrics_irc.nim
        }
      '';
      buildPhase = ''
        cd ./vinemetrics-irc
        build
      '';
      installPhase = ''
        mkdir -p $out/bin
        install  -t $out/bin ./src/vinemetrics_irc'';
    };
    devShell.x86_64-linux = defaultPackage.x86_64-linux;
  };
}
