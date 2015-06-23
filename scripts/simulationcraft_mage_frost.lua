local OVALE, Ovale = ...
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "simulationcraft_mage_frost_t18m"
	local desc = "[6.2] SimulationCraft: Mage_Frost_T18M"
	local code = [[
# Based on SimulationCraft profile "Mage_Frost_T18M".
#	class=mage
#	spec=frost
#	talents=3003322
#	glyphs=icy_veins/splitting_ice/cone_of_cold

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=frost)
AddCheckBox(opt_potion_intellect ItemName(draenic_intellect_potion) default specialization=frost)
AddCheckBox(opt_time_warp SpellName(time_warp) specialization=frost)

AddFunction FrostUsePotionIntellect
{
	if CheckBoxOn(opt_potion_intellect) and target.Classification(worldboss) Item(draenic_intellect_potion usable=1)
}

AddFunction FrostUseItemActions
{
	Item(HandSlot usable=1)
	Item(Trinket0Slot usable=1)
	Item(Trinket1Slot usable=1)
}

AddFunction FrostInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.IsInterruptible()
	{
		Spell(counterspell)
		if not target.Classification(worldboss)
		{
			Spell(arcane_torrent_mana)
			if target.InRange(quaking_palm) Spell(quaking_palm)
		}
	}
}

### actions.default

AddFunction FrostDefaultMainActions
{
	#call_action_list,name=water_jet,if=prev_off_gcd.water_jet|debuff.water_jet.remains>0
	if PreviousOffGCDSpell(water_elemental_water_jet) or target.DebuffRemaining(water_elemental_water_jet_debuff) > 0 FrostWaterJetMainActions()
	#call_action_list,name=crystal_sequence,if=talent.prismatic_crystal.enabled&(cooldown.prismatic_crystal.remains<=gcd.max|pet.prismatic_crystal.active)
	if Talent(prismatic_crystal_talent) and { SpellCooldown(prismatic_crystal) <= GCD() or TotemPresent(prismatic_crystal) } FrostCrystalSequenceMainActions()
	#call_action_list,name=aoe,if=active_enemies>=4
	if Enemies() >= 4 FrostAoeMainActions()
	#call_action_list,name=single_target
	FrostSingleTargetMainActions()
}

AddFunction FrostDefaultShortCdActions
{
	#water_elemental
	if not pet.Present() Spell(water_elemental)
	#call_action_list,name=movement,if=raid_event.movement.exists
	if False(raid_event_movement_exists) FrostMovementShortCdActions()
	unless { PreviousOffGCDSpell(water_elemental_water_jet) or target.DebuffRemaining(water_elemental_water_jet_debuff) > 0 } and FrostWaterJetShortCdPostConditions()
	{
		#rune_of_power,if=buff.rune_of_power.remains<cast_time
		if TotemRemaining(rune_of_power) < CastTime(rune_of_power) Spell(rune_of_power)
		#rune_of_power,if=(cooldown.icy_veins.remains<gcd.max&buff.rune_of_power.remains<20)|(cooldown.prismatic_crystal.remains<gcd.max&buff.rune_of_power.remains<10)
		if SpellCooldown(icy_veins) < GCD() and TotemRemaining(rune_of_power) < 20 or SpellCooldown(prismatic_crystal) < GCD() and TotemRemaining(rune_of_power) < 10 Spell(rune_of_power)
		#water_jet,if=time<1&active_enemies<4&!(talent.ice_nova.enabled&talent.prismatic_crystal.enabled)
		if TimeInCombat() < 1 and Enemies() < 4 and not { Talent(ice_nova_talent) and Talent(prismatic_crystal_talent) } Spell(water_elemental_water_jet)
		#call_action_list,name=crystal_sequence,if=talent.prismatic_crystal.enabled&(cooldown.prismatic_crystal.remains<=gcd.max|pet.prismatic_crystal.active)
		if Talent(prismatic_crystal_talent) and { SpellCooldown(prismatic_crystal) <= GCD() or TotemPresent(prismatic_crystal) } FrostCrystalSequenceShortCdActions()

		unless Talent(prismatic_crystal_talent) and { SpellCooldown(prismatic_crystal) <= GCD() or TotemPresent(prismatic_crystal) } and FrostCrystalSequenceShortCdPostConditions()
		{
			#call_action_list,name=aoe,if=active_enemies>=4
			if Enemies() >= 4 FrostAoeShortCdActions()

			unless Enemies() >= 4 and FrostAoeShortCdPostConditions()
			{
				#call_action_list,name=single_target
				FrostSingleTargetShortCdActions()
			}
		}
	}
}

