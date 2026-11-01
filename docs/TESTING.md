# 测试说明 | Testing

## 中文

作者确认当前合集在自己的 B42.21 单人档中游玩正常：[当前合集](https://steamcommunity.com/sharedfiles/filedetails/?id=3823981387)。这份反馈针对作者当前的单人环境，不表示每个物品、每种组合均已逐项验证。多人和专用服务器未验证。

Steam 合集只提供公开工坊订阅，不包含未公开本地补丁，也不表示启用顺序；实际环境见[完整有序启用列表](current-single-player-modlist.md)。本次双语文案更新未启动游戏复测，未修改玩法、数值、Lua、配方、图片或 1.2.1 版本。

需要复核时，使用已备份的单人测试环境并只保留一种安装来源：

1. 在 MFS 后加载，测试轻型与重型的制作和装卸；重型仅裸枪脚本重量严格大于 5.0 合格。
2. 对比装卸前后受影响枪体与附件重量：最多减重 1.5/5.0，最低 0.1；弹药与弹匣内容仍正常计重。
3. 检查 Misc 互斥、普通枪带共存、已有 Sling 挂件在 Misc 空闲/占用两种情况下的迁移。
4. 保存重进后检查动态减重是否恢复，并检查手持、背挂、转移与容器提示。
5. 自然掉落权重不是掉率百分比；只在未填充的新容器检查，不以旧箱未补货判定失败。

未测得可承诺的 FPS 提升。报告问题时给出 Build、MFS 版本、完整枪械 ID、挂件类型、启用顺序及最小复现步骤，并删去日志中的私人信息。

## English

The author reports normal play with this current collection in their own B42.21 single-player save: [current collection](https://steamcommunity.com/sharedfiles/filedetails/?id=3823981387). This describes the author's current single-player setup, rather than individual testing of every item or combination. Multiplayer and dedicated servers remain untested.

The Steam collection offers public Workshop subscriptions, excludes unpublished local patches and does not represent enabled order; see the [complete ordered enabled list](current-single-player-modlist.md). No fresh game test was run for this bilingual documentation update. Gameplay, values, Lua, recipes, images and version 1.2.1 are unchanged.

When checking behavior, use a backed-up single-player test setup with one installation source:

1. Load after MFS and check crafting, attaching and removal for both charms. Heavy eligibility requires bare weapon script weight strictly above 5.0.
2. Compare affected gun and attachment weight before/after: at most 1.5/5.0 reduction, with a 0.1 minimum. Ammunition and magazine contents still count normally.
3. Check Misc exclusivity, coexistence with ordinary gun slings and legacy Sling migration with Misc both free and occupied.
4. Save/reload and check dynamic reduction restoration, held/hotbar burden, transfers and container tooltips.
5. Loot weights are not percentage drop chances. Check new unfilled containers; old containers receiving no extra loot is expected.

No measured FPS gain is promised. When reporting a problem, provide the Build, MFS version, full weapon ID, charm type, enabled order and minimal reproduction; remove private information from logs.
