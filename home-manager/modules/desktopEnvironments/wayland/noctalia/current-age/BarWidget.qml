// vim: set et sw=2 ts=2:

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  // Plugin API (injected by PluginService)
  property var pluginApi: null

  // Required properties for bar widgets
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  // Per-screen bar properties (for multi-monitor and vertical bar support)
  readonly property string screenName: screen?.name ?? ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  // Content dimensions (visual capsule size)
  readonly property real contentWidth: content.implicitWidth + Style.marginM * 2
  readonly property real contentHeight: capsuleHeight

  // Widget dimensions (extends to full bar height for better click area)
  implicitWidth: contentWidth
  implicitHeight: contentHeight

  property date dateOfBirth: pluginApi?.pluginSettings?.dateOfBirth ||
    pluginApi?.manifest?.metadata?.defaultSettings?.dateOfBirth

  property string mainText: ""

  NPopupContextMenu {
    id: contextMenu

    model: [
      {
        "label": "Widget settings",
        "action": "settings",
        "icon": "settings"
      },
    ]

    onTriggered: action => {
      contextMenu.close();
      PanelService.closeContextMenu(screen);

      if (action === "settings") {
        if (pluginApi) {
          BarService.openPluginSettings(screen, pluginApi.manifest);
        }
      }
    }
  }

  // Visual capsule - centered within the full click area
  Rectangle {
    id: visualCapsule
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)
    width: root.contentWidth
    height: root.contentHeight
    color: Style.capsuleColor
    radius: Style.radiusL
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    // Widget content - centered in visualCapsule
    RowLayout {
      id: content
      anchors.centerIn: parent
      spacing: Style.marginS

      NIcon {
        icon: "calendar-time"
        color: Color.mPrimary
      }

      Process {
        // TODO: Timer to call every second
        running: true
        command: [
          "/tmp/tmp.zONsZN2K2v/current-age/target/release/current-age", // "@EXTERNAL_PROGRAM@",
          root.dateOfBirth.toISOString()
        ]
        stdout: SplitParser {
          onRead: message => root.mainText = message
        }
      }

      NText {
        text: root.mainText
        color: Color.mOnSurface
        pointSize: barFontSize
        font.weight: Font.Medium
      }
    }
  }

  // MouseArea at root level for extended click area
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.RightButton

    onEntered: {
      TooltipService.show(root, "Current age", BarService.getTooltipDirection());
    }

    onExited: {
      TooltipService.hide();
    }

    onClicked: mouse => {
      if (mouse.button === Qt.RightButton) {
        PanelService.showContextMenu(contextMenu, root, screen)
      }
    }
  }
}