AddFunction FrostDefaultCdActions
{
	#counterspell,if=target.debuff.casting.react
	if target.IsInterruptible() FrostInterruptActions()

	unless not pet.Present() and Spell(water_elemental)
	{
		#time_warp,if=target.health.pct<25|time>5
		if { target.HealthPercent() < 25 or TimeInCombat() > 5 } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)

		unless False(raid_event_movement_exists) and FrostMovementCdPostConditions()
		{
			unless { PreviousOffGCDSpell(water_elemental_water_jet) or target.DebuffRemaining(water_elemental_water_jet_debuff) > 0 } and FrostWaterJetCdPostConditions()
			{
				#mirror_image
				Spell(mirror_image)

				unless TotemRemaining(rune_of_power) < CastTime(rune_of_power) and Spell(rune_of_power) or { SpellCooldown(icy_veins) < GCD() and TotemRemaining(rune_of_power) < 20 or SpellCooldown(prismatic_crystal) < GCD() and TotemRemaining(rune_of_power) < 10 } and Spell(rune_of_power)
				{
					#call_action_list,name=cooldowns,if=target.time_to_die<24
					if target.TimeToDie() < 24 FrostCooldownsCdActions()
					#call_action_list,name=crystal_sequence,if=talent.prismatic_crystal.enabled&(cooldown.prismatic_crystal.remains<=gcd.max|pet.prismatic_crystal.active)
					if Talent(prismatic_crystal_talent) and { SpellCooldown(prismatic_crystal) <= GCD() or TotemPresent(prismatic_crystal) } FrostCrystalSequenceCdActions()

					unless Talent(prismatic_crystal_talent) and { SpellCooldown(prismatic_crystal) <= GCD() or TotemPresent(prismatic_crystal) } and FrostCrystalSequenceCdPostConditions()
					{
						#call_action_list,name=aoe,if=active_enemies>=4
						if Enemies() >= 4 FrostAoeCdActions()

						unless Enemies() >= 4 and FrostAoeCdPostConditions()
						{
							#call_action_list,name=single_target
							FrostSingleTargetCdActions()
						}
					}
				}
			}
		}
	}
}

### actions.aoe

AddFunction FrostAoeMainActions
{
	#ice_lance,if=talent.frost_bomb.enabled&buff.fingers_of_frost.react&debuff.frost_bomb.up
	if Talent(frost_bomb_talent) and BuffPresent(fingers_of_frost_buff) and target.DebuffPresent(frost_bomb_debuff) Spell(ice_lance)
	#ice_nova
	Spell(ice_nova)
	#blizzard,interrupt_if=cooldown.frozen_orb.up|(talent.frost_bomb.enabled&buff.fingers_of_frost.react>=2)
	Spell(blizzard)
}

AddFunction FrostAoeShortCdActions
{
	#frost_bomb,if=remains<action.ice_lance.travel_time&(cooldown.frozen_orb.remains<gcd.max|buff.fingers_of_frost.react>=2)
	if target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and { SpellCooldown(frozen_orb) < GCD() or BuffStacks(fingers_of_frost_buff) >= 2 } Spell(frost_bomb)
	#frozen_orb
	Spell(frozen_orb)

	unless Talent(frost_bomb_talent) and BuffPresent(fingers_of_frost_buff) and target.DebuffPresent(frost_bomb_debuff) and Spell(ice_lance)
	{
		#comet_storm
		Spell(comet_storm)
	}
}

AddFunction FrostAoeShortCdPostConditions
{
	Talent(frost_bomb_talent) and BuffPresent(fingers_of_frost_buff) and target.DebuffPresent(frost_bomb_debuff) and Spell(ice_lance) or Spell(ice_nova) or Spell(blizzard)
}

