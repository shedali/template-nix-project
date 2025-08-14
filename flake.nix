{
  description = "A simple Bun application";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://shedali.cachix.org"
    ];
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
            # Set HOME for bun cache
            export HOME=$(mktemp -d)
            
            # Build the application
            # The --compile flag creates a single executable with all dependencies bundled
            bun build index.ts --compile --outfile ./app
          '';

          installPhase = ''
            mkdir -p $out/bin
            
            # Copy the compiled executable
            cp ./app $out/bin/bun-app
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

      in
      {
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
            nixpkgs-fmt
            statix
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
            {
              name = "lint-check";
              help = "Check Nix code formatting and style";
              command = ''
                echo "Checking Nix formatting..."
                nixpkgs-fmt --check *.nix
                echo "Checking for Nix anti-patterns..."
                statix check .
                echo "✅ Lint checks complete"
              '';
            }
            {
              name = "lint-fix";
              help = "Auto-fix Nix formatting and style issues";
              command = ''
                echo "Fixing Nix formatting..."
                nixpkgs-fmt *.nix
                echo "Fixing Nix anti-patterns..."
                statix fix .
                echo "✅ Lint fixes applied"
              '';
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
            • start       - Start the Bun application
            • dev         - Start with watch mode
            • build       - Build for production
            • test-server - Test the running server
            • lint-check  - Check Nix code formatting and style
            • lint-fix    - Auto-fix Nix formatting and style issues
            
            Run 'menu' to see this again.
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      }) // {
    # Template configuration for 'nix flake new'
    templates = {
      default = {
        path = ./.;
        description = "A Nix flake template for Bun applications with Cachix";
        welcomeText = ''
          # Welcome to the Nix Bun Template!
          
          You've created a new project from the template.
          
          ## Next Steps:
          
          1. Update project name in flake.nix (line 19 & 2)
          2. Set up your own Cachix cache (optional)
          3. Replace index.ts with your application
          4. Update README.md
          
          Get started:
            cd into your project directory
            nix develop
          
          See README.md for detailed setup instructions.
        '';
      };
    };
  };
}
