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
        app = pkgs.stdenv.mkDerivation {
          pname = "bun-react-app";
          version = "1.0.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.bun ];
          buildPhase = ''
            bun build src/main.tsx --outdir ./dist --target browser
          '';
          installPhase = ''
            mkdir -p $out/www
            cp -r dist/* $out/www/
            cp public/index.html $out/www/
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
          commands = [
            { name = "dev"; help = "Start dev server"; command = "bunx serve . -p 3000"; }
            { name = "format"; help = "Format files"; command = "nixpkgs-fmt flake.nix && prettier --write 'src/**/*.{ts,tsx}' 'public/**/*.html'"; }
          ];
          motd = "🚀 Bun + React + Nix\nCommands: dev, format, menu";
        };
        formatter = pkgs.writeShellScriptBin "fmt" "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt flake.nix";
        checks.pre-commit-check = pre-commit-check;
      });
}
