{
  pkgs, stdenv, fetchurl, autoreconfHook, pkg-config, which, pidgin, dbus,
  gnutls, farstream, libopus, protobufc, json-glib, libxml2, libsoup, discount,
  imagemagick, gst_all_1, dbus-glib, python3
}:
let
  python' = python3.withPackages (ps: [ ps.dbus-python ]);
in stdenv.mkDerivation rec {
  pname = "pidgin-chime";
  version = "1.3-20210430";

  src = fetchurl {
    url = "https://github.com/awslabs/${pname}/archive/b430eba40f9e5e389cfe2f78e37a68e3cc3aa40a.tar.gz";
    hash = "sha256-MXyFiL+sPoTVXS51KIC5Th9A+O91pxUQHCSsXeGS9xY=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config which imagemagick ];
  buildInputs = [
    # discount is needed for libmarkdown
    pidgin dbus gnutls farstream libopus protobufc json-glib libxml2 libsoup
    discount gst_all_1.gst-plugins-base dbus-glib python'
  ];

  autoreconfPhase = "NOCONFIGURE=x ./autogen.sh";

  # Can't find headers for gstreamer plugins otherwise
  # Beside that libpurple fails to propelry specify dependency to dbus-glib
  NIX_CFLAGS_COMPILE = "-I${gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0 -I${dbus-glib.dev}/include/dbus-1.0";

  # Rely on pidgin-with-plugins to combine these dirs
  postPatch = ''
    sed -i \
      -e "s@^\\(pidgin_datadir\\)=.*\$@\\1=$out/share@" \
      -e "s@^\\(purple_plugindir\\)=.*\$@\\1=$out/lib/purple-${pidgin.majorVersion}@" \
      -e "s@^\\(pidgin_plugindir\\)=.*\$@\\1=$out/lib/pidgin@" \
      -e "s@^\\(gstplugindir\\)=.*\$@\\1=$out/lib/gstreamer-1.0@" \
      -e "s@^\\(fsplugindir\\)=.*\$@\\1=$out/lib/farstream-0.2@" \
      configure.ac

    sed -i \
      -e "s@^\\(Exec\\)=\\([^/]\\)@\\1=$out/bin/\\2@" \
      chime-auth.desktop
  '';
}
