# 前置与相关补丁 | Requirements and Related Patches

[中文 README](../README.md) · [English README](../README.en.md) · [补丁合集 / Patch collection](https://github.com/suching8848/suqing-project-zomboid-patches)

## 中文

本挂件的 Mod ID 为 `Codex_PetGunWeightKits_4221`，声明前置为 **`ModernFirearmsSystem`**，原作工坊 ID 为 [3633421539](https://steamcommunity.com/sharedfiles/filedetails/?id=3633421539)。先安装原作，再启用本附加模组。不要同时启用本地与工坊的重复 Mod ID。

**减重挂件自身不强制依赖补丁合集。** 以下补丁分别处理作者完整环境中的其他问题，不能当作挂件的统一必装项：

| 场景 | 合集中的补丁 | 要求 |
| --- | --- | --- |
| MFS 非瞄具配件被错误标为瞄具 | `Codex_MFSOpticsFix_4221` | 声明前置 MFS；按匹配的上游版本使用 |
| M110 弹药盒引用、弹匣外观兼容 | `Codex_MFS_AmmoVisual_Compat_4221` | 声明前置 MFS；其他可选原作见补丁说明 |
| 枪上手电无法被原生快捷键触达 | `Codex_MFS_AttachedLight_Hotkey_4221` | 声明前置 MFS；保留原作瞄准灯逻辑 |
| Noir 人物枪带单人动作兼容 | `Codex_NoirSling_SP_Compat_4221` | 依赖其自己的 Noir 单人补丁，不是枪械 `Misc` 槽挂件的前置 |
| 固定收购与批量卖出 | [枪械商店固定收购模组](https://github.com/suching8848/suqing-mfs-fixed-buyback) | 独立玩法项目，同样以 MFS 为前置，不是本挂件的兼容补丁 |

每个补丁保留独立 Mod ID。只有使用对应原作、功能或遇到其针对的问题时才选用，并遵守补丁中记录的版本和加载关系。不要全选合集。当前单人档的实际顺序见 [清单](current-single-player-modlist.md)；这不是所有 MFS 组合均已验证的声明。

## English

This add-on's Mod ID is `Codex_PetGunWeightKits_4221`. Its declared prerequisite is **`ModernFirearmsSystem`**, Workshop item [3633421539](https://steamcommunity.com/sharedfiles/filedetails/?id=3633421539). Install the original first, then enable this add-on. Do not enable duplicate local and Workshop copies of the same Mod ID.

**The weight charms do not require the patch collection.** These related patches address separate issues in the author's full setup:

| Scenario | Collection entry | Requirement |
| --- | --- | --- |
| Non-optic MFS attachments incorrectly tagged as optics | `Codex_MFSOpticsFix_4221` | Declares MFS; use with the matching upstream version |
| M110 ammo-box reference and magazine visuals | `Codex_MFS_AmmoVisual_Compat_4221` | Declares MFS; consult its page for optional upstream integrations |
| Native light hotkey cannot reach an attached flashlight | `Codex_MFS_AttachedLight_Hotkey_4221` | Declares MFS and retains upstream aiming-light behavior |
| Noir character-sling single-player action compatibility | `Codex_NoirSling_SP_Compat_4221` | Requires its own Noir SP patch, not a prerequisite for these firearm `Misc` attachments |
| Fixed buyback prices and bulk selling | [MFS Fixed Buyback](https://github.com/suching8848/suqing-mfs-fixed-buyback) | Separate gameplay project requiring MFS, not a weight-charm compatibility patch |

Each patch retains its own Mod ID. Choose only entries relevant to your original mods, desired features or affected behavior and follow their documented version/load requirements. Do not enable the collection wholesale. The [snapshot](current-single-player-modlist.md) records the author's order, not compatibility certification for every MFS combination.