AddFunction FrostAoeCdActions
{
	#call_action_list,name=cooldowns
	FrostCooldownsCdActions()
}

AddFunction FrostAoeCdPostConditions
{
	target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and { SpellCooldown(frozen_orb) < GCD() or BuffStacks(fingers_of_frost_buff) >= 2 } and Spell(frost_bomb) or Spell(frozen_orb) or Talent(frost_bomb_talent) and BuffPresent(fingers_of_frost_buff) and target.DebuffPresent(frost_bomb_debuff) and Spell(ice_lance) or Spell(comet_storm) or Spell(ice_nova) or Spell(blizzard)
}

### actions.cooldowns

AddFunction FrostCooldownsCdActions
{
	#icy_veins
	Spell(icy_veins)
	#blood_fury
	Spell(blood_fury_sp)
	#berserking
	Spell(berserking)
	#arcane_torrent
	Spell(arcane_torrent_mana)
	#potion,name=draenic_intellect,if=buff.bloodlust.up|buff.icy_veins.up
	if BuffPresent(burst_haste_buff any=1) or BuffPresent(icy_veins_buff) FrostUsePotionIntellect()
	#use_item,slot=finger2
	FrostUseItemActions()
}

### actions.crystal_sequence

AddFunction FrostCrystalSequenceMainActions
{
	#frostbolt,if=t18_class_trinket&buff.fingers_of_frost.react>=2+set_bonus.tier18_4pc*2&!in_flight
	if HasTrinket(t18_class_trinket) and BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 and not InFlightToTarget(frostbolt) Spell(frostbolt)
	#ice_lance,if=buff.fingers_of_frost.react>=2+set_bonus.tier18_4pc*2|(buff.fingers_of_frost.react>set_bonus.tier18_4pc*2&active_dot.frozen_orb>=1)
	if BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 or BuffStacks(fingers_of_frost_buff) > ArmorSetBonus(T18 4) * 2 and DebuffCountOnAny(frozen_orb_debuff) >= 1 Spell(ice_lance)
	#ice_nova,if=charges=2|pet.prismatic_crystal.remains<gcd.max
	if Charges(ice_nova) == 2 or TotemRemaining(prismatic_crystal) < GCD() Spell(ice_nova)
	#ice_lance,if=buff.fingers_of_frost.react
	if BuffPresent(fingers_of_frost_buff) Spell(ice_lance)
	#frostfire_bolt,if=buff.brain_freeze.react
	if BuffPresent(brain_freeze_buff) Spell(frostfire_bolt)
	#ice_nova
	Spell(ice_nova)
	#blizzard,interrupt_if=cooldown.frozen_orb.up|(talent.frost_bomb.enabled&buff.fingers_of_frost.react>=2+set_bonus.tier18_4pc),if=active_enemies>=5
	if Enemies() >= 5 Spell(blizzard)
	#choose_target,if=pet.prismatic_crystal.remains<action.frostbolt.cast_time+action.frostbolt.travel_time
	#frostbolt
	Spell(frostbolt)
}

AddFunction FrostCrystalSequenceShortCdActions
{
	#frost_bomb,if=active_enemies=1&current_target!=pet.prismatic_crystal&remains<10
	if Enemies() == 1 and not target.Name(prismatic_crystal) and target.DebuffRemaining(frost_bomb_debuff) < 10 Spell(frost_bomb)
	#prismatic_crystal
	Spell(prismatic_crystal)
	#frozen_orb
	Spell(frozen_orb)
	#frost_bomb,if=talent.prismatic_crystal.enabled&current_target=pet.prismatic_crystal&active_enemies>1&!ticking
	if Talent(prismatic_crystal_talent) and target.Name(prismatic_crystal) and Enemies() > 1 and not target.DebuffPresent(frost_bomb_debuff) Spell(frost_bomb)
}

