// vim: set et sw=2 ts=2:

import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  // Plugin API (injected by the settings dialog system)
  property var pluginApi: null

  property date editDateOfBirth: pluginApi?.pluginSettings?.dateOfBirth ||
    pluginApi?.manifest?.metadata?.defaultSettings?.dateOfBirth ||
    "1970-01-01T00:00:00"

  property int editYear: editDateOfBirth.getFullYear()
  property int editMonth: editDateOfBirth.getMonth()
  property int editDay: editDateOfBirth.getDate()
  property int editHour: editDateOfBirth.getHours()
  property int editMinute: editDateOfBirth.getMinutes()
  property int editSecond: editDateOfBirth.getSeconds()

  spacing: Style.marginM

  NLabel {
    label: "Date of birth"
    description: "Enter your date of birth"
  }

  RowLayout {
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      NLabel {
        label: "Year"
      }

      NSpinBox {
        from: 1900
        to: { new Date().getFullYear() }
        value: root.editYear
        onValueChanged: root.editYear = value
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      NLabel {
        label: "Month"
      }

      NComboBox {
        model: [
          { "key": "0", "name": "January" },
          { "key": "1", "name": "February" },
          { "key": "2", "name": "March" },
          { "key": "3", "name": "April" },
          { "key": "4", "name": "May" },
          { "key": "5", "name": "June" },
          { "key": "6", "name": "July" },
          { "key": "7", "name": "August" },
          { "key": "8", "name": "September" },
          { "key": "9", "name": "October" },
          { "key": "10", "name": "November" },
          { "key": "11", "name": "December" },
        ]

        currentKey: root.editMonth.toString() || "0"
        onSelected: key => {
          root.editMonth = key;
        }
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      NLabel {
        label: "Day"
      }

      NSpinBox {
        from: 1
        to: 31
        value: root.editDay
        onValueChanged: root.editDay = value
      }
    }
  }

  RowLayout {
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      NLabel {
        label: "Hour"
      }

      NSpinBox {
        from: 0
        to: 23
        value: root.editHour
        onValueChanged: root.editHour = value
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      NLabel {
        label: "Minute"
      }

      NSpinBox {
        from: 0
        to: 59
        value: root.editMinute
        onValueChanged: root.editMinute = value
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      NLabel {
        label: "Second"
      }

      NSpinBox {
        from: 0
        to: 59
        value: root.editSecond
        onValueChanged: root.editSecond = value
      }
    }
  }

  // Required: Save function called by the dialog
  function saveSettings() {
    let year = root.editYear
    let month = String(root.editMonth + 1).padStart(2, "0")
    let day = String(root.editDay).padStart(2, "0")

    let hour = String(root.editHour).padStart(2, "0")
    let minute = String(root.editMinute).padStart(2, "0")
    let second = String(root.editSecond).padStart(2, "0")

    root.editDateOfBirth = new Date(`${year}-${month}-${day}T${hour}:${minute}:${second}`)

    pluginApi.pluginSettings.dateOfBirth = root.editDateOfBirth
    pluginApi.saveSettings()
  }
}
