{
  description = "A simple Bun + React application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Static site - just copy files
        staticSite = pkgs.stdenv.mkDerivation {
          pname = "bun-react-app";
          version = "1.0.0";
          src = ./.;

          installPhase = ''
            mkdir -p $out/www
            cp index.html $out/www/
          '';
        };
      in
      {
        packages.default = staticSite;

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.bun ];

          shellHook = ''
            echo "🚀 Bun + React development environment"
            echo "• bun --bun serve .     - Start dev server"
            echo "• Open http://localhost:3000"
          '';
        };

        apps.default = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "serve" ''
            cd ${staticSite}/www && ${pkgs.bun}/bin/bunx serve -p 3000
          '';
        };
      });
}
