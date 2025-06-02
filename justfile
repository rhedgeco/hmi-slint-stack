default:
    just --list

# Builds and enters a development environment
dev VERSION="default":
    nix develop .#{{VERSION}} --impure