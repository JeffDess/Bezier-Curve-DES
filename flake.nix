{
  description = "Bezier Curve DES";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    bosl2 = {
      url = "github:BelfrySCAD/BOSL2";
      flake = false;
    };
    scad-utils = {
      url = "github:openscad/scad-utils";
      flake = false;
    };
    nopscadlib = {
      url = "github:nophead/NopSCADlib";
      flake = false;
    };
  };

  outputs = { nixpkgs, bosl2, scad-utils, nopscadlib }: {
    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      libDir = "$HOME/.local/share/OpenSCAD/libraries";
    in pkgs.mkShell {
      packages = with pkgs; [ openscad ];

      shellHook = ''
        mkdir -p ${libDir}

        echo "Setting up OpenSCAD libraries..."
        ln -sf ${bosl2} ${libDir}/BOSL2
        ln -sf ${scad-utils} ${libDir}/scad-utils
        ln -sf ${nopscadlib}/utils/sweep.scad ${libDir}/sweep.scad

        echo "OpenSCAD libraries ready at ${libDir}"
      '';
    };
  };
}
