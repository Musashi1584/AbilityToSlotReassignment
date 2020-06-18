//-----------------------------------------------------------
//	Class:	LoadoutApiLib
//	Author: Musashi
//	
//-----------------------------------------------------------


class LoadoutApiLib extends Object implements(LoadoutApiInterface) config (LoadoutApi);

var config array<name> PistolWeaponCategories;
var config array<name> ShieldWeaponCategories;
var config array<name> MainWeaponCategories;

var config array<name> MeleeWeaponTemplateBlacklist;
var config array<name> MeleeWeaponCategoryBlacklist;
var config array<name> PistolWeaponTemplateBlacklist;
var config array<name> PistolWeaponCategoryBlacklist;
var config array<name> AkimboWeaponCategoryBlacklist;

static function bool HasPrimaryMeleeOrPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	return HasPrimaryMeleeEquipped(UnitState, CheckGameState) || HasPrimaryPistolEquipped(UnitState, CheckGameState);
}

static function bool HasMeleeAndPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	return (HasPrimaryMeleeEquipped(UnitState, CheckGameState) && HasSecondaryPistolEquipped(UnitState, CheckGameState)) ||
		   (HasPrimaryPistolEquipped(UnitState, CheckGameState) && HasSecondaryMeleeEquipped(UnitState, CheckGameState));
}

static function bool HasPrimaryMeleeEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item PrimaryWeapon;

	if (UnitState == none)
	{
		return false;
	}

	PrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon, CheckGameState);

	return PrimaryWeapon != none && IsPrimaryMeleeItem(PrimaryWeapon) &&
		!HasDualMeleeEquipped(UnitState, CheckGameState) &&
		!HasShieldEquipped(UnitState, CheckGameState);
}

static function bool HasPrimaryPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item PrimaryWeapon;

	if (UnitState == none)
	{
		return false;
	}

	PrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon, CheckGameState);

	return PrimaryWeapon != none && IsPrimaryPistolItem(PrimaryWeapon) &&
		!HasDualPistolEquipped(UnitState, CheckGameState) &&
		!HasShieldEquipped(UnitState, CheckGameState);
}

static function bool HasSecondaryMeleeEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item SecondaryWeapon;

	if (UnitState == none)
	{
		return false;
	}

	SecondaryWeapon = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);

	return SecondaryWeapon != none && IsSecondaryMeleeItem(SecondaryWeapon);
}

static function bool HasSecondaryPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item SecondaryWeapon;

	if (UnitState == none)
	{
		return false;
	}

	SecondaryWeapon = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);

	return SecondaryWeapon != none && IsPistolItem(SecondaryWeapon);
}

static function bool HasShieldEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item SecondaryWeapon;
	local X2WeaponTemplate SecondaryWeaponTemplate;

	if (UnitState == none)
	{
		return false;
	}

	SecondaryWeapon = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);
	if (SecondaryWeapon != none)
	{
		SecondaryWeaponTemplate = X2WeaponTemplate(SecondaryWeapon.GetMyTemplate());
		return SecondaryWeaponTemplate != none && default.ShieldWeaponCategories.Find(SecondaryWeaponTemplate.WeaponCat) != INDEX_NONE;
	}
	return false;
}

static function bool HasDualPistolEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item PrimaryWeapon, SecondaryWeapon;
	local X2WeaponTemplate PrimaryTemplate, SecondaryTemplate;

	if (UnitState == none)
	{
		return false;
	}

	PrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon, CheckGameState);
	SecondaryWeapon = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);
	if (PrimaryWeapon != none && SecondaryWeapon != none)
	{
		PrimaryTemplate = X2WeaponTemplate(PrimaryWeapon.GetMyTemplate());
		SecondaryTemplate = X2WeaponTemplate(SecondaryWeapon.GetMyTemplate());

		return PrimaryTemplate != none && SecondaryTemplate != none && 
				IsPrimaryPistolItem(PrimaryWeapon) && IsSecondaryPistolItem(SecondaryWeapon) &&
				default.AkimboWeaponCategoryBlacklist.Find(PrimaryTemplate.WeaponCat) == INDEX_NONE &&
				default.AkimboWeaponCategoryBlacklist.Find(SecondaryTemplate.WeaponCat) == INDEX_NONE &&
				PrimaryTemplate.WeaponCat == SecondaryTemplate.WeaponCat; // can dual wield guns only with the same WeaponCat
	}

	return false;
}

static function bool HasDualMeleeEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item PrimaryWeapon, SecondaryWeapon;

	if (UnitState == none)
	{
		return false;
	}

	PrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon, CheckGameState);
	SecondaryWeapon = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);

	return PrimaryWeapon != none && IsPrimaryMeleeItem(PrimaryWeapon) &&
		SecondaryWeapon != none && IsSecondaryMeleeItem(SecondaryWeapon);
}


static function bool HasSecondaryPrimaryEquipped(XComGameState_Unit UnitState, optional XComGameState CheckGameState)
{
	local XComGameState_Item PrimaryWeapon, SecondaryWeapon;

	if (UnitState == none)
	{
		return false;
	}

	PrimaryWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon, CheckGameState);
	SecondaryWeapon = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon, CheckGameState);
	if (PrimaryWeapon != none && SecondaryWeapon != none)
	{

		return IsPrimaryMainWeaponItem(PrimaryWeapon) && IsSecondaryMainWeaponItem(SecondaryWeapon);
	}

	return false;
}

