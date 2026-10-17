// Pure helpers for the Nitro fans widget (Node-testable, no Qt deps).
function percentForMode(mode) {
  switch (String(mode || "").trim()) {
    case "quiet": return 30
    case "balanced": return 60
    case "performance": return 85
    case "turbo": return 100
    case "auto": return 50
    default: {
      var m = String(mode || "").match(/^manual-(\d+)$/)
      if (m) return Math.max(0, Math.min(100, parseInt(m[1], 10)))
      return 50
    }
  }
}

function presetKeyForMode(mode) {
  var m = String(mode || "").trim()
  if (m === "quiet" || m === "balanced" || m === "performance" || m === "turbo" || m === "auto") return m
  return "manual"
}

function iconFor(mode, pct) {
  var p = (pct === undefined || pct === null) ? percentForMode(mode) : pct
  if (String(mode) === "auto") return "󰾕"
  if (p <= 0) return "󰾔"
  if (p <= 35) return "󰾔"
  if (p <= 70) return "󰾐"
  if (p < 100) return "󰾖"
  return "󰾗"
}

// Parse `nitro-fan status` first lines:
//   "Nitro AN515-44 | mode: turbo"
//   "CPU: 62.1°C  AMD-GPU: 50.0°C  NVIDIA: 53°C"
function parseNitroStatus(text) {
  var out = { mode: "", cpu: "", gpu: "", nv: "", readOnly: false }
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var m = lines[i].match(/mode:\s*(\S+)/)
    if (m) out.mode = m[1]
    var t = lines[i].match(/CPU:\s*(\S+).*AMD-GPU:\s*(\S+).*NVIDIA:\s*(\S+)/)
    if (t) { out.cpu = t[1]; out.gpu = t[2]; out.nv = t[3] }
    if (/READ-ONLY/.test(lines[i])) out.readOnly = true
  }
  return out
}

// Parse `nbfc status` chunk: Current/Target per fan + Read-only flag.
function parseNbfcStatus(text) {
  var out = { readOnly: null, fans: [] }
  var lines = String(text || "").split("\n")
  var cur = null
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]
    var ro = line.match(/Read-only\s*:\s*(true|false)/i)
    if (ro) out.readOnly = /true/i.test(ro[1])
    var disp = line.match(/Fan Display Name\s*:\s*(.+)/)
    if (disp) { cur = { name: disp[1].trim(), current: "", target: "" }; out.fans.push(cur); continue }
    var c = line.match(/Current Fan Speed\s*:\s*(\S+)/)
    if (c && cur) cur.current = c[1]
    var t = line.match(/Target Fan Speed\s*:\s*(\S+)/)
    if (t && cur) cur.target = t[1]
  }
  return out
}

if (typeof module !== "undefined") {
  module.exports = { percentForMode, presetKeyForMode, iconFor, parseNitroStatus, parseNbfcStatus }
}
