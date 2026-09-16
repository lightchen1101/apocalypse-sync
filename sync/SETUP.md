# Claude Code 對話紀錄同步 — 新機器設定

這個 repo 只同步 `~/.claude/projects`(對話紀錄)與 `sync/`(這幾個同步腳本本身)。
`settings.json`、`.credentials.json`、cache 等本機專屬檔案**不會**被同步。

推送前會自動用 `sync/redact-secrets.mjs` 掃描並隱碼常見金鑰格式
(Anthropic / OpenAI / GCP / Gemini / AWS / GitHub / Slack / Stripe / 私鑰 /
connection string 密碼 / 泛用的 `xxxSecret,Key,Token` 欄位),但這不是萬無一失的
防護網,請仍避免在對話中貼真實密鑰。

## 前置需求

- Git
- Node.js(跑隱碼掃描用,任何近期版本都可以)
- 能推送到 `https://github.com/lightchen1101/apocalypse-sync.git` 的 GitHub 帳號權限

## 第一次設定(每台新電腦只需做一次)

**如果這台電腦「之前沒有」用相同的專案路徑跑過 Claude Code**(不會有
`projects/<同樣路徑>/memory/*.md` 撞名風險),直接手動跑以下指令即可:

### Windows (PowerShell)

```powershell
Set-Location "$env:USERPROFILE\.claude"
git init
git remote add origin https://github.com/lightchen1101/apocalypse-sync.git
git fetch origin
git checkout -b main origin/main
node sync\redact-secrets.mjs
git add .gitignore projects sync
git commit -m "sync: add this machine's existing history"
git push origin main
```

### Mac / Linux (bash)

```bash
cd ~/.claude
git init
git remote add origin https://github.com/lightchen1101/apocalypse-sync.git
git fetch origin
git checkout -b main origin/main
node sync/redact-secrets.mjs
git add .gitignore projects sync
git commit -m "sync: add this machine's existing history"
git push origin main
```

`git checkout -b main origin/main` 會把 repo 裡其他機器的對話紀錄和 `sync/` 腳本
帶進來;這台機器原本就有的對話紀錄(檔名是 session UUID,幾乎不會撞名)會保留
在工作目錄裡變成未追蹤檔案,接著的 `node sync/redact-secrets.mjs` 會先隱碼掃描
它們,再一起加入 commit 並推上去。

**如果這台電腦「之前已經」用相同的專案路徑跑過 Claude Code**(例如兩台機器都把
同一個 repo clone 到 `.../aiProject/_dev`),那這台機器很可能已經自己累積了一份
`projects/<同樣路徑>/memory/MEMORY.md`。這種固定檔名(不像 session 是 UUID)的檔案
內容通常跟別台機器不同,直接跑上面的手動指令,`git checkout -b main origin/main`
會偵測到「本機已有未追蹤檔案且內容不同」而整個中止,什麼都不會同步進來。

這種情況改用這個腳本,它會自動把撞名的本機檔案備份成 `*.pre-sync-backup.md`
(不會覆蓋、也不會遺失原本內容),再把同步的歷史紀錄拉進來:

```powershell
# Windows
.\sync\first-time-setup.ps1
```

```bash
# Mac / Linux
chmod +x sync/first-time-setup.sh   # 第一次執行前
./sync/first-time-setup.sh
```

跑完之後,如果有產生 `*.pre-sync-backup.md`,代表原本這台機器自己的 memory 內容
被留下來了,建議自己看一下有沒有值得留的東西手動補進新的 `MEMORY.md`,確認沒問題
後再刪掉備份檔。這個腳本本身也具備冪等性(`main` 分支已存在時會直接跳過),所以
不小心重跑一次也不會出問題;不確定要不要用哪一個版本時,直接用這個腳本永遠是安全的。

## 之後每次同步

```powershell
# Windows
.\sync\sync.ps1
```

```bash
# Mac / Linux
chmod +x sync/sync.sh   # 第一次執行前
./sync/sync.sh
```

這個腳本會:先跑隱碼掃描 → 若遠端有新內容就先 pull → 把有變動的檔案 commit → push。
沒有變動時會印出 `Nothing to sync.` 並直接結束,可以安全地重複執行。

## 注意事項

- 這是 private repo,但仍建議定期檢查 GitHub 的 secret scanning 有沒有再攔到新東西
  (代表隱碼腳本沒抓到的新格式,遇到時回報給維護這份設定的人補規則)。
- 對話紀錄的合併衝突理論上很少發生(檔名是 UUID),但如果真的同一個 session 在兩台機器
  上都被修改過(例如用了對話續傳),`git pull` 可能會出現 merge conflict,需要手動處理。
- `projects/<project>/memory/*.md`(auto memory 系統的檔案)不是 UUID 命名,如果兩台機器
  用過同一個專案路徑,檔名會撞。第一次設定務必用 `first-time-setup.ps1` / `.sh`,不要
  手動跑指令,否則 checkout 會直接中止。
