# KohakuTrainerAio

MOSS-Image 的本地微调工作区：训练框架 + 本地 Web 工作台 + 素材采集。当前为 **2.0** 版本。

> [!WARNING]
> **Windows 支持未做完整测试。** 2.0 的 Windows 部分只完成了启动脚本的静态检查与一部分兼容性修复（进程、编码、文件语义、工具链探测），没有在真实 Windows 设备上跑通完整流程；采集后端的浏览器进程管理与安全文件读取仍含 POSIX 假设。欢迎提交 issue 说明环境，但请不要把当前状态当作生产可用承诺。

## 2.0 说明

- 发布范围是 `KohakuMossTrainer`、`KohakuMoss-UI`、`ArtistSourceGrabber`、`KohakuGBC` 四个子模块加根目录的两个启动脚本。
- `KohakuGBC`（图结构图像描述）**已作为第 4 个子模块纳入**，父仓库固定其提交指针；本地 `KohakuGBC/` 目录不再是「不随发布分发的本地检出」。
- `KohakuMossTrainer` 与 `KohakuMoss-UI` 的版本号仍为 1.0.0；采集器沿用其自身 2.x 版本线。UI 通过 CLI、文件与进程契约分别对接它们，不导入它们的源码。

## 组件

| 组件 | 职责 | 位置 |
| --- | --- | --- |
| KohakuMossTrainer | MOSS-Image 微调与推理：LoRA / LyCORIS（LoCon、LoHa、LoKr、DoRA、OFT、BOFT、GLoRA、IA3、DyLoRA、T-LoRA）、全量微调、6–8 GB 低显存配置档、多 GPU（仅 Linux） | `KohakuMossTrainer/` |
| KohakuMoss-UI | 本地 Web 工作台：训练队列、运行记录、数据集、产物、环境体检、设置，以及图片采集、标注、翻译工作台 | `KohakuMoss-UI/` |
| ArtistSourceGrabber | 多来源素材采集（X、Pixiv、Danbooru 等）与可选图像打标，由 UI 作为独立服务拉起 | `ArtistSourceGrabber/` |
| KohakuGBC | 图结构图像描述（GBC）：在 Togeari 数据流机上以 KIR 程序生成图与逐实体描述 | `KohakuGBC/` |

总仓只固定四个子模块的提交指针：不合并源码，不提供统一安装器，也不接管各自的依赖、测试与发布节奏。子模块固定在具体提交上，不会自动跟随上游最新分支；新克隆得到的是所固定的提交，不是某台机器上的工作区快照。

## 功能一览

完整说明（数据流、页面逐项读写、契约边界、出处）见 [功能说明](docs/features.md)。

- **训练**：MOSS-Image 的 LoRA / LoCon、LoHa、LoKr、DoRA、OFT 与全量微调，配置里对应 `ALGO` 的 `lora`、`loha`、`lokr`、`oft`、`dora`、`full` 六个预设。
- **低显存与多卡**：6 / 8 / 12 / 16 / 24 GB 与 `auto` 显存档，全量微调另有 24 GB 交换档；DDP、FSDP2、pipeline、threaded 四种并行（仅 Linux）。
- **数据**：kohya、folder、folder_nl、jsonl、parquet、webdataset、moss_shard 七类数据源，支持离线/在线文本与 latent 缓存，规划由数据、种子与参数决定，恢复时精确重放。
- **导出与出图**：ComfyUI 格式适配器、LyCORIS 文件、合并后的 transformer、diffusers 目录；`scripts/sample/sample.py` 可直接采样，`compare_grid.py` 生成检查点对比图。
- **本地工作台**：训练记录与详情、新建训练（AST 扫描参数、只把改动作为 `--set` 下发、命令预览）、训练队列、数据集、产物、环境体检、设置与主题。
- **素材采集工作台**：8 个来源的多来源采集、仅图片模式、按下载分组浏览图库、显式重新打标。
- **标注与翻译工作台**：冻结快照 → 编辑计划 → 服务端差异预览 → 确认写入 → 可撤销；翻译走本地词典或显式启用的文本 API，译文只落 UI 状态目录。
- **契约边界**：UI 只通过 CLI、文件与进程契约对接，不写 run 目录、不导入训练器源码；运行状态由托管 pid、`metrics.jsonl` 与 `config.json` 推断。
- **跨平台**：提供了 `start.sh` 与 `start.bat`，Windows 兼容层覆盖进程、编码、文件语义与工具链探测，但**未在真实设备上跑通完整流程**。
- **素材来源合规**：采集器只执行显式提交的任务，来源站点条款、作品版权与数据集使用许可需自行核验。

