# KVGH 復健系統 CI/CD 審查報告

- **審查日期**：2026-06-13
- **審查範圍**：`backend-fastapi/.gitlab-ci.yml`、`frontend-react/.gitlab-ci.yml`、`scripts/ci/backend-release.sh`、`scripts/ci/frontend-release.sh`、前後端 Dockerfile、根目錄 compose 檔（`compose.yaml` / `compose.prod.yaml`）
- **審查性質**：僅檢查、未做任何調整

---

## 一、總體結論

前後端 CI/CD 採用 **GitLab CI**，皆為六階段流水線：

```
lint_test → application_test → build → build_test → deploy → deploy_test
```

整體設計**完整度高於一般水準**：版本釘選嚴謹、部署具備 pending → last-known-good 兩段式 gate、失敗自動 rollback、release metadata 驗證、映像內機密檔案檢查等，皆是正確且少見的良好實踐。

主要缺口集中在三點：**部署流程未執行資料庫 migration**、**後端部署不會重建 analysis-worker 映像（程式碼版本可能漂移）**、**完全沒有安全掃描類 job**。以下分項說明。

---

## 二、流水線結構檢查

### 後端（backend-fastapi）

| Job | 階段 | 內容 | 觸發條件 |
|---|---|---|---|
| `lint_test` | lint_test | ruff check / ruff format --check / mypy / shell 語法檢查 | 所有分支 |
| `migration_test` | application_test | alembic upgrade head + alembic check（ephemeral PostgreSQL 16） | **手動、allow_failure** |
| `application_test` | application_test | pytest `-m "not slow"`，產出 JUnit 報表 | 所有分支 |
| `build` | build | compileall + import smoke | 所有分支 |
| `build_test` | build_test | venv 結構契約、關鍵套件匯入、`/` 與 `/health` 路由存在 | 所有分支 |
| `docker_build_test` | build_test | buildx 建映像、metadata 驗證、映像內無 .env 檢查 | 所有分支 |
| `deploy` | deploy | `backend-release.sh deploy`（checkout SHA → compose build/up） | 僅 main |
| `deploy_test` | deploy_test | `/health` smoke、7 個服務存活、metadata 比對；失敗 rollback | 僅 main |

### 前端（frontend-react）

| Job | 階段 | 內容 | 觸發條件 |
|---|---|---|---|
| `lint_test` | lint_test | ESLint | 所有分支 |
| `application_test` | application_test | `npm run test:ci`（Vitest + JUnit 報表） | 所有分支 |
| `build` | build | vite build，dist/ artifact（1 天過期） | 所有分支 |
| `build_test` | build_test | dist 結構與體積驗證 | 所有分支 |
| `docker_build_test` | build_test | production target 建映像、容器內首頁 smoke、無 .env 檢查 | 所有分支 |
| `deploy` | deploy | `frontend-release.sh deploy` | 僅 main |
| `deploy_test` | deploy_test | `/login`、首頁 asset、`version.json` commit/ref 比對；失敗 rollback | 僅 main |

**結構評價**：階段劃分清楚、deploy 透過 `needs` 明確依賴所有驗證 job、`resource_group` 防止並發部署、`environment` 標記正確、`rules` 限制 main 分支部署。✅ 標準。

---

## 三、正確性交叉比對（全部通過項目）

逐項驗證 CI 設定引用的檔案、指令與路徑，以下皆確認**存在且一致**：

| 檢查項 | 結果 |
|---|---|
| `scripts/ci/backend-release.sh`、`scripts/ci/frontend-release.sh` 存在且支援 `deploy / deploy-test / rollback` | ✅ |
| `BACKEND_SERVICES` 七個服務名稱（backend-api、worker-video、worker-script、worker-annotation、worker-metrics、worker-metrics-dispatch、beat）皆存在於 `compose.yaml` / `compose.prod.yaml` | ✅ |
| JUnit 報表路徑一致：後端 `reports/pytest.xml`、前端 `reports/vitest.junit.xml`（`test:ci` script 實際輸出相符） | ✅ |
| `package.json` 的 `lint` / `test:ci` / `build` script 皆存在 | ✅ |
| 後端 `/health` 路由存在（`app/main.py:69`），與 build_test 路由契約、compose healthcheck、deploy smoke 一致 | ✅ |
| Alembic 設定正確：`alembic.ini` 的 `script_location = migrations`，`migrations/versions/` 有 baseline migration | ✅ |
| 版本釘選一致：Python 3.12（CI 變數、Dockerfile、mypy `python_version`）；Node 24.12.0（CI 變數、Dockerfile 兩個 stage）；Docker CLI/DinD 27.5.1 | ✅ |
| Release metadata 鏈路完整：CI build-arg → Dockerfile ENV/LABEL → compose build args → smoke 比對 `BACKEND_GIT_SHA` / `version.json` | ✅ |
| 前端 `docker/nginx.conf` 與 `docker/40-write-version-json.sh` 存在；nginx 以 Docker DNS 變數 upstream 解析 backend、SPA fallback 正確 | ✅ |
| `.dockerignore` 排除 `.env*`、`.git`、tests 等，且 CI 在映像內**實際驗證**無 .env 檔（不只依賴 ignore 規則） | ✅ |
| `requirements-test.txt` 與 runtime 依賴分離；lint 工具版本釘選（mypy 1.9.0、ruff 0.4.4）且不混入 runtime | ✅ |
| pip / npm cache key 綁定 lockfile（requirements*.txt / package-lock.json） | ✅ |
| 部署腳本品質：`set -eu`、原子寫入 release env（mktemp + mv）、release history JSONL、rollback 僅允許回到曾成功部署的 SHA、root 身分降權（su-exec）、rollback 成功後仍將 deploy_test 標為失敗（正確語意） | ✅ |
| 前後端 deploy / deploy_test 透過 dotenv artifact 傳遞 pending release 路徑，銜接正確 | ✅ |

