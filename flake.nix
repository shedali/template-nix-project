{
  description = "Bun + React + Nix";

  nixConfig = {
    substituters = [ "https://cache.nixos.org" "https://shedali.cachix.org" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "shedali.cachix.org-1:jnKOvnLAPbsv127ddEfluQ5Wo8h7llUT47CUJCumAvI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, flake-utils, devshell, pre-commit-hooks, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            prettier = {
              enable = true;
              types_or = [ "html" "javascript" "ts" "tsx" "jsx" "json" "css" "markdown" ];
            };
          };
        };
        deps = pkgs.stdenv.mkDerivation {
          pname = "bun-deps";
          version = "1.0.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.bun ];
          buildPhase = ''
            export BUN_INSTALL_CACHE_DIR=$TMPDIR/bun-cache
            bun install --no-save --frozen-lockfile
          '';
          installPhase = ''
            mkdir -p $out
            cp -r node_modules $out/
            cp bun.lockb $out/ 2>/dev/null || true
          '';
          outputHashMode = "recursive";
          outputHashAlgo = "sha256";
          outputHash = "sha256-eX+2TYc2uI88XLY6Azuv+SxWxROHjD/ilZXIvVB9Loc=";
        };
        app = pkgs.stdenv.mkDerivation {
          pname = "bun-react-app";
          version = "1.0.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.bun ];
          buildPhase = ''
            ln -s ${deps}/node_modules ./node_modules
            bun build src/main.tsx --outdir ./dist --target browser
          '';
          installPhase = ''
            mkdir -p $out/www
            cp -r dist/* $out/www/
            cp build.html $out/www/index.html
          '';
        };
      in
      {
        packages.default = app;
        apps.default = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "serve" "cd ${app}/www && ${pkgs.bun}/bin/bunx serve -p 3000";
        };
        devShells.default = devshell.legacyPackages.${system}.mkShell {
          packages = [ pkgs.bun pkgs.nixpkgs-fmt pkgs.nodePackages.prettier pkgs.cachix pkgs.jq ];
          devshell.startup.pre-commit-hooks.text = pre-commit-check.shellHook;
          devshell.startup.bun-install.text = "bun install";
          devshell.startup.git-hooks.text = ''
            # Install version-controlled git hooks
            if [ -f pre-push ]; then
              cp pre-push .git/hooks/pre-push
              chmod +x .git/hooks/pre-push
            fi
          '';
          commands = [
            { name = "dev"; help = "Start Bun dev server"; command = "bunx serve . -p 3000"; }
            { name = "build"; help = "Build static output"; command = "bun build src/main.tsx --outdir ./dist --target browser && cp build.html ./dist/index.html"; }
            { name = "serve"; help = "Serve built output"; command = "bunx serve ./dist -p 3000"; }
            { name = "format"; help = "Format files"; command = "nixpkgs-fmt flake.nix && prettier --write 'src/**/*.{ts,tsx}'"; }
            {
              name = "update-hash";
              help = "Update FOD hash for dependencies";
              command = ''
                echo "Updating FOD hash..."
                sed -i 's/outputHash = "sha256-.*";/outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";/' flake.nix
                echo "Building to get new hash..."
                hash=$(nix build --accept-flake-config 2>&1 | grep "got:" | awk '{print $2}' || echo "")
                if [ -n "$hash" ]; then
                  sed -i "s/sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=/$hash/" flake.nix
                  echo "Updated hash to: $hash"
                else
                  echo "Failed to get new hash - build may have succeeded with old hash"
                fi
              '';
            }
          ];
          motd = "🚀 Bun + React + Nix\nCommands: dev, build, serve, format, update-hash, menu";
        };
        formatter = pkgs.writeShellScriptBin "fmt" "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt flake.nix";
        checks.pre-commit-check = pre-commit-check;
      });
}
