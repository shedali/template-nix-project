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
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , devshell
    , pre-commit-hooks
    ,
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        devshell-pkgs = devshell.legacyPackages.${system};

        # Shared source filtering logic
        sourceFilter = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: type:
            let
              baseName = baseNameOf path;
            in
            # Exclude documentation and non-essential CI files
              ! (pkgs.lib.hasPrefix (toString ./docs) path
              || pkgs.lib.hasPrefix (toString ./.github/workflows) path
              || baseName == "README.md"
              || baseName == ".git"
              || baseName == "result"
              || baseName == ".gitignore"
              || pkgs.lib.hasSuffix ".md" baseName);
        };

        # Pre-commit hooks configuration
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # Nix formatting
            nixpkgs-fmt.enable = true;

            # TypeScript/JavaScript
            prettier = {
              enable = true;
              types_or = [ "javascript" "jsx" "ts" "tsx" "json" "css" "html" "markdown" ];
            };
          };
        };

        # Build the React static site
        reactApp = pkgs.stdenv.mkDerivation {
          pname = "react-bun-app";
          version = "1.0.0";
          src = sourceFilter;
          nativeBuildInputs = with pkgs; [
            bun
          ];

          buildPhase = ''
            # Set HOME for bun cache
            export HOME=$(mktemp -d)
            echo "Building React app with Bun (standalone version for Nix)..."

            # Create dist directory
            mkdir -p dist

            # Bundle the standalone React app (no external deps needed)
            bun build standalone.tsx --outdir ./dist --minify --target=browser

            # Copy HTML file
            cp index.html ./dist/

            # Update HTML to use the bundled JS with relative path (works with GitHub Pages)
            sed -i 's|type="module" src="/index.tsx"|src="./standalone.js"|' ./dist/index.html
          '';

          installPhase = ''
            mkdir -p $out/www
            cp -r dist/* $out/www/

            # Create a Bun serve script
            mkdir -p $out/bin
            cat > $out/bin/serve <<EOF
            #!${pkgs.bash}/bin/bash
            echo "Serving static files from $out/www on http://localhost:3000"
            cd $out/www && ${pkgs.bun}/bin/bunx serve -p 3000
            EOF
            chmod +x $out/bin/serve
          '';

          meta = with pkgs.lib; {
            description = "React application built with Bun";
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
          default = reactApp;
          react = reactApp;
          script = bunScript;
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = reactApp;
            name = "serve";
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
            # Formatters and linters (pre-commit managed via hooks)
            nodePackages.prettier
          ];

          commands = [
            {
              name = "install-hooks";
              help = "Install pre-commit hooks";
              command = ''
                ${pre-commit-check.shellHook}
                echo "Pre-commit hooks installed!"
              '';
            }
            {
              name = "start";
              help = "Start React development server";
              command = "bunx --bun vite";
            }
            {
              name = "dev";
              help = "Start React dev server with hot reload";
              command = "bunx --bun vite";
            }
            {
              name = "build";
              help = "Build React app for production";
              command = "bun build index.tsx --outdir ./dist --minify";
            }
            {
              name = "preview";
              help = "Preview production build";
              command = "cd dist && bunx --bun serve -p 3000";
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
            {
              name = "fix-cache-warnings";
              help = "Show commands to fix Cachix warnings";
              command = ''
                echo "🔧 To fix Cachix warnings, run these commands:"
                echo ""
                echo "1️⃣ Add yourself to trusted users:"
                echo "   sudo mkdir -p /etc/nix"
                echo "   echo 'trusted-users = root $USER' | sudo tee -a /etc/nix/nix.conf"
                echo ""
                echo "2️⃣ Restart the Nix daemon:"
                echo "   sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true"
                echo "   sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist"
                echo ""
                echo "3️⃣ Start a new shell:"
                echo "   exit"
                echo "   nix develop"
                echo ""
                echo "💡 Alternative: Use --accept-flake-config flag:"
                echo "   nix develop --accept-flake-config"
                echo ""
                echo "⚠️  Note: The warnings don't affect functionality, they're just security notices."
              '';
            }
            {
              name = "ci-perf";
              help = "Generate CI performance report";
              command = "./scripts/ci-perf-report.sh";
            }
            {
              name = "ci-status";
              help = "Check current CI status and recent runs";
              command = ''
                echo "🔍 Checking CI status..."
                echo ""
                gh run list --limit 5 --json number,conclusion,displayTitle,createdAt,updatedAt | \
                jq -r '.[] | "[\(.conclusion // "running")] \(.displayTitle) - \(.createdAt | split("T")[0])"'
                echo ""
                echo "💡 Use 'ci-perf' for detailed performance analysis"
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

            🪝 Run 'install-hooks' to set up pre-commit hooks (first time only)

            Available commands:
            • start          - Start React development server
            • dev            - Start React dev server with hot reload (Vite)
            • build          - Build React app for production
            • test-server    - Test the running server
            • lint-check     - Check Nix code formatting and style
            • lint-fix       - Auto-fix Nix formatting and style issues
            • install-hooks  - Install pre-commit hooks
            • fix-cache-warnings - Fix Cachix warnings (requires sudo)
            • ci-perf        - Generate CI performance report  
            • ci-status      - Check current CI status

            Run 'menu' to see this again.
          '';
        };

        formatter = pkgs.nixpkgs-fmt;

        # Export pre-commit checks so they can be run in CI
        checks = {
          inherit pre-commit-check;
        };
      })
    // {
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