## 界面一览

| 训练记录 | 新建训练 |
| --- | --- |
| ![训练记录](docs/images/runs.png) | ![新建训练](docs/images/new-run.png) |
| **数据集** | **图片采集** |
| ![数据集](docs/images/datasets.png) | ![图片采集](docs/images/grabber.png) |

<sub>截图为演示数据，路径与数值以你本机为准。其余页面（训练详情、训练队列、产物、环境体检、设置、标注与翻译工作台）与逐步操作见 [功能说明](docs/features.md) 与 [训练图文教程](docs/training-tutorial.md)。</sub>

## 克隆

```bash
git clone --recurse-submodules https://github.com/buxinzi2233/KohakuTrainerAio.git
cd KohakuTrainerAio
```

已克隆但缺子模块时，在总仓内执行 `git submodule update --init --recursive`（这是 Git 操作，启动脚本不会代做）。

各子项目的依赖要分别安装，命令以子项目自己的 README 为准：

| 子项目 | 安装入口 |
| --- | --- |
| Trainer | `bash scripts/install/install.sh`（Linux）或 `powershell -ExecutionPolicy Bypass -File scripts\install\install.ps1`（Windows），详见 `KohakuMossTrainer/docs/guides/install.md` 与 `KohakuMossTrainer/docs/guides/install-windows.md` |
| UI | 在 Trainer 的虚拟环境里 `uv pip install -e .`（可选 `-e ".[native]"` 启用 pywebview 窗口），详见 `KohakuMoss-UI/README.md` |
| ASG | 按 `ArtistSourceGrabber/README.md` 安装其 `requirements`；UI 通过 `KOHAKUMOSS_GRABBER_ROOT` 与 `KOHAKUMOSS_GRABBER_PYTHON` 指向它 |
| GBC | 按 `KohakuGBC/README.md` 安装其发行包（`pip install kohakugbc`，可选 extras 如 `[torch]`、`[vllm]`、`[qwen35]`），或可编辑安装 `uv pip install -e packages/kohakugbc-data -e ".[torch,qwen35,dev]"` |

## 快速开始

脚本只按自身位置定位子项目，以前台方式启动 UI（`python -m kohakumoss_ui --root <Trainer>`），不安装依赖、不初始化子模块、不更新仓库、不自动启动采集或训练任务。

```bash
./start.sh                 # Linux
```

```bat
start.bat                  :: Windows，原生 cmd，无需 PowerShell
```

默认只监听 `127.0.0.1`、自动选择空闲端口并生成访问令牌；保持终端打开，`Ctrl+C` 停止。UI 自身会恢复状态中已有的待运行队列，需要隔离验证时传入全新的 `--state` 与 `--runs`。

### 参数与解释器

参数原样转交给 UI：

| 参数 | 说明 |
| --- | --- |
| `--root` | Trainer checkout；脚本已传入本工作区的绝对路径，后写的 `--root` 覆盖它 |
| `--runs` | run 输出根，默认 `<root>/runs/moss` |
| `--state` | UI 状态目录，默认 `$XDG_STATE_HOME/kohakumoss-ui`（未设置时为 `~/.local/state/kohakumoss-ui`） |
| `--host` | 绑定地址，默认 `127.0.0.1` |
| `--port` | 端口，`0` 表示由系统挑空闲端口 |
| `--token` | 固定访问令牌，默认自动生成 |
| `--no-open` | 不打开浏览器 |
| `--native` | 使用 pywebview 原生窗口（需装 `[native]`） |

```bash
./start.sh --help
./start.sh --port 7860 --no-open
./start.sh --state "/tmp/aio-test-state" --runs "/tmp/aio-test-runs" --no-open
```

```bat
start.bat --port 7860 --no-open
set "AIO_PYTHON=C:\Python312\python.exe"
start.bat --state "D:\AIO test\state" --runs "D:\AIO test\runs" --no-open
```

