function UpdateUnits( event_data )
{
//	$.Msg( "updateunits: ", event_data );
	$( "#units" ).text = event_data.units
//	$( "#pigs" ).text = event_data.pigs
}

GameEvents.Subscribe( "update_units_count", UpdateUnits );