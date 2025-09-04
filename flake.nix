{
  description = "AnkiGenerators";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.05";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.url = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    zig-overlay,
    ...
  }: let
    system = "x86_64-linux";
  in {
    devShells.${system}.default = let
      pkgs = nixpkgs.legacyPackages.${system};
      zigpkgs = zig-overlay.outputs.packages.${system};
    in
      pkgs.mkShell {
        packages = [
          zigpkgs."0.15.1"
        ];
      };
  };
}