解释器选择顺序：`AIO_PYTHON` → Trainer 的 `.venv` → UI 的 `.venv` → 系统 `python3` / `python`（Windows 最后尝试 `py -3`），要求 **Python >= 3.11**。显式覆盖无效或已有虚拟环境损坏时脚本直接报错，不会悄悄换环境。Windows 启动失败会保留退出码并暂停，便于双击查看错误；自动化场景可先 `set "AIO_NO_PAUSE=1"`。

脚本会设置或补全的环境变量（已存在的值不覆盖）：

| 变量 | 作用 |
| --- | --- |
| `AIO_PYTHON` | 启动器使用的解释器路径（不是带参数的命令） |
| `AIO_NO_PAUSE` | Windows 下为 `1` 时失败不暂停 |
| `PYTHONPATH` | 追加 UI 的 `src`，无需先做 editable 安装 |
| `KOHAKUMOSS_PYTHON` | 训练使用的解释器，默认 Trainer 的 venv，否则用启动器所选解释器 |
| `KOHAKUMOSS_ROOT` / `KOHAKUMOSS_RUNS` | 覆盖 Trainer 根与 run 输出根 |
| `KOHAKUMOSS_UI_STATE` | 覆盖 UI 状态目录（等同于 `--state`） |
| `KOHAKUMOSS_GRABBER_ROOT` / `KOHAKUMOSS_GRABBER_PYTHON` | 覆盖采集器 checkout 与解释器 |

## 版本与许可证

各子项目保留自己的许可证，本文件不构成再许可：

| 子项目 | 许可证 |
| --- | --- |
| Trainer | KohakuMoss License 1.0（Apache-2.0 加一项附加条款：衍生作品名称须含 “Kohaku”） |
| UI | MIT |
| ASG | 沿用其上游仓库的许可与使用条款；当前 checkout 根目录没有 `LICENSE` 文件，上游 README 明确说明未提供许可证时不自动授予复制、再分发或商业使用许可 |
| GBC | Apache-2.0（见 `KohakuGBC/LICENSE`） |

总仓根目录不额外新增统一许可证，也没有覆盖子项目许可的能力。

## 文档

- [功能说明](docs/features.md)：四个子模块的能力、数据流、页面逐项读写与契约边界。
- [训练图文教程](docs/training-tutorial.md)：从安装到出图的完整走查。
- [变更记录](CHANGELOG.md)：按版本列出新增、修复与已知限制。
- Trainer：[README](KohakuMossTrainer/README.md) · [文档索引](KohakuMossTrainer/docs/README.md) · [中文文档](KohakuMossTrainer/docs/zh-CN/README.md)（安装、数据、配置、全量微调、多卡、导出与推理都在 `KohakuMossTrainer/docs/guides/`）。
- UI：[README](KohakuMoss-UI/README.md) · [接口参考](KohakuMoss-UI/docs/interfaces.md) · [采集接入](KohakuMoss-UI/docs/grabber.md) · [标注工作台](KohakuMoss-UI/docs/annotation-workbench.md)。
- 采集器：[README](ArtistSourceGrabber/README.md) · [接口参考](ArtistSourceGrabber/docs/API.md)。

## 贡献

欢迎 issue 与 PR。

- issue 请附系统与版本（OS、Python、torch/CUDA、GPU）、复现步骤和相关日志；Windows 问题请附 `start.bat` 的完整输出。
- PR 请保持改动聚焦，遵循对应子项目已有的代码风格与测试方式；跨子项目的改动请拆开提交。
- Trainer 的功能类 PR 需先有已批准的 issue，详见 `KohakuMossTrainer/CONTRIBUTING.md`。
- 采集、标注、翻译相关接口的现行契约见 `KohakuMoss-UI/docs/interfaces.md`、`KohakuMoss-UI/docs/grabber.md`、`KohakuMoss-UI/docs/annotation-workbench.md`。

## 已知限制

- Windows 未完整测试（见文首声明）；多 GPU 训练仅 Linux。
- 采集服务的适配器目前面向 POSIX，Windows 下的采集与停止流程需独立适配。
- 关闭 UI 进程不会停止已启动的采集服务与其任务，重启 UI 也不会接管旧服务或旧任务历史。
