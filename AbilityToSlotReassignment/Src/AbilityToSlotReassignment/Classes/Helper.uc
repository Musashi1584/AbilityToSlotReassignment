//-----------------------------------------------------------
//	Class:	Helper
//	Author: Musashi
//	
//-----------------------------------------------------------


class Helper extends Object;

public static function bool TriggerOverrideShowEquipmentTemplateInUI(
	EInventorySlot Slot,
	X2EquipmentTemplate EquipmentTemplate
)
{
	local XComLWTuple Tuple;

	Tuple = new class'XComLWTuple';
	Tuple.Id = 'OverrideShowEquipmentTemplateInUI';
	Tuple.Data.Add(2);
	Tuple.Data[0].kind = XComLWTVBool;
	Tuple.Data[0].b = false;
	Tuple.Data[1].kind = XComLWTVInt;
	Tuple.Data[1].i = Slot;

	`XEVENTMGR.TriggerEvent('OverrideShowItemInLockerList', Tuple, EquipmentTemplate);

	return Tuple.Data[0].b;
}


