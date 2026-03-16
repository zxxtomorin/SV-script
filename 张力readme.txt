#自动张力绘制脚本（带图形界面）

本脚本可依据音高映射、起点/中点/终点调整、抖动和峰值处理，为音符自动绘制张力曲线。它提供了一个图形界面，让您能实时调整所有参数。

---

## 中文说明

### 简介
“自动张力调参版”是一个为 Synthesizer V Studio 设计的脚本，它能根据用户设定的参数，在选中的音符组内自动生成张力控制点，从而快速塑造富有动态的演唱表情。脚本内置了音高到张力的线性映射、长音增强、随机抖动以及音高峰值处的特殊处理，非常适合用于制作摇滚、流行或情感强烈的歌曲。

### 特性
- **图形化调参**：所有参数均通过滑块和下拉框调整，所见即所得。
- **音高映射**：根据音符的音高（MIDI 编号）线性计算基础张力。
- **起点/中点/终点独立调节**：可分别增强音符起点、长音中点的张力，并衰减终点张力。
- **长音抖动**：对超过一定长度的音符，在内部添加随机抖动点，增加自然感。
- **峰值处理**：当出现连续音高峰值时，可降低峰值本身的张力，同时增强前后音符的张力，形成对比。
- **实时预览**：运行后直接在当前组生成张力曲线，不满意可撤销重来。

### 参数详解
| 参数 | 范围 | 默认值 | 说明 |
|------|------|--------|------|
| 最低音 (MIDI) | 0–127 | 48 | 音高映射的最低音（如 C3） |
| 最低音张力值 | -1 – 1 | 0.1 | 对应最低音的张力值 |
| 最高音 (MIDI) | 0–127 | 84 | 音高映射的最高音（如 C6） |
| 最高音张力值 | -1 – 1 | 0.7 | 对应最高音的张力值 |
| 起点增强因子 | 0 – 2 | 1.1 | 音符起点的张力乘以此因子 |
| 长音中点增强因子 | 0 – 2 | 1.5 | 长音中点的张力乘以此因子 |
| 终点衰减因子 | 0 – 1 | 0.9 | 音符终点的张力乘以此因子 |
| 长音阈值 (四分音符) | 0 – 10 | 2 | 超过此长度的音符被视为长音 |
| 抖动幅度 | 0 – 0.5 | 0.05 | 长音内部抖动的随机偏移量 |
| 每四分音符点数 | 1 – 16 | 4 | 每四分音符插入的控制点数量 |
| 峰值降低因子 | 0 – 1 | 0.5 | 音高峰值处张力乘以此因子 |
| 相邻音增强因子 | 0 – 2 | 1.3 | 峰值前后音符的张力乘以此因子 |

参数详解的详解（手动狗头）：
### 基础映射（决定“音高”和“张力”的大致关系）
- **低音基准音高**：定义哪个音算“最低音”。例如 48 对应 C3（中央 C 下面一个八度）。  
- **低音对应张力**：当音高等于“低音基准音高”时，给它多少张力（通常较小，因为低音一般不会太用力）。  
- **高音基准音高**：定义哪个音算“最高音”。例如 84 对应 C6（比中央 C 高两个八度）。  
- **高音对应张力**：当音高等于“高音基准音高”时，给它多少张力（通常较大，因为高音一般需要更多力气）。  

> **效果**：  
> - 如果你想让高音更用力，就把“高音对应张力”调大。  
> - 如果觉得低音不够柔和，就把“低音对应张力”调小（甚至可以负数，代表放松）。

---

### 起点/中点/终点调整（控制每个音符内部的张力变化）
- **起点增强因子**：每个音符开头的张力会比基础值再乘这个倍数。  
  > 1.1 表示起点比中间稍微用力一点，符合“字头发力”的习惯。  
  > 如果改成 1.0，起点就不增强了；改成 1.5，起点会明显更用力。

- **长音中点增强因子**：对于较长的音符，中间点（时间中点）的张力会再乘这个倍数。  
  > 1.5 表示长音中间会有一个明显的凸起，模拟歌手在长音中段重新发力。  
  > 如果改成 1.0，就没有这个凸起；改大则凸起更明显。

- **终点衰减因子**：每个音符结束点的张力会乘这个倍数（通常小于 1，表示结尾放松）。  
  > 0.9 表示结尾张力比中间稍微低一点。  
  > 如果改成 1.0，结尾和中间一样；改成 0.5，结尾明显变软。

---

### 长音与抖动（让长音更自然，带一点随机波动）
- **长音阈值（四分音符数）**：音符多长才算“长音”？单位是四分音符。  
  > 2 表示长度 ≥ 2 个四分音符（即两拍）的音符才应用中点增强和抖动。  
  > 如果改成 1，所有一拍以上的音符都算长音；改成 4，只有四拍以上的长音才特殊处理。

- **抖动幅度**：在长音内部随机增加一些小波动，模仿人声的不完美感。  
  > 0.05 表示波动最大偏离 0.05（张力范围是 -1 到 1）。  
  > 改成 0.1 抖动更明显，改成 0 则无抖动。

- **每四分音符点数**：每个四分音符长度内插入多少个控制点。  
  > 4 表示每四分音符插入 4 个点，即每 16 分音符一个点。  
  > 数字越大，曲线越精细（但也可能太密）。一般 4 或 8 就够了。

---

