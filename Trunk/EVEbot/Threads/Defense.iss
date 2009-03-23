#include ..\core\defines.iss
/*
	Defense Thread

	This thread handles ship _defense_.

	No offensive actions occur in this thread.

	-- CyberTech

*/

objectdef obj_Defense
{
	variable string SVN_REVISION = "$Rev$"
	variable int Version

	variable bool Running = TRUE

	variable time NextPulse
	variable int PulseIntervalInSeconds = 1

	variable bool Hide = FALSE
	variable string HideReason
	variable bool Hiding = FALSE

	method Initialize()
	{
		Event[OnFrame]:AttachAtom[This:Pulse]
		UI:UpdateConsole["Thread: obj_Defense: Initialized", LOG_MINOR]
	}

	method Pulse()
	{
		if !${Script[EVEBot](exists)}
		{
			Script:End
		}

		if ${Time.Timestamp} >= ${This.NextPulse.Timestamp}
		{
			if ${EVEBot.SessionValid} && ${This.Running}
			{
				This:TakeDefensiveAction[]
				This:CheckTankMinimums[]
				This:CheckLocal[]

				if !${EVEBot.Paused}
				{
					This:CheckAmmo[]
				}

				if !${This.Hide} && ${This.Hiding} && ${This.TankReady}
				{
					UI:UpdateConsole["Thread: obj_Defense: No longer hiding"]
					This.Hiding:Set[FALSE]
				}
			}

			This.NextPulse:Set[${Time.Timestamp}]
			This.NextPulse.Second:Inc[${This.PulseIntervalInSeconds}]
			This.NextPulse:Update
		}
	}

	method CheckTankMinimums()
	{
		if !${Script[EVEBot](exists)}
		{
			return
		}

		if	${Ship.IsCloaked} || \
			${Me.InStation}
		{
			return
		}

		if ${Ship.IsPod}
		{
			This:RunAway["We're in a pod! Run Away! Run Away!"]
		}

		if (${_MyShip.ArmorPct} < ${Config.Combat.MinimumArmorPct}  || \
			${_MyShip.ShieldPct} < ${Config.Combat.MinimumShieldPct} || \
			${_MyShip.CapacitorPct} < ${Config.Combat.MinimumCapPct})
		{
			UI:UpdateConsole["Armor is at ${_MyShip.ArmorPct.Int}%: ${MyShip.Armor.Int}/${MyShip.MaxArmor.Int}", LOG_CRITICAL]
			UI:UpdateConsole["Shield is at ${_MyShip.ShieldPct.Int}%: ${MyShip.Shield.Int}/${MyShip.MaxShield.Int}", LOG_CRITICAL]
			UI:UpdateConsole["Cap is at ${_MyShip.CapacitorPct.Int}%: ${MyShip.Capacitor.Int}/${MyShip.MaxCapacitor.Int}", LOG_CRITICAL]

			if !${Config.Combat.RunOnLowTank}
			{
				UI:UpdateConsole["Run On Low Tank Disabled: Fighting", LOG_CRITICAL]
			}
			elseif ${_Me.ToEntity.IsWarpScrambled}
			{
				UI:UpdateConsole["Warp Scrambled: Fighting", LOG_CRITICAL]
			}
			else
			{
				This:RunAway["Defensive Status"]
				return
			}
		}
	}

	; 3rd Parties should call this if they want Defense thread to initiate safespotting
	method RunAway(string Reason="Not Specified")
	{
		if !${Script[EVEBot](exists)}
		{
			return
		}

		This.Hide:Set[TRUE]
		This.HideReason:Set[${Reason}]
		if !${This.Hiding}
		{
			UI:UpdateConsole["Fleeing: ${Reason}", LOG_CRITICAL]
		}
	}

	method ReturnToDuty()
	{
		UI:UpdateConsole["Returning to duty", LOG_CRITICAL]
		This.Hide:Set[FALSE]
	}

	member:bool TankReady()
	{
		if !${Script[EVEBot](exists)}
		{
			return
		}

		if ${Me.InStation}
		{
			return TRUE
		}

		;TODO:  These should be moved to config variables w/ UI controls
		variable int ArmorPctReady = 50
		variable int ShieldPctReady = 80
		variable int CapacitorPctReady = 80

		if  ${_MyShip.ArmorPct} < ${ArmorPctReady} || \
			(${_MyShip.ShieldPct} < ${ShieldPctReady} && ${Config.Combat.MinimumShieldPct} > 0) || \
			${_MyShip.CapacitorPct} < ${CapacitorPctReady}
		{
			return FALSE
		}

		return TRUE
	}

	method CheckLocal()
	{
		if !${Script[EVEBot](exists)}
		{
			return
		}

		if	${Ship.IsCloaked} || \
			${Me.InStation}
		{
			return
		}

		if ${Social.IsSafe} == FALSE
		{
			if ${_Me.ToEntity.IsWarpScrambled}
			{
				; TODO - we need to quit if a red warps in while we're scrambled -- CyberTech
				UI:UpdateConsole["Warp Scrambled: Ignoring System Status"]
			}
			else
			{
				This:RunAway["Hostiles in Local"]
			}
		}
	}

	method CheckAmmo()
	{
		if !${Script[EVEBot](exists)}
		{
			return
		}

		; TODO - move this to offensive thread, and call back to Defense.RunAway() if necessary - CyberTech

		if	${Ship.IsCloaked} || \
			${Me.InStation}
		{
			return
		}

		if ${Ship.IsAmmoAvailable} == FALSE
		{
			if ${Config.Combat.RunOnLowAmmo} == TRUE
			{
				; TODO - what to do about being warp scrambled in this case?
				This:RunAway["No Ammo!"]
			}
		}
	}

	function Flee()
	{
		if !${Script[EVEBot](exists)}
		{
			return
		}

		This.Hiding:Set[TRUE]
		if ${Config.Combat.RunToStation} || ${Safespots.Count} == 0
		{
			call This.FleeToStation
		}
		else
		{
			call This.FleeToSafespot
		}
	}

	function FleeToStation()
	{
		if !${Script[EVEBot](exists)}
		{
			return
		}

		if !${Station.Docked}
		{
			call Station.Dock
		}
	}

	function FleeToSafespot()
	{
		if !${Script[EVEBot](exists)}
		{
			return
		}

		if ${Safespots.IsAtSafespot}
		{
			if ${Ship.HasCloak} && !${Ship.IsCloaked}
			{
				${Ship:Activate_Cloak[]
			}

			;;; Doing this for hours would make you look like a bot.
			;;; TODO Shutdown Eve or dock if we are fleeing without a cloak for more than 5-10 minutes
			;;;if !${Ship.HasCloak} && ${Safespots.Count} > 1
			;;;{
			;;;	; This ship doesn't have a cloak so let's bounce between safe spots
			;;;	if ${Me.ToEntity.Mode} != 3
			;;;	{
			;;;		call Safespots.WarpToNext
			;;;		wait 30
			;;;	}
			;;;}
		}
		else
		{
			; Are we at the safespot and not warping?
			if ${Me.ToEntity.Mode} != 3
			{
				call Safespots.WarpToNext
				wait 30
			}
		}
	}

	method TakeDefensiveAction()
	{
		if !${Script[EVEBot](exists)}
		{
			return
		}

		;TODO: These should be moved to config variables w/ UI controls
		variable int ArmorPctEnable = 100
		variable int ArmorPctDisable = 98
		variable int ShieldPctEnable = 99
		variable int ShieldPctDisable = 95
		variable int CapacitorPctEnable = 20
		variable int CapacitorPctDisable = 80

		if	${Ship.IsCloaked} || \
			${Me.InStation}
		{
			return
		}

		if ${_MyShip.ArmorPct} < ${ArmorPctEnable}
		{
			/* Turn on armor reps, if you have them
				Armor reps do not rep right away -- they rep at the END of the cycle.
				To counter this we start the rep as soon as any damage occurs.
			*/
			Ship:Activate_Armor_Reps[]
		}
		elseif ${_MyShip.ArmorPct} > ${ArmorPctDisable}
		{
			Ship:Deactivate_Armor_Reps[]
		}

		if (${_Me.ToEntity.Mode} == 3)
		{
			; We are in warp, we turn on shield regen so we can use up cap while it has time to regen
			if ${_MyShip.ShieldPct} < 99
			{
				Ship:Activate_Shield_Booster[]
			}
			else
			{
				Ship:Deactivate_Shield_Booster[]
			}
		}
		else
		{
			; We're not in warp, so use normal percentages to enable/disable
			if ${_MyShip.ShieldPct} < ${ShieldPctEnable} || ${Config.Combat.AlwaysShieldBoost}
			{
				Ship:Activate_Shield_Booster[]
			}
			elseif ${_MyShip.ShieldPct} > ${ShieldPctDisable} && !${Config.Combat.AlwaysShieldBoost}
			{
				Ship:Deactivate_Shield_Booster[]
			}
		}

		if ${_MyShip.CapacitorPct} < ${CapacitorPctEnable}
		{
			Ship:Activate_Cap_Booster[]
		}
		elseif ${_MyShip.CapacitorPct} > ${CapacitorPctDisable}
		{
			Ship:Deactivate_Cap_Booster[]
		}

		; Active shield (or armor) hardeners
		; If you don't have hardeners this code does nothing.
		; This uses shield and uncached GetTargetedBy (to reduce chance of a
		; volley making it thru before hardeners are up)
		if ${Me.GetTargetedBy} > 0 || ${_MyShip.ShieldPct} < 99
		{
			Ship:Activate_Hardeners[]
		}
		else
		{
			Ship:Deactivate_Hardeners[]
		}
	}
}

variable(global) obj_Defense Defense

function main()
{
	while ${Script[EVEBot](exists)}
	{
		if ${Defense.Hide}
		{
			call Defense.Flee
			wait 10 !${Script[EVEBot](exists)}
		}
		waitframe
	}
	echo "EVEBot exited, unloading ${Script.Filename}"
}