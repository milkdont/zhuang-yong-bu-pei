# 莊永不賠（Anti-Gambling Demo）

倉庫：https://github.com/milkdont/zhuang-yong-bu-pei

Godot **4.7** 反賭博敘事 Demo（繁體中文／港式用語）。用真實莊家優勢示範：長期嚟講，賭場永遠有優勢。

## 點樣運行

### 方法 A：Godot 編輯器／命令列

```bash
# 本機已下載嘅編輯器示例路徑：
/home/box/godot/Godot_v4.7.2-stable_linux.x86_64 --path /workspace/anti-gambling-demo

# 或者：
godot --path /workspace/anti-gambling-demo
```

### 方法 B：匯出嘅 Linux 二進位

```bash
/workspace/anti-gambling-demo/export/ZhuangYongBuPei.x86_64
```

（若尚未匯出，見下方「匯出」。）


### 方法 C：Windows 下載／運行

1. 喺 GitHub **Releases** 下載 `ZhuangYongBuPei-windows.zip`（或 `.exe`）。
2. 解壓後雙擊 **`ZhuangYongBuPei.exe`**。
3. 若 Windows Defender／SmartScreen 提示「未知發行者」，可選「仍要執行」（本 Demo 未簽名）。
4. 建議解析度：1280×720 或以上。

直接下載頁（建立 Release 後）：  
https://github.com/milkdont/zhuang-yong-bu-pei/releases

本機匯出路徑（開發用）：`export/windows/ZhuangYongBuPei.exe`


### Headless 冒煙測試

```bash
godot --headless --path /workspace/anti-gambling-demo -s res://scripts/SmokeTest.gd
```

## 操作

| 操作 | 說明 |
|------|------|
| 滑鼠左鍵 | 選籌碼、下注、選檯、確認 |
| 「返回大廳」 | 由各遊戲返回選檯 |
| 「真勝利停手」 | 現金 ≥ **$2,000,000,000** 先至可按，達成 **登峰造極** |
| 「放棄／逃出」 | 非登峰結局，可隨時離開 |

## 勝利／結局條件

| 結局 | 條件 |
|------|------|
| **登峰造極** | 淨資產 ≥ 二十億，並按「真勝利停手」 |
| **翻本又輸返** | 曾經達到／超過一億，之後跌穿一億（或破產） |
| **賭到清零** | 從未翻到一億就輸光 |
| **放棄／逃出** | 大廳按「放棄／逃出」（唔算登峰） |

開局：欠債敘事 **一億**，現金 **$100,000**。  
跨過一億後動機為貪婪金句：*「贏返本唔夠爽——唔係而家衝，更待何時？」*

## Demo 遊戲（真實／公開賠率）

1. **歐洲輪盤**（單一零 0–36）— 直注 35:1；紅黑／單雙／高低 1:1；打 2:1；莊家優勢 ≈ **2.70%**
2. **百家樂**（只賭閒／莊）— 閒 1:1；莊贏扣 **5%** 佣金；和退本；優勢約莊 **1.06%**／閒 **1.24%**
3. **老虎機**（3 軸單線）— 固定權重表，理論 **RTP ≈ 96%**（即長期約 −4%）

HUD 顯示：現金、距一億／二十億、累計損益、莊家優勢備註。

## 專案結構

```
anti-gambling-demo/
  autoload/GameState.gd   # 現金、峰值、結局
  autoload/BGM.gd         # 輕快循環音效
  scenes/                 # MainMenu, Intro, CasinoHub, Roulette, Baccarat, Slots, Ending, HudBar
  scripts/                # UI + *Logic 賠率邏輯
  assets/audio/cheerful_loop.wav
  export/
```

## 音效／BGM

預設使用程序生成嘅輕快 WAV 循環（`assets/audio/cheerful_loop.wav`），同陰森賭場畫面形成對比。

**換曲：** 將你嘅 `bgm.mp3`／`.ogg`／`.wav` 放入 `assets/audio/`，然後：

1. 用 Godot 開啟專案，喺 `autoload/BGM.gd` 改 `PATH`；或
2. 直接取代 `cheerful_loop.wav`（保持檔名）。


## 匯出 Windows

```bash
godot --headless --path . --export-release "Windows Desktop" export/windows/ZhuangYongBuPei.exe
```

產出：`export/windows/ZhuangYongBuPei.exe`（已 embed `.pck`，約 120MB+）。大型二進位請用 GitHub Release 發佈，唔好直接 commit。

## 匯出 Linux

需要已安裝 Godot 4.7.x export templates（本機已有 `4.7.2.stable` templates 时可直接）：

```bash
godot --headless --path /workspace/anti-gambling-demo --export-release "Linux" export/ZhuangYongBuPei.x86_64
```

## 字型

專案內建 **Noto Sans CJK HK Regular**（`assets/fonts/`，SIL OFL），確保繁體中文／港式字形可顯示。

## Demo 驗收

標題畫面下方有「結局預覽」按鈕。因為採用**真實莊家優勢**，由十萬本金滾到二十億在正常遊玩中幾乎不可能——這正是反賭博訊息。預覽鈕只為驗收結局畫面。

## 免責

本作為**教育／敘事 Demo**，唔鼓勵任何形式賭博。現實請尋求正规協助渠道（例如本地戒賭輔導熱線）。