AddFunction FrostCrystalSequenceShortCdPostConditions
{
	HasTrinket(t18_class_trinket) and BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 and not InFlightToTarget(frostbolt) and Spell(frostbolt) or { BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 or BuffStacks(fingers_of_frost_buff) > ArmorSetBonus(T18 4) * 2 and DebuffCountOnAny(frozen_orb_debuff) >= 1 } and Spell(ice_lance) or { Charges(ice_nova) == 2 or TotemRemaining(prismatic_crystal) < GCD() } and Spell(ice_nova) or BuffPresent(fingers_of_frost_buff) and Spell(ice_lance) or BuffPresent(brain_freeze_buff) and Spell(frostfire_bolt) or Spell(ice_nova) or Enemies() >= 5 and Spell(blizzard) or Spell(frostbolt)
}

AddFunction FrostCrystalSequenceCdActions
{
	unless Enemies() == 1 and not target.Name(prismatic_crystal) and target.DebuffRemaining(frost_bomb_debuff) < 10 and Spell(frost_bomb) or Spell(prismatic_crystal) or Spell(frozen_orb)
	{
		#call_action_list,name=cooldowns
		FrostCooldownsCdActions()
	}
}

AddFunction FrostCrystalSequenceCdPostConditions
{
	Enemies() == 1 and not target.Name(prismatic_crystal) and target.DebuffRemaining(frost_bomb_debuff) < 10 and Spell(frost_bomb) or Spell(prismatic_crystal) or Spell(frozen_orb) or Talent(prismatic_crystal_talent) and target.Name(prismatic_crystal) and Enemies() > 1 and not target.DebuffPresent(frost_bomb_debuff) and Spell(frost_bomb) or HasTrinket(t18_class_trinket) and BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 and not InFlightToTarget(frostbolt) and Spell(frostbolt) or { BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 or BuffStacks(fingers_of_frost_buff) > ArmorSetBonus(T18 4) * 2 and DebuffCountOnAny(frozen_orb_debuff) >= 1 } and Spell(ice_lance) or { Charges(ice_nova) == 2 or TotemRemaining(prismatic_crystal) < GCD() } and Spell(ice_nova) or BuffPresent(fingers_of_frost_buff) and Spell(ice_lance) or BuffPresent(brain_freeze_buff) and Spell(frostfire_bolt) or Spell(ice_nova) or Enemies() >= 5 and Spell(blizzard) or Spell(frostbolt)
}

### actions.init_water_jet

AddFunction FrostInitWaterJetMainActions
{
	#ice_lance,if=buff.fingers_of_frost.react&pet.water_elemental.cooldown.water_jet.up
	if BuffPresent(fingers_of_frost_buff) and not SpellCooldown(water_elemental_water_jet) > 0 Spell(ice_lance)
	#frostbolt
	Spell(frostbolt)
}

AddFunction FrostInitWaterJetShortCdActions
{
	#frost_bomb,if=remains<4*spell_haste*(1+set_bonus.tier18_4pc)+cast_time
	if target.DebuffRemaining(frost_bomb_debuff) < 4 * { 100 / { 100 + SpellHaste() } } * { 1 + ArmorSetBonus(T18 4) } + CastTime(frost_bomb) Spell(frost_bomb)

	unless BuffPresent(fingers_of_frost_buff) and not SpellCooldown(water_elemental_water_jet) > 0 and Spell(ice_lance)
	{
		#water_jet,if=prev_gcd.frostbolt|action.frostbolt.travel_time<spell_haste
		if PreviousGCDSpell(frostbolt) or TravelTime(frostbolt) < 100 / { 100 + SpellHaste() } Spell(water_elemental_water_jet)
	}
}

### actions.movement

AddFunction FrostMovementShortCdActions
{
	#blink,if=movement.distance>10
	if 0 > 10 Spell(blink)
	#blazing_speed,if=movement.remains>0
	if 0 > 0 Spell(blazing_speed)
	#ice_floes,if=buff.ice_floes.down&(raid_event.movement.distance>0|raid_event.movement.in<action.frostbolt.cast_time)
	if BuffExpires(ice_floes_buff) and { 0 > 0 or 600 < CastTime(frostbolt) } Spell(ice_floes)
}

AddFunction FrostMovementCdPostConditions
{
	0 > 10 and Spell(blink) or BuffExpires(ice_floes_buff) and { 0 > 0 or 600 < CastTime(frostbolt) } and Spell(ice_floes)
}

### actions.precombat

