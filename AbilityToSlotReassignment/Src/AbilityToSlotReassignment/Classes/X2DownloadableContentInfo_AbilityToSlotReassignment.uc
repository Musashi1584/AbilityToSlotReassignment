class X2DownloadableContentInfo_AbilityToSlotReassignment extends X2DownloadableContentInfo;


static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	class'AbilityToSlotReassignmentLib'.static.FinalizeUnitAbilitiesForInit(UnitState, SetupData, StartState, PlayerState, bMultiplayerDisplay);
}


static exec function ASR_GiveItem(string ItemTemplateName, EInventorySlot Slot)
{
	local X2ItemTemplateManager ItemTemplateManager;
	local X2EquipmentTemplate ItemTemplate;
	local XComGameState NewGameState;
	local XComGameState_Unit Unit;
	local XGUnit Visualizer;
	local XComGameState_Item Item;
	local XComGameState_Item OldItem;
	local XComGameStateHistory History;
	local XGItem OldItemVisualizer;
	local XComGameState_Player kPlayer;

	local XComGameState_Ability ItemAbility;	
	local int AbilityIndex;
	local array<AbilitySetupData> AbilityData;
	local X2TacticalGameRuleset TacticalRules;
	local XComTacticalController TacticalController;

	History = `XCOMHISTORY;

	TacticalController = XComTacticalController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());
	if (TacticalController == none)
	{
		return;
	}

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = X2EquipmentTemplate(ItemTemplateManager.FindItemTemplate(name(ItemTemplateName)));
	if(ItemTemplate == none) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Give Item '" $ ItemTemplateName $ "'");

	Unit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', TacticalController.GetActiveUnitStateRef().ObjectID));
	Visualizer = XGUnit(Unit.GetVisualizer());

	Item = ItemTemplate.CreateInstanceFromTemplate(NewGameState);

	//Take away the old item
	if (Slot == eInvSlot_PrimaryWeapon ||
		Slot == eInvSlot_SecondaryWeapon ||
		Slot == eInvSlot_HeavyWeapon)
	{
		OldItem = Unit.GetItemInSlot(Slot);
		Unit.RemoveItemFromInventory(OldItem, NewGameState);		

		//Remove abilities that were being granted by the old item
		for( AbilityIndex = Unit.Abilities.Length - 1; AbilityIndex > -1; --AbilityIndex )
		{
			ItemAbility = XComGameState_Ability(History.GetGameStateForObjectID(Unit.Abilities[AbilityIndex].ObjectID));
			if( ItemAbility.SourceWeapon.ObjectID == OldItem.ObjectID )
			{
				Unit.Abilities.Remove(AbilityIndex, 1);
			}
		}
	}

	Unit.bIgnoreItemEquipRestrictions = true; //Instruct the system that we don't care about item restrictions
	Unit.AddItemToInventory(Item, Slot, NewGameState);	

	//Give the unit any abilities that this weapon confers
	kPlayer = XComGameState_Player(History.GetGameStateForObjectID(Unit.ControllingPlayer.ObjectID));			
	AbilityData = Unit.GatherUnitAbilitiesForInit(NewGameState, kPlayer);
	TacticalRules = `TACTICALRULES;
	for (AbilityIndex = 0; AbilityIndex < AbilityData.Length; ++AbilityIndex)
	{
		if( AbilityData[AbilityIndex].SourceWeaponRef.ObjectID == Item.ObjectID )
		{
			TacticalRules.InitAbilityForUnit(AbilityData[AbilityIndex].Template, Unit, NewGameState, AbilityData[AbilityIndex].SourceWeaponRef);
		}
	}

	TacticalRules.SubmitGameState(NewGameState);

	if( OldItem.ObjectID > 0 )
	{
		//Destroy the visuals for the old item if we had one
		OldItemVisualizer = XGItem(History.GetVisualizer(OldItem.ObjectID));
		OldItemVisualizer.Destroy();
		History.SetVisualizer(OldItem.ObjectID, none);
	}
	
	//Create the visualizer for the new item, and attach it if needed
	Visualizer.ApplyLoadoutFromGameState(Unit, NewGameState);
}