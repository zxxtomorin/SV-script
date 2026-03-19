--[[
    MIT License

    Copyright (c) 2026 zxxtomorin(bilibili 火丁的卫兵)

    tomorin - 张力（音高映射版）

    I would appreciate it if you could credit me in the work.
    如果能在工程或作品标注我的名字，我将不胜感激。

    This plugin was made with the assistance of Deepseek.
    本插件使用 Deepseek 辅助制作。
--]]

function getClientInfo()
  return {
    name = SV:T("张力（音高映射版）"),
    category = "tomorin",
    author = "tomorin",
    versionNumber = 1,
    minEditorVersion = 65540,
  }
end

function getTranslations(langCode)
  if langCode == "zh-cn" then
    return {
      { "Auto Tension Settings", "自动张力参数设置" },
      { "Please adjust parameters and click OK.", "请调整参数后点击“确定”。" },
      { "Pitch Mapping", "音高映射" },
      { "Lowest pitch (MIDI)", "最低音 (MIDI)" },
      { "Tension at lowest pitch", "最低音张力值" },
      { "Highest pitch (MIDI)", "最高音 (MIDI)" },
      { "Tension at highest pitch", "最高音张力值" },
      { "Onset/Mid/End Adjustments", "起点/中点/终点调整" },
      { "Onset boost factor", "起点增强因子" },
      { "Mid boost factor (long notes)", "长音中点增强因子" },
      { "End decay factor", "终点衰减因子" },
      { "Long Notes & Jitter", "长音与抖动" },
      { "Long note threshold (quarters)", "长音阈值 (四分音符数)" },
      { "Jitter amount", "抖动幅度" },
      { "Points per quarter note", "每四分音符点数" },
      { "Peak Processing", "峰值处理" },
      { "Peak reduction factor", "峰值降低因子" },
      { "Neighbor boost factor", "相邻音增强因子" },
      { "OK", "确定" },
      { "Cancel", "取消" },
      { "No note group open.", "没有打开的音符组。" },
      { "Please open a note group (double‑click a track).", "请打开一个音符组（双击音轨）。" },
      { "Done", "完成" },
      { "Tension drawn for %d notes.", "已为 %d 个音符绘制张力。" },
    }
  end
  return {}
end

function main()
  local mainEditor = SV:getMainEditor()
  local groupRef = mainEditor:getCurrentGroup()
  if not groupRef then
    SV:showMessageBox(SV:T("Info"), SV:T("Please open a note group (double‑click a track)."))
    SV:finish()
    return
  end

  -- 构建对话框表单
  local form = {
    title = SV:T("Auto Tension Settings"),
    message = SV:T("Please adjust parameters and click OK."),
    buttons = "OkCancel",
    widgets = {
      -- 音高映射
      { type = "Label", text = SV:T("Pitch Mapping") },
      { type = "Slider", name = "baseLowPitch",   label = SV:T("Lowest pitch (MIDI)"),   minValue = 0, maxValue = 127, interval = 1,   default = 48,  format = "%3.0f" },
      { type = "Slider", name = "baseLowTension", label = SV:T("Tension at lowest pitch"), minValue = -1, maxValue = 1, interval = 0.01, default = 0.1, format = "%+5.2f" },
      { type = "Slider", name = "baseHighPitch",  label = SV:T("Highest pitch (MIDI)"),  minValue = 0, maxValue = 127, interval = 1,   default = 84,  format = "%3.0f" },
      { type = "Slider", name = "baseHighTension",label = SV:T("Tension at highest pitch"),minValue = -1, maxValue = 1, interval = 0.01, default = 0.7, format = "%+5.2f" },

      -- 起点/中点/终点调整
      { type = "Label", text = SV:T("Onset/Mid/End Adjustments") },
      { type = "Slider", name = "onsetBoost", label = SV:T("Onset boost factor"), minValue = 0, maxValue = 2, interval = 0.01, default = 1.1, format = "%4.2f" },
      { type = "Slider", name = "midBoost",   label = SV:T("Mid boost factor (long notes)"), minValue = 0, maxValue = 2, interval = 0.01, default = 1.5, format = "%4.2f" },
      { type = "Slider", name = "endDecay",   label = SV:T("End decay factor"), minValue = 0, maxValue = 1, interval = 0.01, default = 0.9, format = "%4.2f" },

      -- 长音与抖动
      { type = "Label", text = SV:T("Long Notes & Jitter") },
      { type = "Slider", name = "longNoteThresholdBeats", label = SV:T("Long note threshold (quarters)"), minValue = 0, maxValue = 10, interval = 0.5, default = 2, format = "%3.1f" },
      { type = "Slider", name = "jitterAmount", label = SV:T("Jitter amount"), minValue = 0, maxValue = 0.5, interval = 0.01, default = 0.05, format = "%4.2f" },
      { type = "Slider", name = "pointDensity", label = SV:T("Points per quarter note"), minValue = 1, maxValue = 16, interval = 1, default = 4, format = "%3.0f" },

      -- 峰值处理
      { type = "Label", text = SV:T("Peak Processing") },
      { type = "Slider", name = "peakReduce",   label = SV:T("Peak reduction factor"), minValue = 0, maxValue = 1, interval = 0.01, default = 0.5, format = "%4.2f" },
      { type = "Slider", name = "neighborBoost",label = SV:T("Neighbor boost factor"), minValue = 0, maxValue = 2, interval = 0.01, default = 1.3, format = "%4.2f" },
    }
  }

  local results = SV:showCustomDialog(form)
  if not results or not results.status then
    SV:finish()
    return
  end

  -- 从 results.answers 中获取参数
  local params = {
    baseLowPitch           = results.answers.baseLowPitch,
    baseLowTension         = results.answers.baseLowTension,
    baseHighPitch          = results.answers.baseHighPitch,
    baseHighTension        = results.answers.baseHighTension,
    onsetBoost             = results.answers.onsetBoost,
    midBoost               = results.answers.midBoost,
    endDecay               = results.answers.endDecay,
    longNoteThresholdBeats = results.answers.longNoteThresholdBeats,
    jitterAmount           = results.answers.jitterAmount,
    pointDensity           = results.answers.pointDensity,
    peakReduce             = results.answers.peakReduce,
    neighborBoost          = results.answers.neighborBoost,
  }

  drawTension(groupRef, params)
