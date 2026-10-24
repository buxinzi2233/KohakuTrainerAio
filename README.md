# KohakuTrainerAio

MOSS-Image 的本地微调工作区：训练框架 + 本地 Web 工作台 + 素材采集。当前为 **1.0** 版本。

> [!WARNING]
> **Windows 支持未做完整测试。** 1.0 的 Windows 部分只完成了启动脚本的静态检查与一部分兼容性修复（进程、编码、文件语义、工具链探测），没有在真实 Windows 设备上跑通完整流程；采集后端的浏览器进程管理与安全文件读取仍含 POSIX 假设。欢迎提交 issue 说明环境，但请不要把当前状态当作生产可用承诺。

## 1.0 说明

- 发布范围是 `KohakuMossTrainer`、`KohakuMoss-UI`、`ArtistSourceGrabber` 三个子模块加根目录的两个启动脚本。
- `KohakuGBC`（图结构图像描述）**尚未完成，因此 1.0 不含它**：组件表与快速开始都没有它；本地若存在 `KohakuGBC/` 目录，只是一份本地检出，不随 1.0 分发。
- Trainer 与 UI 的版本号为 1.0.0；采集器沿用其自身 2.0 版本线。UI 通过 CLI、文件与进程契约分别对接两者，不导入它们的源码。

## 组件

| 组件 | 职责 | 位置 |
| --- | --- | --- |
| KohakuMossTrainer | MOSS-Image 微调与推理：LoRA / LyCORIS（LoCon、LoHa、LoKr、DoRA、OFT、BOFT、GLoRA、IA3、DyLoRA、T-LoRA）、全量微调、6–8 GB 低显存配置档、多 GPU（仅 Linux） | `KohakuMossTrainer/` |
| KohakuMoss-UI | 本地 Web 工作台：训练队列、运行记录、数据集、产物、环境体检、设置，以及图片采集、标注、翻译工作台 | `KohakuMoss-UI/` |
| ArtistSourceGrabber | 多来源素材采集（X、Pixiv、Danbooru 等）与可选图像打标，由 UI 作为独立服务拉起 | `ArtistSourceGrabber/` |

总仓只固定三个子模块的提交指针：不合并源码，不提供统一安装器，也不接管各自的依赖、测试与发布节奏。子模块固定在具体提交上，不会自动跟随上游最新分支；新克隆得到的是所固定的提交，不是某台机器上的工作区快照。

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

总仓根目录不额外新增统一许可证，也没有覆盖子项目许可的能力。

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
