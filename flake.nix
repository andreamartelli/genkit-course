{
  description = "Development environment for the Genkit Course";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          # This is the fix: the shell is now the 'default' attribute.
          default = pkgs.mkShell {
            name = "genkit-course-env";
            packages = [
              pkgs.git
              pkgs.nodejs_20
              pkgs.google-cloud-sdk
              pkgs.python311
            ];
            shellHook = ''
              echo "Welcome to the Genkit Course Dev Environment!"
              echo "--------------------------------------------"

              if [ ! -d ".venv" ]; then
                echo "Creating Python virtual environment..."
                python3 -m venv .venv
              fi

              source .venv/bin/activate
              echo "Python virtual environment activated."

              if ! command -v uv &> /dev/null; then
                echo "Installing 'uv' into the virtual environment..."
                pip install uv
              fi

              if [ ! -d "node_modules" ]; then
                echo "Installing Node.js dependencies..."
                npm install
              fi

              echo ""
              echo "✅ Setup is complete. You can now run 'npm start'."
              echo "❗ IMPORTANT: If this is your first time, run 'gcloud auth login' now."
            '';
          };
        }
      );
    };
}