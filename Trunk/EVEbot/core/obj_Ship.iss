/*
	Ship class

	Main object for interacting with the ship and its functions

	-- CyberTech

*/

objectdef obj_Ship
{
	variable int MODE_WARPING = 3

	variable time NextPulse
	variable int PulseIntervalInSeconds = 8

	variable int Calculated_MaxLockedTargets
	variable float BaselineUsedCargo
	variable bool CargoIsOpen
	variable index:module ModuleList
	variable index:module ModuleList_MiningLaser
	variable index:module ModuleList_Weapon
	variable index:module ModuleList_ActiveResists
	variable index:module ModuleList_Regen_Shield
	variable index:module ModuleList_Repair_Armor
	variable index:module ModuleList_Repair_Hull
	variable index:module ModuleList_AB_MWD
	variable index:module ModuleList_Passive
	variable index:module ModuleList_Salvagers
	variable index:module ModuleList_TractorBeams
	variable index:module ModuleList_Cloaks
	variable bool Repairing_Armor = FALSE
	variable bool Repairing_Hull = FALSE
	variable float m_MaxTargetRange
	variable bool  m_WaitForCapRecharge = FALSE
	variable int   m_CargoSanityCounter = 0

	variable iterator ModulesIterator

	variable obj_Drones Drones

	method Initialize()
	{
		This:StopShip[]
		This:UpdateModuleList[]

		Event[OnFrame]:AttachAtom[This:Pulse]
		This:CalculateMaxLockedTargets
		UI:UpdateConsole["obj_Ship: Initialized"]
	}

	method Shutdown()
	{
		Event[OnFrame]:DetachAtom[This:Pulse]
	}

	method Pulse()
	{
		if ${EVEBot.Paused}
		{
			return
		}

	    if ${Time.Timestamp} > ${This.NextPulse.Timestamp}
		{
    		if (${Me.InStation(exists)} && !${Me.InStation})
    		{
    			This:ValidateModuleTargets

				if !${Config.Common.BotModeName.Equal[Ratter]}
				{	/* ratter was converted to use obj_Combat already */

	    			;Ship Armor Repair
	    			if ${This.Total_Armor_Reps} > 0
	    			{
	    				if ${Me.Ship.ArmorPct} < 100
	    				{
	    					This:ActivateRepairing_Armor
	    				}

	    				if ${This.Repairing_Armor}
	    				{
	    					if ${Me.Ship.ArmorPct} == 100
	    					{
	    						This:DeactivateRepairing_Armor
	    						This.Repairing_Armor:Set[FALSE]
	    					}
	    				}
	    			}

	    			;Shield Boosters
	    			/* Why check ${Social.PossibleHostiles}?
	    			 * If your shield is going down something is hostile!
	    			 * The code below pulses your booster around the sweet spot
	    			 */
					if ${Me.Ship.ShieldPct} < 70 || ${Config.Combat.AlwaysShieldBoost}
					{	/* Turn on the shield booster */
						This:Activate_Shield_Booster[]
					}

					if ${Me.Ship.ShieldPct} > 80 && !${Config.Combat.AlwaysShieldBoost}
					{	/* Turn off the shield booster */
						This:Deactivate_Shield_Booster[]
					}
				}
    		}
    		This.NextPulse:Set[${Time.Timestamp}]
    		This.NextPulse.Second:Inc[${This.IntervalInSeconds}]
    		This.NextPulse:Update
		}
	}

	/* The IsSafe function should check the tank, ammo availability, etc.. */
	/* and determine if it is safe to put the ship back into harms way.    */
	/* TODO - Rename to SystemsReady (${Ship.SystemsReady}) or similar for clarity - CyberTech */
	member:bool IsSafe()
	{
		if ${m_WaitForCapRecharge} && ${Me.Ship.CapacitorPct} < 90
		{
			return FALSE
		}
		else
		{
			m_WaitForCapRecharge:Set[FALSE]
		}

		/* TODO - These functions are not reliable. Redo per Looped armor/shield test in obj_Miner.Mine() (then consolidate code) -- CyberTech */
		if ${Me.Ship.CapacitorPct} < 10
		{
			UI:UpdateConsole["Capacitor low!  Run for cover!"]
			m_WaitForCapRecharge:Set[TRUE]
			return FALSE
		}

		if ${Me.Ship.ArmorPct} < 25
		{
			UI:UpdateConsole["Armor low!  Run for cover!"]
			return FALSE
		}

		return TRUE
	}

	member:bool IsAmmoAvailable()
	{
		variable iterator aWeaponIterator
		variable index:item anItemIndex
		variable iterator anItemIterator
		variable bool bAmmoAvailable = TRUE

		This.ModuleList_Weapon:GetIterator[aWeaponIterator]
		if ${aWeaponIterator:First(exists)}
		do
		{
			if ${aWeaponIterator.Value.Charge(exists)}
			{
				;UI:UpdateConsole["DEBUG: obj_Ship.IsAmmoAvailable:"]
				;UI:UpdateConsole["Slot: ${aWeaponIterator.Value.ToItem.Slot}  ${aWeaponIterator.Value.ToItem.Name}"]

				aWeaponIterator.Value:DoGetAvailableAmmo[anItemIndex]
				;UI:UpdateConsole["Ammo: Used = ${anItemIndex.Used}"]

				anItemIndex:GetIterator[anItemIterator]
				if ${anItemIterator:First(exists)}
				{
					do
					{
						;UI:UpdateConsole["Ammo: Type = ${anItemIterator.Value.Type}"]
						if ${anItemIterator.Value.TypeID} == ${aWeaponIterator.Value.Charge.TypeID}
						{
							;UI:UpdateConsole["Ammo: Match!"]
							;UI:UpdateConsole["Ammo: Qty = ${anItemIterator.Value.Quantity}"]
							;UI:UpdateConsole["Ammo: Max = ${aWeaponIterator.Value.MaxCharges}"]
							if ${anItemIterator.Value.Quantity} < ${Math.Calc[${aWeaponIterator.Value.MaxCharges}*6]}
							{
								;UI:UpdateConsole["DEBUG: obj_Ship.IsAmmoAvailable: FALSE!"]
								bAmmoAvailable:Set[FALSE]
							}
						}
					}
					while ${anItemIterator:Next(exists)}
				}
				else
				{
					;UI:UpdateConsole["DEBUG: obj_Ship.IsAmmoAvailable: FALSE!"]
					bAmmoAvailable:Set[FALSE]
				}
			}
		}
		while ${aWeaponIterator:Next(exists)}

		return ${bAmmoAvailable}
	}

	member:bool HasCovOpsCloak()
	{
		variable bool rVal = FALSE

		variable iterator aModuleIterator
		This.ModuleList_Cloaks:GetIterator[aModuleIterator]
		if ${aModuleIterator:First(exists)}
		do
		{
			if ${aModuleIterator.Value.MaxVelocityPenalty} == 0
			{
				rVal:Set[TRUE]
				break
			}
		}
		while ${aModuleIterator:Next(exists)}

		return ${rVal}
	}

	member:float CargoMinimumFreeSpace()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		return ${Math.Calc[${Me.Ship.CargoCapacity}*0.02]}
	}

	member:float CargoFreeSpace()
	{
		if !${Me.Ship(exists)}
		{
			return 0
		}

		if ${Me.Ship.UsedCargoCapacity} < 0
		{
			return ${Me.Ship.CargoCapacity}
		}
		return ${Math.Calc[${Me.Ship.CargoCapacity}-${Me.Ship.UsedCargoCapacity}]}
	}

	member:bool CargoFull()
	{
		if !${Me.Ship(exists)}
		{
			return FALSE
		}

		if ${This.CargoFreeSpace} <= ${This.CargoMinimumFreeSpace}
		{
			return TRUE
		}
		return FALSE
	}

	member:bool CargoHalfFull()
	{
		if !${Me.Ship(exists)}
		{
			return FALSE
		}

		if ${This.CargoFreeSpace} <= ${Math.Calc[${Me.Ship.CargoCapacity}*0.50]}
		{
			return TRUE
		}
		return FALSE
	}

	member:bool IsDamped()
	{
		return ${Me.Ship.MaxTargetRange} < ${This.m_MaxTargetRange}
	}

	member:float MaxTargetRange()
	{
		return ${m_MaxTargetRange}
	}

	method UpdateModuleList()
	{
		if ${Me.InStation}
		{
			; GetModules cannot be used in station as of 07/15/2007
			UI:UpdateConsole["DEBUG: obj_Ship:UpdateModuleList called while in station"]
			return
		}

		/* save ship values that may change in combat */
		This.m_MaxTargetRange:Set[${Me.Ship.MaxTargetRange}]

		/* build module lists */
		This.ModuleList:Clear
		This.ModuleList_MiningLaser:Clear
		This.ModuleList_Weapon:Clear
		This.ModuleList_ActiveResists:Clear
		This.ModuleList_Regen_Shield:Clear
		This.ModuleList_Repair_Armor:Clear
		This.ModuleList_AB_MWD:Clear
		This.ModuleList_Passive:Clear
		This.ModuleList_Repair_Armor:Clear
		This.ModuleList_Repair_Hull:Clear
		This.ModuleList_Salvagers:Clear
		This.ModuleList_TractorBeams:Clear
		This.ModuleList_Cloaks:Clear

		Me.Ship:DoGetModules[This.ModuleList]

		if !${This.ModuleList.Used} && ${Me.Ship.HighSlots} > 0
		{
			UI:UpdateConsole["ERROR: obj_Ship:UpdateModuleList - No modules found. Pausing - If this ship has slots, you must have at least one module equipped, of any type."]
			EVEBot:Pause
			return
		}

		variable iterator Module

		UI:UpdateConsole["Module Inventory:"]
		This.ModuleList:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			variable int GroupID
			GroupID:Set[${Module.Value.ToItem.GroupID}]
			variable int TypeID
			TypeID:Set[${Module.Value.ToItem.TypeID}]

			if !${Module.Value.IsActivatable}
			{
				This.ModuleList_Passive:Insert[${Module.Value}]
				continue
			}

			;echo "DEBUG: Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"
			;echo " DEBUG: Group: ${Module.Value.ToItem.Group}  ${GroupID}"
			;echo " DEBUG: Type: ${Module.Value.ToItem.Type}  ${TypeID}"

			if ${Module.Value.MiningAmount(exists)}
			{
				This.ModuleList_MiningLaser:Insert[${Module.Value}]
				continue
			}

			; TODO - Populate these arrays
			;This.ModuleList_Weapon
			;This.ModuleList_ActiveResists
			;This.ModuleList_AB_MWD
			switch ${GroupID}
			{
				case GROUPID_SHIELD_HARDENER
				case GROUPID_ARMOR_HARDENERS
					This.ModuleList_ActiveResists:Insert[${Module.Value}]
					break
				case GROUPID_MISSILE_LAUNCHER_CRUISE
				case GROUPID_MISSILE_LAUNCHER_ROCKET
				case GROUPID_MISSILE_LAUNCHER_SIEGE
				case GROUPID_MISSILE_LAUNCHER_STANDARD
				case GROUPID_MISSILE_LAUNCHER_HEAVY
					This.ModuleList_Weapon:Insert[${Module.Value}]
					break
				case GROUPID_FREQUENCY_MINING_LASER
					break
				case GROUPID_SHIELD_BOOSTER
					This.ModuleList_Regen_Shield:Insert[${Module.Value}]
					continue
				case GROUPID_AFTERBURNER
					This.ModuleList_AB_MWD:Insert[${Module.Value}]
					continue
				case GROUPID_ARMOR_REPAIRERS
					This.ModuleList_Repair_Armor:Insert[${Module.Value}]
					continue
				case 538
					/* data miners */
					; DEBUG: Group: Data Miners  538
					; DEBUG: Type: Salvager I  25861
					if ${TypeID} == 25861
				   	{	/* Salvager I */
						This.ModuleList_Salvagers:Insert[${Module.Value}]
				   	}
					continue
				case 650
					/* tractor beams */
					; DEBUG: Group: Tractor Beam  650
					; DEBUG: Type: Small Tractor Beam I  24348
					This.ModuleList_TractorBeams:Insert[${Module.Value}]
					continue
				case NONE
					This.ModuleList_Repair_Hull:Insert[${Module.Value}]
				  continue
				case GROUPID_CLOAKING_DEVICE
					This.ModuleList_Cloaks:Insert[${Module.Value}]
					continue
				default
					continue
			}

		}
		while ${Module:Next(exists)}

		UI:UpdateConsole["Weapons:"]
		This.ModuleList_Weapon:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			UI:UpdateConsole["    Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"]
		}
		while ${Module:Next(exists)}

		UI:UpdateConsole["Active Resistance Modules:"]
		This.ModuleList_ActiveResists:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			UI:UpdateConsole["    Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"]
		}
		while ${Module:Next(exists)}

		UI:UpdateConsole["Passive Modules:"]
		This.ModuleList_Passive:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			UI:UpdateConsole["    Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"]
		}
		while ${Module:Next(exists)}

		UI:UpdateConsole["Mining Modules:"]
		This.ModuleList_MiningLaser:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			UI:UpdateConsole["    Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"]
		}
		while ${Module:Next(exists)}

		UI:UpdateConsole["Armor Repair Modules:"]
		This.ModuleList_Repair_Armor:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			UI:UpdateConsole["    Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"]
		}
		while ${Module:Next(exists)}

		UI:UpdateConsole["Shield Regen Modules:"]
		This.ModuleList_Regen_Shield:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			UI:UpdateConsole["    Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"]
		}
		while ${Module:Next(exists)}

		UI:UpdateConsole["AfterBurner Modules:"]
		This.ModuleList_AB_MWD:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			UI:UpdateConsole["    Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"]
		}
		while ${Module:Next(exists)}

		if ${This.ModuleList_AB_MWD.Used} > 1
		{
			UI:UpdateConsole["Warning: More than 1 Afterburner or MWD was detected, I will only use the first one."]
		}

		UI:UpdateConsole["Salvaging Modules:"]
		This.ModuleList_Salvagers:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			UI:UpdateConsole["    Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"]
		}
		while ${Module:Next(exists)}

		UI:UpdateConsole["Tractor Beam Modules:"]
		This.ModuleList_TractorBeams:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			UI:UpdateConsole["    Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"]
		}
		while ${Module:Next(exists)}

		UI:UpdateConsole["Cloaking Device Modules:"]
		This.ModuleList_Cloaks:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			UI:UpdateConsole["    Slot: ${Module.Value.ToItem.Slot}  ${Module.Value.ToItem.Name}"]
		}
		while ${Module:Next(exists)}
	}

	method UpdateBaselineUsedCargo()
	{
		; Store the used cargo space as the cargo hold exists NOW, with whatever is leftover in it.
		This.BaselineUsedCargo:Set[${Me.Ship.UsedCargoCapacity.Ceil}]
	}

	member:int MaxLockedTargets()
	{
		This:CalculateMaxLockedTargets[]
		return ${This.Calculated_MaxLockedTargets}
	}

	; "Safe" max locked targets is defined as max locked targets - 1
	; for a buffer of targets so that hostiles may be targeted.
	; Always return at least 1

	member:int SafeMaxLockedTargets()
	{
		variable int result
		result:Set[${This.Calculated_MaxLockedTargets}]
		if ${result} > 3
		{
			result:Dec
		}
		return ${result}
	}

	member:int TotalMiningLasers()
	{
		return ${This.ModuleList_MiningLaser.Used}
	}

	member:int TotalActivatedMiningLasers()
	{
		if !${Me.Ship(exists)}
		{
			return 0
		}

		variable int count
		variable iterator Module

		This.ModuleList_MiningLaser:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if ${Module.Value.IsActive} || \
				${Module.Value.IsGoingOnline} || \
				${Module.Value.IsDeactivating} || \
				${Module.Value.IsChangingAmmo} || \
				${Module.Value.IsReloadingAmmo}
			{
				count:Inc
			}
		}
		while ${Module:Next(exists)}

		return ${count}
	}

	; Note: This doesn't return ALL the mining amounts, just one.
	; It should perhaps be changed to return the largest, or the smallest, or an average.
	member:float MiningAmountPerLaser()
	{
		if !${Me.Ship(exists)}
		{
			return 0
		}

		variable iterator Module

		This.ModuleList_MiningLaser:GetIterator[Module]
		if ${Module:First(exists)}
		{
			if ${Module.Value.SpecialtyCrystalMiningAmount(exists)}
			{
				return ${Module.Value.SpecialtyCrystalMiningAmount}
			}
			else
			{
				return ${Module.Value.MiningAmount}
			}
		}
		return 0
	}

	; Note: This doesn't return ALL the mining amounts, just one.
	; Returns the laser mining range minus 10%
	member:int OptimalMiningRange()
	{
		if !${Me.Ship(exists)}
		{
			return 0
		}

		variable iterator Module

		This.ModuleList_MiningLaser:GetIterator[Module]
		if ${Module:First(exists)}
		{
			return ${Math.Calc[${Module.Value.OptimalRange}*0.90]}
		}

		return 0
	}

	; Returns the loaded crystal in a mining laser, given the slot name ("HiSlot0"...)
	member:string LoadedMiningLaserCrystal(string SlotName, bool fullName = FALSE)
	{
		if !${Me.Ship(exists)}
		{
			return "NOCHARGE"
		}


		if ${Me.Ship.Module[${SlotName}].Charge(exists)}
		{
			if ${fullName}
                        {
                                return ${Me.Ship.Module[${SlotName}].Charge.Name}
                        }
                        else
                        {
                                return ${Me.Ship.Module[${SlotName}].Charge.Name.Token[1, " "]}

                        }
		}
		return "NOCHARGE"

		variable iterator Module

		This.ModuleList_MiningLaser:GetIteratorModule]
		if ${Module:First(exists)}
		do
		{
			if !${Module.Value.SpecialtyCrystalMiningAmount(exists)}
			{
				continue
			}
			if ${Module.Value.ToItem.Slot.Equal[${SlotName}]} && \
				${Module.Value.Charge(exists)}
			{
				;UI:UpdateConsole["DEBUG: obj_Ship:LoadedMiningLaserCrystal Returning ${Module.Value.Charge.Name.Token[1, " "]}]
				return ${Module.Value.Charge.Name.Token[1, " "]}
			}
		}
		while ${Module:Next(exists)}

		return "NOCHARGE"
	}

	; Returns TRUE if we've got a laser mining this entity already
	member:bool IsMiningAsteroidID(int EntityID)
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_MiningLaser:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if ${Module.Value.LastTarget(exists)} && \
				${Module.Value.LastTarget.ID} == ${EntityID} && \
				( ${Module.Value.IsActive} || ${Module.Value.IsGoingOnline} )
			{
				return TRUE
			}
		}
		while ${Module:Next(exists)}

		return FALSE
	}

	method UnlockAllTargets()
	{
		variable index:entity LockedTargets
		variable iterator Target

		Me:DoGetTargets[LockedTargets]
		LockedTargets:GetIterator[Target]

		if ${Target:First(exists)}
		{
			UI:ConsoleUpdate["Unlocking all targets"]
		}

		do
		{
			Target.Value:UnlockTarget
		}
		while ${Target:Next(exists)}
	}

	method CalculateMaxLockedTargets()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		if ${Me.MaxLockedTargets(exists)} && ${Me.MaxLockedTargets} < ${Me.Ship.MaxLockedTargets}
		{
			Calculated_MaxLockedTargets:Set[${Me.MaxLockedTargets}]
		}
		else
		{
			Calculated_MaxLockedTargets:Set[${Me.Ship.MaxLockedTargets}]
		}
	}

	function ChangeMiningLaserCrystal(string OreType, string SlotName)
	{
		; We might need to change loaded crystal
		variable string LoadedAmmo

		LoadedAmmo:Set[${This.LoadedMiningLaserCrystal[${SlotName}]}]
		if !${OreType.Find[${LoadedAmmo}](exists)}
		{
			UI:UpdateConsole["Current crystal in ${SlotName} is ${LoadedAmmo}, looking for ${OreType}"]
			variable index:item CrystalList
			variable iterator CrystalIterator

			Me.Ship.Module[${SlotName}]:DoGetAvailableAmmo[CrystalList]

			CrystalList:GetIterator[CrystalIterator]
			if ${CrystalIterator:First(exists)}
			do
			{
				variable string CrystalType
				CrystalType:Set[${CrystalIterator.Value.Name.Token[1, " "]}]

				;echo "DEBUG: ChangeMiningLaserCrystal Testing ${OreType} contains ${CrystalType}"
				if ${OreType.Find[${CrystalType}](exists)}
				{
					UI:UpdateConsole["Switching Crystal in ${SlotName} from ${LoadedAmmo} to ${CrystalIterator.Value.Name}"]
					Me.Ship.Module[${SlotName}]:ChangeAmmo[${CrystalIterator.Value.ID},1]
					; This takes 2 seconds ingame, let's give it 50% more
					wait 30
					return
				}
			}
			while ${CrystalIterator:Next(exists)}
			UI:UpdateConsole["Warning: No crystal found for ore type ${OreType}, efficiency reduced"]
		}
	}

	; Validates that all targets of activated modules still exist
	; TODO - Add mid and low targetable modules, and high hostile modules, as well as just mining.
	method ValidateModuleTargets()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_MiningLaser:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if ${Module.Value.IsActive} && \
				!${Module.Value.IsDeactivating} && \
				( !${Module.Value.LastTarget(exists)} || !${Entity[id,${Module.Value.LastTarget.ID}](exists)} )
			{
				UI:UpdateConsole["${Module.Value.ToItem.Slot}:${Module.Value.ToItem.Name} has no target: Deactivating"]
				Module.Value:Click
			}
		}
		while ${Module:Next(exists)}
	}


