{
  description = "A simple Bun application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, devshell }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        devshell-pkgs = devshell.legacyPackages.${system};
        
        # Build the Bun application
        bunApp = pkgs.stdenv.mkDerivation {
          pname = "bun-nix-example";
          version = "1.0.0";
          
          src = ./.;
          
          nativeBuildInputs = with pkgs; [
            bun
          ];
          
          buildPhase = ''
            # Install dependencies if any
            bun install
            
            # Build the application
            bun build index.ts --outdir ./dist --target bun
          '';
          
          installPhase = ''
            mkdir -p $out/bin $out/lib
            
            # Copy the built application
            cp -r dist/* $out/lib/
            
            # Create a wrapper script
            cat > $out/bin/bun-app <<EOF
            #!${pkgs.bash}/bin/bash
            exec ${pkgs.bun}/bin/bun $out/lib/index.js "\$@"
            EOF
            
            chmod +x $out/bin/bun-app
          '';
          
          meta = with pkgs.lib; {
            description = "Simple Bun application example";
            license = licenses.mit;
            platforms = platforms.all;
          };
        };
        
        # Alternative: Direct execution without building
        bunScript = pkgs.writeShellScriptBin "bun-script" ''
          exec ${pkgs.bun}/bin/bun ${./index.ts} "$@"
        '';
        
      in {
        packages = {
          default = bunApp;
          app = bunApp;
          script = bunScript;
        };
        
        apps = {
          default = flake-utils.lib.mkApp {
            drv = bunApp;
            name = "bun-app";
          };
          
          script = flake-utils.lib.mkApp {
            drv = bunScript;
            name = "bun-script";
          };
        };
        
        devShells.default = devshell-pkgs.mkShell {
          name = "bun-dev-environment";
          
          packages = with pkgs; [
            bun
            nodejs
          ];
          
          commands = [
            {
              name = "start";
              help = "Start the Bun application";
              command = "bun run index.ts";
            }
            {
              name = "dev";
              help = "Start the application with watch mode";
              command = "bun --watch run index.ts";
            }
            {
              name = "build";
              help = "Build the application for production";
              command = "bun build index.ts --outdir ./dist --target bun";
            }
            {
              name = "test-server";
              help = "Test the server with curl";
              command = "curl http://localhost:3000";
            }
          ];
          
          env = [
            {
              name = "BUN_ENV";
              value = "development";
            }
          ];
          
          motd = ''
            Welcome to the Bun development environment!
            
            Available commands:
            • start      - Start the Bun application
            • dev        - Start with watch mode
            • build      - Build for production
            • test-server - Test the running server
            
            Run 'menu' to see this again.
          '';
        };
      });
}
