
// Copyright Olivier Le Doeuff 2020 (C)

import QtQuick 2.0
import Qaterial 1.0 as Qaterial
import ArtnetConverter 1.0 as ArtnetConverter

Qaterial.ApplicationWindow
{
  id: window

  title: "ArtnetConverter"

  width: 400
  height: 300

  minimumWidth: 200
  minimumHeight: 200

  ArtnetConverter.Application { anchors.fill: parent }

  Qaterial.WindowLayoutSave { name: "ArtnetConverter" }
}