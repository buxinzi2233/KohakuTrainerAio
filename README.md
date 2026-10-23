# KohakuTrainerAio

使用 Git submodule 固定四个独立项目版本的私有总仓库。这里只管理项目布局与提交指针，不合并子项目源码，也不提供统一安装器或已完成的端到端采集、标注、训练流水线。

## 项目关系

| 子目录 | 职责 |
| --- | --- |
| [ArtistSourceGrabber](ArtistSourceGrabber/) | 素材采集工具；具体能力以该子项目固定版本的说明为准。 |
| [KohakuGBC](KohakuGBC/) | 图结构图像描述（Graph-Based Captioning）。 |
| [KohakuMossTrainer](KohakuMossTrainer/) | MOSS-Image 微调与推理。 |
| [KohakuMoss-UI](KohakuMoss-UI/) | 通过 CLI、文件与进程协议连接 Trainer 的独立本地工作台。 |

四项目可分别承担素材准备、描述生成、训练与操作界面等职责；将它们放在同一工作区，不代表 UI 已接入素材采集或 GBC，也不代表这些流程已自动打通。

## 克隆

```bash
git clone --recurse-submodules https://github.com/buxinzi2233/KohakuTrainerAio.git
cd KohakuTrainerAio
```

总仓和 `KohakuMoss-UI` 均为私有仓库，克隆者须分别具备访问权限，并配置可访问它们的 GitHub HTTPS 身份认证。只有总仓访问权不等于拥有私有子仓访问权；不要把令牌或密码写入远程 URL、配置样例或提交文件。

子模块固定到具体提交，而不是自动跟随远程最新分支。四个子项目保留各自的 Git 历史、依赖与安装流程；总仓不创建或合并它们的运行环境。按各自 README 安装，采集、GBC 和训练环境应独立管理；UI 使用 Trainer CLI 时，按 UI 文档配置 Trainer 的 Python/CLI 环境。

## 本地工作与发布范围

本次总仓提交只包含 `README.md`、`.gitignore`、`.gitmodules` 和四个子模块的已提交版本指针。**各子项目当前本地未提交的修改、未跟踪文档、缓存、凭据与下载产物不会包含在子模块指针内，也不会随本次总仓发布。** 新克隆得到的是所固定的远程提交，不是当前机器未提交的工作区快照。

子项目有本地修改时，总仓显示子模块为 dirty 是正常现象，不应为消除提示而重置或覆盖工作。以后更新指针前，须先独立审查并发布子项目所需提交，确保对应远程可获取，再在总仓中明确更新并提交该指针；总仓推送不替代子项目发布。
