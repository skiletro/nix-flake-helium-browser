final: prev: {
  helium = prev.callPackage ./helium.nix { widevine-cdm = null; };
  helium-wv = prev.callPackage ./helium.nix { widevine-cdm = final.widevine-cdm; };
}
