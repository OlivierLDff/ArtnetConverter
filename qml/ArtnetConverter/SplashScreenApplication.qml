import QtQuick 2.0
import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0 as QLab

import ArtnetConverter 1.0 as ArtnetConverter

Qaterial.SplashScreenApplication
{
  id: root

  property int appTheme: Qaterial.Style.theme

  splashScreen: ArtnetConverter.SplashScreenWindow { }
  window: ArtnetConverter.ApplicationWindow { }

  QLab.Settings { property alias appTheme: root.appTheme }

  Component.onCompleted: function()
  {
    Qaterial.Style.theme = root.appTheme
  }
}