end

function drawTension(groupRef, params)
  local group = groupRef:getTarget()
  local tension = group:getParameter("tension")
  tension:removeAll()

  local noteCount = group:getNumNotes()
  if noteCount == 0 then
    SV:showMessageBox(SV:T("Info"), SV:T("No notes in this group."))
    SV:finish()
    return
  end

  local notes = {}
  for i = 1, noteCount do
    notes[i] = group:getNote(i)
  end

  local QUARTER = SV.QUARTER
  local longNoteThreshold = params.longNoteThresholdBeats * QUARTER
  local step = QUARTER / params.pointDensity

  -- 基础线性映射
  local baseTension = {}
  local pitchRange = params.baseHighPitch - params.baseLowPitch
  local tensionRange = params.baseHighTension - params.baseLowTension
  for i = 1, noteCount do
    local pitch = notes[i]:getPitch()
    local t = (pitch - params.baseLowPitch) / pitchRange
    if t < 0 then t = 0 end
    if t > 1 then t = 1 end
    local val = params.baseLowTension + t * tensionRange
    baseTension[i] = clamp(val, -1, 1)
  end

  -- 峰值调整
  local adjusted = {}
  for i = 1, noteCount do adjusted[i] = baseTension[i] end
  for i = 1, noteCount do
    local currPitch = notes[i]:getPitch()
    local leftPitch = i > 1 and notes[i - 1]:getPitch() or -math.huge
    local rightPitch = i < noteCount and notes[i + 1]:getPitch() or -math.huge

    if currPitch > leftPitch and currPitch > rightPitch then
      adjusted[i] = adjusted[i] * params.peakReduce
      if i > 1 then adjusted[i - 1] = adjusted[i - 1] * params.neighborBoost end
      if i < noteCount then adjusted[i + 1] = adjusted[i + 1] * params.neighborBoost end
    end
  end

  for i = 1, noteCount do
    adjusted[i] = clamp(adjusted[i], -1, 1)
  end

  math.randomseed(os.time())

  -- 生成控制点
  for i = 1, noteCount do
    local note = notes[i]
    local onset = note:getOnset()
    local duration = note:getDuration()
    local endPos = onset + duration
    local level = adjusted[i]

    tension:add(onset, clamp(level * params.onsetBoost, -1, 1))

    local mid = onset + duration * 0.5
    if duration >= longNoteThreshold then
      tension:add(mid, clamp(level * params.midBoost, -1, 1))

      local numSteps = math.floor(duration / step)
      for j = 1, numSteps - 1 do
        local t = onset + j * step
        if math.abs(t - mid) > step * 0.8 then
          local val = level + (math.random() * 2 - 1) * params.jitterAmount
          tension:add(t, clamp(val, -1, 1))
        end
      end
    else
      tension:add(mid, clamp(level, -1, 1))
    end

    tension:add(endPos, clamp(level * params.endDecay, -1, 1))
  end

  local msg = string.format(SV:T("Tension drawn for %d notes."), noteCount)
  SV:showMessageBox(SV:T("Done"), msg)
  SV:finish()
end

function clamp(value, min, max)
  if value < min then return min end
  if value > max then return max end
  return value
end
