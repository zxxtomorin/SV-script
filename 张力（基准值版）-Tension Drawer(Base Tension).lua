--[[
    MIT License

    Copyright (c) 2026 zxxtomorin(bilibili 火丁的卫兵)

    tomorin - 张力（基准值版）

    I would appreciate it if you could credit me in the work.
    如果能在工程或作品标注我的名字，我将不胜感激。

    This plugin was made with the assistance of Deepseek.
    本插件使用 Deepseek 辅助制作。
--]]


function getClientInfo()
  return {
    name = SV:T("Tension Drawer(Base Tension)"),
    category = "tomorin",
    author = "tomorin",
    versionNumber = 1,
    minEditorVersion = 65540,
  }
end

function getTranslations(langCode)
  if langCode == "zh-cn" then
    return {
      { "Tension Drawer(Base Tension)", "张力（基准值版）" },
      { "Please adjust parameters and click OK.", "请调整参数后点击“确定”。" },
      { "Base Tension", "基准张力" },
      { "Base tension value", "基准张力值" },
      { "Attack Boost", "音头增强" },
      { "Attack boost offset", "音头增强偏移量" },
      { "Attack region (0-1)", "音头作用区域 (占音符比例)" },
      { "Pitch Jump", "音高跳进" },
      { "Jump threshold (semitones)", "跳进阈值（半音）" },
      { "Jump boost offset", "跳进增强偏移量" },
      { "Jump region (0-1)", "跳进作用区域 (占音符比例)" },
      { "Glottal Stop", "喉塞音" },
      { "Glottal boost offset", "喉塞增强偏移量" },
      { "Glottal region (0-1)", "喉塞作用区域 (占音符比例)" },
      { "Long Notes", "长音设置" },
      { "Long note threshold (quarters)", "长音阈值 (四分音符数)" },
      { "Mid boost offset", "中点增强偏移量" },
      { "End decay factor", "终点衰减因子" },
      { "Jitter amount", "抖动幅度" },
      { "Points per quarter note", "每四分音符点数" },
      { "OK", "确定" },
      { "Cancel", "取消" },
      { "No note group open.", "没有打开的音符组。" },
      { "Please open a note group (double‑click a track).", "请打开一个音符组（双击音轨）。" },
      { "No notes in this group.", "当前组中没有音符。" },
      { "Phonemes not ready. Please run the script again.", "音素信息尚未准备好，请稍后重试。" },
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
    title = SV:T("Tension Drawer(Base Tension)"),
    message = SV:T("Please adjust parameters and click OK."),
    buttons = "OkCancel",
    widgets = {
      -- 基准张力
      { type = "Label", text = SV:T("Base Tension") },
      { type = "Slider", name = "baseTension", label = SV:T("Base tension value"), minValue = -1, maxValue = 1, interval = 0.01, default = 0.5, format = "%+5.2f" },

      -- 音头增强
      { type = "Label", text = SV:T("Attack Boost") },
      { type = "Slider", name = "attackBoost", label = SV:T("Attack boost offset"), minValue = 0, maxValue = 0.5, interval = 0.01, default = 0.2, format = "%4.2f" },
      { type = "Slider", name = "attackRegion", label = SV:T("Attack region (0-1)"), minValue = 0, maxValue = 0.5, interval = 0.01, default = 0.15, format = "%4.2f" },

      -- 音高跳进（仅升高触发）
      { type = "Label", text = SV:T("Pitch Jump") },
      { type = "Slider", name = "jumpThreshold", label = SV:T("Jump threshold (semitones)"), minValue = 0, maxValue = 24, interval = 0.5, default = 5, format = "%4.1f" },
      { type = "Slider", name = "jumpBoost", label = SV:T("Jump boost offset"), minValue = 0, maxValue = 0.5, interval = 0.01, default = 0.3, format = "%4.2f" },
      { type = "Slider", name = "jumpRegion", label = SV:T("Jump region (0-1)"), minValue = 0, maxValue = 0.5, interval = 0.01, default = 0.15, format = "%4.2f" },

      -- 喉塞音
      { type = "Label", text = SV:T("Glottal Stop") },
      { type = "Slider", name = "throatBoost", label = SV:T("Glottal boost offset"), minValue = 0, maxValue = 0.5, interval = 0.01, default = 0.2, format = "%4.2f" },
      { type = "Slider", name = "throatRegion", label = SV:T("Glottal region (0-1)"), minValue = 0, maxValue = 0.5, interval = 0.01, default = 0.15, format = "%4.2f" },

      -- 长音设置
      { type = "Label", text = SV:T("Long Notes") },
      { type = "Slider", name = "longNoteThresholdBeats", label = SV:T("Long note threshold (quarters)"), minValue = 0, maxValue = 10, interval = 0.5, default = 2, format = "%3.1f" },
      { type = "Slider", name = "midBoost", label = SV:T("Mid boost offset"), minValue = 0, maxValue = 0.5, interval = 0.01, default = 0.3, format = "%4.2f" },
      { type = "Slider", name = "endDecay", label = SV:T("End decay factor"), minValue = 0, maxValue = 1, interval = 0.01, default = 0.9, format = "%4.2f" },
      { type = "Slider", name = "jitterAmount", label = SV:T("Jitter amount"), minValue = 0, maxValue = 0.3, interval = 0.01, default = 0.05, format = "%4.2f" },
      { type = "Slider", name = "pointDensity", label = SV:T("Points per quarter note"), minValue = 1, maxValue = 16, interval = 1, default = 4, format = "%3.0f" },
    }
  }

  local results = SV:showCustomDialog(form)
  if not results or not results.status then
    SV:finish()
    return
  end

  local params = {
    baseTension              = results.answers.baseTension,
    attackBoost               = results.answers.attackBoost,
    attackRegion              = results.answers.attackRegion,
    jumpThreshold             = results.answers.jumpThreshold,
    jumpBoost                 = results.answers.jumpBoost,
    jumpRegion                = results.answers.jumpRegion,
    throatBoost               = results.answers.throatBoost,
    throatRegion              = results.answers.throatRegion,
    longNoteThresholdBeats    = results.answers.longNoteThresholdBeats,
    midBoost                  = results.answers.midBoost,
    endDecay                  = results.answers.endDecay,
    jitterAmount              = results.answers.jitterAmount,
    pointDensity              = results.answers.pointDensity,
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

  -- 获取音符列表
  local notes = {}
  for i = 1, noteCount do
    notes[i] = group:getNote(i)
  end

  -- 获取每个音符的音素字符串
  local phonemeStrings = SV:getPhonemesForGroup(groupRef)
  if not phonemeStrings or #phonemeStrings == 0 then
    SV:showMessageBox(SV:T("Info"), SV:T("Phonemes not ready. Please run the script again."))
    SV:finish()
    return
  end

  -- 解析音素
  local function splitPhonemes(str)
    if not str or str == "" then return {} end
    local t = {}
    for token in string.gmatch(str, "%S+") do
      table.insert(t, token)
    end
    return t
  end

  local QUARTER = SV.QUARTER
  local longNoteThreshold = params.longNoteThresholdBeats * QUARTER
  local step = QUARTER / params.pointDensity

  math.randomseed(os.time())

  for i = 1, noteCount do
    local note = notes[i]
    local onset = note:getOnset()
    local duration = note:getDuration()
    if duration <= 0 then goto continue end

    local endPos = onset + duration
    local base = params.baseTension

    -- 跳进判断：只有升高超过阈值才触发
    local jumpActive = false
    if i > 1 then
      local prevPitch = notes[i-1]:getPitch()
      local currPitch = note:getPitch()
      if currPitch - prevPitch >= params.jumpThreshold then
        jumpActive = true
      end
    end

    -- 喉塞音判断
    local phonemeList = splitPhonemes(phonemeStrings[i])
    local throatActive = false
    if #phonemeList > 0 and phonemeList[1] == "cl" then
      throatActive = true
    end

    -- 延音判断：歌词为 "-" 或 "—" 时不应用音头增强
    local lyrics = note:getLyrics()  -- 获取歌词
    local isSustain = (lyrics == "-" or lyrics == "—" or lyrics == "ー")  -- 判断是否为延音
  

    -- 收集所有可能的时间点
    local points = {}
    table.insert(points, onset)
    if not isSustain then
      table.insert(points, onset + params.attackRegion * duration)
    end
    if jumpActive then
      table.insert(points, onset + params.jumpRegion * duration)
    end
    if throatActive then
      table.insert(points, onset + params.throatRegion * duration)
    end
    if duration >= longNoteThreshold then
      table.insert(points, onset + duration * 0.5)
      -- 抖动点
      local numSteps = math.floor(duration / step)
      for j = 1, numSteps - 1 do
        local t = onset + j * step
        local tooClose = false
        for _, pt in ipairs(points) do
          if math.abs(t - pt) < step * 0.5 then
            tooClose = true
            break
          end
        end
        if not tooClose then
          table.insert(points, t)
        end
      end
    end

    -- 添加回归基准点（仅对非长音），紧贴终点前 1 blick
    local regressionPoint = nil
    if duration < longNoteThreshold then
      if duration > 1 then
        regressionPoint = endPos - 1  -- 距离终点仅 1 blick
      else
        regressionPoint = onset + duration * 0.9  -- 极短音符则放在 90% 处
      end
      table.insert(points, regressionPoint)
    end

    table.insert(points, endPos)

    -- 排序去重
    table.sort(points)
    local uniquePoints = {}
    local last = nil
    for _, t in ipairs(points) do
      if last == nil or math.abs(t - last) > 1e-6 then
        table.insert(uniquePoints, t)
        last = t
      end
    end

    -- 计算每个点的张力值
    for _, t in ipairs(uniquePoints) do
      local value
      local isRegressionPoint = regressionPoint and math.abs(t - regressionPoint) < 1e-6

      if isRegressionPoint then
        value = base
      else
        local offset = 0

        -- 音头增强（仅当非延音时）
        if not isSustain then
          local attackEnd = onset + params.attackRegion * duration
          if t >= onset and t <= attackEnd then
            local ratio = (t - onset) / (params.attackRegion * duration)
            offset = offset + params.attackBoost * (1 - ratio)
          end
        end

        -- 跳进偏移（仅升高触发）
        if jumpActive then
          local regionEnd = onset + params.jumpRegion * duration
          if t >= onset and t <= regionEnd then
            local ratio = (t - onset) / (params.jumpRegion * duration)
            offset = offset + params.jumpBoost * (1 - ratio)
          end
        end

        -- 喉塞偏移
        if throatActive then
          local regionEnd = onset + params.throatRegion * duration
          if t >= onset and t <= regionEnd then
            local ratio = (t - onset) / (params.throatRegion * duration)
            offset = offset + params.throatBoost * (1 - ratio)
          end
        end

        -- 中点增强
        if duration >= longNoteThreshold and math.abs(t - (onset + duration*0.5)) < 1e-6 then
          offset = offset + params.midBoost
        end

        -- 抖动（仅对非关键点）
        local isJitterPoint = false
        if duration >= longNoteThreshold then
          local special = false
          if math.abs(t - onset) < 1e-6 or math.abs(t - endPos) < 1e-6 then special = true end
          if math.abs(t - (onset + duration*0.5)) < 1e-6 then special = true end
          if not isSustain and math.abs(t - (onset + params.attackRegion*duration)) < 1e-6 then special = true end
          if jumpActive and math.abs(t - (onset + params.jumpRegion*duration)) < 1e-6 then special = true end
          if throatActive and math.abs(t - (onset + params.throatRegion*duration)) < 1e-6 then special = true end
          if not special then
            isJitterPoint = true
          end
        end
        if isJitterPoint then
          offset = offset + (math.random() * 2 - 1) * params.jitterAmount
        end

        value = base + offset
      end

      value = math.max(-1, math.min(1, value))

      -- 终点衰减（仅对真正的终点）
      if math.abs(t - endPos) < 1e-6 then
        value = value * params.endDecay
        value = math.max(-1, math.min(1, value))
      end

      tension:add(t, value)
    end

    ::continue::
  end

  local msg = string.format(SV:T("Tension drawn for %d notes."), noteCount)
  SV:showMessageBox(SV:T("Done"), msg)
  SV:finish()
end
