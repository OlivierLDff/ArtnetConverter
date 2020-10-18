
// Copyright Olivier Le Doeuff 2020 (C)

import QtQuick 2.0
import Qaterial 1.0 as Qaterial

Qaterial.SplashScreenWindow
{
  id: splash

  image: Qaterial.Style.theme === Qaterial.Style.Theme.Dark ? "qrc:/ArtnetConverter/logo-white.png" : "qrc:/ArtnetConverter/logo-black.png"
  padding: Qaterial.Style.card.horizontalPadding

  text: "Loading ..."
  version: "1.0.0"

  property int dots: 1

  Timer
  {
    interval: 1000; running: true; repeat: true
    onTriggered: function()
    {
      ++splash.dots
      let text = "Loading "
      for(let i = 0; i < splash.dots; ++i)
        text += '.'

      splash.text = text
      if(splash.dots == 3)
        splash.dots = 0
    }
  }
}