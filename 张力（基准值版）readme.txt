# Tension Drawer (Base Tension) / 张力（基准值版）

A Synthesizer V Studio script that automatically draws tension curves based on a base tension value, with enhancements for note attacks, pitch jumps, glottal stops, and long notes.  
本脚本可根据基准张力值自动绘制张力曲线，并支持音头增强、音高跳进增强、喉塞音增强以及长音处理。

---

## Parameters / 参数说明

| Parameter | 参数 | Range | Default | Description / 说明 |
|-----------|------|-------|---------|-------------------|
| Base tension value | 基准张力值 | -1.0 … 1.0 | 0.5 | Constant tension value used as the base. / 用作基础的恒定张力值。 |
| Attack boost offset | 音头增强偏移量 | 0 … 0.5 | 0.2 | Amount added near the note onset (linear decay). / 在音符起点附近添加的偏移量（线性衰减）。 |
| Attack region (0-1) | 音头作用区域 | 0 … 0.5 | 0.15 | Fraction of the note duration where attack boost applies. / 音头增强作用的音符时长比例。 |
| Jump threshold (semitones) | 跳进阈值（半音） | 0 … 24 | 5 | Minimum pitch rise to trigger jump boost. / 触发跳进增强的最小音高升高值。 |
| Jump boost offset | 跳进增强偏移量 | 0 … 0.5 | 0.3 | Extra offset added near the onset when a jump occurs. / 跳进发生时在起点附近添加的额外偏移量。 |
| Jump region (0-1) | 跳进作用区域 | 0 … 0.5 | 0.15 | Fraction of the note duration for jump boost. / 跳进增强作用的音符时长比例。 |
| Glottal boost offset | 喉塞增强偏移量 | 0 … 0.5 | 0.2 | Extra offset when the first phoneme is `cl`. / 第一个音素为 `cl` 时添加的额外偏移量。 |
| Glottal region (0-1) | 喉塞作用区域 | 0 … 0.5 | 0.15 | Fraction of the note duration for glottal boost. / 喉塞增强作用的音符时长比例。 |
| Long note threshold (quarters) | 长音阈值 (四分音符) | 0 … 10 | 2 | Notes longer than this (in quarter notes) are considered long. / 超过此长度（以四分音符为单位）的音符被视为长音。 |
| Mid boost offset | 中点增强偏移量 | 0 … 0.5 | 0.3 | Offset added at the exact middle of a long note. / 在长音中点添加的偏移量。 |
| End decay factor | 终点衰减因子 | 0 … 1.0 | 0.9 | Tension multiplier at the end of a note. / 音符终点处的张力乘数。 |
| Jitter amount | 抖动幅度 | 0 … 0.3 | 0.05 | Random offset range for points inside long notes. / 长音内部点的随机偏移范围。 |
| Points per quarter note | 每四分音符点数 | 1 … 16 | 4 | Number of tension points inserted per quarter note. / 每四分音符插入的张力点数量。 |

---

## Usage / 使用方法

**English**  
1. Open a project and double‑click a track to enter note editing mode.  
2. Ensure the current group contains at least one note.  
3. Run the script from the **Scripts** menu.  
4. Adjust the parameters in the dialog and click **OK**.  
5. The script clears the existing tension curve in the current group and generates a new one based on your settings.  
6. If you are not satisfied, press `Ctrl+Z` to undo.

**中文**  
1. 打开工程，双击音轨进入音符编辑模式。  
2. 确保当前组中至少有一个音符。  
3. 从 **脚本** 菜单运行本脚本。  
4. 在弹出的对话框中调整参数，点击 **确定**。  
5. 脚本会清除当前组的所有张力曲线，并根据您的设置生成新曲线。  
6. 若不满意，可按 `Ctrl+Z` 撤销。

---

## Installation / 安装

**English**  
Save the script file (`.lua`) into the Synthesizer V Studio scripts folder:  
- **Windows**: `%USERPROFILE%\Documents\Dreamtonics\Synthesizer V Studio\scripts\`  
- **macOS**: `~/Library/Application Support/Dreamtonics/Synthesizer V Studio/scripts/`  

Then restart Synthesizer V Studio. The script will appear in the scripts menu.

**中文**  
将脚本文件（`.lua`）保存到 Synthesizer V Studio 的脚本目录：  
- **Windows**: `%USERPROFILE%\Documents\Dreamtonics\Synthesizer V Studio\scripts\`  
- **macOS**: `~/Library/Application Support/Dreamtonics/Synthesizer V Studio/scripts\`  

然后重启 Synthesizer V Studio，脚本就会出现在脚本菜单中。

---

## Notes / 注意事项

- Requires Synthesizer V Studio **1.0.4 or newer**.  
  需要 **Synthesizer V Studio 1.0.4 或更高版本**。  
- The script **clears all existing tension points** in the current group.  
  脚本会**清除当前组的所有现有张力点**。  
- Phoneme information is obtained via `SV:getPhonemesForGroup()`. If the phonemes are not ready, the script will ask you to run it again.  
  音素信息通过 `SV:getPhonemesForGroup()` 获取。若音素尚未准备好，脚本会提示重试。  
- Sustain notes (lyrics `-`, `—`, `ー`) receive **no attack boost**, but other enhancements may still apply.  
  延音乐符（歌词为 `-`、`—`、`ー`）**不会**获得音头增强，但其他增强仍可能生效。  
- All offsets are **additive**; they stack together.  
  所有偏移量为**加法叠加**，可同时生效。  

---

## License / 许可证

MIT License. See the LICENSE file for details.  
MIT 许可证。详见 LICENSE)文件。

---

## Author / 作者

tomorin (bilibili: 火丁的卫兵)  
Thanks to Deepseek for development assistance.  
感谢 Deepseek 在开发过程中提供的帮助。