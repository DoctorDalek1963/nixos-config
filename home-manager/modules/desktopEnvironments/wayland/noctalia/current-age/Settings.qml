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

  // TODO: Split into year, month, etc.

  spacing: Style.marginM

  NTextInput {
    text: "Hello"
    // onTextChanged: root.editMessage = text

    // TODO: Dropdowns or limited text inputs for each part
  }

  // Required: Save function called by the dialog
  function saveSettings() {
    // TODO: Reassemble parts into date object
    pluginApi.pluginSettings.dateOfBirth = root.editDateOfBirth
    pluginApi.saveSettings()
  }
}