---

## 四、發現的問題

### 🔴 高風險

**1. 部署流程不會執行資料庫 migration**
`deploy` / `deploy_test` 全程沒有 `alembic upgrade head`；應用程式啟動時也不會自動跑 migration（`app/` 內無 alembic 呼叫）。同時 `migration_test` 是 `when: manual` + `allow_failure: true`，表示 **schema 變更可以在完全未驗證的情況下合入 main 並部署**，而部署後新程式碼會跑在舊 schema 上。建議：將 `migration_test` 改為自動必過 job，並在 deploy 流程加入 migration 步驟（或明文規範人工 migration SOP）。

**2. 後端部署不會更新 analysis-worker 映像**
`backend-release.sh` 的 `deploy_target()` 只執行 `compose build backend-api`，但 `worker-script` / `worker-annotation` 使用獨立映像 `kvgh-analysis-worker:release`（`Dockerfile.analysis-worker`）。`up -d` 只會沿用宿主機既有映像，**分析 worker 的程式碼版本會與 backend 漂移**，且 smoke 只檢查 container running、metadata 只驗 backend-api，無法察覺。若拆分是刻意的（近期 commit「拆分 analysis worker 映像」），目前**沒有任何 pipeline job 負責更新該映像**，屬於部署覆蓋缺口；建議至少在文件與 pipeline 註明 analysis-worker 的更新管道。

### 🟡 中風險

**3. 缺少安全掃描**
前後端 pipeline 皆無 SAST、dependency scanning（`pip-audit` / `npm audit`）、container scanning、secret detection。對處理病患資料的醫療系統而言是標準 CI/CD 的明顯缺項，建議至少補上依賴弱點掃描與 secret detection。

**4. 違反「build once, deploy artifact」原則（已知緩解）**
`docker_build_test` 在 CI 建好並驗證的映像會被丟棄，部署機從 source checkout **重新 build** 一份映像——實際部署的映像並非通過測試的那一顆（無 container registry）。現有緩解：checkout 同一 commit SHA + 部署後 metadata 驗證，風險可控但 build 環境差異仍可能造成結果不同。長期建議導入 GitLab Container Registry，CI push、部署 pull。

**5. rollback 無 pipeline 入口**
兩支 release 腳本都支援 `rollback` action（含指定 SHA 與自動找上一版），但 `.gitlab-ci.yml` **沒有對應的 manual job**，回滾必須登入部署機手動執行，失去 CI 的權限控管與紀錄。建議補一個 `when: manual` 的 rollback job。

**6. 機密資料入庫**
- 根目錄 `.env.docker`（含 `POSTGRES_PASSWORD`、`KVGH_AUTH_SECRET_KEY`、RabbitMQ 帳密）**被 git 追蹤**，僅 `.env.docker.example` 應入庫。
- `compose.yaml` 的 RabbitMQ 預設值直接寫死真實密碼（`imis95510`）。
- 部署時讀取宿主機 `/opt/.../.env.docker` 的做法本身沒問題，但 repo 內不應存在真實機密。

### 🟢 低風險 / 優化建議

7. **前端 cache 設定效益極低**：cache `node_modules/` 但每個 job 都跑 `npm ci`（會先刪除 node_modules）。標準做法是 cache `~/.npm`（`--cache .npm` + cache `.npm/`）。
8. **後端全域 cache 套用到所有 job**：`cache:` 定義在 top-level，docker/deploy job 也會拉送 pip cache，純屬浪費；建議移入 `.python_job`。
9. **pending release 檔清理不對稱**：後端 `deploy_test` 透過 artifact 副本驗證，宿主機 `/opt/.../deploy/backend-pending-release.env` 不會被 `remove_pending_release_env` 清掉（下次 deploy 會覆寫，無實害）；前端則直接清宿主機檔案，兩邊行為不一致。
10. **無 `workflow:rules`**：目前僅 branch pipeline 所以不會重複觸發，但若日後啟用 MR pipeline 會出現 branch + MR 雙跑；建議預先補上。
11. **驗證 job 未設 `interruptible: true`**：同分支連續 push 時舊 pipeline 不會自動取消，浪費 runner 資源（deploy 類 job 則正確地不應 interruptible）。
12. **根目錄部署 repo 本身沒有 CI**：`compose.yaml` / `compose.prod.yaml` / `postgres/init/*.sql` 變更無任何驗證（連 `docker compose config` 語法檢查都沒有），而這些檔案直接影響部署結果。
13. **GitHub remote 無 CI**：前後端 repo 同時推送 GitHub 與 GitLab，但 CI 僅存在於 GitLab（無 `.github/workflows/`）。若 GitHub 僅作鏡像備份則屬正常，建議在 README 註明。

---

## 五、評分總結

| 面向 | 評價 |
|---|---|
| 流水線結構與階段設計 | ★★★★★ 完整標準 |
| 設定正確性（引用一致性） | ★★★★★ 全部比對通過 |
| 測試與品質 gate | ★★★★☆ lint/test/build 驗證紮實，migration 驗證缺位 |
| 部署與回滾機制 | ★★★★☆ 兩段式 gate + 自動 rollback 優秀，但 migration 與 analysis-worker 覆蓋缺口 |
| 安全性 | ★★☆☆☆ 無任何掃描 job、機密入庫 |
| 效率優化 | ★★★☆☆ cache 設定有改善空間 |

**結論**：CI/CD 骨架標準、設定無錯誤引用，可正常運作；但在「資料庫 migration 自動化」「analysis-worker 部署覆蓋」「安全掃描」三點需要補強後，才能視為完整的生產級流水線。