AddFunction FrostPrecombatMainActions
{
	#flask,type=greater_draenic_intellect_flask
	#food,type=salty_squid_roll
	#arcane_brilliance
	if BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) Spell(arcane_brilliance)
	#frostbolt,if=!talent.frost_bomb.enabled
	if not Talent(frost_bomb_talent) Spell(frostbolt)
}

AddFunction FrostPrecombatShortCdActions
{
	unless { BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) } and Spell(arcane_brilliance)
	{
		#water_elemental
		if not pet.Present() Spell(water_elemental)
		#snapshot_stats
		#rune_of_power,if=buff.rune_of_power.remains<150
		if TotemRemaining(rune_of_power) < 150 Spell(rune_of_power)

		unless not Talent(frost_bomb_talent) and Spell(frostbolt)
		{
			#frost_bomb
			Spell(frost_bomb)
		}
	}
}

AddFunction FrostPrecombatShortCdPostConditions
{
	{ BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) } and Spell(arcane_brilliance) or not Talent(frost_bomb_talent) and Spell(frostbolt)
}

AddFunction FrostPrecombatCdActions
{
	unless { BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) } and Spell(arcane_brilliance) or not pet.Present() and Spell(water_elemental) or TotemRemaining(rune_of_power) < 150 and Spell(rune_of_power)
	{
		#mirror_image
		Spell(mirror_image)
		#potion,name=draenic_intellect
		FrostUsePotionIntellect()
	}
}

AddFunction FrostPrecombatCdPostConditions
{
	{ BuffExpires(critical_strike_buff any=1) or BuffExpires(spell_power_multiplier_buff any=1) } and Spell(arcane_brilliance) or not pet.Present() and Spell(water_elemental) or TotemRemaining(rune_of_power) < 150 and Spell(rune_of_power) or not Talent(frost_bomb_talent) and Spell(frostbolt) or Spell(frost_bomb)
}

### actions.single_target