static function bool IsPrimaryPistolItem(XComGameState_Item ItemState, optional bool bUseTemplateForSlotCheck = false)
{
	return IsPistolItem(ItemState, eInvSlot_PrimaryWeapon, bUseTemplateForSlotCheck);
}

static function bool IsPrimaryMeleeItem(XComGameState_Item ItemState, optional bool bUseTemplateForSlotCheck = false)
{
	return IsMeleeItem(ItemState, eInvSlot_PrimaryWeapon, bUseTemplateForSlotCheck);
}

static function bool IsPrimaryMainWeaponItem(XComGameState_Item ItemState, optional bool bUseTemplateForSlotCheck = false)
{
	return IsMainWeaponItem(ItemState, eInvSlot_PrimaryWeapon, bUseTemplateForSlotCheck);
}

static function bool IsSecondaryPistolItem(XComGameState_Item ItemState, optional bool bUseTemplateForSlotCheck = false)
{
	return IsPistolItem(ItemState, eInvSlot_SecondaryWeapon, bUseTemplateForSlotCheck);
}

static function bool IsSecondaryMeleeItem(XComGameState_Item ItemState, optional bool bUseTemplateForSlotCheck = false)
{
	return IsMeleeItem(ItemState, eInvSlot_SecondaryWeapon, bUseTemplateForSlotCheck);
}

static function bool IsSecondaryMainWeaponItem(XComGameState_Item ItemState, optional bool bUseTemplateForSlotCheck = false)
{
	return IsMainWeaponItem(ItemState, eInvSlot_SecondaryWeapon, bUseTemplateForSlotCheck);
}


static function bool IsPistolItem(
	XComGameState_Item ItemState,
	optional EInventorySlot InventorySlot = eInvSlot_SecondaryWeapon,
	optional bool bUseTemplateForSlotCheck = false
)
{
	local X2WeaponTemplate WeaponTemplate;
	local bool bMatchesSlot;

	if (ItemState == none)
	{
		return false;
	}

	WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());

	if (WeaponTemplate == none)
	{
		return false;
	}

	bMatchesSlot = (bUseTemplateForSlotCheck) ? WeaponTemplate.InventorySlot == InventorySlot : ItemState.InventorySlot == InventorySlot;

	return bMatchesSlot && IsPistolWeaponTemplate(WeaponTemplate);
}

static function bool IsMeleeItem(
	XComGameState_Item ItemState,
	optional EInventorySlot InventorySlot = eInvSlot_SecondaryWeapon,
	optional bool bUseTemplateForSlotCheck = false
)
{
	local X2WeaponTemplate WeaponTemplate;
	local bool bMatchesSlot;

	if (ItemState == none)
	{
		return false;
	}

	WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());

	if (WeaponTemplate == none)
	{
		return false;
	}

	bMatchesSlot = (bUseTemplateForSlotCheck) ? WeaponTemplate.InventorySlot == InventorySlot : ItemState.InventorySlot == InventorySlot;

	return bMatchesSlot && IsMeleeWeaponTemplate(WeaponTemplate);
}

static function bool IsMainWeaponItem(
	XComGameState_Item ItemState,
	optional EInventorySlot InventorySlot = eInvSlot_SecondaryWeapon,
	optional bool bUseTemplateForSlotCheck = false
)
{
	local X2WeaponTemplate WeaponTemplate;
	local bool bMatchesSlot;

	if (ItemState == none)
	{
		return false;
	}

	WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());

	if (WeaponTemplate == none)
	{
		return false;
	}

	bMatchesSlot = (bUseTemplateForSlotCheck) ? WeaponTemplate.InventorySlot == InventorySlot : ItemState.InventorySlot == InventorySlot;

	return bMatchesSlot && IsMainWeaponTemplate(WeaponTemplate);
}

static function bool IsMeleeWeaponTemplate(X2WeaponTemplate WeaponTemplate)
{
	return WeaponTemplate != none &&
		default.MeleeWeaponTemplateBlacklist.Find(WeaponTemplate.DataName) == INDEX_NONE &&
		default.MeleeWeaponCategoryBlacklist.Find(WeaponTemplate.WeaponCat) == INDEX_NONE &&
		WeaponTemplate.iRange == 0;
}

static function bool IsPistolWeaponTemplate(X2WeaponTemplate WeaponTemplate)
{
	return WeaponTemplate != none &&
		default.PistolWeaponTemplateBlacklist.Find(WeaponTemplate.DataName) == INDEX_NONE &&
		default.PistolWeaponCategoryBlacklist.Find(WeaponTemplate.WeaponCat) == INDEX_NONE &&
		default.PistolWeaponCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE &&
		InStr(WeaponTemplate.DataName, "_TMP_") == INDEX_NONE;
}

static function bool IsMainWeaponTemplate(X2WeaponTemplate WeaponTemplate)
{
	return WeaponTemplate != none &&
		default.MainWeaponCategories.Find(WeaponTemplate.DataName) != INDEX_NONE;
}