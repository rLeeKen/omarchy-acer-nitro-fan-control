import QtQuick 6.11
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import "Model.js" as Model

Panel {
  id: root
  moduleName: "chmonya.fans"
  ipcTarget: "chmonya.fans"
  manageIpc: false

  // ---- State ----
  property string mode: "auto"
  property int targetPct: 50
  property int livePct: -1
  property string tempsLine: "—"
  property bool readOnly: false
  property bool hot: false
  property string nbfcLine: ""
  property int sliderPreview: -1
  property int focusIndex: 0      // 0..3 = пресеты, 4 = auto, 5 = слайдер
  property int pendingManual: -1

  readonly property bool isAuto: root.mode === "auto"
  readonly property bool sliderEnabled: !root.isAuto && !root.readOnly
  readonly property bool busy: setProc.running
  readonly property int shownPct: sliderPreview >= 0 ? sliderPreview
    : (root.isAuto && root.livePct >= 0 ? root.livePct : root.targetPct)

  readonly property var presetModes: ["quiet", "balanced", "performance", "turbo", "auto"]
  readonly property var presetLabels: ["Quiet", "Balanced", "Performance", "Turbo"]

  onFocusIndexChanged: root.sliderPreview = -1
  onSliderEnabledChanged: {
    if (!root.sliderEnabled && root.focusIndex === 5) {
      root.focusIndex = 4
    }
  }

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function applyMode(m) {
    if (root.readOnly || root.busy) return
    setProc.command = ["nitro-fan", m]
    setProc.running = true
  }

  function applyManual(pct) {
    if (!root.sliderEnabled) return
    var v = Math.max(0, Math.min(100, Math.round(pct)))
    if (root.busy) {
      root.pendingManual = v
      return
    }
    setProc.command = ["nitro-fan", "set", String(v)]
    setProc.running = true
  }

  IpcHandler {
    target: "chmonya.fans"
    function open() { root.open() }
    function close() { root.close() }
    function toggle() { root.toggle() }
    function show() { root.open() }
    function hide() { root.close() }
  }

  property FileView modeFile: FileView {
    path: Quickshell.env("HOME") + "/.local/state/nitro-fan/mode"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      var m = String(text() || "").trim() || "auto"
      root.mode = m
      root.targetPct = Model.percentForMode(m)
    }
    onLoadFailed: {
      root.mode = "auto"
      root.targetPct = 50
    }
  }

  function parseStatus(raw) {
    var parts = String(raw || "").split("__NBFC__")
    var nitro = Model.parseNitroStatus(parts[0] || "")
    if (nitro.mode) {
      root.mode = nitro.mode
      root.targetPct = Model.percentForMode(nitro.mode)
    }
    if (nitro.cpu) {
      var cpu = parseFloat(nitro.cpu)
      var gpu = parseFloat(nitro.gpu)
      root.hot = (!isNaN(cpu) && cpu > 85) || (!isNaN(gpu) && gpu > 85)
      root.tempsLine = "CPU " + nitro.cpu + " · GPU " + nitro.gpu + " · NV " + nitro.nv
    }
    var nbfc = Model.parseNbfcStatus(parts[1] || "")
    if (nbfc.readOnly !== null) root.readOnly = nbfc.readOnly
    else root.readOnly = !!nitro.readOnly

    if (nbfc.fans.length > 0) {
      var bits = []
      var peak = -1
      for (var i = 0; i < nbfc.fans.length; i++) {
        var f = nbfc.fans[i]
        var cur = parseFloat(f.current)
        if (!isNaN(cur)) {
          if (cur > 100) cur = Math.round(cur / 6122 * 100)
          cur = Math.max(0, Math.min(100, Math.round(cur)))
          if (cur > peak) peak = cur
          bits.push(f.name.split(" ")[0] + " " + cur + "%")
        }
      }
      root.nbfcLine = bits.join(" · ")
      root.livePct = peak
    } else {
      root.nbfcLine = ""
      root.livePct = -1
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onCompleted: {
    modeFile.reload()
    refresh()
  }

  onOpenedChanged: {
    if (opened) {
      refresh()
      root.focusIndex = 0
    } else {
      root.sliderPreview = -1
    }
  }

  Timer {
    interval: 3000
    running: root.opened
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: statusProc
    command: ["bash", "-c", "nitro-fan status 2>&1; echo __NBFC__; nbfc status 2>&1"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseStatus(text)
    }
  }

  Process {
    id: setProc
    onRunningChanged: {
      if (running) return
      root.sliderPreview = -1
      if (root.pendingManual >= 0) {
        var v = root.pendingManual
        root.pendingManual = -1
        root.applyManual(v)
        return
      }
      root.refresh()
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: Model.iconFor(root.mode, root.shownPct)
    tooltipText: "Nitro Fans: " + root.mode + " " + root.shownPct + "%\n" + root.tempsLine
    onPressed: root.toggle()
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(panelColumn.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      focus: true
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      onMoveRequested: function(dx, dy) {
        if (dy !== 0) {
          if (!root.sliderEnabled) {
            root.focusIndex = root.focusIndex === 4 ? 0 : 4
          } else if (root.focusIndex === 5) {
            root.focusIndex = dy > 0 ? 0 : 4
          } else if (root.focusIndex === 4) {
            root.focusIndex = dy < 0 ? 0 : 5
          } else {
            root.focusIndex = dy > 0 ? 4 : 5
          }
        }
        if (dx !== 0) {
          if (root.focusIndex >= 0 && root.focusIndex < 4) {
            root.focusIndex = Math.max(0, Math.min(3, root.focusIndex + dx))
          } else if (root.focusIndex === 5 && root.sliderEnabled) {
            var step = dx > 0 ? 5 : -5
            root.sliderPreview = Math.max(0, Math.min(100, root.shownPct + step))
          }
        }
      }

      onActivateRequested: {
        if (root.focusIndex === 5) {
          root.applyManual(root. shownPct)
        } else {
          root.applyMode(root.presetModes[root.focusIndex])
        }
      }
    }

    Column {
      id: panelColumn
      width: parent.width
      spacing: Style.space(12)

      // ---------- Hero ----------
      Item {
        width: parent.width
        implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight)

        Text {
          id: heroIcon
          textFormat: Text.PlainText
          text: Model.iconFor(root.mode, root.shownPct)
          color: Color.accent
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.display
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
        }

        Column {
          id: heroLabels
          anchors.left: heroIcon.right
          anchors.leftMargin: Style.space(14)
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(2)

          Text {
            text: "Nitro Fans"
            color: root.hot ? root.bar.urgent : root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.title
            font.bold: true
            elide: Text.ElideRight
            width: parent.width
          }

          Text {
            textFormat: Text.PlainText
            text: root.tempsLine.toUpperCase()
            color: Qt.darker(root.bar.foreground, 1.4)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 1.2
            elide: Text.ElideRight
            width: parent.width
          }
        }
      }

      PanelSeparator { foreground: root.bar.foreground }

      // ---------- Slider ----------
      Column {
        width: parent.width
        spacing: Style.space(6)

        Item {
          width: parent.width
          implicitHeight: Math.max(sliderHeader.implicitHeight, sliderPct.implicitHeight)

          PanelSectionHeader {
            id: sliderHeader
            text: root.isAuto ? "SPEED · LIVE" : "SPEED"
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            id: sliderPct
            textFormat: Text.PlainText
            text: root.shownPct + "%"
            color: Color.accent
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.title
            font.bold: true
            anchors.right: parent.right
            anchors.rightMargin: Style.space(6)
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        CursorSurface {
          width: parent.width
          height: fanSlider.implicitHeight + Style.spacing.controlGap
          foreground: root.focusIndex === 5 ? root.bar.urgent : root.bar.foreground
          outline: true
          enabled: root.sliderEnabled
          opacity: root.sliderEnabled ? 1.0 : 0.45

          Behavior on opacity {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
          }

          PanelSlider {
            id: fanSlider
            bar: root.bar
            anchors.fill: parent
            anchors.leftMargin: Style.space(6)
            anchors.rightMargin: Style.space(6)
            minimum: 0
            maximum: 100
            step: 1
            integer: true
            value: root.shownPct
            enabled: root.sliderEnabled
            onMoved: function(v) { root.sliderPreview = Math.round(v) }
            onReleased: function(v) { root.applyManual(v) }
          }
        }
      }

      // ---------- Presets ----------
      PanelSectionHeader {
        text: "MODE"
        foreground: root.bar.foreground
        fontFamily: root.bar.fontFamily
      }

      Grid {
        id: presetGrid
        width: parent.width
        columns: 4
        spacing: Style.spacing.xs

        readonly property real cellWidth: (width - spacing * (columns - 1)) / columns

        Repeater {
          model: 4
          PresetPill {
            modeName: root.presetModes[index]
            label: root.presetLabels[index]
            pillIndex: index
            width: presetGrid.cellWidth
            focused: root.focusIndex === index
          }
        }
      }

      // ---------- Auto ----------
      PresetPill {
        modeName: "auto"
        label: "AUTO"
        pillIndex: 4
        wide: true
        width: parent.width
        focused: root.focusIndex === 4
      }

      // ---------- Footer ----------
      Text {
        width: parent.width
        visible: root.nbfcLine !== "" || root.readOnly
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        text: root.readOnly ? "⚠ READ-ONLY: sudo nbfc restart" : root.nbfcLine
        color: root.readOnly ? root.bar.urgent : Qt.darker(root.bar.foreground, 1.4)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
      }
    }
  }

  component PresetPill: Item {
    id: pill
    property string modeName: ""
    property string label: ""
    property bool wide: false
    property bool focused: false
    property int pillIndex: -1

    readonly property bool active: root.mode === modeName
    readonly property color railColor: pill.active ? root.bar.urgent : Qt.darker(root.bar.urgent, 1.3)

    implicitHeight: pillBtn.implicitHeight

    Rectangle {
      width: Style.space(3)
      anchors.top: pillBtn.top
      anchors.bottom: pillBtn.bottom
      anchors.left: pillBtn.left
      radius: width / 2
      color: pill.railColor
      visible: pill.active || pill.focused
    }

    Rectangle {
      width: Style.space(3)
      anchors.top: pillBtn.top
      anchors.bottom: pillBtn.bottom
      anchors.right: pillBtn.right
      radius: width / 2
      color: pill.railColor
      visible: pill.active || pill.focused
    }

    Button {
      id: pillBtn
      anchors.fill: parent
      anchors.leftMargin: Style.space(6)
      anchors.rightMargin: Style.space(6)
      text: pill.wide ? ("󰾕  " + pill.label) : pill.label
      fontSize: Style.font.caption
      foreground: root.bar.foreground
      fontFamily: root.bar.fontFamily
      horizontalPadding: Style.spacing.sm
      verticalPadding: Style.spacing.controlPaddingY
      bordered: true
      selected: pill.active
      enabled: !root.readOnly && !root.busy
      onClicked: root.applyMode(pill.modeName)

      onHovered: function(isHovered) {
        if (isHovered) root.focusIndex = pill.pillIndex
      }
    }
  }
}