AddFunction FrostSingleTargetMainActions
{
	#ice_lance,if=buff.fingers_of_frost.react&(buff.fingers_of_frost.remains<action.frostbolt.execute_time|buff.fingers_of_frost.remains<buff.fingers_of_frost.react*gcd.max)
	if BuffPresent(fingers_of_frost_buff) and { BuffRemaining(fingers_of_frost_buff) < ExecuteTime(frostbolt) or BuffRemaining(fingers_of_frost_buff) < BuffStacks(fingers_of_frost_buff) * GCD() } Spell(ice_lance)
	#frostfire_bolt,if=buff.brain_freeze.react&(buff.brain_freeze.remains<action.frostbolt.execute_time|buff.brain_freeze.remains<buff.brain_freeze.react*gcd.max)
	if BuffPresent(brain_freeze_buff) and { BuffRemaining(brain_freeze_buff) < ExecuteTime(frostbolt) or BuffRemaining(brain_freeze_buff) < BuffStacks(brain_freeze_buff) * GCD() } Spell(frostfire_bolt)
	#ice_nova,if=target.time_to_die<10|(charges=2&(!talent.prismatic_crystal.enabled|!cooldown.prismatic_crystal.up))
	if target.TimeToDie() < 10 or Charges(ice_nova) == 2 and { not Talent(prismatic_crystal_talent) or not { not SpellCooldown(prismatic_crystal) > 0 } } Spell(ice_nova)
	#frostbolt,if=t18_class_trinket&buff.fingers_of_frost.react>=2+set_bonus.tier18_4pc*2&!in_flight
	if HasTrinket(t18_class_trinket) and BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 and not InFlightToTarget(frostbolt) Spell(frostbolt)
	#ice_lance,if=buff.fingers_of_frost.react>=2+set_bonus.tier18_4pc*2|(buff.fingers_of_frost.react>1+set_bonus.tier18_4pc&dot.frozen_orb.ticking)
	if BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 or BuffStacks(fingers_of_frost_buff) > 1 + ArmorSetBonus(T18 4) and SpellCooldown(frozen_orb) > SpellCooldownDuration(frozen_orb) - 10 Spell(ice_lance)
	#ice_nova,if=(!talent.prismatic_crystal.enabled|(charges=1&cooldown.prismatic_crystal.remains>recharge_time&(buff.incanters_flow.stack>3|!talent.ice_nova.enabled)))&(buff.icy_veins.up|(charges=1&cooldown.icy_veins.remains>recharge_time))
	if { not Talent(prismatic_crystal_talent) or Charges(ice_nova) == 1 and SpellCooldown(prismatic_crystal) > SpellChargeCooldown(ice_nova) and { BuffStacks(incanters_flow_buff) > 3 or not Talent(ice_nova_talent) } } and { BuffPresent(icy_veins_buff) or Charges(ice_nova) == 1 and SpellCooldown(icy_veins) > SpellChargeCooldown(ice_nova) } Spell(ice_nova)
	#frostfire_bolt,if=buff.brain_freeze.react
	if BuffPresent(brain_freeze_buff) Spell(frostfire_bolt)
	#frostbolt,if=t18_class_trinket&buff.fingers_of_frost.react&!in_flight
	if HasTrinket(t18_class_trinket) and BuffPresent(fingers_of_frost_buff) and not InFlightToTarget(frostbolt) Spell(frostbolt)
	#ice_lance,if=talent.frost_bomb.enabled&buff.fingers_of_frost.react&debuff.frost_bomb.remains>travel_time&(!talent.thermal_void.enabled|cooldown.icy_veins.remains>8)
	if Talent(frost_bomb_talent) and BuffPresent(fingers_of_frost_buff) and target.DebuffRemaining(frost_bomb_debuff) > TravelTime(ice_lance) and { not Talent(thermal_void_talent) or SpellCooldown(icy_veins) > 8 } Spell(ice_lance)
	#frostbolt,if=set_bonus.tier17_2pc&buff.ice_shard.up&!(talent.thermal_void.enabled&buff.icy_veins.up&buff.icy_veins.remains<10)
	if ArmorSetBonus(T17 2) and BuffPresent(ice_shard_buff) and not { Talent(thermal_void_talent) and BuffPresent(icy_veins_buff) and BuffRemaining(icy_veins_buff) < 10 } Spell(frostbolt)
	#call_action_list,name=init_water_jet,if=pet.water_elemental.cooldown.water_jet.remains<=gcd.max*(buff.fingers_of_frost.react+talent.frost_bomb.enabled)&!dot.frozen_orb.ticking
	if SpellCooldown(water_elemental_water_jet) <= GCD() * { BuffStacks(fingers_of_frost_buff) + TalentPoints(frost_bomb_talent) } and not SpellCooldown(frozen_orb) > SpellCooldownDuration(frozen_orb) - 10 FrostInitWaterJetMainActions()
	#ice_lance,if=!talent.frost_bomb.enabled&buff.fingers_of_frost.react&(!talent.thermal_void.enabled|cooldown.icy_veins.remains>8)
	if not Talent(frost_bomb_talent) and BuffPresent(fingers_of_frost_buff) and { not Talent(thermal_void_talent) or SpellCooldown(icy_veins) > 8 } Spell(ice_lance)
	#frostbolt
	Spell(frostbolt)
	#ice_lance,moving=1
	if Speed() > 0 Spell(ice_lance)
}

