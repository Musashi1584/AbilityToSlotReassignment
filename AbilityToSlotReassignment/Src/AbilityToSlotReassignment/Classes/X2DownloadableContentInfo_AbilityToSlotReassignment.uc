class X2DownloadableContentInfo_AbilityToSlotReassignment extends X2DownloadableContentInfo;


static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	class'AbilityToSlotReassignmentLib'.static.FinalizeUnitAbilitiesForInit(UnitState, SetupData, StartState, PlayerState, bMultiplayerDisplay);
}
