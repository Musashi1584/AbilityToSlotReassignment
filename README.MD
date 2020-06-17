### Dynamic reassignment of item slots to abilities
This mod allows you to define weapon categories for abilities.
Based on this config the mod will look for an item in the soldiers loadout
that matches the weapon category and assigns the ability to the slot of the found item.
This functionality was part of rpgo and is released standalone in this mod.

Example config in `XComAbilityToSlotReassignment.ini`

```
+AbilityWeaponCategories = (AbilityName=PistolStandardShot, WeaponCategories=(pistol, sidearm))
```

What this does is it will reassign the PistolStandardShot to the first slot it finds a pistol in.
So it will be irrelvant what slot is defined in the XComClassData.ini of the soldier like
```
AbilityType=(AbilityName="PistolStandardShot",  ApplyToWeaponSlot=eInvSlot_SecondaryWeapon))
```
usually means PistolStandardShot will only work for secondary pistols.
With the config above it doesnt matter if the pistol is in the primary, secondary, utility or dedicated pistol slot.


### Loadout API
Another feature of the mod is the loadout api. Its only interesting for modder as it offers an API
to detect different loadouts like e.g primary pistol or dual wield melee.

```cs
static function bool HasPrimaryMeleeOrPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState);
static function bool HasMeleeAndPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState);
static function bool HasPrimaryMeleeEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState);
static function bool HasPrimaryPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState);
static function bool HasSecondaryMeleeEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState);
static function bool HasSecondaryPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState);
static function bool HasShieldEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState);
static function bool HasDualPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState);
static function bool HasDualMeleeEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState);
static function bool IsPrimaryPistolItem(XComGameState_Item ItemState, optional bool bUseTemplateForSlotCheck = false);
static function bool IsPrimaryMeleeItem(XComGameState_Item ItemState, optional bool bUseTemplateForSlotCheck = false);
static function bool IsSecondaryPistolItem(XComGameState_Item ItemState, optional bool bUseTemplateForSlotCheck = false);
static function bool IsSecondaryMeleeItem(XComGameState_Item ItemState, optional bool bUseTemplateForSlotCheck = false);
static function bool IsPistolItem(XComGameState_Item ItemState, optional EInventorySlot InventorySlot = eInvSlot_SecondaryWeapon, optional bool bUseTemplateForSlotCheck = false);
static function bool IsMeleeItem(XComGameState_Item ItemState, optional EInventorySlot InventorySlot = eInvSlot_SecondaryWeapon, optional bool bUseTemplateForSlotCheck = false);
static function bool IsMeleeWeaponTemplate(X2WeaponTemplate WeaponTemplate);
static function bool IsPistolWeaponTemplate(X2WeaponTemplate WeaponTemplate);
```

#### Client side usage
Add the `LoadoutApi_1_0_0` package of this mod to the mod you want to use the api in.
Enable it in `XComEngine.ini` like
```
[UnrealEd.EditorEngine]
!ModEditPackages=()
+ModEditPackages=LoadoutApi_1_0_0
```

then you can use the api functions e.g like 
```cs
bHasDualPistolsEquipped = class'LoadoutApiFactory'.static.GetLoadoutApi().HasDualPistolEquipped(UnitState);
```
