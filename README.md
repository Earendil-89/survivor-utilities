# survivor-utilties
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Sourcemod API for L4D/2 to get control in survivor speeds and add effects

If you only install this plugin, you will have only access to survivor speed control via ConVar.
This plugin modifies survivor moving speeds, but is not a speed scaler that accelerates player movements in all directions making them jump or fall unrealistically fast or slow, it modifies the max speed that the player can run or walk, it doesn’t scale survivor movement.

Current speeds that can be modified by ConVar:
    Running speed.
    Walking speed.
    Moving speed on water, should work in L4D.
    Limping speed (when survivor health is lower than 40 by default).
    Critical speed (probably will have other name, but this refers to the survivor speed when he has been incapacitated once and HP falls to 1).
    Crouch speed.
    Exhaust speed (this is an API feature that will only be activated by other plugins).

When the plugin has to choose different speeds in a situation, will choose the most restrictive one. (Lets say that your walk speed is higher than water speed, if a survivor tries to walk on water plugin will set his speed to the water speed to prevent to cheat speed on water).
Other plugins can use the Natives provided in this plugin to change specific survivor speeds, for perks, RPG, or anything you can imagine. 
As an API this plugin has the next conditions for survivors:
    Bleeding: Survivors will lose health over time; bleeding can be stopped if the survivor uses a medkit.
    Intoxication: Survivors will lose health over time due to an intoxication; it can be stopped if the survivor uses pain pills or adrenaline.
    Improved freeze: Survivor is unable to move, shoot, reload or shove, also a screen effect is displayed while the survivor is frozen.
    Exhaustion, while exhausted the survivor will lose movement speed, maxed shove penalty and increased recoil, a screen effect is displayed (thanks to Silvers for the fog_volume and postprocess code). Exhaust can be cancelled with adrenaline, also if the survivor doesn’t move will recover faster.
    
Requirements:
    Left 4 DHooks Direct