AddFunction FrostSingleTargetShortCdActions
{
	unless BuffPresent(fingers_of_frost_buff) and { BuffRemaining(fingers_of_frost_buff) < ExecuteTime(frostbolt) or BuffRemaining(fingers_of_frost_buff) < BuffStacks(fingers_of_frost_buff) * GCD() } and Spell(ice_lance) or BuffPresent(brain_freeze_buff) and { BuffRemaining(brain_freeze_buff) < ExecuteTime(frostbolt) or BuffRemaining(brain_freeze_buff) < BuffStacks(brain_freeze_buff) * GCD() } and Spell(frostfire_bolt)
	{
		#frost_bomb,if=!talent.prismatic_crystal.enabled&cooldown.frozen_orb.remains<gcd.max&debuff.frost_bomb.remains<10
		if not Talent(prismatic_crystal_talent) and SpellCooldown(frozen_orb) < GCD() and target.DebuffRemaining(frost_bomb_debuff) < 10 Spell(frost_bomb)
		#frozen_orb,if=!talent.prismatic_crystal.enabled&buff.fingers_of_frost.stack<2&cooldown.icy_veins.remains>45
		if not Talent(prismatic_crystal_talent) and BuffStacks(fingers_of_frost_buff) < 2 and SpellCooldown(icy_veins) > 45 Spell(frozen_orb)
		#frost_bomb,if=remains<action.ice_lance.travel_time&(buff.fingers_of_frost.react>=2+set_bonus.tier18_4pc*2|(buff.fingers_of_frost.react&(talent.thermal_void.enabled|buff.fingers_of_frost.remains<gcd.max*(buff.fingers_of_frost.react+1))))
		if target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and { BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 or BuffPresent(fingers_of_frost_buff) and { Talent(thermal_void_talent) or BuffRemaining(fingers_of_frost_buff) < GCD() * { BuffStacks(fingers_of_frost_buff) + 1 } } } Spell(frost_bomb)

		unless { target.TimeToDie() < 10 or Charges(ice_nova) == 2 and { not Talent(prismatic_crystal_talent) or not { not SpellCooldown(prismatic_crystal) > 0 } } } and Spell(ice_nova) or HasTrinket(t18_class_trinket) and BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 and not InFlightToTarget(frostbolt) and Spell(frostbolt) or { BuffStacks(fingers_of_frost_buff) >= 2 + ArmorSetBonus(T18 4) * 2 or BuffStacks(fingers_of_frost_buff) > 1 + ArmorSetBonus(T18 4) and SpellCooldown(frozen_orb) > SpellCooldownDuration(frozen_orb) - 10 } and Spell(ice_lance)
		{
			#comet_storm
			Spell(comet_storm)

			unless { not Talent(prismatic_crystal_talent) or Charges(ice_nova) == 1 and SpellCooldown(prismatic_crystal) > SpellChargeCooldown(ice_nova) and { BuffStacks(incanters_flow_buff) > 3 or not Talent(ice_nova_talent) } } and { BuffPresent(icy_veins_buff) or Charges(ice_nova) == 1 and SpellCooldown(icy_veins) > SpellChargeCooldown(ice_nova) } and Spell(ice_nova) or BuffPresent(brain_freeze_buff) and Spell(frostfire_bolt) or HasTrinket(t18_class_trinket) and BuffPresent(fingers_of_frost_buff) and not InFlightToTarget(frostbolt) and Spell(frostbolt) or Talent(frost_bomb_talent) and BuffPresent(fingers_of_frost_buff) and target.DebuffRemaining(frost_bomb_debuff) > TravelTime(ice_lance) and { not Talent(thermal_void_talent) or SpellCooldown(icy_veins) > 8 } and Spell(ice_lance) or ArmorSetBonus(T17 2) and BuffPresent(ice_shard_buff) and not { Talent(thermal_void_talent) and BuffPresent(icy_veins_buff) and BuffRemaining(icy_veins_buff) < 10 } and Spell(frostbolt)
			{
				#call_action_list,name=init_water_jet,if=pet.water_elemental.cooldown.water_jet.remains<=gcd.max*(buff.fingers_of_frost.react+talent.frost_bomb.enabled)&!dot.frozen_orb.ticking
				if SpellCooldown(water_elemental_water_jet) <= GCD() * { BuffStacks(fingers_of_frost_buff) + TalentPoints(frost_bomb_talent) } and not SpellCooldown(frozen_orb) > SpellCooldownDuration(frozen_orb) - 10 FrostInitWaterJetShortCdActions()
			}
		}
	}
}

AddFunction FrostSingleTargetCdActions
{
	#call_action_list,name=cooldowns,if=!talent.prismatic_crystal.enabled|cooldown.prismatic_crystal.remains>15
	if not Talent(prismatic_crystal_talent) or SpellCooldown(prismatic_crystal) > 15 FrostCooldownsCdActions()
}

### actions.water_jet

