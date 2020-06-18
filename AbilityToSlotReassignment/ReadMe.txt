[h1]Dynamic reassignment of item slots to abilities[/h1]
This mod allows you to define weapon categories for abilities. Based on this config the mod will look for an item in the soldiers loadout that matches the weapon category and assigns the ability to the slot of the found item. This functionality was part of rpgo and is released standalone in this mod.

Example config in XComAbilityToSlotReassignment.ini

[code]
+AbilityWeaponCategories = (AbilityName=PistolStandardShot, WeaponCategories=(pistol, sidearm))
[/code]
What this does is it will reassign the PistolStandardShot to the first slot it finds a pistol in. So it will be irrelvant what slot is defined in the XComClassData.ini of the soldier like

[code]
AbilityType=(AbilityName="PistolStandardShot",  ApplyToWeaponSlot=eInvSlot_SecondaryWeapon))
[/code]

usually means PistolStandardShot will only work for secondary pistols. With the config above it doesnt matter if the pistol is in the primary, secondary, utility or dedicated pistol slot.

By default this mod supplies config for vanilla melee and pistol abilities.

[h1]Loadout API[/h1]

Another feature of the mod is the loadout api. Its only interesting for modder as it offers an API to detect different loadouts like e.g primary pistol or dual wield melee. This is an attempt to unify the different methods of detecting loadouts in various mods and provide a single source of truth.

For more info see https://github.com/Musashi1584/AbilityToSlotReassignment/blob/master/README.MD

[h1]Mod troubleshooting[/h1]
https://www.reddit.com/r/xcom2mods/wiki/mod_troubleshooting

[h1]Patreon[/h1]
Have look at my work in progress and infos on my mods at my patreon page.
Your really like my mods and would like to help me have more time for modding? Consider become a patreon :)

https://www.patreon.com/musashi1584