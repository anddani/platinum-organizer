{ mkDerivation, base, bytestring, cassava, stdenv, vector }:
mkDerivation {
  pname = "platinum-organizer";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base bytestring cassava vector ];
  license = "unknown";
  hydraPlatforms = stdenv.lib.platforms.none;
}
