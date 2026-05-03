{ lib
, stdenv
, fetchurl
, dpkg
, patchelf
, makeWrapper
, wrapGAppsHook3
, qt6
, glib
, gsettings-desktop-schemas
, gtk3
, gtk4
, adwaita-icon-theme
, nss
, nspr
, libGL
, libgbm
, libdrm
, libxkbcommon
, libX11
, libXcomposite
, libXdamage
, libXext
, libXfixes
, libXrandr
, libXrender
, libxcb
, libxshmfence
, libXi
, libXcursor
, libXScrnSaver
, libXtst
, libSM
, libICE
, alsa-lib
, dbus
, cups
, ffmpeg
, libva
, pipewire
, wayland
, vulkan-loader
, systemd
, xdg-utils
, coreutils
, pango
, cairo
, gdk-pixbuf
, atk
, at-spi2-atk
, at-spi2-core
, freetype
, fontconfig
, libuuid
, expat
, zlib
, libxml2
}:

let
  pname = "helium";
  version = "0.11.3.2";

  suffix = {
    aarch64-linux = "arm64";
    x86_64-linux = "amd64";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-bin_${version}-1_${suffix}.deb";
    sha256 = "sha256-Dc9gtij5o7dGAnkE/asgIMo0d7HBp5fGTt+iLS2Ys0M=";
  };

  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    nss
    nspr
    libGL
    libgbm
    libdrm
    libxkbcommon
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libXrender
    libxcb
    libxshmfence
    libXi
    libXcursor
    libXScrnSaver
    libXtst
    libSM
    libICE
    alsa-lib
    dbus
    cups
    ffmpeg
    libva
    pipewire
    wayland
    vulkan-loader
    systemd
    pango
    cairo
    gdk-pixbuf
    atk
    at-spi2-atk
    at-spi2-core
    freetype
    fontconfig
    libuuid
    expat
    zlib
    libxml2
    gtk3
    glib
  ] + ":$out/opt/helium";
in

stdenv.mkDerivation {
  inherit pname version src;

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;

  nativeBuildInputs = [
    patchelf
    makeWrapper
    wrapGAppsHook3
    qt6.wrapQtAppsHook
    dpkg
  ];

  dontWrapQtApps = true;

  buildInputs = [
    glib
    gsettings-desktop-schemas
    gtk3
    gtk4
    adwaita-icon-theme
    qt6.qtbase
    qt6.qtwayland
  ];

  unpackPhase = "dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner";

  installPhase = ''
    runHook preInstall

    mkdir -p $out $out/bin $out/opt

    cp -r opt/helium $out/opt/helium
    cp -r usr/share $out/share

    # Patch main binaries
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/opt/helium/helium

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/opt/helium/helium_crashpad_handler

    # Patch shared libraries that need it
    for lib in $out/opt/helium/libEGL.so $out/opt/helium/libGLESv2.so; do
      if [ -f "$lib" ]; then
        patchelf --set-rpath "${libPath}" "$lib" || true
      fi
    done

    # Create wrapper using makeWrapper to set up environment like helium-wrapper does
    makeWrapper $out/opt/helium/helium $out/bin/helium \
      --set-default CHROME_VERSION_EXTRA nix \
      --prefix LD_LIBRARY_PATH : "$out/opt/helium:$out/opt/helium/lib"

    # Fix .desktop file
    substituteInPlace $out/share/applications/helium.desktop \
      --replace-fail Exec=helium Exec=$out/bin/helium

    # Icon is already in the correct location from the copy above
    # Just ensure the directory structure exists
    mkdir -p $out/share/icons/hicolor/256x256/apps

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${libPath}"
      --prefix PATH : ${lib.makeBinPath [ xdg-utils coreutils ]}
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto}}"
    )
  '';

  meta = {
    homepage = "https://helium.computer";
    description = "Private, fast, and honest web browser based on Chromium";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "helium";
  };
}
