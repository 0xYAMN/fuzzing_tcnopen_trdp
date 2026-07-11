{
	description = "fuzzing_tcnopen_trdp";
	inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

	outputs = { self, nixpkgs, ... }:
		let
			system = "x86_64-linux";
			pkgs   = nixpkgs.legacyPackages.${system};
		in {
			devShells.${system}.default = pkgs.mkShell {
				hardeningDisable = [ "format" "fortify" "fortify3" ];

				nativeBuildInputs = [
					pkgs.cmake
					pkgs.gnumake
					pkgs.gcc
					pkgs.clang
					pkgs.pkg-config
					pkgs.aflplusplus
				];

				buildInputs = [
					pkgs.util-linux.dev  # uuid/uuid.h
					pkgs.util-linux.lib  # libuuid.so
					pkgs.libxml2.dev     # libxml/*.h, for xsd_check
					pkgs.libxml2.out     # libxml2.so
				];
			};
		};
}
