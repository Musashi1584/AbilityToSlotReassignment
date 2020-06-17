//-----------------------------------------------------------
//	Class:	AbilityToSlotReassignmentLib
//	Author: Musashi
//	
//-----------------------------------------------------------
class AbilityToSlotReassignmentLib extends Object config (AbilityToSlotReassignment);

struct AbilityWeaponCategory
{
	var name AbilityName;
	var array<name> WeaponCategories;
};

var config array<AbilityWeaponCategory> AbilityWeaponCategories;

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local int Index, ConfigIndex;
	local name WeaponCategory;
	local array<XComGameState_Item> FoundItems;
	local XComGameState_Item InventoryItem;
	local StateObjectReference ItemRef;
	local array<StateObjectReference> ItemRefs;

	if (!UnitState.IsSoldier())
		return;

	for(Index = SetupData.Length - 1; Index >= 0; Index--)
	{
		ConfigIndex = default.AbilityWeaponCategories.Find('AbilityName', SetupData[Index].TemplateName);
		
		if (ConfigIndex != INDEX_NONE)
		{
			// Reset ref
			SetupData[Index].SourceWeaponRef.ObjectID = 0;

			foreach default.AbilityWeaponCategories[ConfigIndex].WeaponCategories(WeaponCategory)
			{
				FoundItems = GetInventoryItemsForCategory(UnitState, WeaponCategory, StartState);

				if (FoundItems.Length > 0)
				{
					ItemRefs.Length = 0;
					// Checking slots in descending priority
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_PrimaryWeapon));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_SecondaryWeapon));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_Armor));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_Pistol));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_PsiAmp));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_HeavyWeapon));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_ExtraSecondary));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_GrenadePocket));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_AmmoPocket));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_Utility));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_CombatDrugs));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_CombatSim));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_Plating));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_Vest));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_SparkLauncher));
					ItemRefs.AddItem(GetItemReferenceForInventorySlot(FoundItems, eInvSlot_SecondaryPayload));
					
					foreach ItemRefs(ItemRef)
					{
						If (ItemRef.ObjectID != 0)
						{
							SetupData[Index].SourceWeaponRef = ItemRef;
							break;
						}
					}

					// We havent found anything above, take the first found item
					if (SetupData[Index].SourceWeaponRef.ObjectID == 0)
					{
						SetupData[Index].SourceWeaponRef = FoundItems[0].GetReference();
						break;
					}
					else
					{
						break;
					}
				}
			}

			if (SetupData[Index].SourceWeaponRef.ObjectID > 0)
			{
				InventoryItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID));

				`LOG(GetFuncName() @ UnitState.SummaryString() @
					"Patching" @ SetupData[Index].TemplateName @
					"to" @ InventoryItem.InventorySlot
					@ InventoryItem.SummaryString()
				,, 'AbilityToSlotReassignment');
			}
		}
	}
}

public static function StateObjectReference GetItemReferenceForInventorySlot(array<XComGameState_Item> Items, EInventorySlot InventorySlot)
{
	local XComGameState_Item Item;
	local StateObjectReference EmptyRef;

	foreach Items(Item)
	{
		if (Item.InventorySlot == InventorySlot)
		{
			return Item.GetReference();
		}
	}

	return EmptyRef;
}

public static function array<XComGameState_Item> GetInventoryItemsForCategory(
	XComGameState_Unit UnitState,
	name WeaponCategory,
	optional XComGameState StartState
	)
{
	local array<XComGameState_Item> CurrentInventory, FoundItems;
	local X2WeaponTemplate WeaponTemplate;
	local X2PairedWeaponTemplate PairedWeaponTemplate;
	local array<name> PairedTemplates;
	local XComGameState_Item InventoryItem;

	CurrentInventory = UnitState.GetAllInventoryItems(StartState);

	foreach CurrentInventory(InventoryItem)
	{
		PairedWeaponTemplate = X2PairedWeaponTemplate(InventoryItem.GetMyTemplate());
		if (PairedWeaponTemplate != none)
		{
			PairedTemplates.AddItem(PairedWeaponTemplate.PairedTemplateName);
		}
	}

	foreach CurrentInventory(InventoryItem)
	{
		PairedWeaponTemplate = X2PairedWeaponTemplate(InventoryItem.GetMyTemplate());
		// Ignore loot mod created paired templates
		if (PairedWeaponTemplate != none && InStr(string(PairedWeaponTemplate.DataName), "Paired") != INDEX_NONE)
		{
			continue;
		}

		// ignore paired targets like WristBladeLeft_CV
		if (PairedTemplates.Find(InventoryItem.GetMyTemplateName()) != INDEX_NONE)
		{
			continue;
		}

		WeaponTemplate = X2WeaponTemplate(InventoryItem.GetMyTemplate());
		if (WeaponTemplate != none && WeaponTemplate.WeaponCat == WeaponCategory)
		{
			`LOG(GetFuncName() @ InventoryItem.GetMyTemplate().DataName @ InventoryItem.GetMyTemplate().Class.Name @ X2WeaponTemplate(InventoryItem.GetMyTemplate()).WeaponCat @ WeaponCategory,, 'AbilityToSlotReassignment');
			FoundItems.AddItem(InventoryItem);
		}
	}
	return FoundItems;
}