### 峰值处理（处理旋律中的“最高音”）
- **峰值降低因子**：当出现一个局部最高音（比前后音都高）时，这个音符的张力会乘这个倍数。  
  > 0.5 表示最高音的张力砍掉一半，模拟“高音处反而放松”的演唱技巧。  
  > 改成 1.0 则不做降低；改成 0.2 则几乎完全放松。

- **前后增强因子**：最高音前面的一个音符和后面的一个音符，它们的张力会乘这个倍数。  
  > 1.3 表示前后音符的张力提高 30%，形成“最高音放松，前后用力”的对比。  
  > 改成 1.0 则不做增强；改大会更突出对比。


### 使用方法
1. 在 Synthesizer V Studio 中打开一个工程，并双击音轨进入音符编辑模式。
2. 确保当前组中有至少一个音符（脚本将对**当前组内所有音符**生效，不依赖于选区）。
3. 通过“脚本”菜单运行本脚本。
4. 在弹出的对话框中调整参数，点击“确定”。
5. 脚本将自动清除该组原有的张力曲线，并依据新参数生成曲线。
6. 如不满意，可使用 `Ctrl+Z` 撤销。

### 安装
1. 将脚本文件（`.lua`）保存到 Synthesizer V Studio 的脚本目录中：
   - Windows: `%USERPROFILE%\Documents\Dreamtonics\Synthesizer V Studio\scripts\`
   - macOS: `~/Library/Application Support/Dreamtonics/Synthesizer V Studio/scripts/`
2. 重启 Synthesizer V Studio，脚本就会出现在脚本菜单中。

### 注意事项
- 脚本会清除当前组原有的所有张力点（`tension` 参数），请确保已保存重要数据。
- 所有参数必须在合理范围内，超出限制的值会被滑块自动截断。
- 抖动使用了 `math.random`，每次运行生成的抖动点会不同，以增加自然变化。

### 许可证
本项目采用 MIT 许可证。您可以自由使用、修改和分发，但需保留原作者署名。

### 作者
[zxxtomorin]  
如有问题或建议，欢迎在 GitHub 提交 Issue。

---

## English Description

### Introduction
The "Auto Tension Drawer with GUI" is a script for Synthesizer V Studio that automatically generates tension control points based on user‑defined parameters. It helps you quickly sculpt dynamic vocal expressions, making it ideal for rock, pop, or emotionally intense songs.

### Features
- **Graphical Interface** – All parameters are adjustable via sliders and combo boxes.
- **Pitch Mapping** – Base tension is linearly interpolated from the note's pitch (MIDI number).
- **Onset/Mid/End Adjustments** – Independently boost onset tension, mid‑note tension (for long notes), and decay the end.
- **Jitter for Long Notes** – Adds random fluctuations inside long notes for a more natural feel.
- **Peak Processing** – When consecutive pitch peaks are detected, the peak note's tension is reduced while neighboring notes are boosted, creating contrast.
- **Live Preview** – Tension curves are generated immediately; use undo if you are not satisfied.

### Parameters
| Parameter | Range | Default | Description |
|-----------|-------|---------|-------------|
| Lowest pitch (MIDI) | 0–127 | 48 | Lowest pitch for mapping (e.g., C3) |
| Tension at lowest pitch | -1 – 1 | 0.1 | Tension value at the lowest pitch |
| Highest pitch (MIDI) | 0–127 | 84 | Highest pitch for mapping (e.g., C6) |
| Tension at highest pitch | -1 – 1 | 0.7 | Tension value at the highest pitch |
| Onset boost factor | 0 – 2 | 1.1 | Multiplier for tension at note onset |
| Mid boost factor (long notes) | 0 – 2 | 1.5 | Multiplier for tension at the middle of long notes |
| End decay factor | 0 – 1 | 0.9 | Multiplier for tension at note end |
| Long note threshold (quarters) | 0 – 10 | 2 | Notes longer than this are considered “long” |
| Jitter amount | 0 – 0.5 | 0.05 | Random offset added inside long notes |
| Points per quarter note | 1 – 16 | 4 | Number of control points inserted per quarter note |
| Peak reduction factor | 0 – 1 | 0.5 | Tension multiplier for peak notes |
| Neighbor boost factor | 0 – 2 | 1.3 | Tension multiplier for notes adjacent to peaks |

### Usage
1. Open a project in Synthesizer V Studio and double‑click a track to enter note editing mode.
2. Make sure the current group contains at least one note (the script works on **all notes in the current group**, not the selection).
3. Run the script from the “Scripts” menu.
4. Adjust the parameters in the dialog and click **OK**.
5. The script will clear the existing tension curve in the group and generate a new one based on the parameters.
6. If you are not satisfied, use `Ctrl+Z` to undo.

### Installation
1. Save the script file (`.lua`) into the Synthesizer V Studio scripts folder:
   - Windows: `%USERPROFILE%\Documents\Dreamtonics\Synthesizer V Studio\scripts\`
   - macOS: `~/Library/Application Support/Dreamtonics/Synthesizer V Studio/scripts/`
2. Restart Synthesizer V Studio. The script will appear in the scripts menu.

### Notes
- It **clears all existing tension points** in the current group. Make sure you have saved any important data.
- All parameters are clamped to safe ranges by the sliders.
- Jitter uses `math.random`, so results will vary slightly each run, adding natural variation.

### License
This project is licensed under the MIT License. You are free to use, modify, and distribute it, provided the original author is credited.

### Author
[zxxtomorin]  
For issues or suggestions, please open an issue on GitHub.