AddFunction FrostWaterJetMainActions
{
	#frostbolt,if=prev_off_gcd.water_jet
	if PreviousOffGCDSpell(water_elemental_water_jet) Spell(frostbolt)
	#frostfire_bolt,if=buff.brain_freeze.react=2
	if BuffStacks(brain_freeze_buff) == 2 Spell(frostfire_bolt)
	#ice_lance,if=buff.fingers_of_frost.react>=2+2*set_bonus.tier18_4pc&action.frostbolt.in_flight
	if BuffStacks(fingers_of_frost_buff) >= 2 + 2 * ArmorSetBonus(T18 4) and InFlightToTarget(frostbolt) Spell(ice_lance)
	#frostbolt,if=debuff.water_jet.remains>cast_time+travel_time
	if target.DebuffRemaining(water_elemental_water_jet_debuff) > CastTime(frostbolt) + TravelTime(frostbolt) Spell(frostbolt)
}

AddFunction FrostWaterJetShortCdPostConditions
{
	PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or BuffStacks(brain_freeze_buff) == 2 and Spell(frostfire_bolt) or BuffStacks(fingers_of_frost_buff) >= 2 + 2 * ArmorSetBonus(T18 4) and InFlightToTarget(frostbolt) and Spell(ice_lance) or target.DebuffRemaining(water_elemental_water_jet_debuff) > CastTime(frostbolt) + TravelTime(frostbolt) and Spell(frostbolt)
}

AddFunction FrostWaterJetCdPostConditions
{
	PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or BuffStacks(brain_freeze_buff) == 2 and Spell(frostfire_bolt) or BuffStacks(fingers_of_frost_buff) >= 2 + 2 * ArmorSetBonus(T18 4) and InFlightToTarget(frostbolt) and Spell(ice_lance) or target.DebuffRemaining(water_elemental_water_jet_debuff) > CastTime(frostbolt) + TravelTime(frostbolt) and Spell(frostbolt)
}

### Frost icons.

AddCheckBox(opt_mage_frost_aoe L(AOE) default specialization=frost)

AddIcon checkbox=!opt_mage_frost_aoe enemies=1 help=shortcd specialization=frost
{
	if not InCombat() FrostPrecombatShortCdActions()
	unless not InCombat() and FrostPrecombatShortCdPostConditions()
	{
		FrostDefaultShortCdActions()
	}
}

AddIcon checkbox=opt_mage_frost_aoe help=shortcd specialization=frost
{
	if not InCombat() FrostPrecombatShortCdActions()
	unless not InCombat() and FrostPrecombatShortCdPostConditions()
	{
		FrostDefaultShortCdActions()
	}
}

AddIcon enemies=1 help=main specialization=frost
{
	if not InCombat() FrostPrecombatMainActions()
	FrostDefaultMainActions()
}

AddIcon checkbox=opt_mage_frost_aoe help=aoe specialization=frost
{
	if not InCombat() FrostPrecombatMainActions()
	FrostDefaultMainActions()
}

AddIcon checkbox=!opt_mage_frost_aoe enemies=1 help=cd specialization=frost
{
	if not InCombat() FrostPrecombatCdActions()
	unless not InCombat() and FrostPrecombatCdPostConditions()
	{
		FrostDefaultCdActions()
	}
}

AddIcon checkbox=opt_mage_frost_aoe help=cd specialization=frost
{
	if not InCombat() FrostPrecombatCdActions()
	unless not InCombat() and FrostPrecombatCdPostConditions()
	{
		FrostDefaultCdActions()
	}
}

### Required symbols
# arcane_brilliance
# arcane_torrent_mana
# berserking
# blazing_speed
# blink
# blizzard
# blood_fury_sp
# brain_freeze_buff
# comet_storm
# counterspell
# draenic_intellect_potion
# fingers_of_frost_buff
# frost_bomb
# frost_bomb_debuff
# frost_bomb_talent
# frostbolt
# frostfire_bolt
# frozen_orb
# frozen_orb_debuff
# ice_floes
# ice_floes_buff
# ice_lance
# ice_nova
# ice_nova_talent
# ice_shard_buff
# icy_veins
# icy_veins_buff
# incanters_flow_buff
# mirror_image
# prismatic_crystal
# prismatic_crystal_talent
# quaking_palm
# rune_of_power
# t18_class_trinket
# thermal_void_talent
# time_warp
# water_elemental
# water_elemental_water_jet
# water_elemental_water_jet_debuff
]]
	OvaleScripts:RegisterScript("MAGE", "frost", name, desc, code, "script")
end
