# Steam 创意工坊发布 | Workshop publishing

[中文](#中文) · [English](#english)

## 中文

已发布条目：[蘇清的现代枪械减重挂件](https://steamcommunity.com/sharedfiles/filedetails/?id=3824003141)。Workshop ID 固定为 `3824003141`，后续更新必须使用这个 ID，不能再次以 `0` 新建。

**本模组极其影响游戏真实性与平衡性，请谨慎添加。适合喜欢收集、囤积物资和多带枪械的屯屯鼠玩家。**

原模组：[ModernFirearmsSystem](https://steamcommunity.com/sharedfiles/filedetails/?id=3633421539)。必须启用其 Mod ID `ModernFirearmsSystem`。

在仓库根目录准备标准上传目录：

```sh
python tools/prepare_workshop.py
python tools/prepare_workshop.py --check
```

默认创建 `%UserProfile%/Zomboid/Workshop/SuQingGunWeightCharms`，包含 `workshop.txt`、512×512 PNG 预览、更新说明及 `Contents/mods/PetGunWeightKits_4221_Local`。脚本不连接 Steam，不修改已安装模组或个人存档，也不会覆盖已有上传目录。

通过游戏主菜单的创意工坊上传器，选择该目录，核对标题、说明、封面、标签和公开可见性后提交。脚本会从 `publishing/workshop.json` 读取已发布的 ID 并写入 `workshop.txt`；更新前务必核对 `id=3824003141`，保留此 ID 更新，不能重新创建重复条目。

也可按 [Valve 的 SteamCMD 官方说明](https://partner.steamgames.com/doc/features/workshop/implementation#SteamCmd)，使用已登录的 SteamCMD 发布 `Contents`。本机上传配置保存在仓库之外，不提交登录缓存、凭证或主机专用路径。SteamCMD 不保证设置网页分类和必需条目，发布后须核对这些字段；需要的工坊前置为 `3633421539`，不要误设其他可选模组。

工坊介绍源文件是 `publishing/description.bbcode.txt`，发布资料是 `publishing/workshop.json`。封面沿用已选白紫战术插画，图片只是宣传素材，不新增人物皮肤、服装或枪上模型。

订阅版与旧本地版的 Mod ID 均为 `Codex_PetGunWeightKits_4221`。切换安装来源时退出游戏并保留备份，只保留一种来源，避免重复 Mod ID；发布本身不需要改变个人存档的启用配置。

## English

Published item: [SuQing's Firearm Weight Charms](https://steamcommunity.com/sharedfiles/filedetails/?id=3824003141). Its Workshop ID remains `3824003141`; update that item rather than creating a duplicate with ID `0`.

**This mod greatly changes realism and balance. Use with care. It is intended for players who enjoy collecting, stockpiling and carrying several firearms.**

The required original mod is [ModernFirearmsSystem](https://steamcommunity.com/sharedfiles/filedetails/?id=3633421539); enable its Mod ID `ModernFirearmsSystem`.

From the repository root, prepare and check the standard upload folder:

```sh
python tools/prepare_workshop.py
python tools/prepare_workshop.py --check
```

The default destination is `%UserProfile%/Zomboid/Workshop/SuQingGunWeightCharms`, containing `workshop.txt`, a 512×512 PNG preview, change notes and `Contents/mods/PetGunWeightKits_4221_Local`. The script does not contact Steam, change installed mods or personal saves, or overwrite an existing upload directory.

Select the directory in the game's main-menu Workshop uploader. Check the bilingual title, description, preview, tags and public visibility before submitting. The script reads the published ID from `publishing/workshop.json` and writes it into `workshop.txt`. Confirm `id=3824003141` before updating; preserve that ID.

[Valve's SteamCMD publishing instructions](https://partner.steamgames.com/doc/features/workshop/implementation#SteamCmd) are another option for submitting `Contents` with a logged-in SteamCMD. Keep machine-specific upload settings outside the repository; never commit login caches, credentials or host-specific paths. SteamCMD does not guarantee webpage categories or required-item metadata, so verify them afterward. The required Workshop item is `3633421539`; do not mark unrelated optional mods as required.

Description source: `publishing/description.bbcode.txt`. Metadata: `publishing/workshop.json`. The selected white-and-purple tactical artwork remains promotional material; it adds no character skin, clothing or visible gun model.

Workshop and old local versions share Mod ID `Codex_PetGunWeightKits_4221`. Exit the game and retain a backup before switching sources; keep only one copy of that ID. Publishing does not require changing the enabled list in a personal save.
