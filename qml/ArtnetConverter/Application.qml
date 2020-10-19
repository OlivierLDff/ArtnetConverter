import QtQuick 2.0
import Qaterial 1.0 as Qaterial

Qaterial.ScrollablePage
{
  id: root

  property int universe: 0
  readonly property int artnetUniverse: universe & 0x000F
  readonly property int artnetSubNet: (universe & 0x00F0) >> 4
  readonly property int artnetNetwork: ((universe & 0xFF00) >> 8) + 1

  function evaluateUniverseFromDecimalInput()
  {
    universe = parseInt(decimalTextField.text)
  }

  function evaluateUniverseFromArtnetInput()
  {
    const network = (parseInt(networkTextField.text) - 1) << 8
    const subnet = parseInt(subNetTextField.text, 16) << 4
    const univ = parseInt(universeTextField.text, 16)

    universe = network + subnet + univ
  }

  header: Qaterial.ToolBar
  {
    Qaterial.Label
    {
      anchors.centerIn: parent

      text: "Artnet To Decimal Converter"
      textType: Qaterial.Style.TextType.Title
    }
  }

  Column
  {
    id: mainColumn
    spacing: Qaterial.Style.card.horizontalPadding

    Qaterial.Label
    {
      width: parent.width
      text: "Convert Absolute universe to Network/SubNet/Universe for Art-Net protocol"
      wrapMode: Text.Wrap
      padding: Qaterial.Style.card.horizontalPadding
    }

    Qaterial.TextField
    {
      id: decimalTextField

      x: Qaterial.Style.card.horizontalPadding
      width: parent.width - 32
      title: "Absolute Universe"
      text: universe.toString()
      helperText: "Universe from 0 to 65535"
      inputMethodHints: Qt.ImhFormattedNumbersOnly
      validator: IntValidator{ bottom: 0; top: 65535 }

      onTextEdited: function()
      {
        if(acceptableInput)
          root.evaluateUniverseFromDecimalInput()
      }
    }

    Qaterial.Icon
    {
      icon: Qaterial.Icons.arrowUpDownBold
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Qaterial.Grid
    {
      width: parent.width
      columns: 12

      Qaterial.TextField
      {
        id: networkTextField

        Qaterial.Layout.extraSmall: Qaterial.Layout.FillParent
        Qaterial.Layout.small: Qaterial.Layout.FillThird
        Qaterial.Layout.medium: Qaterial.Layout.FillThird
        Qaterial.Layout.large: Qaterial.Layout.FillThird
        Qaterial.Layout.extraLarge: Qaterial.Layout.FillThird

        title: "Network"
        text: root.artnetNetwork.toString()
        validator: IntValidator{ bottom: 1; top: 128 }
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        helperText: "1 to 128"

        onTextEdited: function()
        {
          if(acceptableInput)
            root.evaluateUniverseFromArtnetInput()
        }
      }

      Qaterial.TextField
      {
        id: subNetTextField

        Qaterial.Layout.extraSmall: Qaterial.Layout.FillParent
        Qaterial.Layout.small: Qaterial.Layout.FillThird
        Qaterial.Layout.medium: Qaterial.Layout.FillThird
        Qaterial.Layout.large: Qaterial.Layout.FillThird
        Qaterial.Layout.extraLarge: Qaterial.Layout.FillThird

        title: "Sub-Net"
        text: root.artnetSubNet.toString(16).toUpperCase()
        validator: RegExpValidator { regExp: /[a-fA-F0-9]/ }
        helperText: "0 to F"
        inputMethodHints: Qt.ImhSensitiveData

        onTextEdited: function()
        {
          if(acceptableInput)
            root.evaluateUniverseFromArtnetInput()
        }
      }

      Qaterial.TextField
      {
        id: universeTextField

        Qaterial.Layout.extraSmall: Qaterial.Layout.FillParent
        Qaterial.Layout.small: Qaterial.Layout.FillThird
        Qaterial.Layout.medium: Qaterial.Layout.FillThird
        Qaterial.Layout.large: Qaterial.Layout.FillThird
        Qaterial.Layout.extraLarge: Qaterial.Layout.FillThird

        title: "Universe"
        text: root.artnetUniverse.toString(16).toUpperCase()
        validator: RegExpValidator { regExp: /[a-fA-F0-9]/ }
        helperText: "0 to F"
        inputMethodHints: Qt.ImhSensitiveData

        onTextEdited: function()
        {
          if(acceptableInput)
            root.evaluateUniverseFromArtnetInput()
        }
      }
    } // Grid

    Image
    {
      id: logo
      anchors.horizontalCenter: parent.horizontalCenter
      source: Qaterial.Style.theme === Qaterial.Style.Theme.Dark ? "qrc:/ArtnetConverter/logo-white.png" : "qrc:/ArtnetConverter/logo-black.png"
      width: parent.width/2
      fillMode: Image.PreserveAspectFit
    }
  } // Column
}