/*
CycleMiningLaser: HiSlot1 Activate: FALSE
Error: Math sequence not available
Dumping script stack
--------------------
-->C:/Program Files/InnerSpace/Scripts/evebot/core/obj_Ship.iss:516 Atom000000B1() if !${Activate} &&(!${Me.Ship.Module[${Slot}].IsActive} ||${Me.Ship.Module[${Slot}].IsGoingOnline}
||${Me.Ship.Module[${Slot}].IsDeactivating} ||${Me.Ship.Module[${Slot}].IsChangingAmmo} ||${Me.Ship.Module[${Slot}].IsReloadingAmmo}
C:/Program Files/InnerSpace/Scripts/evebot/core/obj_Ship.iss:584 ActivateFreeMiningLaser() wait 10
C:/Program Files/InnerSpace/Scripts/evebot/core/obj_Miner.iss:190 Mine() call Ship.ActivateFreeMiningLaser
C:/Program Files/InnerSpace/Scripts/evebot/core/obj_Miner.iss:59 ProcessState() call Miner.Mine
C:/Program Files/InnerSpace/Scripts/evebot/evebot.iss:90 main() call ${BotType}.ProcessState
	*/

	method CycleMiningLaser(string Activate, string Slot)
	{
		echo CycleMiningLaser: ${Slot} Activate: ${Activate}
		if ${Activate.Equal[ON]} && \
			( ${Me.Ship.Module[${Slot}].IsActive} || \
			  ${Me.Ship.Module[${Slot}].IsGoingOnline} || \
			  ${Me.Ship.Module[${Slot}].IsDeactivating} || \
			  ${Me.Ship.Module[${Slot}].IsChangingAmmo} || \
			  ${Me.Ship.Module[${Slot}].IsReloadingAmmo} \
			)
		{
			echo "obj_Ship:CycleMiningLaser: Tried to Activate the module, but it's already active or changing state."
			return
		}

		if ${Activate.Equal[OFF]} && \
			(!${Me.Ship.Module[${Slot}].IsActive} || \
			  ${Me.Ship.Module[${Slot}].IsGoingOnline} || \
			  ${Me.Ship.Module[${Slot}].IsDeactivating} || \
			  ${Me.Ship.Module[${Slot}].IsChangingAmmo} || \
			  ${Me.Ship.Module[${Slot}].IsReloadingAmmo} \
			)
		{
			echo "obj_Ship:CycleMiningLaser: Tried to Deactivate the module, but it's already active or changing state."
			return
		}

		if ${Activate.Equal[ON]} && \
			(	!${Me.Ship.Module[${Slot}].LastTarget(exists)} || \
				!${Entity[id,${Me.Ship.Module[${Slot}].LastTarget.ID}](exists)} \
			)
		{
			echo "obj_Ship:CycleMiningLaser: Target doesn't exist"
			return
		}

		Me.Ship.Module[${Slot}]:Click
		if ${Activate.Equal[ON]}
		{
			; Delay from 18 to 45 seconds before deactivating
			TimedCommand ${Math.Rand[65]:Inc[30]} Script[EVEBot].ExecuteAtom[Ship:CycleMiningLaser, OFF, ${Slot}]
			echo "next: off"
			return
		}
		else
		{
			; Delay for the time it takes the laser to deactivate and be ready for reactivation
			TimedCommand 20 Script[EVEBot].ExecuteAtom[Ship:CycleMiningLaser, ON, "${Slot}"]
			echo "next: on"
			return
		}
	}

	method DeactivateAllMiningLasers()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_MiningLaser:GetIterator[Module]
		if ${Module:First(exists)}
		{
			if ${Module.Value.IsActive} && \
				!${Module.Value.IsDeactivating}
			{
				UI:UpdateConsole["Deactivating all mining lasers..."]
			}
		}
		do
		{
			if ${Module.Value.IsActive} && \
				!${Module.Value.IsDeactivating}
			{
				Module.Value:Click
			}
		}
		while ${Module:Next(exists)}
	}
	function ActivateFreeMiningLaser()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		if ${Me.ActiveTarget.CategoryID} != ${Asteroids.AsteroidCategoryID}
		{
			UI:UpdateConsole["Error: Mining Lasers may only be used on Asteroids"]
			return
		}

		variable iterator Module

		This.ModuleList_MiningLaser:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if !${Module.Value.IsActive} && \
				!${Module.Value.IsGoingOnline} && \
				!${Module.Value.IsDeactivating} && \
				!${Module.Value.IsChangingAmmo} &&\
				!${Module.Value.IsReloadingAmmo}
			{
				variable string Slot
				Slot:Set[${Module.Value.ToItem.Slot}]
				if ${Module.Value.SpecialtyCrystalMiningAmount(exists)}
				{
					variable string OreType
					OreType:Set[${Me.ActiveTarget.Name.Token[2,"("]}]
					OreType:Set[${OreType.Token[1,")"]}]
					;OreType:Set[${OreType.Replace["(",]}]
					;OreType:Set[${OreType.Replace[")",]}]
					call This.ChangeMiningLaserCrystal "${OreType}" ${Slot}
				}

				UI:UpdateConsole["Activating: ${Module.Value.ToItem.Slot}: ${Module.Value.ToItem.Name}"]
				Module.Value:Click
				wait 25
				;TimedCommand ${Math.Rand[35]:Inc[18]} Script[EVEBot].ExecuteAtom[Ship:CycleMiningLaser, OFF, ${Slot}]
				return
			}
			wait 10
		}
		while ${Module:Next(exists)}
	}

	method StopShip()
	{
		EVE:Execute[CmdStopShip]
	}

	; Approaches EntityID to within 5% of Distance, then stops ship.  Momentum will handle the rest.
	function Approach(int EntityID, int64 Distance)
	{
		if ${Entity[${EntityID}](exists)}
		{
			variable float64 OriginalDistance = ${Entity[${EntityID}].Distance}
			variable float64 CurrentDistance

			If ${OriginalDistance} < ${Distance}
			{
				return
			}
			OriginalDistance:Inc[10]

			CurrentDistance:Set[${Entity[${EntityID}].Distance}]
			UI:UpdateConsole["Approaching: ${Entity[${EntityID}].Name} - ${Math.Calc[(${CurrentDistance} - ${Distance}) / ${Me.Ship.MaxVelocity}].Ceil} Seconds away"]

			This:Activate_AfterBurner[]
			do
			{
				Entity[${EntityID}]:Approach
				wait 50
				CurrentDistance:Set[${Entity[${EntityID}].Distance}]

				if ${Entity[${EntityID}](exists)} && \
					${OriginalDistance} < ${CurrentDistance}
				{
					UI:UpdateConsole["DEBUG: obj_Ship:Approach: ${Entity[${EntityID}].Name} is getting further away!  Is it moving? Are we stuck, or colliding?"]
				}
			}
			while ${CurrentDistance} > ${Math.Calc[${Distance} * 1.05]}
			EVE:Execute[CmdStopShip]
			This:Deactivate_AfterBurner[]
		}
	}

	member IsCargoOpen()
	{
		if ${EVEWindow[MyShipCargo](exists)}
		{
			if ${EVEWindow[MyShipCargo].Caption(exists)}
			{
				return TRUE
			}
			else
			{
				UI:UpdateConsole["\${EVEWindow[MyShipCargo](exists)} == ${EVEWindow[MyShipCargo](exists)}"]
				UI:UpdateConsole["\${EVEWindow[MyShipCargo].Caption(exists)} == ${EVEWindow[MyShipCargo].Caption(exists)}"]
			}
		}
		return FALSE
	}

	function OpenCargo()
	{
		if !${This.IsCargoOpen}
		{
			UI:UpdateConsole["Opening Ship Cargohold"]
			EVE:Execute[OpenCargoHoldOfActiveShip]
			wait WAIT_CARGO_WINDOW

			; Note that this has a race condition. If the window populates fully before we check the CaptionCount
			; OR if the cargo hold is empty, then we will sit forever.  Hence the LoopCheck test
			; -- CyberTech
			variable int CaptionCount
			variable int LoopCheck

			LoopCheck:Set[0]
			CaptionCount:Set[${EVEWindow[MyShipCargo].Caption.Token[2,"["].Token[1,"]"]}]

			while (${CaptionCount} > ${Me.Ship.GetCargo} && \
					${LoopCheck} < 10)
			{
				UI:UpdateConsole["obj_Cargo: Waiting for cargo to load...(${Loopcheck})"]
				while !${This.IsCargoOpen}
				{
					wait 0.5
				}
				wait 10
				LoopCheck:Inc
			}
		}
	}

	function CloseCargo()
	{
		if ${This.IsCargoOpen}
		{
			UI:UpdateConsole["Closing Ship Cargohold"]
			EVEWindow[MyShipCargo]:Close
			wait WAIT_CARGO_WINDOW
			while ${This.IsCargoOpen}
			{
				wait 0.5
			}
			wait 10
		}
	}


	function WarpToID(int Id)
	{
		if (${Id} <= 0)
		{
			UI:UpdateConsole["Error: obj_Ship:WarpToID: Id is <= 0 (${Id})"]
			return
		}

		if !${Entity[${Id}](exists)}
		{
			UI:UpdateConsole["Error: obj_Ship:WarpToID: No entity matched the ID given."]
			return
		}

		call This.WarpPrepare
		while ${Entity[${Id}].Distance} >= WARP_RANGE
		{
			UI:UpdateConsole["Warping to ${Entity[${Id}].Name}"]
			Entity[${Id}]:WarpTo
			call This.WarpWait
		}
	}

	function WarpToBookMarkName(string DestinationBookmarkLabel)
	{
		if (!${EVE.Bookmark[${DestinationBookmarkLabel}](exists)})
		{
			UI:UpdateConsole["ERROR: Bookmark: '${DestinationBookmarkLabel}' does not exist!"]
			return
		}

		call This.WarpToBookMark ${EVE.Bookmark[${DestinationBookmarkLabel}].ID}
	}

	function WarpToBookMark(bookmark DestinationBookmark)
	{
		variable int Counter

		if (${Me.InStation})
		{
			call Station.Undock
		}

		call This.WarpPrepare
		if (${DestinationBookmark.SolarSystemID} != ${Me.SolarSystemID})
		{
			UI:UpdateConsole["Setting autopilot destination: ${DestinationBookmark.Label}]}"]
			DestinationBookmark:SetDestination
			wait 5
			UI:UpdateConsole["Activating autopilot and waiting until arrival..."]
			EVE:Execute[CmdToggleAutopilot]
			do
			{
				wait 50
				if !${Me.AutoPilotOn(exists)}
				{
					do
					{
						wait 5
					}
					while !${Me.AutoPilotOn(exists)}
				}
			}
			while ${Me.AutoPilotOn}
			wait 20
			do
			{
			   wait 10
			}
			while !${Me.ToEntity.IsCloaked}
			wait 5
		}

		if ${DestinationBookmark.ToEntity(exists)} && \
			${DestinationBookmark.ToEntity.CategoryID} == CATEGORYID_STATION
		{
			/* This is a station bookmark, we can use .Distance properly */

			while ${DestinationBookmark.ToEntity.Distance} > WARP_RANGE
			{
				UI:UpdateConsole["Warping to bookmark ${DestinationBookmark.Label}"]
				DestinationBookmark:WarpTo
				call This.WarpWait
				;; TODO - verify we entered warp
			}
		}
		elseif ${DestinationBookmark.TypeID} != 5
		{
			/* This is an entity bookmark, but that entity is not on the overhead yet. */
			/* TODO - ToEntity.Distance doesnt work for anything but stations at the moment, merge with above when it does - CyberTech */

			while !${DestinationBookmark.ToEntity(exists)}
			{
				UI:UpdateConsole["Warping to bookmark ${DestinationBookmark.Label}"]
				DestinationBookmark:WarpTo
				call This.WarpWait
				;; TODO - verify we entered warp
			}
		}
		else
		{
			/* This is an in-space bookmark, just warp to it. */
			/* TODO - write distance(xyz,xyz) function to check distance to  */
			/* the bookmark.  We'll have to figure out eve units to convert it to meters. */
			/* we won't support multi-warp bookmarks of this type till we do so */

			UI:UpdateConsole["Warping to bookmark ${DestinationBookmark.Label}"]
			DestinationBookmark:WarpTo
			call This.WarpWait
		}

		if ${DestinationBookmark.ToEntity(exists)}
		{
			switch ${DestinationBookmark.ToEntity.CategoryID}
			{
				case 2
					; stargate
					break
				case CATEGORYID_STATION
				    variable int StationID
				    StationID:Set[${DestinationBookmark.ToEntity.ID}]
					call This.Approach ${StationID} DOCKING_RANGE
					UI:UpdateConsole["Docking with destination station..."]
					DestinationBookmark.ToEntity:Dock
					Counter:Set[0]
					do
					{
					   wait 20
					   Counter:Inc[1]
					   UI:UpdateConsole["Tick ${Counter}"]
					   if ${Counter} > 5
					   {
					      UI:UpdateConsole["Retrying to dock with destination station"]
					      ;DestinationBookmark.ToEntity:Dock
					      Entity[CategoryID,3]:Dock
					      Counter:Set[0]
					   }
					}
					while !${Station.DockedAtStation[${StationID}]}
					break
			}

			switch ${DestinationBookmark.ToEntity.TypeID}
			{
				case TYPEID_CORPORATE_HANGAR_ARRAY
					call This.Approach ${DestinationBookmark.ToEntity.ID} CORP_HANGAR_LOOT_RANGE
					break
			}
		}
		wait 20
	}

	function WarpPrepare()
	{
		UI:UpdateConsole["Preparing for warp"]
		if ${This.Drones.WaitingForDrones}
		{
			UI:UpdateConsole["Drone deployment already in process, delaying warp"]
			do
			{
				waitframe
			}
			while ${This.Drones.WaitingForDrones}
		}
		if !${This.HasCovOpsCloak}
		{
        	This:Deactivate_Cloak[]
        }
		This:DeactivateAllMiningLasers[]
		This:UnlockAllTargets[]
		call This.Drones.ReturnAllToDroneBay
	}

	member:bool InWarp()
	{
		if ${Me.ToEntity.Mode} == 3
		{
			return TRUE
		}
		return FALSE
	}

	function WarpWait()
	{
		variable bool Warped = FALSE
		; TODO - add check for InWarp== true at least once, to validate we did actually warp.
		wait 150
		if ${Me.ToEntity.Mode} == 3
		{
			UI:UpdateConsole["Warping..."]
		}
		while ${Me.ToEntity.Mode} == 3
		{
			Warped:Set[TRUE]
			wait 20
		}
		UI:UpdateConsole["Dropped out of warp"]
		wait 20
		return ${Warped}
	}

	method Activate_AfterBurner()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_AB_MWD:GetIterator[Module]
		if ${Module:First(exists)}
		{
			if !${Module.Value.IsActive} && ${Module.Value.IsOnline}
			{
				UI:UpdateConsole["Activating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
	}

	member:int Total_Armor_Reps()
	{
		return ${This.ModuleList_Repair_Armor.Used}
	}

	method Activate_Armor_Reps()
	{
		if !${Me.Ship(exists) || }
		{
			return
		}

		variable iterator Module

		This.ModuleList_Repair_Armor:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if !${Module.Value.IsActive} && ${Module.Value.IsOnline}
			{
				UI:UpdateConsole["Activating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
				This.Repairing_Armor:Set[TRUE]
			}
		}
		while ${Module:Next(exists)}
	}

	method Deactivate_Armor_Reps()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_Repair_Armor:GetIterator[Module]
		if ${Module:First(exists)}
		{
			if ${Module.Value.IsActive} && ${Module.Value.IsOnline} && !${Module.Value.IsDeactivating}
			{
				UI:UpdateConsole["Deactivating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
	}

	method Deactivate_AfterBurner()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_AB_MWD:GetIterator[Module]
		if ${Module:First(exists)}
		{
			if ${Module.Value.IsActive} && ${Module.Value.IsOnline} && !${Module.Value.IsDeactivating}
			{
				UI:UpdateConsole["Deactivating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
	}

	method Activate_Shield_Booster()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_Regen_Shield:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if !${Module.Value.IsActive} && ${Module.Value.IsOnline}
			{
				UI:UpdateConsole["Activating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
		while ${Module:Next(exists)}
	}

	method Deactivate_Shield_Booster()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_Regen_Shield:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if ${Module.Value.IsActive} && ${Module.Value.IsOnline} && !${Module.Value.IsDeactivating}
			{
				UI:UpdateConsole["Deactivating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
		while ${Module:Next(exists)}
	}

	method Activate_Hardeners()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_ActiveResists:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if !${Module.Value.IsActive} && ${Module.Value.IsOnline}
			{
				UI:UpdateConsole["Activating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
		while ${Module:Next(exists)}
	}

	method Deactivate_Hardeners()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_ActiveResists:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if ${Module.Value.IsActive} && ${Module.Value.IsOnline} && !${Module.Value.IsDeactivating}
			{
				UI:UpdateConsole["Deactivating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
		while ${Module:Next(exists)}
	}

	method Activate_Cloak()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_Cloaks:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if !${Module.Value.IsActive} && ${Module.Value.IsOnline}
			{
				UI:UpdateConsole["Activating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
		while ${Module:Next(exists)}
	}

	method Deactivate_Cloak()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_Cloaks:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if ${Module.Value.IsActive} && ${Module.Value.IsOnline} && !${Module.Value.IsDeactivating}
			{
				UI:UpdateConsole["Deactivating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
		while ${Module:Next(exists)}
	}

	function LockTarget(int64 TargetID)
	{
		if ${Entity[${TargetID}](exists)}
		{
			UI:UpdateConsole["Locking ${Entity[${TargetID}].Name}: ${EVEBot.MetersToKM_Str[${Entity[${TargetID}].Distance}]}"]
			Entity[${TargetID}]:LockTarget
			wait 30
		}
	}

	function StackAll()
	{
		if ${This.IsCargoOpen}
		{
			Me.Ship:StackAllCargo
		}
	}

	; Returns the salvager range minus 10%
	member:int OptimalSalvageRange()
	{
		if !${Me.Ship(exists)}
		{
			return 0
		}

		variable iterator Module

		This.ModuleList_Salvagers:GetIterator[Module]
		if ${Module:First(exists)}
		{
			return ${Math.Calc[${Module.Value.OptimalRange}*0.90]}
		}

		return 0
	}

	; Returns the tractor range minus 10%
	member:int OptimalTractorRange()
	{
		if !${Me.Ship(exists)}
		{
			return 0
		}

		variable iterator Module

		This.ModuleList_TractorBeams:GetIterator[Module]
		if ${Module:First(exists)}
		{
			return ${Math.Calc[${Module.Value.OptimalRange}*0.90]}
		}

		return 0
	}
	function SetActiveCrystals()
    {
        variable iterator ModuleIterator

        This.ModuleList_MiningLaser:GetIterator[ModuleIterator]

        Cargo.ActiveMiningCrystals:Clear

        ;echo Found ${This.ModuleList_MiningLaser.Used} lasers

        if ${ModuleIterator:First(exists)}
        do
        {
            variable string crystal
            if ${ModuleIterator.Value.SpecialtyCrystalMiningAmount(exists)}
            {
                crystal:Set[${This.LoadedMiningLaserCrystal[${ModuleIterator.Value.ToItem.Slot},TRUE]}]
                ;echo ${crystal} found
                if !${crystal.Equal["NOCHARGE"]}
                {
                    Cargo.ActiveMiningCrystals:Insert[${crystal}]
                }
            }
        }
        while ${ModuleIterator:Next(exists)}
    }

	method Activate_Weapons()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_Weapon:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if !${Module.Value.IsActive} && !${Module.Value.IsChangingAmmo} && !${Module.Value.IsReloadingAmmo} && ${Module.Value.IsOnline}
			{
				;;UI:UpdateConsole["Activating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
		while ${Module:Next(exists)}
	}

	method Deactivate_Weapons()
	{
		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_Weapon:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if (${Module.Value.IsActive} || ${Module.Value.IsWaitingForActiveTarget}) && ${Module.Value.IsOnline} && !${Module.Value.IsDeactivating}
			{
				;;UI:UpdateConsole["Deactivating ${Module.Value.ToItem.Name}"]
				Module.Value:Click
			}
		}
		while ${Module:Next(exists)}
	}

	method Reload_Weapons(bool force)
	{
		variable bool NeedReload = FALSE


		if !${Me.Ship(exists)}
		{
			return
		}

		variable iterator Module

		This.ModuleList_Weapon:GetIterator[Module]
		if ${Module:First(exists)}
		do
		{
			if !${Module.Value.IsActive} && !${Module.Value.IsChangingAmmo} && !${Module.Value.IsReloadingAmmo}
			{
				; Sometimes this value can be NULL
				if !${Module.Value.MaxCharges(exists)}
				{
					UI:UpdateConsole["Sanity check failed... weapon has no MaxCharges!"]
					return
				}

				; Has ammo been used?
				if ${Module.Value.CurrentCharges} != ${Module.Value.MaxCharges}
				{
					; Force reload ?
					if ${force}
					{
						; Yes, reload
						NeedReload:Set[TRUE]
					}
					else
					{
						; Is there still more then 30% ammo available?
						if ${Math.Calc[${Module.Value.CurrentCharges}/${Module.Value.MaxCharges}]} < 0.3
						{
							; No, reload
							NeedReload:Set[TRUE]
						}
					}
				}
			}
		}
		while ${Module:Next(exists)}

		if ${NeedReload}
		{
			UI:UpdateConsole["Reloading weapons..."'
			EVE:Execute[CmdReloadAmmo]
		}
	}
}
