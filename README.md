Adds 4 commands to your chat and console. One lets you replace all of the chosen spawned NPCs with another of your choosing and the other one tells you the classes and models of all spawned NPCs.

This was going to just be a quick script I had AI make, but I ended up spending more time playtesting it and asking for more features for the AI to add than I thought. Figured others might be interested in it too.

Console: npcreplace | Chat: !npcreplace
This replaces the specified NPC class with the NPC you specify. Has options to specify which models of a class to replace, what model to spawn the replacement class with, and what weapon they spawn with.

Don't know what NPC classes or model an NPC is using? See the npccheck command below!

❗ Usage: npcreplace <target_class> [target_model (optional)] <new_class> [new_model (optional)] [spawn_weapon (optional, 'none' for no weapon)] [health (optional)]
💡 Example 1: npcreplace npc_combine_s npc_metropolice
💡 Example 2: npcreplace npc_combine_s models/combine_soldier.mdl npc_metropolice models/combine_elite.mdl weapon_ar2
💡 Example 3: npcreplace npc_citizen models/humans/group01/male_01.mdl npc_citizen models/humans/group01/female_01.mdl weapon_smg1 500
💡 Example 4: npcreplace npc_zombie npc_antlion 1000
💡 Example 5: npcreplace npc_combine_s npc_metropolice none 50
❗ For custom models, use the FULL model path, e.g., models/mymod/mymodel.mdl

Console: npccheck | Chat: !npccheck
This will paste a list of how many NPCs of each class are currently spawned and how many of each class is using a specific model. If your lazy like me it also shows a shorter version that just counts the classes. npc_citizens and npc_combine_s classes can have a lot of models which can create a lot of lines in the console, so you just want the class amount, you can ignore those lines and read the yellow summary at the bottom.
 
💡Example output in console when npccheck is used:

Current NPC Breakdown (excluding restricted classes) - 23 total:
npc_alyx (1 total):
- models/alyx.mdl: 1
npc_citizen (7 total):
- models/humans/group01/female_06.mdl: 1
- models/humans/group01/male_05.mdl: 3
- models/humans/group01/male_08.mdl: 2
- models/humans/group03m/male_06.mdl: 1
npc_combine_s (9 total):
- models/combine_soldier.mdl: 4
- models/combine_soldier_prisonguard.mdl: 2
- models/combine_super_soldier.mdl: 3
npc_gman (1 total):
- models/gman.mdl: 1
npc_metropolice (5 total):
- models/police.mdl: 5
Current NPC Summary (excluding restricted classes) - 23 total:
npc_alyx: 1, npc_citizen: 7, npc_combine_s: 9, npc_gman: 1, npc_metropolice: 5

Console: npcclasskill | Chat: !npcclasskill
This is just like the npcreplace command, but it doesn't spawn anything in place of the removed NPCs. I had this added because sometimes NPCs can get lost on older maps that spawn NPCs and I needed a way to, well, remove them so the map would spawn more.

Command usage (console and chat):
npcclasskill <npc_class> [optional_model_path]
!npcclasskill <npc_class> [optional_model_path]

Console: npcremovaleffect | Chat: !npcremovaleffect
Lets you change (or disable) the disintegration effect that plays when NPCs are removed. If you're using a lower end computer and want some extra performance when replacing NPCs or don't like the default heavy disintegration effect, you can now change or remove it! Available options for this command are energy, heavy (default), light, core, and none.

Command usage (console and chat):
npcremovaleffect <effect name>
!npcremovaleffect <npc_class>

💡 Example: npcremovaleffect energy

FAQ:
Couldn't I just press Z (Undo) or use the remover tool and spawn in NPCs with the Q menu?
Sure! But maybe you'll play on maps and use mods that spawn waves of enemies to fight. If you want to change things up or make certain NPCs fight each other, this lets you pause the game and replace NPCs instead of noclipping mid fight, flying around the map with the remover tool to remove select NPCs and spawn them in with the Q menu and manually setting weapons. These commands also help if you've spawned a bunch of new NPCs or props since you spawned the NPCs you want to replace.

How do I know what name to put in the weapon section?
Open Q Menu - Weapons - Right click on the weapon you want the NPC to have - copy to clipboard. Just know the weapon you select must support NPCs!

Does this work in multiplayer?
I exclusively tested it in singleplayer cause that's where I use it. If it does, you probably want an addon that will restrict who can use these commands. It could lead to other players replacing NPCs they didn't spawn. Also, since the replacement NPCs aren't spawned by a player they can't be deleted with the Z (Undo) key. Oh, and it could be used to bypass NPC spawn limits.

What are the restricted classes?
I play on maps that spawn NPCs themselves and use a npc_enemyfinder class that kept getting counted. Probably would break the map if that was changed, so ya. That's pretty much it.

I just turned an NPC into an entity!
Ya, I found that out too just before posting this. I was able to turn NPCs into helicopter bombs to effectively delete them without knowing where they were. Bonus feature I guess? I haven't tested this, so prepare for unforeseen consequences...

Which AIs did you use to make these commands and how much work did you really do on this tool?
Deepseek, Grok, and Claude depending on usage limits. I spent time troubleshooting lua errors, thinking of more features to tell the AI to add, but I'm not going to act like I slaved away at these commands. It is just a few commands after all.


Can you update/add something to this tool for me?

No. I wasn't even planning on releasing this initially. I'm only publishing it now because I spent WAY too long on it and since I spent all this time on it I might as well post it and hope someone else finds it cool/useful too. ¯\_(ツ)_/¯



Can I change/improve this addon and upload my own version?

Sure. While I did a lot of playtesting and error troubleshooting, ultimately AI made the code, and due to legal precedent (in the USA as of writing) I couldn't claim the rights to this code even if I wanted to since it wasn't made by a human. So change it yourself or shove it into your favorite AI and see what pops out!
