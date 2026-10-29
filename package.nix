{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libGL,
  libnotify,
  libpulseaudio,
  libuuid,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemdLibs,
  libx11,
  libxscrnsaver,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libxcb,
  libxshmfence,
}:

stdenv.mkDerivation rec {
  pname = "bettercrewlink";
  version = "3.2.2";

  src = appimageTools.extract {
    inherit pname version;
    src = fetchurl {
      url = "https://github.com/OhMyGuus/BetterCrewLink/releases/download/v${version}/Better-CrewLink-${version}.AppImage";
      hash = "sha256-QDhm1mv7O2sAcH8X4GnEek7Fxz/UX59Gzh7i8YVocAA=";
    };
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libnotify
    libpulseaudio
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemdLibs
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
    libxshmfence
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libappindicator.so.1"
    "libindicator.so.7"
    "libgconf-2.so.4"
    "libdbusmenu-gtk.so.4"
    "libdbusmenu-glib.so.4"
    "libgtk-x11-2.0.so.0"
    "libdbus-glib-1.so.2"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt/bettercrewlink $out/bin
    cp -r * $out/opt/bettercrewlink/
    chmod +x $out/opt/bettercrewlink/bettercrewlink

    # Clean up unnecessary AppImage wrapper artifacts
    rm -f $out/opt/bettercrewlink/AppRun

    makeWrapper $out/opt/bettercrewlink/bettercrewlink $out/bin/bettercrewlink \
      --add-flags "--ozone-platform-hint=auto"

    mkdir -p $out/share/applications
    cp bettercrewlink.desktop $out/share/applications/
    substituteInPlace $out/share/applications/bettercrewlink.desktop \
      --replace-fail "Exec=AppRun" "Exec=bettercrewlink"

    mkdir -p $out/share/icons/hicolor/512x512/apps
    cp usr/share/icons/hicolor/512x512/apps/bettercrewlink.png $out/share/icons/hicolor/512x512/apps/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Free, open-source proximity voice chat for Among Us";
    homepage = "https://github.com/OhMyGuus/BetterCrewLink";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "bettercrewlink";
  };
}
