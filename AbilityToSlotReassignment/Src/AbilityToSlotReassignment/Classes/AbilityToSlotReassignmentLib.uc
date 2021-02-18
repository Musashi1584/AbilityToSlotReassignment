//-----------------------------------------------------------
//	Class:	AbilityToSlotReassignmentLib
//	Author: Musashi
//	
//-----------------------------------------------------------
class AbilityToSlotReassignmentLib extends Object config (AbilityToSlotReassignment);

struct WeaponCategorySet
{
	var name WeaponCategorySetName;
	var array<name> WeaponCategories;
};

struct AbilityWeaponCategory
{
	var name AbilityName;
	var name WeaponCategorySetName;
};

struct AbilityOverride
{
	var name OverrideAbility;
	var array<name> OverriddenAbilities;
};

var config array<WeaponCategorySet> WeaponCategorySets;
var config array<AbilityWeaponCategory> AbilityWeaponCategories;
var config array<AbilityWeaponCategory> MandatoryAbilities;

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local int Index, ConfigIndex, OverrideAbilityIndex;
	local name WeaponCategory, OverrideAbility;
	local array<XComGameState_Item> FoundItems;
	local XComGameState_Item InventoryItem;
	local StateObjectReference ItemRef;
	local array<StateObjectReference> ItemRefs;
	local AbilityWeaponCategory MandatoryAbility;
	local bool bFoundItems;
	local array<AbilitySetupData> DataToAdd;
	local AbilitySetupData NewAbility, EmptySetup;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;
	local X2DataTemplate DataTemplate;
	local array<XComGameState_Item> CurrentInventory;
	local array<AbilityOverride> AbilityOverrides;
	local AbilityOverride NewAbilityOverride, EmptyAbilityOverride;
	local bool bSkipMandatoryAbility;
	local array<name> WeaponCategories;

	if (!UnitState.IsSoldier())
		return;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	CurrentInventory = UnitState.GetAllInventoryItems(StartState);

	// Collect all overriden abilities
	foreach AbilityTemplateManager.IterateTemplates(DataTemplate)
	{
		AbilityTemplate = X2AbilityTemplate(DataTemplate);
		if (AbilityTemplate != none && AbilityTemplate.OverrideAbilities.Length > 0)
		{
			`LOG(GetFuncName() @ UnitState.SummaryString() @ "Override Ability" @ AbilityTemplate.DataName,, 'AbilityToSlotReassignment');

			if (SetupData.Find('TemplateName', AbilityTemplate.DataName) == INDEX_NONE)
			{
				continue;
			}

			`LOG(GetFuncName() @ UnitState.SummaryString() @
				"   -> Override Ability" @ AbilityTemplate.DataName @
				"found on soldier",,
			'AbilityToSlotReassignment');	

			foreach AbilityTemplate.OverrideAbilities(OverrideAbility)
			{
				`LOG(GetFuncName() @ UnitState.SummaryString() @
					"      ->Adding overriden Ability" @ OverrideAbility @
					"for override" @ AbilityTemplate.DataName
				,, 'AbilityToSlotReassignment');

				OverrideAbilityIndex = AbilityOverrides.Find('OverrideAbility', AbilityTemplate.DataName);
				if (OverrideAbilityIndex == INDEX_NONE)
				{
					NewAbilityOverride = EmptyAbilityOverride;
					NewAbilityOverride.OverrideAbility = AbilityTemplate.DataName;
					NewAbilityOverride.OverriddenAbilities.AddItem(OverrideAbility);
					AbilityOverrides.AddItem(NewAbilityOverride);
				}
				else
				{
					if (AbilityOverrides[OverrideAbilityIndex].OverriddenAbilities.Find(OverrideAbility) == INDEX_NONE)
					{
						AbilityOverrides[OverrideAbilityIndex].OverriddenAbilities.AddItem(OverrideAbility);
					}
				}
			}
		}
	}

	foreach default.MandatoryAbilities(MandatoryAbility)
	{
		bSkipMandatoryAbility = false;

		foreach AbilityOverrides(NewAbilityOverride)
		{
			if (NewAbilityOverride.OverriddenAbilities.Find(MandatoryAbility.AbilityName) != INDEX_NONE)
			{
				`LOG(GetFuncName() @ UnitState.SummaryString() @
					"Skippinng mandatory ability" @ MandatoryAbility.AbilityName @
					"because override ability" @ NewAbilityOverride.OverrideAbility @
					"is present"
				,, 'AbilityToSlotReassignment');
				bSkipMandatoryAbility = true;
				break;
			}
		}

		if (bSkipMandatoryAbility)
		{
			continue;
		}

		bFoundItems = false;

		WeaponCategories = GetWeaponCategoriesFromSet(MandatoryAbility.WeaponCategorySetName);

		foreach WeaponCategories(WeaponCategory)
		{
			FoundItems = GetInventoryItemsForCategory(UnitState, WeaponCategory, StartState);
			if (FoundItems.Length > 0)
			{
				bFoundItems = true;
				break;
			}
		}

		if (bFoundItems)
		{
			if (!UnitState.HasAbilityFromAnySource(MandatoryAbility.AbilityName))
			{
				AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(MandatoryAbility.AbilityName);
				if(AbilityTemplate != none &&
					(!AbilityTemplate.bUniqueSource || SetupData.Find('TemplateName', AbilityTemplate.DataName) == INDEX_NONE) &&
					AbilityTemplate.ConditionsEverValidForUnit(UnitState, false)
				)
				{
					NewAbility.TemplateName = AbilityTemplate.DataName;
					NewAbility.Template = AbilityTemplate;
					SetupData.AddItem(NewAbility);
					`LOG(GetFuncName() @ UnitState.SummaryString() @ "Adding mandatory ability" @ NewAbility.TemplateName,, 'AbilityToSlotReassignment');
				}
			}
		}
	}

	if (IsModInstalled('XCOM2RPGOverhaul'))
	{
		return;
	}

	for(Index = SetupData.Length - 1; Index >= 0; Index--)
	{
		ConfigIndex = default.AbilityWeaponCategories.Find('AbilityName', SetupData[Index].TemplateName);
		
		if (ConfigIndex == INDEX_NONE)
		{
			foreach AbilityOverrides(NewAbilityOverride)
			{
				if (NewAbilityOverride.OverrideAbility == SetupData[Index].TemplateName)
				{
					foreach NewAbilityOverride.OverriddenAbilities(OverrideAbility)
					{
						ConfigIndex = default.AbilityWeaponCategories.Find('AbilityName', OverrideAbility);
						if (ConfigIndex != INDEX_NONE)
						{
							`LOG(GetFuncName() @ UnitState.SummaryString() @
								"No config for" @ SetupData[Index].TemplateName @ "found." @
								"Using config for override ability" @ OverrideAbility @ "instead"
							,, 'AbilityToSlotReassignment');
							break;
						}
					}
				}
				if (ConfigIndex != INDEX_NONE)
				{
					break;
				}
			}
		}

		if (ConfigIndex != INDEX_NONE)
		{
			// Reset ref
			SetupData[Index].SourceWeaponRef.ObjectID = 0;

			WeaponCategories = GetWeaponCategoriesFromSet(default.AbilityWeaponCategories[ConfigIndex].WeaponCategorySetName);

			foreach WeaponCategories(WeaponCategory)
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

			// havent found any items for ability, lets remove it
			if (SetupData[Index].SourceWeaponRef.ObjectID == 0)
			{
				`LOG(GetFuncName() @ UnitState.SummaryString() @
					"Removing" @ SetupData[Index].TemplateName @
					"cause no matching items found"
				,, 'AbilityToSlotReassignment');

				SetupData.Remove(Index, 1);
			}
			else
			{
				InventoryItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SetupData[Index].SourceWeaponRef.ObjectID));

				`LOG(GetFuncName() @ UnitState.SummaryString() @
					"Patching" @ SetupData[Index].TemplateName @
					"to" @ InventoryItem.InventorySlot
					@ InventoryItem.SummaryString()
				,, 'AbilityToSlotReassignment');
			}
		}

		// Do this here again because the launch grenade ability is now on the grenade lanucher itself and not in earned soldier abilities
		//if (SetupData[Index].Template.bUseLaunchedGrenadeEffects)
		//{
		//	NewAbility = EmptySetup;
		//	NewAbility.TemplateName = SetupData[Index].TemplateName;
		//	NewAbility.Template = SetupData[Index].Template;
		//	NewAbility.SourceWeaponRef = SetupData[Index].SourceWeaponRef;
		//
		//	// Remove the original ability
		//	SetupData.Remove(Index, 1);
		//
		//	//  populate a version of the ability for every grenade in the inventory
		//	foreach CurrentInventory(InventoryItem)
		//	{
		//		if (InventoryItem.bMergedOut) 
		//			continue;
		//
		//		if (X2GrenadeTemplate(InventoryItem.GetMyTemplate()) != none)
		//		{ 
		//			NewAbility.SourceAmmoRef = InventoryItem.GetReference();
		//			DataToAdd.AddItem(NewAbility);
		//			`LOG(GetFuncName()  @ UnitState.GetFullName() @ "Patching" @ NewAbility.TemplateName @ "Setting SourceAmmoRef" @ InventoryItem.GetMyTemplateName() @ NewAbility.SourceAmmoRef.ObjectID,, 'AbilityToSlotReassignment');
		//		}
		//	}
		//}
	}


	foreach DataToAdd(NewAbility)
	{
		SetupData.AddItem(NewAbility);
	}
}

public static function array<name> GetWeaponCategoriesFromSet(name WeaponCategorySetName)
{
	local int Index;
	local array<name> EmptyArray;

	Index = default.WeaponCategorySets.Find('WeaponCategorySetName', WeaponCategorySetName);
	if (Index != INDEX_NONE)
	{
		return default.WeaponCategorySets[Index].WeaponCategories;
	}

	EmptyArray.Length = 0;
	return EmptyArray;
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

static function bool IsModInstalled(coerce string DLCIdentifer)
{
	local array<string> Mods;
  
	Mods = class'Helpers'.static.GetInstalledModNames();
	return Mods.Find(DLCIdentifer) != INDEX_NONE;
}