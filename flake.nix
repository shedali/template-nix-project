{
  description = "A simple Bun + React application";

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
        devshell-pkgs = devshell.legacyPackages.${system};

        # Pre-commit hooks (auto-format on commit)
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt = {
              enable = true;
              # Auto-format Nix files
            };
            prettier = {
              enable = true;
              types_or = [ "html" "javascript" "ts" "tsx" "jsx" "json" "css" "markdown" ];
              # Auto-format these files
            };
          };
        };

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

        devShells.default = devshell-pkgs.mkShell {
          packages = [
            pkgs.bun
            pkgs.nixpkgs-fmt
            pkgs.nodePackages.prettier
            pkgs.cachix
            pkgs.jq
          ];

          # Auto-install pre-commit hooks when entering shell
          devshell.startup.pre-commit-hooks.text = pre-commit-check.shellHook;

          commands = [
            {
              name = "dev";
              help = "Start development server on port 3000";
              command = "bunx serve . -p 3000";
            }
            {
              name = "build";
              help = "Build the application";
              command = "nix build";
            }
            {
              name = "serve";
              help = "Build and serve the application";
              command = "nix run";
            }
            {
              name = "format";
              help = "Format all files";
              command = ''
                nixpkgs-fmt flake.nix
                prettier --write index.html
                echo "Files formatted!"
              '';
            }
            {
              name = "setup-cachix";
              help = "Configure Cachix cache name";
              command = ''
                echo "Enter your Cachix cache name (e.g., 'my-cache'):"
                read -r cache_name
                echo "export CACHIX_CACHE=$cache_name" >> .envrc
                echo "✅ Cachix cache set to: $cache_name"
                echo ""
                echo "Now configure authentication:"
                echo "  cachix authtoken <your-token>"
                echo ""
                echo "Get your token from: https://app.cachix.org/personal-auth-tokens"
              '';
            }
            {
              name = "install-pre-push";
              help = "Install pre-push hook with Cachix upload";
              command = ''
                    mkdir -p .git/hooks
                    cat > .git/hooks/pre-push <<'EOF'
                #!/bin/bash
                echo "🔍 Running pre-push checks..."
            
                # Build to ensure everything works
                if ! nix build; then
                  echo "❌ Build failed - push aborted"
                  exit 1
                fi
            
                # Format check - should block push if not formatted
                # (pre-commit should have auto-formatted, so this catches bypasses)
                if ! timeout 10 nix fmt -- --check 2>/dev/null; then
                  echo "❌ Files are not formatted correctly!"
                  echo "   This should have been auto-formatted by pre-commit."
                  echo "   Run 'nix fmt' to format, then commit the changes."
                  exit 1
                fi
            
                # Push to Cachix if configured
                if command -v cachix &> /dev/null; then
                  if [ -n "$CACHIX_CACHE" ]; then
                    echo "📦 Pushing to Cachix cache: $CACHIX_CACHE"
                    nix build --json | jq -r '.[].outputs | to_entries[].value' | cachix push "$CACHIX_CACHE"
                    echo "✅ Pushed to Cachix"
                  else
                    echo "⚠️  CACHIX_CACHE not set - skipping Cachix push"
                    echo "   Set with: export CACHIX_CACHE=your-cache-name"
                  fi
                else
                  echo "⚠️  Cachix not installed - skipping cache push"
                fi
            
                echo "✅ Pre-push checks passed"
                EOF
                    chmod +x .git/hooks/pre-push
                    echo "Pre-push hook installed!"
                    echo ""
                    echo "To enable Cachix pushing:"
                    echo "  1. Install cachix: nix-env -iA nixpkgs.cachix"
                    echo "  2. Set cache name: export CACHIX_CACHE=your-cache-name"
                    echo "  3. Configure auth: cachix authtoken <your-token>"
              '';
            }
          ];

          motd = ''
            🚀 Bun + React development environment
            
            ✅ Pre-commit hooks auto-installed!
            
            Available commands:
            • dev              - Start dev server on http://localhost:3000
            • build            - Build the application  
            • serve            - Build and serve the application
            • format           - Format all files
            • setup-cachix     - Configure Cachix cache
            • install-pre-push - Install pre-push hook (with Cachix)
            
            Run 'menu' to see this again.
          '';
        };

        apps.default = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "serve" ''
            echo "🚀 Serving React app on http://localhost:3000"
            cd ${staticSite}/www && ${pkgs.bun}/bin/bunx serve -p 3000
          '';
        };

        checks = {
          inherit pre-commit-check;
        };

        formatter = pkgs.writeShellScriptBin "formatter" ''
          # Only format the flake.nix file, not symlinks or other directories
          ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt flake.nix "$@"
        '';
      });
}
