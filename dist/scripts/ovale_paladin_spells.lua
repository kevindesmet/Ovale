local __exports = LibStub:NewLibrary("ovale/scripts/ovale_paladin_spells", 80300)
if not __exports then return end
__exports.registerPaladinSpells = function(OvaleScripts)
    local name = "ovale_paladin_spells"
    local desc = "[9.0] Ovale: Paladin spells"
    local code = [[Define(anima_of_death_0 294926)
# Draw upon your vitality to sear your foes, dealing s2 of your maximum health in Fire damage to all nearby enemies and heal for 294946s1 of your maximum health per enemy hit, up to ?a294945[294945s1*2][294945s1] of your maximum health.
  SpellInfo(anima_of_death_0 cd=150)
Define(anima_of_death_1 294946)
# Heal for s1 of your maximum health.
  SpellInfo(anima_of_death_1 gcd=0 offgcd=1)
Define(anima_of_death_2 300002)
# Draw upon your vitality to sear your foes, dealing s2 of your maximum health in Fire damage to all nearby enemies and heal for 294946s1 of your maximum health per enemy hit, up to 294945s1 of your maximum health.
  SpellInfo(anima_of_death_2 cd=120 gcd=1)
Define(anima_of_death_3 300003)
# Draw upon your vitality to sear your foes, dealing s2 of your maximum health in Fire damage to all nearby enemies and heal for 294946s1+294945s2 of your maximum health per enemy hit, up to 294945s1*2 of your maximum health.
  SpellInfo(anima_of_death_3 cd=120 gcd=1)
Define(avengers_shield 31935)
# Hurls your shield at an enemy target, dealing s1 Holy damage?a231665[, interrupting and silencing the non-Player target for 3 seconds][], and then jumping to x1-1 additional nearby enemies.rnrnIncreases the effects of your next Shield of the Righteous by 197561s2.
# Rank 2: Avenger's Shield interrupts and silences the main target for 3 seconds if it is not a player.
  SpellInfo(avengers_shield cd=15 duration=3 interrupt=1)

  # Silenced.
  SpellAddTargetDebuff(avengers_shield avengers_shield=1)
Define(avenging_wrath 31884)
# Call upon the Light to become an avatar of retribution, increasing your damage, healing, and critical strike chance by s1 for 20 seconds. Your first ?c1[Holy Shock]?c3[Templar's Verdict or Divine Storm][Light of the Protector] will critically strike.
  SpellInfo(avenging_wrath cd=120 duration=20)
  # Damage, healing, and critical strike chance increased by w1.
  SpellAddBuff(avenging_wrath avenging_wrath=1)
Define(bastion_of_light 204035)
# Immediately grants s1 charges of Shield of the Righteous.
  SpellInfo(bastion_of_light cd=120 gcd=0 offgcd=1 talent=bastion_of_light_talent)
Define(blade_of_justice 184575)
# Pierces an enemy with a blade of light, dealing s2*<mult> Physical damage.rnrn|cFFFFFFFFGenerates s3 Holy Power.|r
  SpellInfo(blade_of_justice cd=10.5 holypower=-2)
Define(blessed_hammer 204019)
# Throws a Blessed Hammer that spirals outward, dealing 204301s1 Holy damage to enemies and weakening them, reducing the damage you take from their next auto attack by 204301s2.
  SpellInfo(blessed_hammer cd=4.5 duration=5 talent=blessed_hammer_talent)
Define(blinding_light 115750)
# Emits dazzling light in all directions, blinding enemies within 105421A1 yards, causing them to wander disoriented for 105421d. Non-Holy damage will break the disorient effect.
  SpellInfo(blinding_light cd=90 duration=6 talent=blinding_light_talent)
  SpellAddBuff(blinding_light blinding_light=1)
Define(blood_of_the_enemy_0 297108)
# The Heart of Azeroth erupts violently, dealing s1 Shadow damage to enemies within A1 yds. You gain m2 critical strike chance against the targets for 10 seconds?a297122[, and increases your critical hit damage by 297126m for 5 seconds][].
  SpellInfo(blood_of_the_enemy_0 cd=120 duration=10 channel=10)
  # You have a w2 increased chance to be Critically Hit by the caster.
  SpellAddTargetDebuff(blood_of_the_enemy_0 blood_of_the_enemy_0=1)
Define(blood_of_the_enemy_1 297969)
# Infuse your Heart of Azeroth with Blood of the Enemy.
  SpellInfo(blood_of_the_enemy_1)
Define(blood_of_the_enemy_2 297970)
# Infuse your Heart of Azeroth with Blood of the Enemy.
  SpellInfo(blood_of_the_enemy_2)
Define(blood_of_the_enemy_3 297971)
# Infuse your Heart of Azeroth with Blood of the Enemy.
  SpellInfo(blood_of_the_enemy_3)
Define(blood_of_the_enemy_4 298273)
# The Heart of Azeroth erupts violently, dealing 297108s1 Shadow damage to enemies within 297108A1 yds. You gain 297108m2 critical strike chance against the targets for 10 seconds.
  SpellInfo(blood_of_the_enemy_4 cd=90 duration=15 gcd=0 offgcd=1)
  SpellAddBuff(blood_of_the_enemy_4 blood_of_the_enemy_4=1)
Define(blood_of_the_enemy_5 298277)
# The Heart of Azeroth erupts violently, dealing 297108s1 Shadow damage to enemies within 297108A1 yds. You gain 297108m2 critical strike chance against the targets for 10 seconds, and increases your critical hit damage by 297126m for 5 seconds.
  SpellInfo(blood_of_the_enemy_5 cd=90 duration=15 gcd=0 offgcd=1)
  SpellAddBuff(blood_of_the_enemy_5 blood_of_the_enemy_5=1)
Define(blood_of_the_enemy_6 299039)
# Infuse your Heart of Azeroth with Blood of the Enemy.
  SpellInfo(blood_of_the_enemy_6)
Define(bloodlust 2825)
# Increases Haste by (25 of Spell Power) for all party and raid members for 40 seconds.rnrnAllies receiving this effect will become Sated and unable to benefit from Bloodlust or Time Warp again for 600 seconds.
  SpellInfo(bloodlust cd=300 duration=40 channel=40 gcd=0 offgcd=1)
  # Haste increased by s1.
  SpellAddBuff(bloodlust bloodlust=1)
Define(consecration 26573)
# Consecrates the land beneath you, causing 81297s1*9 Holy damage over 12 seconds to enemies who enter the area. Limit s2.
  SpellInfo(consecration cd=4.5 duration=12 tick=1)
  # Damage every t1 sec.
  SpellAddBuff(consecration consecration=1)
Define(crusade 231895)
# Call upon the Light and begin a crusade, increasing your damage done and Haste by <damage> for 25 seconds.rnrnEach Holy Power spent during Crusade increases damage done and Haste by an additional <damage>.rnrnMaximum u stacks.
  SpellInfo(crusade cd=20 charge_cd=120 duration=25 max_stacks=10 talent=crusade_talent)
  # ?a206338[Damage done increased by w1.rnHaste increased by w3.][Damage done and Haste increased by <damage>.]
  SpellAddBuff(crusade crusade=1)
Define(crusader_strike 35395)
# Strike the target for s1 Physical damage.?s137027[rnrn|cFFFFFFFFGenerates s2 Holy Power.][]
# Rank 2: Crusader Strike now has s1+1 charges.
  SpellInfo(crusader_strike cd=6 holypower=0)
Define(divine_purpose_retribution 223817)
# Your abilities that consume Holy Power have a s1 chance to make your next ability that consumes Holy Power free and deal 223819s2 increased damage and healing.
  SpellInfo(divine_purpose_retribution channel=0 gcd=0 offgcd=1 talent=divine_purpose_talent_retribution)
  SpellAddBuff(divine_purpose_retribution divine_purpose_retribution=1)
Define(divine_storm 53385)
# Unleashes a whirl of divine energy, dealing 224239sw1 Holy damage to all nearby enemies.
  SpellInfo(divine_storm holypower=3)
Define(empyrean_power_buff 286392)
# Your attacks have a chance to make your next Divine Storm free and deal s1 additional damage.
  SpellInfo(empyrean_power_buff channel=-0.001 gcd=0 offgcd=1)

Define(execution_sentence 267798)
# Calls down the Light's punishment upon an enemy target, dealing s1 Holy damage and increasing the target's Holy damage taken from your attacks by 267799s1 for 12 seconds.
  SpellInfo(execution_sentence holypower=3 cd=30 talent=execution_sentence_talent)

Define(fireblood_0 265221)
# Removes all poison, disease, curse, magic, and bleed effects and increases your ?a162700[Agility]?a162702[Strength]?a162697[Agility]?a162698[Strength]?a162699[Intellect]?a162701[Intellect][primary stat] by 265226s1*3 and an additional 265226s1 for each effect removed. Lasts 8 seconds. ?s195710[This effect shares a 30 sec cooldown with other similar effects.][]
  SpellInfo(fireblood_0 cd=120 gcd=0 offgcd=1)
Define(fireblood_1 265226)
# Increases ?a162700[Agility]?a162702[Strength]?a162697[Agility]?a162698[Strength]?a162699[Intellect]?a162701[Intellect][primary stat] by s1.
  SpellInfo(fireblood_1 duration=8 max_stacks=6 gcd=0 offgcd=1)
  # Increases ?a162700[Agility]?a162702[Strength]?a162697[Agility]?a162698[Strength]?a162699[Intellect]?a162701[Intellect][primary stat] by w1.
  SpellAddBuff(fireblood_1 fireblood_1=1)
Define(focused_azerite_beam_0 295258)
# Focus excess Azerite energy into the Heart of Azeroth, then expel that energy outward, dealing m1*10 Fire damage to all enemies in front of you over 3 seconds.?a295263[ Castable while moving.][]
  SpellInfo(focused_azerite_beam_0 cd=90 duration=3 channel=3 tick=0.33)
  SpellAddBuff(focused_azerite_beam_0 focused_azerite_beam_0=1)
  SpellAddBuff(focused_azerite_beam_0 focused_azerite_beam_1=1)
Define(focused_azerite_beam_1 295261)
# Focus excess Azerite energy into the Heart of Azeroth, then expel that energy outward, dealing m1*10 Fire damage to all enemies in front of you over 3 seconds.?a295263[ Castable while moving.][]
  SpellInfo(focused_azerite_beam_1 cd=90)
Define(focused_azerite_beam_2 299336)
# Focus excess Azerite energy into the Heart of Azeroth, then expel that energy outward, dealing m1*10 Fire damage to all enemies in front of you over 3 seconds.
  SpellInfo(focused_azerite_beam_2 cd=90 duration=3 channel=3 tick=0.33)
  SpellAddBuff(focused_azerite_beam_2 focused_azerite_beam_0=1)
  SpellAddBuff(focused_azerite_beam_2 focused_azerite_beam_1=1)
Define(focused_azerite_beam_3 299338)
# Focus excess Azerite energy into the Heart of Azeroth, then expel that energy outward, dealing m1*10 Fire damage to all enemies in front of you over 3 seconds. Castable while moving.
  SpellInfo(focused_azerite_beam_3 cd=90 duration=3 channel=3 tick=0.33)
  SpellAddBuff(focused_azerite_beam_3 focused_azerite_beam_0=1)
  SpellAddBuff(focused_azerite_beam_3 focused_azerite_beam_1=1)
Define(guardian_of_azeroth_0 295840)
# Call upon Azeroth to summon a Guardian of Azeroth for 30 seconds who impales your target with spikes of Azerite every s1/10.1 sec that deal 295834m1*(1+@versadmg) Fire damage.?a295841[ Every 303347t1 sec, the Guardian launches a volley of Azerite Spikes at its target, dealing 295841s1 Fire damage to all nearby enemies.][]?a295843[rnrnEach time the Guardian of Azeroth casts a spell, you gain 295855s1 Haste, stacking up to 295855u times. This effect ends when the Guardian of Azeroth despawns.][]rn
  SpellInfo(guardian_of_azeroth_0 cd=180 duration=30)
  SpellAddBuff(guardian_of_azeroth_0 guardian_of_azeroth_0=1)
Define(guardian_of_azeroth_1 295855)
# Each time the Guardian of Azeroth casts a spell, you gain 295855s1 Haste, stacking up to 295855u times. This effect ends when the Guardian of Azeroth despawns.
  SpellInfo(guardian_of_azeroth_1 duration=60 max_stacks=5 gcd=0 offgcd=1)
  # Haste increased by s1.
  SpellAddBuff(guardian_of_azeroth_1 guardian_of_azeroth_1=1)
Define(guardian_of_azeroth_2 299355)
# Call upon Azeroth to summon a Guardian of Azeroth for 30 seconds who impales your target with spikes of Azerite every 295840s1/10.1 sec that deal 295834m1*(1+@versadmg)*(1+(295836m1/100)) Fire damage. Every 303347t1 sec, the Guardian launches a volley of Azerite Spikes at its target, dealing 295841s1 Fire damage to all nearby enemies.
  SpellInfo(guardian_of_azeroth_2 cd=180 duration=30 gcd=1)
  SpellAddBuff(guardian_of_azeroth_2 guardian_of_azeroth_2=1)
Define(guardian_of_azeroth_3 299358)
# Call upon Azeroth to summon a Guardian of Azeroth for 30 seconds who impales your target with spikes of Azerite every 295840s1/10.1 sec that deal 295834m1*(1+@versadmg)*(1+(295836m1/100)) Fire damage. Every 303347t1 sec, the Guardian launches a volley of Azerite Spikes at its target, dealing 295841s1 Fire damage to all nearby enemies.rnrnEach time the Guardian of Azeroth casts a spell, you gain 295855s1 Haste, stacking up to 295855u times. This effect ends when the Guardian of Azeroth despawns.
  SpellInfo(guardian_of_azeroth_3 cd=180 duration=20 gcd=1)
  SpellAddBuff(guardian_of_azeroth_3 guardian_of_azeroth_3=1)
Define(guardian_of_azeroth_4 300091)
# Call upon Azeroth to summon a Guardian of Azeroth to aid you in combat for 30 seconds.
  SpellInfo(guardian_of_azeroth_4 cd=300 duration=30 gcd=1)
Define(guardian_of_azeroth_5 303347)
  SpellInfo(guardian_of_azeroth_5 gcd=0 offgcd=1 tick=8)

Define(hammer_of_justice 853)
# Stuns the target for 6 seconds.
  SpellInfo(hammer_of_justice cd=60 duration=6)
  # Stunned.
  SpellAddTargetDebuff(hammer_of_justice hammer_of_justice=1)
Define(hammer_of_the_righteous 53595)
# Hammers the current target for 53595sw1 Physical damage.?s26573&s203785[rnrnHammer of the Righteous also causes a wave of light that hits all other targets within 88263A1 yds for 88263sw1 Holy damage.]?s26573[rnrnWhile you are standing in your Consecration, Hammer of the Righteous also causes a wave of light that hits all other targets within 88263A1 yds for 88263sw1 Holy damage.][]
  SpellInfo(hammer_of_the_righteous cd=4.5)
  SpellInfo(crusader_strike replaced_by=hammer_of_the_righteous)
Define(hammer_of_wrath 24275)
# Hurls a divine hammer that strikes an enemy for s1 Holy damage. Only usable on enemies that have less than 20 health, or while you are empowered by ?s231895[Crusade][Avenging Wrath].rnrn|cFFFFFFFFGenerates s2 Holy Power.
  SpellInfo(hammer_of_wrath cd=7.5 holypower=-1 talent=hammer_of_wrath_talent)
Define(inquisition 84963)
# Consumes up to 3 Holy Power to increase your damage done and Haste by s1.rnrnLasts 15 seconds per Holy Power consumed.
  SpellInfo(inquisition holypower=1 duration=15 tick=15 talent=inquisition_talent)
  # Damage done increased by w1.rnHaste increased by w3.
  SpellAddBuff(inquisition inquisition=1)
Define(judgment 20271)
# Judges the target, dealing (95 of Spell Power) Holy damage?s231663[, and causing them to take 197277s1 increased damage from your next ability that costs Holy Power.][]?s137027[rnrn|cFFFFFFFFGenerates 220637s1 Holy Power.][]
# Rank 2: Judgment causes the target to take s1 increased damage from your next Holy Power spender.
  SpellInfo(judgment cd=12)
Define(judgment_protection 275779)
# Judges the target, dealing (112.5 of Spell Power) Holy damage?a231657[, and reducing the remaining cooldown on Shield of the Righteous by 231657s1 sec, or 231657s1*2 sec on a critical strike][].
  SpellInfo(judgment_protection cd=12)
Define(lifeblood_buff 274419)
# When you use a Healthstone, gain s1 Leech for 20 seconds.
  SpellInfo(lifeblood_buff channel=-0.001 gcd=0 offgcd=1)

Define(lights_judgment 255647)
# Call down a strike of Holy energy, dealing <damage> Holy damage to enemies within A1 yards after 3 sec.
  SpellInfo(lights_judgment cd=150)

Define(purifying_blast_0 295337)
# Call down a purifying beam upon the target area, dealing 295293s3*(1+@versadmg)*s2 Fire damage over 6 seconds.?a295364[ Has a low chance to immediately annihilate any specimen deemed unworthy by MOTHER.][]?a295352[rnrnWhen an enemy dies within the beam, your damage is increased by 295354s1 for 8 seconds.][]rnrnAny Aberration struck by the beam is stunned for 3 seconds.
  SpellInfo(purifying_blast_0 cd=60 duration=6)
Define(purifying_blast_1 295338)
# Call down a purifying beam upon the target area, dealing 295293s3*(1+@versadmg)*s2 Fire damage over 6 seconds.?a295364[ Has a low chance to immediately annihilate any specimen deemed unworthy by MOTHER.][]?a295352[rnrnWhen an enemy dies within the beam, your damage is increased by 295354s1 for 8 seconds.][]rnrnAny Aberration struck by the beam is stunned for 3 seconds.
  SpellInfo(purifying_blast_1 channel=0 gcd=0 offgcd=1)
Define(purifying_blast_2 295354)
# When an enemy dies within the beam, your damage is increased by 295354s1 for 8 seconds.
  SpellInfo(purifying_blast_2 duration=8 gcd=0 offgcd=1)
  # Damage dealt increased by s1.
  SpellAddBuff(purifying_blast_2 purifying_blast_2=1)
Define(purifying_blast_3 295366)
# Call down a purifying beam upon the target area, dealing 295293s3*(1+@versadmg)*s2 Fire damage over 6 seconds.?a295364[ Has a low chance to immediately annihilate any specimen deemed unworthy by MOTHER.][]?a295352[rnrnWhen an enemy dies within the beam, your damage is increased by 295354s1 for 8 seconds.][]rnrnAny Aberration struck by the beam is stunned for 3 seconds.
  SpellInfo(purifying_blast_3 duration=3 gcd=0 offgcd=1)
  # Stunned.
  SpellAddTargetDebuff(purifying_blast_3 purifying_blast_3=1)
Define(purifying_blast_4 299345)
# Call down a purifying beam upon the target area, dealing 295293s3*(1+@versadmg)*s2 Fire damage over 6 seconds. Has a low chance to immediately annihilate any specimen deemed unworthy by MOTHER.?a295352[rnrnWhen an enemy dies within the beam, your damage is increased by 295354s1 for 8 seconds.][]rnrnAny Aberration struck by the beam is stunned for 3 seconds.
  SpellInfo(purifying_blast_4 cd=60 duration=6 channel=6 gcd=1)
Define(purifying_blast_5 299347)
# Call down a purifying beam upon the target area, dealing 295293s3*(1+@versadmg)*s2 Fire damage over 6 seconds. Has a low chance to immediately annihilate any specimen deemed unworthy by MOTHER.rnrnWhen an enemy dies within the beam, your damage is increased by 295354s1 for 8 seconds.rnrnAny Aberration struck by the beam is stunned for 3 seconds.
  SpellInfo(purifying_blast_5 cd=60 duration=6 gcd=1)
Define(razor_coral_0 303564)
# ?a303565[Remove Razor Coral from your target, granting you 303573s1 Critical Strike per stack for 20 seconds.][Deal 304877s1*(1+@versadmg) Physical damage and apply Razor Coral to your target, giving your damaging abilities against the target a high chance to deal 304877s1*(1+@versadmg) Physical damage and add a stack of Razor Coral.rnrnReactivating this ability will remove Razor Coral from your target, granting you 303573s1 Critical Strike per stack for 20 seconds.]
  SpellInfo(razor_coral_0 cd=20 channel=0 gcd=0 offgcd=1)
Define(razor_coral_1 303565)
# ?a303565[Remove Razor Coral from your target, granting you 303573s1 Critical Strike per stack for 20 seconds.][Deal 304877s1*(1+@versadmg) Physical damage and apply Razor Coral to your target, giving your damaging abilities against the target a high chance to deal 304877s1*(1+@versadmg) Physical damage and add a stack of Razor Coral.rnrnReactivating this ability will remove Razor Coral from your target, granting you 303573s1 Critical Strike per stack for 20 seconds.]rn
  SpellInfo(razor_coral_1 duration=120 max_stacks=100 gcd=0 offgcd=1)
  SpellAddBuff(razor_coral_1 razor_coral_1=1)
Define(razor_coral_2 303568)
# ?a303565[Remove Razor Coral from your target, granting you 303573s1 Critical Strike per stack for 20 seconds.][Deal 304877s1*(1+@versadmg) Physical damage and apply Razor Coral to your target, giving your damaging abilities against the target a high chance to deal 304877s1*(1+@versadmg) Physical damage and add a stack of Razor Coral.rnrnReactivating this ability will remove Razor Coral from your target, granting you 303573s1 Critical Strike per stack for 20 seconds.]rn
  SpellInfo(razor_coral_2 duration=120 max_stacks=100 gcd=0 offgcd=1)
  # Withdrawing the Razor Coral will grant w1 Critical Strike.
  SpellAddTargetDebuff(razor_coral_2 razor_coral_2=1)
Define(razor_coral_3 303570)
# ?a303565[Remove Razor Coral from your target, granting you 303573s1 Critical Strike per stack for 20 seconds.][Deal 304877s1*(1+@versadmg) Physical damage and apply Razor Coral to your target, giving your damaging abilities against the target a high chance to deal 304877s1*(1+@versadmg) Physical damage and add a stack of Razor Coral.rnrnReactivating this ability will remove Razor Coral from your target, granting you 303573s1 Critical Strike per stack for 20 seconds.]rn
  SpellInfo(razor_coral_3 duration=20 channel=20 max_stacks=100 gcd=0 offgcd=1)
  # Critical Strike increased by w1.
  SpellAddBuff(razor_coral_3 razor_coral_3=1)
Define(razor_coral_4 303572)
# ?a303565[Remove Razor Coral from your target, granting you 303573s1 Critical Strike per stack for 20 seconds.][Deal 304877s1*(1+@versadmg) Physical damage and apply Razor Coral to your target, giving your damaging abilities against the target a high chance to deal 304877s1*(1+@versadmg) Physical damage and add a stack of Razor Coral.rnrnReactivating this ability will remove Razor Coral from your target, granting you 303573s1 Critical Strike per stack for 20 seconds.]rn
  SpellInfo(razor_coral_4 channel=0 gcd=0 offgcd=1)
Define(reaping_flames_0 310690)
# Burn your target with a bolt of Azerite, dealing 310712s3 Fire damage. If the target has less than s2 health?a310705[ or more than 310705s1 health][], the cooldown is reduced by s3 sec.?a310710[rnrnIf Reaping Flames kills an enemy, its cooldown is lowered to 310710s2 sec and it will deal 310710s1 increased damage on its next use.][]
  SpellInfo(reaping_flames_0 cd=45 channel=0)
Define(reaping_flames_1 311194)
# Burn your target with a bolt of Azerite, dealing 310712s3 Fire damage. If the target has less than s2 health or more than 310705s1 health, the cooldown is reduced by m3 sec.
  SpellInfo(reaping_flames_1 cd=45 channel=0)
Define(reaping_flames_2 311195)
# Burn your target with a bolt of Azerite, dealing 310712s3 Fire damage. If the target has less than s2 health or more than 310705s1 health, the cooldown is reduced by m3 sec.rnrnIf Reaping Flames kills an enemy, its cooldown is lowered to 310710s2 sec and it will deal 310710s1 increased damage on its next use. 
  SpellInfo(reaping_flames_2 cd=45 channel=0)
Define(reaping_flames_3 311202)
# Burn your target with a bolt of Azerite, dealing 310712s3 Fire damage. If the target has less than s2 health?a310705[ or more than 310705s1 health][], the cooldown is reduced by s3 sec.?a310710[rnrnIf Reaping Flames kills an enemy, its cooldown is lowered to 310710s2 sec and it will deal 310710s1 increased damage on its next use.][]
  SpellInfo(reaping_flames_3 duration=30 gcd=0 offgcd=1)
  # Damage of next Reaping Flames increased by w1.
  SpellAddBuff(reaping_flames_3 reaping_flames_3=1)
Define(rebuke 96231)
# Interrupts spellcasting and prevents any spell in that school from being cast for 4 seconds.
  SpellInfo(rebuke cd=15 duration=4 gcd=0 offgcd=1 interrupt=1)
Define(reckless_force_buff_0 298409)
# When an ability fails to critically strike, you have a high chance to gain Reckless Force. When Reckless Force reaches 302917u stacks, your critical strike is increased by 302932s1 for 4 seconds.
  SpellInfo(reckless_force_buff_0 max_stacks=5 gcd=0 offgcd=1 tick=10)
  # Gaining unstable Azerite energy.
  SpellAddBuff(reckless_force_buff_0 reckless_force_buff_0=1)
Define(reckless_force_buff_1 304038)
# When an ability fails to critically strike, you have a high chance to gain Reckless Force. When Reckless Force reaches 302917u stacks, your critical strike is increased by 302932s1 for 4 seconds.
  SpellInfo(reckless_force_buff_1 channel=-0.001 gcd=0 offgcd=1)
  SpellAddBuff(reckless_force_buff_1 reckless_force_buff_1=1)
Define(seething_rage 297126)
# Increases your critical hit damage by 297126m for 5 seconds.
  SpellInfo(seething_rage duration=5 gcd=0 offgcd=1)
  # Critical strike damage increased by w1.
  SpellAddBuff(seething_rage seething_rage=1)
Define(seraphim 152262)
# The Light temporarily magnifies your power, increasing your Haste, Critical Strike, Mastery, and Versatility by s1.rnrnConsumes up to s2 charges of Shield of the Righteous, and lasts 8 seconds per charge.
  SpellInfo(seraphim cd=45 duration=8 talent=seraphim_talent)
  # Haste, Critical Strike, Mastery, and Versatility increased by s1.
  SpellAddBuff(seraphim seraphim=1)
Define(shield_of_the_righteous 53600)
# Slams enemies in front of you with your shield, causing s1 Holy damage, and increasing your Armor by 132403s1*STR/100 for 4.5 seconds.
  SpellInfo(shield_of_the_righteous cd=1 charge_cd=18 gcd=0 offgcd=1)
Define(shield_of_vengeance 184662)
# Creates a barrier of holy light that absorbs s2/100*MHP damage for 15 seconds.rnrnWhen the shield expires, it bursts to inflict Holy damage equal to the total amount absorbed, divided among all nearby enemies.
  SpellInfo(shield_of_vengeance cd=120 duration=15)
  # Absorbs w1 damage and deals damage when the barrier fades or is fully consumed.
  SpellAddBuff(shield_of_vengeance shield_of_vengeance=1)
Define(templars_verdict 85256)
# Unleashes a powerful weapon strike that deals 224266sw1*<mult> Holy damage to an enemy target.
  SpellInfo(templars_verdict holypower=3)
Define(the_unbound_force_0 298452)
# Unleash the forces within the Heart of Azeroth, causing shards of Azerite to strike your target for (298407s3*((2 seconds/t)+1)+298407s3) Fire damage over 2 seconds. This damage is increased by s2 if it critically strikes.?a298456[rnrnEach time The Unbound Force causes a critical strike, it immediately strikes the target with an additional Azerite shard, up to a maximum of 298456m2.][]
  SpellInfo(the_unbound_force_0 cd=60 duration=2 channel=2 tick=0.33)
  SpellAddBuff(the_unbound_force_0 the_unbound_force_0=1)
  SpellAddTargetDebuff(the_unbound_force_0 the_unbound_force_0=1)
Define(the_unbound_force_1 298453)
# Unleash the forces within the Heart of Azeroth, causing shards of Azerite to strike your target for (298407s3*((2 seconds/t)+1)+298407s3) Fire damage over 2 seconds. This damage is increased by s2 if it critically strikes.?a298456[rnrnEach time The Unbound Force causes a critical strike, it immediately strikes the target with an additional Azerite shard, up to a maximum of 298456m2.][]
  SpellInfo(the_unbound_force_1 gcd=0 offgcd=1)
Define(the_unbound_force_2 299321)
# Infuse your Heart of Azeroth with The Unbound Force.
  SpellInfo(the_unbound_force_2)
Define(the_unbound_force_3 299322)
# Infuse your Heart of Azeroth with The Unbound Force.
  SpellInfo(the_unbound_force_3)
Define(the_unbound_force_4 299323)
# Infuse your Heart of Azeroth with The Unbound Force.
  SpellInfo(the_unbound_force_4)
Define(the_unbound_force_5 299324)
# Infuse your Heart of Azeroth with The Unbound Force.
  SpellInfo(the_unbound_force_5)
Define(the_unbound_force_6 299376)
# Unleash the forces within the Heart of Azeroth, causing shards of Azerite to strike your target for (298407s3*((2 seconds/298452t)+1)+298407s3) Fire damage over 2 seconds. This damage is increased by s2 if it critically strikes.
  SpellInfo(the_unbound_force_6 cd=45 duration=2 channel=2 gcd=1 tick=0.33)
  SpellAddBuff(the_unbound_force_6 the_unbound_force_6=1)
  SpellAddTargetDebuff(the_unbound_force_6 the_unbound_force_6=1)
Define(the_unbound_force_7 299378)
# Unleash the forces within the Heart of Azeroth, causing shards of Azerite to strike your target for (298407s3*((2 seconds/298452t)+1)+298407s3) Fire damage over 2 seconds. This damage is increased by s2 if it critically strikes.rnrnEach time The Unbound Force causes a critical strike, it immediately strikes the target with an additional Azerite shard, up to a maximum of 298456m2.
  SpellInfo(the_unbound_force_7 cd=45 duration=2 channel=2 gcd=1 tick=0.33)
  SpellAddBuff(the_unbound_force_7 the_unbound_force_7=1)
  SpellAddTargetDebuff(the_unbound_force_7 the_unbound_force_7=1)
Define(wake_of_ashes 255937)
# Lash out at your enemies, dealing sw1 Radiant damage to all enemies within a1 yd in front of you and reducing their movement speed by s2 for 5 seconds.rnrnDemon and Undead enemies are also stunned for 5 seconds.rnrn|cFFFFFFFFGenerates s3 Holy Power.
  SpellInfo(wake_of_ashes cd=45 duration=5 holypower=-5 talent=wake_of_ashes_talent)
  # Movement speed reduced by s2.
  SpellAddTargetDebuff(wake_of_ashes wake_of_ashes=1)
Define(war_stomp 20549)
# Stuns up to i enemies within A1 yds for 2 seconds.
  SpellInfo(war_stomp cd=90 duration=2 gcd=0 offgcd=1)
  # Stunned.
  SpellAddTargetDebuff(war_stomp war_stomp=1)
SpellList(anima_of_death anima_of_death_0 anima_of_death_1 anima_of_death_2 anima_of_death_3)
SpellList(fireblood fireblood_0 fireblood_1)
SpellList(razor_coral razor_coral_0 razor_coral_1 razor_coral_2 razor_coral_3 razor_coral_4)
SpellList(blood_of_the_enemy blood_of_the_enemy_0 blood_of_the_enemy_1 blood_of_the_enemy_2 blood_of_the_enemy_3 blood_of_the_enemy_4 blood_of_the_enemy_5 blood_of_the_enemy_6)
SpellList(focused_azerite_beam focused_azerite_beam_0 focused_azerite_beam_1 focused_azerite_beam_2 focused_azerite_beam_3)
SpellList(guardian_of_azeroth guardian_of_azeroth_0 guardian_of_azeroth_1 guardian_of_azeroth_2 guardian_of_azeroth_3 guardian_of_azeroth_4 guardian_of_azeroth_5)
SpellList(purifying_blast purifying_blast_0 purifying_blast_1 purifying_blast_2 purifying_blast_3 purifying_blast_4 purifying_blast_5)
SpellList(reaping_flames reaping_flames_0 reaping_flames_1 reaping_flames_2 reaping_flames_3)
SpellList(reckless_force_buff reckless_force_buff_0 reckless_force_buff_1)
SpellList(the_unbound_force the_unbound_force_0 the_unbound_force_1 the_unbound_force_2 the_unbound_force_3 the_unbound_force_4 the_unbound_force_5 the_unbound_force_6 the_unbound_force_7)
Define(bastion_of_light_talent 6) #22594
# Immediately grants s1 charges of Shield of the Righteous.
Define(blessed_hammer_talent 3) #22430
# Throws a Blessed Hammer that spirals outward, dealing 204301s1 Holy damage to enemies and weakening them, reducing the damage you take from their next auto attack by 204301s2.
Define(blinding_light_talent 9) #21811
# Emits dazzling light in all directions, blinding enemies within 105421A1 yards, causing them to wander disoriented for 105421d. Non-Holy damage will break the disorient effect.
Define(crusade_talent 20) #22215
# Call upon the Light and begin a crusade, increasing your damage done and Haste by <damage> for 25 seconds.rnrnEach Holy Power spent during Crusade increases damage done and Haste by an additional <damage>.rnrnMaximum u stacks.
Define(crusaders_judgment_talent 5) #22604
# Judgment now has 1+s1 charges, and Grand Crusader now also grants a charge of Judgment.
Define(divine_purpose_talent_retribution 19) #22591
# Your abilities that consume Holy Power have a s1 chance to make your next ability that consumes Holy Power free and deal 223819s2 increased damage and healing.
Define(execution_sentence_talent 3) #22175
# Calls down the Light's punishment upon an enemy target, dealing s1 Holy damage and increasing the target's Holy damage taken from your attacks by 267799s1 for 12 seconds.
Define(hammer_of_wrath_talent 6) #22593
# Hurls a divine hammer that strikes an enemy for s1 Holy damage. Only usable on enemies that have less than 20 health, or while you are empowered by ?s231895[Crusade][Avenging Wrath].rnrn|cFFFFFFFFGenerates s2 Holy Power.
Define(inquisition_talent 21) #22634
# Consumes up to 3 Holy Power to increase your damage done and Haste by s1.rnrnLasts 15 seconds per Holy Power consumed.
Define(righteous_verdict_talent 2) #22557
# Templar's Verdict increases the damage of your next Templar's Verdict by 267611s1 for 6 seconds.
Define(seraphim_talent 21) #22645
# The Light temporarily magnifies your power, increasing your Haste, Critical Strike, Mastery, and Versatility by s1.rnrnConsumes up to s2 charges of Shield of the Righteous, and lasts 8 seconds per charge.
Define(wake_of_ashes_talent 12) #22183
# Lash out at your enemies, dealing sw1 Radiant damage to all enemies within a1 yd in front of you and reducing their movement speed by s2 for 5 seconds.rnrnDemon and Undead enemies are also stunned for 5 seconds.rnrn|cFFFFFFFFGenerates s3 Holy Power.
Define(grongs_primal_rage_item 165574)
Define(unbridled_fury_item 169299)
Define(focused_resolve_item 168506)
Define(anima_of_life_and_death_essence_id 7)
Define(memory_of_lucid_dreams_essence_id 27)
Define(the_crucible_of_flame_essence_id 12)
Define(worldvein_resonance_essence_id 4)
Define(condensed_life_force_essence_id 14)
    ]]
    OvaleScripts:RegisterScript("PALADIN", nil, name, desc, code, "include")
end
