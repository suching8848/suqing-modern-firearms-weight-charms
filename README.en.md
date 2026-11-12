# 蘇清的现代枪械减重挂件模组 | SuQing's Firearm Weight Charms Mod

## 42.22.2 offline compatibility candidate

`1.2.2-rc.1` is a local candidate for B42.21–42.22 single-player. Preserves the four charm and material IDs, legacy Sling migration, and Misc-slot exclusivity. In-game testing on 42.22.2 is pending. The release notes below cover the published version.

[中文](README.md) · [English](README.en.md)

A personal weight reduction add-on for [ModernFirearmsSystem (MFS)](https://steamcommunity.com/sharedfiles/filedetails/?id=3633421539) in Project Zomboid.

[**Subscribe on Steam Workshop**](https://steamcommunity.com/sharedfiles/filedetails/?id=3824003141) · Workshop ID: `3824003141`

> **I made these because I wanted to carry both a rifle and a large sniper rifle, but they were too heavy.**
>
> **This mod greatly changes realism and balance. Add it with care. It is intended for players who enjoy collecting, stockpiling and carrying several firearms.**
>
> Large weight reductions weaken the trade-offs involved in carrying guns, looting and moving supplies. This is a personal convenience mod; consider that impact if you prefer realistic carry weight, the original mod's balance or hardcore survival.

![Promotional artwork for SuQing's Firearm Weight Charms](docs/assets/cover.png)

The promotional image is AI-generated illustration. Its character, clothing and weapons are not installed as skins or models. This mod adds no visible charm model to guns.

## The author’s single-player setup and collection

[Workshop collection](https://steamcommunity.com/sharedfiles/filedetails/?id=3823981387) · [Single-player enabled snapshot: 205 IDs on 2026-11-02 01:10 UTC+08:00](docs/current-single-player-modlist.md) · [Ten source repositories and 42 Mod IDs](docs/project-index.md)

The current snapshot contains **205 Mod IDs, 161 Workshop items and 33 separately installed local mods or patches not included in collection downloads**. The author previously reported normal play with their full B42.21 single-player setup; this is not individual acceptance of every project or new version. Multiplayer and dedicated servers remain untested.

Source repositories are now linked for the local projects. Subscribing to the Steam collection alone still does not reproduce the full setup. See [requirements and patch relationships](docs/PATCH_DEPENDENCIES.md) for mandatory dependencies and conditional integrations.

## Original mod and requirement

- **Original mod:** [ModernFirearmsSystem on Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3633421539)
- **Required Workshop ID:** `3633421539`
- **Required Mod ID:** `ModernFirearmsSystem`
- **This add-on's Mod ID:** `Codex_PetGunWeightKits_4221`

Thanks to the original author for the weapons, attachment system and inspection interface. This is an independent personal add-on with no affiliation to that author. It contains only the weight charms, with none of MFS's code, models, textures or sounds. Subscribe to MFS separately and follow its own installation, load order and compatibility guidance.

## Version and scope

| Item | Current scope |
| --- | --- |
| Game | Build 42.21 |
| Environment | Maintained for single-player; multiplayer untested |
| Package version | 1.2.1 |
| Weight reduction core version | 1.1.1 |
| Attachment slot | The firearm's `Misc` slot |
| This update | Bilingual documentation, the author's current collection and complete enabled list; gameplay, assets and version remain 1.2.1 |

The mod was made primarily for MFS firearms. Its code builds the attachment list from ranged weapons that define an ammunition type, so qualifying vanilla or other modded firearms can also be included. **That is not a claim of tested compatibility with every firearm mod.**

## Two charms

| Charm | Eligibility | Maximum weight reduction | Charm's own weight |
| --- | --- | ---: | ---: |
| Light | Qualifying firearms | 1.5 | 0.1 |
| Heavy | Bare weapon script weight strictly above 5.0 | 5.0 | 0.2 |

These are game weight values. A weapon with a bare script weight of exactly 5.0 is ineligible for the heavy charm. Adding heavy attachments does not make it eligible.

- Only one light or heavy charm may be installed on a firearm.
- It occupies `Misc`, excluding other attachments in that slot, and can coexist with an ordinary firearm sling.
- It does not occupy Noir character slings or character back-carry positions.
- After other attachment modifiers are applied, reduction is capped at the amounts above, with at least 0.1 left for the affected gun and attachments.
- Ammunition and magazine contents are excluded from reducible weight and still count toward carried weight. A light gun may receive less than the full 1.5 reduction.
- Native held and hotbar burden multipliers remain in use. If another mod changes weight calculation, the actual in-game result takes precedence.

For example, a bare weapon weighing 7.0, without ammunition or other attachments, has its affected gun weight reduced to 2.0 by the heavy charm. This large reduction explains its impact on realism and balance.

## Installation

The Workshop and manual versions use the same Mod ID. Choose one source. Before switching from a local version, exit the game and retain a backup; avoid two installed copies of the same ID.

For Workshop installation, subscribe to [this add-on](https://steamcommunity.com/sharedfiles/filedetails/?id=3824003141) and [MFS](https://steamcommunity.com/sharedfiles/filedetails/?id=3633421539). Enable them in the game and target single-player save, with this add-on loading after MFS. A Workshop installation does not require copying the local folder below.

For manual installation:

1. Subscribe to and enable MFS.
2. Exit the game; back up the save and any existing local version.
3. Copy the repository's entire `mods/PetGunWeightKits_4221_Local` folder into your Windows user's `Zomboid/mods` folder.
4. Keep the folder structure `Zomboid/mods/PetGunWeightKits_4221_Local/42/mod.info`, alongside `42/media` and the supplied `common` directory.
5. Start the game and enable this add-on in the mod list and target single-player save, loading after `ModernFirearmsSystem`.

Copy the named mod folder, rather than the repository root. Existing users of the old pet weight kits retain the original Mod ID and do not need a second copy.

## Obtaining and using charms

### Crafting

In the crafting menu's Weapons category, search for “SuQing” or the charm name. Recipes are visible by default.

| Charm | Mechanics | Consumed materials | Kept tool |
| --- | ---: | --- | --- |
| Light | 1 | Aluminum ×2, screws ×2, duct tape ×1 use | Screwdriver |
| Heavy | 3 | Aluminum ×4, screws ×4, duct tape ×2 uses | Screwdriver |

Aluminum means `Base.Aluminum` (Aluminum Foil). Localized names may differ. Aluminum scrap or fragments are different items and cannot substitute for it.

### Natural loot

| Container distribution | Light relative weight | Heavy relative weight |
| --- | ---: | ---: |
| Gun store accessories `GunStoreAccessories` | 1.0 | — |
| Police gun storage `PoliceStorageGuns` | 0.5 | — |
| Military gun storage `ArmyStorageGuns` | 0.8 | 0.15 |

These are relative native draw weights, **not percentage drop chances**. Loot rarity settings and the other items in the same distribution also affect results. The mod does not add charms to containers already filled, add a timed restock system or add zombie drops. Look in unexplored areas or containers not yet populated.

### Attaching and removing

Keep the charm in your character's main inventory and leave the gun's `Misc` slot empty. Use the standard right-click attachment action or MFS's inspection interface. Installation requires no additional tool.

Remove it through the standard attachment menu or MFS's current slot controls. Charms are reusable; light and heavy cannot stack.

## Saves and removal

Legacy `Sling` charm definitions and item IDs remain available. Loose legacy charms in ordinary containers can migrate to the new version. Charms already on guns migrate when `Misc` is free; when it is occupied, the old charm remains active until that slot is cleared.

Native saves do not retain an attachment instance's dynamic weight modifier. This mod restores it on load, attachment changes, equipping, transfers and container checks.

**Before disabling or removing the mod, detach its charms from every gun, deal with existing charm items, and back up the save.** Mod and item IDs remain stable for save compatibility; avoid renaming those internal identifiers.

## Validation and limits

- Maintained for Build 42.21 single-player; multiplayer has not been tested.
- The author reports normal play with the current collection in their own B42.21 single-player save. This bilingual documentation and collection-link update did not launch the game for a fresh test.
- Version 1.2.1 includes relevant-item caching and reduced repeated container scanning. No measured FPS improvement is promised.
- MFS or other mod updates may require new checks of attaching, removal, display and weight calculation.
- No separate inventory UI performance patch is required or included.
- See [Testing / 测试说明](docs/TESTING.md) for validation scope and suggested checks.

## Repository layout

```text
mods/PetGunWeightKits_4221_Local/42/   Installable mod
  media/scripts/                    Items and crafting recipes
  media/lua/shared/Items/            Weight reduction, eligibility and migration
  media/lua/client/                  Native action integration and tooltips
  media/lua/server/Items/            Natural loot registration
  media/lua/shared/Translate/        CH / CN / EN translations
  media/textures/                   Current charm icon
docs/assets/cover.png                Promotional artwork
```

## Assets and credits

- Original firearms, attachments and weapon inspection belong to [MFS](https://steamcommunity.com/sharedfiles/filedetails/?id=3633421539) and their respective author.
- The current charm icon uses character artwork supplied by the author. The promotional illustration was generated with imagegen for separate promotional use.
- Internal names such as `Codex_PetGunWeightKits_4221`, `CodexPetGunWeightKits.*` and `MakePet*` remain stable for existing items and recipes. The displayed mod name is SuQing's Firearm Weight Charms.

See [Changelog / 更新记录](CHANGELOG.md) and [Workshop publishing / 工坊发布](docs/WORKSHOP.md).
