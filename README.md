# hrpg
Heretic RPG by Peewee RotA

## Summary
This is a gameplay mod that adds classes, leveling, and melee enhancements to Heretic. Each weapon gets a melee or similar attack for alt-fire. The two new calsses get their own signature weapon. This enhances the RPG and fantasy elements of the game as well as gives players more options when out of ammo.

This mod was made for COOP but works fine in Single Player and deathmatch.

# Features

## New Classes

### Heretic
The base class. Starts with the most Trickery and is the fastest. All ranged weapons are balanced, best with weapons like the crossbow.

Best at movement and stealth.

Soul Essences give temporary invisibility. Other powerups also take effect after reaching higher levels.

When the heretic attacks an unsuspecting foe, or one engaged in another fight, he deals a big surprise attack bonus. Be quick to catch the monsters off guard.

### Heathen
A brute who likes to get up close and personal. Starts with a warhammer and the most health.

Best at melee and has the most heath.

Soul Essences give armor and makes the Heathen go berserk, greatly increases melee damage with strength weapons.

The Heathen cannot use all of the classic heretic weapons, but gains new martial weapons to shed some blood and take some names.

### Blasphemer
A magician who excells at magical staffs and wands. Starts with a spellbook and is the slowest.

Best at ranged magical weapons. By far the biggest damage dealer at range.

Soul Essences give a small amount of ammo.

The Blasphemer learns spells at level 1, 4, 8, 12, and 16 which are usable in the inventory.

#### Bindings
The Blasphemer earns spells as he levels. The following can be bound as shortcuts:
 - use FireballSpell
 - use IceSpell
 - use VampireSpell
 - use VolcanoSpell
 - use LightningSpell

## Leveling
Players now have XP and gain XP when damaging a monster.

You'll need 1000 per current level to gain the next level. Each level gain resets XP, raises health max, heals the player, increases stats.

Stat increases are randomized, but weighted to give more points to the highest score.

### Stats
There are 3 stats. Brutality, Trickery, and Corruption.

Each level increases stats. Each level the player increases 5 stat points, awarded randomly, weighted to go to the highest stat.

#### Brutality
Brute force and might.

Determines health increases at levels and increases melee damage with strength weapons. (War hammer, morning star, battering ram, firemace melee attack)

Health increases are randomized up to Brutality, with a minimum increase of 5 per level.

#### Trickery
Speed and cunning.

Determines damage with dexterity based weapons. (Staff, Crossbow, Dragon Claw, Fire Mace)

#### Corruption
Megic and raw power.

Determines damage with magic wands and staffs (Spellbook, Gold Wand, Hellstaff, Pheonix staff)

## Monster Soul Essence
Monsters sometimes leak some of their power as soul essence. These strange objects power the player. Their effects are based on class.

Every class gains some health back.

- Heretic becomes invisible for a short time and can gain even more powers
- Heathen gains armor and goes berserk, giving a damage bonus to his melee weapons.
- Blasphemer regains magical ammuntion.

## Weapons

### Blasphemer Spellbook

The no-ammo weapon for this magic user is a spellbook with medium and short range spells. A bolt of fire that guides towards foes and a chilling touch of cold.

In addition, there are new spells that the Blasphemer learns when leveling, usable like items or through hot keys.

### Heathen Melee Weapons
The Heathen's aresenal has been replaced by melee weapons with weaker alternative ranged attacks. The ranged attacks use ammo.

 - Warhammer
 - War Axe
 - Flail
 - Trident
 - Maul

### Alt Fires
Each weapon gains an alt fire designed to enhance strategy for each weapon, such as slower and more accurate blasts from rapid fire weapons.

## Captured Souls
The Serpent Riders have captured souls of the innocent and bound them into terrifying monsters. These spirits have unlimited energy that the evil D'Sparil and his kin torture into grotesque minions. Only a Heretic would be willing to risk his eternity to free this poor souls.

When a monster is killed, they will pulsate with soul energy. These pulses can be viewed on your magic map. After a time the energy will revive the monster. This viscious cycle repeats until the soul is freed and purified with holy fire.

Every time one of these monsters is killed, one of these souls has a chance to escape. The most powerful monsters take too much energy to stitch back together, and the soul escapes right away.

The only way to stop each level from refilling with deadly minions is to free the soul from every monster.

## New Monsters

Monsters have a chance to appear stronger. As players level, the monsters they kill have a higher chance of spawning as special monsters.

There are 4 monster types, and many of them can combine to make even stronger mini-bosses. As the spawn chance increases, so does the chance they will combine. The higher level, the more challenging monsters that respawn.

### Brute
Bigger and tougher with more health.

### Spectre
A vengful spirit that packs a stronger punch.

### Miniboss
A beefed up monster made up of one of the elements.

#### Stone
Hard as stone, really hard to kill.

#### Poison
Leaves a sting with ranged attacks.

#### Ice
Dodging their shots may still leave you with a cold reception.

#### Fire
A burning hatred coupled with volcanic retribution.

#### Lightning
Shockingly strong enemies with explosive attacks.

#### Death
The gravest of threats. When it's your time to go, they'll follow you anywhere.


### Runt
Weee!!!!

# Credits

Heretic is a product of Raven Software and id Software.

## Special Thanks

* neoworm for base sprites for Flail, Trident, and Firemace
* gerolf for base sprites for Flail

# Contributing

This mod is entirely just putzing around with ZScript while trying to make a better COOP experience for local LAN play. If you have any suggestions, drop a line on the [ZDOOM forums thread](https://forum.zdoom.org/viewtopic.php?f=43&t=72263).