local OVALE, Ovale = ...
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "ovale_druid_spells"
	local desc = "[6.0.2] Ovale: Druid spells"
	local code = [[
# Druid spells and functions.

# Learned spells.
Define(harmony 77495)
	SpellInfo(harmony learn=1 level=80 specialization=restoration)

Define(astral_showers 33605)
Define(balance_of_power 152220)
Define(barkskin 22812)
	SpellInfo(barkskin cd=60 gcd=0)
	SpellInfo(barkskin buff_cdr=cooldown_reduction_tank_buff specialization=guardian)
Define(bear_form 5487)
	SpellInfo(bear_form rage=-10 to_stance=druid_bear_form)
	SpellInfo(bear_form unusable=1 if_stance=druid_bear_form)
Define(berserk_bear 50334)
	SpellInfo(berserk_bear cd=180 gcd=0)
	SpellInfo(berserk_bear buff_cdr=cooldown_reduction_tank_buff specialization=guardian)
	SpellAddBuff(berserk_bear berserk_bear_buff=1)
Define(berserk_bear_buff 50334)
	SpellInfo(berserk_bear_buff duration=10)
	SpellInfo(berserk_bear_buff addduration=5 if_spell=empowered_berserk)
Define(berserk_cat 106951)
	SpellInfo(berserk_cat cd=180 gcd=0)
	SpellInfo(berserk_cat buff_cdr=cooldown_reduction_agility_buff specialization=feral)
	SpellAddBuff(berserk_cat berserk_cat_buff=1)
Define(berserk_cat_buff 106951)
	SpellInfo(berserk_cat duration=15)
Define(bloodtalons 155672)
Define(bloodtalons_buff 145152)
	SpellInfo(bloodtalons_buff duration=30 max_stacks=2)
Define(bloodtalons_talent 20)
Define(cat_form 768)
	SpellInfo(cat_form replace=claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(cat_form to_stance=druid_cat_form)
	SpellInfo(cat_form unusable=1 if_stance=druid_cat_form)
Define(celestial_alignment 112071)
	SpellInfo(celestial_alignment cd=180)
Define(celestial_alignment_buff 112071)
	SpellInfo(celestial_alignment_buff duration=15)
Define(cenarion_ward 102351)
	SpellInfo(cenarion_ward cd=30)
Define(cenarion_ward_talent 6)
Define(chosen_of_elune_buff 102560)
	SpellInfo(chosen_of_elune_buff duration=30)
Define(claws_of_shirvallah 171745)
	SpellInfo(claws_of_shirvallah to_stance=druid_claws_of_shirvallah)
	SpellInfo(claws_of_shirvallah unusable=1 if_stance=druid_claws_of_shirvallah)
Define(dash 1850)
	SpellInfo(dash cd=180)
	SpellInfo(dash addcd=-60 glyph=glyph_of_dash)
	SpellInfo(dash buff_cdr=cooldown_reduction_agility_buff specialization=feral)
	SpellInfo(dash to_stance=druid_cat_form if_stance=!druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(dash to_stance=druid_claws_of_shirvallah if_stance=!druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
Define(displacer_beast 102280)
	SpellInfo(displacer_beast cd=30)
	SpellInfo(displacer_beast to_stance=druid_cat_form if_stance=!druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(displacer_beast to_stance=druid_claws_of_shirvallah if_stance=!druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellAddBuff(displacer_beast displacer_beast_buff=1)
Define(displacer_beast_buff 137452)
	SpellInfo(displacer_beast_buff duration=4)
Define(dream_of_cenarius_tank 158501)
Define(dream_of_cenarius_tank_buff 145162)
	SpellInfo(dream_of_cenarius_tank_buff duration=20)
Define(empowered_berserk 157284)
Define(enhanced_rejuvenation 157280)
Define(enhanced_tooth_and_claw 157283)
Define(ferocious_bite 22568)
	SpellInfo(ferocious_bite combo=finisher energy=25 extra_energy=25 physical=1 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(ferocious_bite combo=finisher energy=25 extra_energy=25 physical=1 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(ferocious_bite buff_energy_half=berserk_cat_buff)
	SpellRequire(ferocious_bite energy 0=buff,omen_of_clarity_melee_buff if_spell=omen_of_clarity_melee)
	SpellAddBuff(ferocious_bite bloodtalons_buff=-1 if_spell=bloodtalons)
	SpellAddBuff(ferocious_bite omen_of_clarity_melee_buff=0 if_spell=omen_of_clarity_melee)
	SpellAddTargetBuff(ferocious_bite rip_debuff=refresh_keep_snapshot,target_health_pct,25 if_spell=rip)
Define(force_of_nature_caster 33831)
	SpellInfo(force_of_nature_heal gcd=0)
Define(force_of_nature_heal 102693)
	SpellInfo(force_of_nature_heal gcd=0)
Define(force_of_nature_melee 102703)
	SpellInfo(force_of_nature_melee gcd=0)
Define(force_of_nature_talent 12)
Define(force_of_nature_tank 102706)
	SpellInfo(force_of_nature_tank gcd=0)
Define(frenzied_regeneration 22842)
	SpellInfo(frenzied_regeneration cd=1.5 cd_haste=melee gcd=0 max_rage=60 rage=finisher stance=druid_bear_form)
Define(genesis 145518)
Define(glyph_of_blooming 121840)
Define(glyph_of_dash 59219)
Define(glyph_of_regrowth 116218)
Define(glyph_of_savage_roar 127540)
SpellList(glyph_of_savage_roar_buff king_of_the_jungle_buff prowl_buff)
Define(glyph_of_savagery 171752)
Define(glyph_of_skull_bash 116216)
Define(glyph_of_wild_growth 62970)
Define(guardian_of_elune 155578)
Define(harmony_buff 100977)
	SpellInfo(harmony_buff duration=20)
Define(healing_touch 5185)
	SpellAddBuff(healing_touch bloodtalons_buff=2 if_spell=bloodtalons)
	SpellAddBuff(healing_touch dream_of_cenarius_tank_buff=0 if_spell=dream_of_cenarius_tank)
	SpellAddBuff(healing_touch harmony_buff=1 if_spell=harmony)
	SpellAddBuff(healing_touch natures_swiftness_buff=0 if_spell=natures_swiftness)
	SpellAddBuff(healing_touch predatory_swiftness_buff=0 if_spell=predatory_swiftness)
	SpellAddBuff(healing_touch sage_mender_buff=0 itemset=T16_heal itemcount=2)
	SpellAddTargetBuff(healing_touch lifebloom_buff=refresh glyph=!glyph_of_blooming if_spell=lifebloom)
Define(heart_of_the_wild_heal 108294)
	SpellInfo(heart_of_the_wild_heal cd=360 gcd=0)
Define(heart_of_the_wild_tank 108293)
	SpellInfo(heart_of_the_wild_tank cd=360 gcd=0)
	SpellAddBuff(heart_of_the_wild_tank heart_of_the_wild_tank_buff=1)
Define(heart_of_the_wild_tank_buff 108293)
	SpellInfo(heart_of_the_wild_tank_buff duration=45)
Define(heart_of_the_wild_talent 16)
Define(improved_rake 157276)
SpellList(improved_rake_buff king_of_the_jungle_buff prowl_buff shadowmeld_buff)
Define(incarnation_caster 102560)
	SpellInfo(incarnation_caster cd=180)
	SpellAddBuff(incarnation_caster chosen_of_elune_buff=1)
Define(incarnation_heal 33891)
	SpellInfo(incarnation_heal cd=180)
	SpellAddBuff(incarnation_heal tree_of_life_buff=1)
Define(incarnation_melee 102543)
	SpellInfo(incarnation_melee cd=180)
	SpellAddBuff(incarnation_melee king_of_the_jungle_buff=1)
Define(incarnation_tank 102558)
	SpellInfo(incarnation_tank cd=180)
	SpellAddBuff(incarnation_tank son_of_ursoc_buff=1)
Define(incarnation_talent 11)
Define(king_of_the_jungle_buff 102543)
	SpellInfo(king_of_the_jungle_buff duration=30)
Define(lacerate 33745)
	SpellInfo(lacerate rage=-2 stance=druid_bear_form)
	SpellAddBuff(lacerate bloodtalons_buff=-1 if_spell=bloodtalons)
	SpellAddTargetDebuff(lacerate lacerate_debuff=1)
Define(lacerate_debuff 33745)
	SpellInfo(lacerate_debuff duration=15 max_stacks=3 tick=3)
Define(lifebloom 33763)
	SpellAddTargetBuff(lifebloom lifebloom_buff=1)
Define(lifebloom_buff 33763)
	SpellInfo(lifebloom_buff duration=15 haste=spell tick=1)
	SpellInfo(lifebloom_buff addduration=-5 glyph=glyph_of_blooming)
Define(lunar_empowerment_buff 164547)
	SpellInfo(lunar_empowerment_buff duration=30)
Define(lunar_inspiration 155627)
Define(lunar_inspiration_talent 19)
Define(lunar_peak_buff 171743)
	SpellInfo(lunar_peak_buff duration=5)
Define(maim 22570)
	SpellInfo(maim cd=10 combo=finisher energy=35 interrupt=1 physical=1 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(maim cd=10 combo=finisher energy=35 interrupt=1 physical=1 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(maim buff_energy_half=berserk_cat_buff)
	SpellRequire(maim energy 0=buff,omen_of_clarity_melee_buff if_spell=omen_of_clarity_melee)
	SpellAddBuff(maim bloodtalons_buff=-1 if_spell=bloodtalons)
	SpellAddBuff(maim omen_of_clarity_melee_buff=0 if_spell=omen_of_clarity_melee)
Define(mangle 33917)
	SpellInfo(mangle cd=6 cd_haste=melee rage=-10 stance=druid_bear_form)
	SpellInfo(mangle rage=-15 if_spell=soul_of_the_forest_tank)
	SpellRequire(mangle cd 0=buff,berserk_bear_buff if_spell=berserk_bear)
	SpellRequire(mangle cd 0=buff,son_of_ursoc_buff if_spell=incarnation_tank)
	SpellAddBuff(mangle bloodtalons_buff=-1 if_spell=bloodtalons)
Define(mark_of_the_wild 1126)
	SpellInfo(mark_of_the_wild mark_of_the_wild_buff=1)
Define(mark_of_the_wild_buff 1126)
	SpellInfo(mark_of_the_wild_buff duration=60)
Define(maul 6807)
	SpellInfo(maul cd=3 cd_haste=melee gcd=0 rage=20 stance=druid_bear_form)
	SpellInfo(maul buff_rage=tooth_and_claw_buff buff_rage_amount=-10 if_spell=tooth_and_claw itemset=T17 itemcount=2)
	SpellRequire(maul cd 0=buff,son_of_ursoc_buff if_spell=incarnation_tank)
	SpellAddBuff(maul bloodtalons_buff=-1 if_spell=bloodtalons)
	SpellAddBuff(maul tooth_and_claw_buff=-1 if_spell=tooth_and_claw)
Define(mighty_bash 5211)
	SpellInfo(mighty_bash cd=50 interrupt=1)
Define(moonfire 8921)
	SpellRequire(moonfire replace sunfire=eclipse,solar)
	SpellAddBuff(moonfire lunar_peak_buff=0)
	SpellAddTargetDebuff(moonfire moonfire_debuff=1)
	SpellAddTargetDebuff(moonfire sunfire_debuff=1,buff,celestial_alignment_buff if_spell=celestial_alignment)
Define(moonfire_cat 155625)
	SpellInfo(moonfire_cat combo=1 energy=30 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(moonfire_cat combo=1 energy=30 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(moonfire_cat unusable=1 if_stance=!druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(moonfire_cat unusable=1 if_stance=!druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(moonfire_cat unusable=1 specialization=!feral)
	SpellInfo(moonfire_cat unusable=1 talent=!lunar_inspiration_talent)
	SpellAddTargetDebuff(moonfire_cat moonfire_cat_debuff=1)
Define(moonfire_cat_debuff 155625)
	SpellInfo(moonfire_cat_debuff duration=14 tick=2)
Define(moonfire_debuff 164812)
	SpellInfo(moonfire_debuff duration=20 haste=spell tick=2)
	SpellInfo(moonfire_debuff addduration=20 if_spell=astral_showers)
Define(moonkin_form 24858)
	SpellInfo(moonkin_form to_stance=druid_moonkin_form)
	SpellInfo(moonkin_form unusable=1 if_stance=druid_moonkin_form)
Define(natures_swiftness 132158)
	SpellInfo(natures_swiftness cd=60 gcd=0)
	SpellAddBuff(natures_swiftness natures_swiftness_buff=1)
Define(natures_swiftness_buff 132158)
Define(natures_vigil 124974)
	SpellInfo(natures_vigil cd=90 gcd=0)
Define(omen_of_clarity_heal 113043)
Define(omen_of_clarity_heal_buff 16870)
	SpellInfo(omen_of_clarity_heal_buff duration=15)
Define(omen_of_clarity_melee 16864)
Define(omen_of_clarity_melee_buff 135700)
	SpellInfo(omen_of_clarity_melee_buff duration=15)
Define(predatory_swiftness 16974)
Define(predatory_swiftness_buff 69369)
	SpellInfo(predatory_swiftness_buff duration=8)
Define(prowl 5215)
	SpellInfo(prowl cd=10 to_stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(prowl cd=10 to_stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellAddBuff(prowl prowl_buff=1)
Define(prowl_buff 5215)
Define(pulverize 80313)
	SpellAddBuff(pulverize pulverize_buff=1)
	SpellAddTargetDebuff(pulverize lacerate_debuff=0)
Define(pulverize_buff 158792)
	SpellInfo(pulverize_buff duration=12)
Define(pulverize_talent 20)
Define(rake 1822)
	SpellInfo(rake combo=1 energy=35 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(rake combo=1 energy=35 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(rake buff_energy_half=berserk_cat_buff)
	SpellRequire(rake energy 0=buff,omen_of_clarity_melee_buff if_spell=omen_of_clarity_melee)
	SpellAddBuff(rake bloodtalons_buff=-1 if_spell=bloodtalons)
	SpellAddBuff(rake omen_of_clarity_melee_buff=0 if_spell=omen_of_clarity_melee)
	SpellAddBuff(rake savage_roar_glyph_of_savage_roar_buff=1,buff,glyph_of_savage_roar_buff glyph=glyph_of_savage_roar)
	SpellAddTargetDebuff(rake rake_debuff=1)
	SpellDamageBuff(rake bloodtalons_buff=1.3 if_spell=bloodtalons)
	SpellDamageBuff(rake glyph_of_savage_roar_buff=1.4,buff,!savage_roar_buff glyph=glyph_of_savage_roar)
	SpellDamageBuff(rake improved_rake_buff=2 if_spell=improved_rake)
	SpellDamageBuff(rake savage_roar_buff=1.4 if_spell=savage_roar)
	SpellDamageBuff(rake tigers_fury_buff=1.15 if_spell=tigers_fury)
Define(rake_debuff 155722)
	SpellInfo(rake_debuff duration=15 tick=3)
	SpellDamageBuff(rake_debuff bloodtalons_buff=1.3 if_spell=bloodtalons)
	SpellDamageBuff(rake_debuff glyph_of_savage_roar_buff=1.4,buff,!savage_roar_buff glyph=glyph_of_savage_roar)
	SpellDamageBuff(rake_debuff improved_rake_buff=2 if_spell=improved_rake)
	SpellDamageBuff(rake_debuff savage_roar_buff=1.4 if_spell=savage_roar)
	SpellDamageBuff(rake_debuff tigers_fury_buff=1.15 if_spell=tigers_fury)
Define(regrowth 8936)
	SpellAddBuff(regrowth harmony_buff=1 if_spell=harmony)
	SpellAddBuff(regrowth natures_swiftness_buff=0 if_spell=natures_swiftness)
	SpellAddBuff(regrowth omen_of_clarity_heal_buff=0 if_spell=omen_of_clarity_heal)
	SpellAddTargetBuff(regrowth regrowth_buff=1 glyph=!glyph_of_regrowth)
	SpellAddTargetBuff(regrowth lifebloom_buff=refresh glyph=!glyph_of_blooming if_spell=lifebloom)
Define(regrowth_buff 8936)
	SpellInfo(regrowth_buff duration=6 haste=spell tick=2)
Define(rejuvenation 774)
Define(rejuvenation_buff 774)
	SpellInfo(rejuvenation_buff haste=spell duration=12 tick=3)
Define(renewal 108238)
	SpellInfo(renewal cd=120 gcd=0)
Define(rip 1079)
	SpellInfo(rip combo=finisher energy=30 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(rip combo=finisher energy=30 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(rip buff_energy_half=berserk_cat_buff)
	SpellRequire(rip energy 0=buff,omen_of_clarity_melee_buff if_spell=omen_of_clarity_melee)
	SpellAddBuff(rip bloodtalons_buff=-1 if_spell=bloodtalons)
	SpellAddBuff(rip omen_of_clarity_melee_buff=0 if_spell=omen_of_clarity_melee)
	SpellAddTargetDebuff(rip rip_debuff=1)
Define(rip_debuff 1079)
	SpellInfo(rip_debuff duration=24 tick=2)
	SpellDamageBuff(rip_debuff bloodtalons_buff=1.3 if_spell=bloodtalons)
	SpellDamageBuff(rip_debuff savage_roar_buff=1.4 if_spell=savage_roar)
	SpellDamageBuff(rip_debuff tigers_fury_buff=1.15 if_spell=tigers_fury)
Define(sage_mender_buff 144871)
	SpellInfo(sage_mender_buff duration=60 max_stacks=5)
Define(savage_defense 62606)
	SpellInfo(savage_defense gcd=0 rage=60 stance=druid_bear_form)
	SpellAddBuff(savage_defense savage_defense_buff=1)
Define(savage_defense_buff 132402)
	SpellInfo(savage_defense_buff duration=6)
	SpellInfo(savage_defense_buff duration=3 if_spell=guardian_of_elune)
Define(savage_roar 52610)
	SpellInfo(savage_roar combo=finisher energy=25 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(savage_roar combo=finisher energy=25 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(savage_roar duration=12 adddurationcp=6 tick=3)
	SpellInfo(savage_roar buff_energy_half=berserk_cat_buff)
	SpellInfo(savage_roar unusable=1 glyph=glyph_of_savagery)
	SpellRequire(savage_roar energy 0=buff,omen_of_clarity_melee_buff if_spell=omen_of_clarity_melee)
	SpellAddBuff(savage_roar omen_of_clarity_melee_buff=0 if_spell=omen_of_clarity_melee)
	SpellAddBuff(savage_roar savage_roar=1)
SpellList(savage_roar_buff savage_roar savage_roar_glyph_of_savage_roar_buff)
Define(savage_roar_glyph_of_savage_roar_buff 174544)
	SpellInfo(savage_roar_glyph_of_savage_roar_buff duration=42 tick=3)
Define(shred 5221)
	SpellInfo(shred combo=1 energy=40 physical=1 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(shred combo=1 energy=40 physical=1 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(shred buff_energy_half=berserk_cat_buff)
	SpellRequire(shred energy 0=buff,omen_of_clarity_melee_buff if_spell=omen_of_clarity_melee)
	SpellAddBuff(shred bloodtalons_buff=-1 if_spell=bloodtalons)
	SpellAddBuff(shred omen_of_clarity_melee_buff=0 if_spell=omen_of_clarity_melee)
	SpellAddBuff(shred savage_roar_glyph_of_savage_roar_buff=1,buff,glyph_of_savage_roar_buff glyph=glyph_of_savage_roar)
Define(skull_bash 106839)
	SpellInfo(skull_bash cd=15 gcd=0)
	SpellInfo(skull_bash addcd=5 glyph=glyph_of_skull_bash)
Define(solar_beam 78675)
	SpellInfo(solar_beam cd=60 interrupt=1)
Define(solar_empowerment_buff 164545)
	SpellInfo(solar_empowerment_buff duration=30)
Define(solar_peak_buff 171744)
	SpellInfo(solar_peak_buff duration=5)
Define(son_of_ursoc_buff 102558)
	SpellInfo(son_of_ursoc_buff duration=30)
Define(soul_of_the_forest_tank 158477)
Define(starfall 48505)
	SpellAddBuff(starfall starfall_buff=1)
Define(starfall_buff 48505)
	SpellInfo(starfall_buff duration=10)
Define(starfire 2912)
	SpellAddBuff(starfire lunar_empowerment_buff=-1)
	SpellAddTargetBuff(starfire moonfire_debuff=extend,6 if_spell=balance_of_power)
Define(starsurge 78674)
	SpellAddBuff(starsurge lunar_empowerment_buff=2,eclipse,lunar)
	SpellAddBuff(starsurge solar_empowerment_buff=3,eclipse,solar)
Define(stellar_flare 152221)
	SpellAddTargetDebuff(stellar_flare stellar_flare_debuff=1)
Define(stellar_flare_debuff 152221)
	SpellInfo(stellar_flare_debuff duration=20 haste=spell tick=2)
Define(sunfire 93402)
	SpellRequire(sunfire replace moonfire=eclipse,lunar)
	SpellAddBuff(sunfire solar_peak_buff=0)
	SpellAddTargetDebuff(sunfire moonfire_debuff=1,buff,celestial_alignment_buff if_spell=celestial_alignment)
	SpellAddTargetDebuff(sunfire sunfire_debuff=1)
Define(sunfire_debuff 164815)
	SpellInfo(sunfire_debuff duration=24 haste=spell tick=2)
Define(survival_instincts 61336)
	SpellInfo(survival_instincts cd=180 gcd=0)
Define(swiftmend 18562)
	SpellInfo(swiftmend cd=15)
	SpellAddBuff(swiftmend harmony_buff=1 if_spell=harmony)
Define(swipe 106785)
	SpellInfo(swipe combo=1 energy=45 physical=1 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(swipe combo=1 energy=45 physical=1 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(swipe buff_energy_half=berserk_cat_buff)
	SpellRequire(swipe energy 0=buff,omen_of_clarity_melee_buff if_spell=omen_of_clarity_melee)
	SpellAddBuff(swipe bloodtalons_buff=-1 if_spell=bloodtalons)
	SpellAddBuff(swipe omen_of_clarity_melee_buff=0 if_spell=omen_of_clarity_melee)
Define(thrash_bear 77758)
	SpellInfo(thrash_bear rage=-1 stance=druid_bear_form)
	SpellAddBuff(thrash_bear bloodtalons_buff=-1 if_spell=bloodtalons)
	SpellAddTargetDebuff(thrash_bear thrash_bear_debuff=1)
Define(thrash_bear_debuff 77758)
	SpellInfo(thrash_bear duration=16 tick=2)
Define(thrash_cat 106830)
	SpellInfo(thrash_cat energy=50 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(thrash_cat energy=50 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(thrash_cat buff_energy_half=berserk_cat_buff)
	SpellRequire(thrash_cat energy 0=buff,omen_of_clarity_melee_buff if_spell=omen_of_clarity_melee)
	SpellAddBuff(thrash_cat bloodtalons_buff=-1 if_spell=bloodtalons)
	SpellAddBuff(thrash_cat omen_of_clarity_melee_buff=0 if_spell=omen_of_clarity_melee)
	SpellAddTargetDebuff(thrash_cat thrash_cat_debuff=1)
Define(thrash_cat_debuff 106830)
	SpellInfo(thrash_cat_debuff duration=15 tick=3)
Define(tigers_fury 5217)
	SpellInfo(tigers_fury cd=30 energy=-60 gcd=0 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(tigers_fury cd=30 energy=-60 gcd=0 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
	SpellInfo(tigers_fury buff_cdr=cooldown_reduction_agility_buff specialization=feral)
	SpellAddBuff(tigers_fury tigers_fury_buff=1)
Define(tigers_fury_buff 5217)
	SpellInfo(tigers_fury duration=8)
Define(tooth_and_claw 135288)
Define(tooth_and_claw_buff 135286)
	SpellInfo(tooth_and_claw_buff duration=10 max_stacks=2)
	SpellInfo(tooth_and_claw_buff max_stacks=3 if_spell=enhanced_tooth_and_claw)
Define(tree_of_life_buff 117679)
	SpellInfo(tree_of_life_buff duration=30)
Define(typhoon 132469)
	SpellInfo(typhoon cd=30 interrupt=1)
Define(wild_charge 102401)
	SpellInfo(wild_charge cd=15)
	SpellInfo(wild_charge replace=wild_charge_bear if_stance=druid_bear_form)
	SpellInfo(wild_charge replace=wild_charge_cat if_stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(wild_charge replace=wild_charge_cat if_stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
Define(wild_charge_bear 16979)
	SpellInfo(wild_charge_bear cd=15 stance=druid_bear_form)
Define(wild_charge_cat 49376)
	SpellInfo(wild_charge_cat cd=15 stance=druid_cat_form if_spell=!claws_of_shirvallah)
	SpellInfo(wild_charge_cat cd=15 stance=druid_claws_of_shirvallah if_spell=claws_of_shirvallah)
Define(wild_charge_talent 3)
Define(wild_growth 48438)
	SpellInfo(wild_growth cd=8)
	SpellInfo(wild_growth addcd=2 glyph=glyph_of_wild_growth)
Define(wild_growth_buff 48438)
	SpellInfo(wild_growth_buff duration=7 haste=spell tick=1)
Define(wild_mushroom_heal 145205)
Define(wrath 5176)
	SpellAddBuff(wrath solar_empowerment_buff=-1)
	SpellAddTargetBuff(wrath sunfire_debuff=extend,4 if_spell=balance_of_power)
]]

	OvaleScripts:RegisterScript("DRUID", name, desc, code, "include")
end
