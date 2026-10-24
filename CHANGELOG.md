# 变更记录

## v1.0.0 — 2026-10-24

### 新增

- UI 新增**图片采集工作台**（`#/grabber`）：多来源采集、采集范围/图片处理/标签/认证分页、实时任务结果，以及按下载分组浏览的磁盘图库与显式重新打标。
- UI 新增**标注工作台**：按分组快照浏览、批量编辑与全选、服务端差异预览、确认后写入、撤销预览，以及受保护的原始字段编辑边界。
- UI 新增**翻译工作台**：本地词典加显式启用的文本 API，译文按已保存的服务端 ID 对应，而非按同词猜测。
- UI 新增采集与标注的后端契约模块（`contract/grabber.py`、`grabber_models.py`、`grabber_preview.py`、`annotations.py`、`store/annotations.py`）与前端模块（`grabber*.js`、`annotation-api.js`）。
- UI 新增 `/api/grabber/annotations` 与 `/api/translation` 路由：严格解析查询与 JSON、固定请求体与响应上限、拒绝重复参数与非法 framing，失败返回结构化错误。
- Trainer 与 UI 版本号统一升至 1.0.0（`pyproject.toml` 与 `__version__`）。
- 新增 Windows 兼容层：进程创建标志（`CREATE_NO_WINDOW` / `CREATE_NEW_PROCESS_GROUP`）、`RUN_NAME` 可移植性校验（非法字符、保留设备名、结尾点或空格）、`taskkill` 停止路径、`.venv/Scripts` 工具发现、Win32 进程存活探测。
- 新增根目录 `start.sh` 与 `start.bat`：按脚本位置定位子项目、前台启动本地 UI，不做安装或 Git 操作。
- 新增跨进程接口文档：`docs/guides/interfaces.md`（英文）与 `docs/zh-CN/guides/interfaces.md`（中文），以及 6 个兼容性回归测试文件。
- 1.0 发布结构：总仓文档与启动脚本成型；`KohakuGBC` 尚未完成，因此不在本次发布中。

### 修复

- UI 进程存活探测不再用 `os.kill(pid, 0)`：Windows 上该调用等价于 `TerminateProcess`，会在启动后 0.15 秒误杀训练进程；改为 `OpenProcess` + `WaitForSingleObject` 只观察句柄。
- UI 工具发现识别 Windows 布局：`.venv/Scripts/<name>.exe` 与 `.venv/bin/<name>` 双向回退，`kogine` / `kohakumoss-config` / `kohakumoss-doctor` 不再只在 POSIX 布局下可见。
- UI 停止流程按平台分支构造信号：`signal.SIGKILL` 只在 POSIX 求值，Windows 走 `taskkill /T`，礼貌停止未生效时立即升级 `/F`。
- UI 子进程输出统一按 UTF-8 读取并设置 `PYTHONIOENCODING`，config 载入与 doctor 输出不再因本地代码页出现乱码。
- UI 静态资源改用固定 MIME 表：Windows 注册表常把 `.js` 报成 `text/plain`，导致模块脚本被浏览器拒绝。
- UI 退出时在 5 秒窗口内停止自己启动的训练进程，避免 `Ctrl+C` 后遗留进程继续占用显存。
- UI 备份文件从创建起即为 0600（`O_CREAT` + `fchmod`）；无 `fchmod` 的平台退回 `chmod`。
- Trainer vcvars 输出不再按本地文本模式解码：依次尝试 UTF-8、locale 代码页与 ANSI，全部失败时丢弃捕获并说明原因，避免注入 mojibake；同时加 120 秒超时与隐藏窗口标志。
- Trainer 工具链补齐 Windows SDK 校验（`WindowsSdkDir` 或 SDK include 树）并设置 `DISTUTILS_USE_SDK` / `MSSdk`，`INCLUDE` / `LIB` 缺失时报出明确原因。
- Trainer MSVC `cl.exe` 发现按本机 host 架构排序（x64，ARM64 机器再退 arm64），覆盖非 vswhere 安装路径。
- Trainer 共享内存不再硬编码 `/dev/shm`：`KOHAKUMOSS_SHM_DIR` → `/dev/shm` → 系统临时目录；Windows 上明确报错而不是尝试映射。
- Trainer 在 Windows 上按名字加载 `cudart64_*.dll` 并注册 `os.add_dll_directory`，`reset_last_error` 失败降级为告警。
- Trainer 新增带指数退避的 `remove_file`：缓存分片、catalog vault、扫描锁与 ready 标记在文件仍被占用时重试，最终以含文件名的 `PermissionError` 或告警收场。
- Trainer 检查点清理能处理只读文件（`rmtree` 的 `onerror` 清位重试），未删除目录会留下告警；`state.json` 显式按 UTF-8 读取。
- Trainer 标注侧文件按 `utf-8-sig` 读取以丢弃 BOM，非 UTF-8 文件回退到 locale 编码并给出一次告警；jsonl 源同样兼容 BOM。

### 已知限制

- Windows 支持未完整测试：仅完成脚本静态检查与上述兼容性修复，未在真实设备上跑通完整训练、多卡与采集流程。
- 采集后端仍有 POSIX 假设（`openat` / `O_NOFOLLOW` / `pread`、浏览器进程管理），Windows 下的采集与停止需独立适配与验证。
- `KohakuGBC` 尚未完成，因此未纳入 1.0。
- 多 GPU 训练（DDP、FSDP2、流水线、线程化）仍仅限 Linux。
- 关闭 UI 进程会保留已启动的采集服务及其任务，重启 UI 不接管旧服务，也不恢复其任务历史。
