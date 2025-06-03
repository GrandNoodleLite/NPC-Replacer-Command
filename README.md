# NPC-Replacer-Command
This is the github version of the NPC Replacer Command I posted on the Garry's Mod Steam Workshop.
https://steamcommunity.com/sharedfiles/filedetails/?id=3492368069

Adds 2 commands to your chat and console. One lets you replace all of the chosen spawned NPCs with another of your choosing and the other one tells you the classes and models of all spawned NPCs.

This was going to just be a quick script I had AI make, but I ended up spending more time playtesting it and asking for more features for the AI to add than I thought. Figured others might be interested in it too.

[h1]Console: npcreplace | Chat: !npcreplace[/h1]
This replaces the specified NPC class with the NPC you specify. Has options to specify which models of a class to replace, what model to spawn the replacement class with, and what weapon they spawn with.

[u][b]Don't know what NPC classes or model an NPC is using? See the npccheck command below![/b][/u]

Usage: npcreplace <target_class> [target_model (optional)] <new_class> [new_model (optional)] [spawn_weapon (optional)]

💡 Example 1: npcreplace npc_citizen npc_zombie
💡 Example 2: npcreplace npc_combine_s npc_metropolice weapon_stunstick
💡 Example 3: npcreplace npc_citizen models/player/group01/female_01.mdl npc_zombie
💡 Example 4: npcreplace npc_citizen models/player/group01/male_07.mdl npc_combine_s models/combine_super_soldier.mdl weapon_ar2
❗ Use the FULL model path, e.g., models/mymod/mymodel.mdl

[h1]Console: npccheck | Chat: !npccheck[/h1]
This will paste a list of how many NPCs of each class are currently spawned and how many of each class is using a specific model. If your lazy like me it also shows a shorter version in yellow text that just counts the classes. npc_citizens and npc_combine_s classes can have a lot of models which can create a lot of lines in the console, so you just want the class amount, you can ignore those lines and read the yellow summary at the bottom.
 
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

[h2] FAQ: [/h2]
[b][u]Couldn't I just press Z (Undo) or use the remover tool and spawn in NPCs with the Q menu?[/u][/b]
Sure! But I like to play on maps and use mods that spawn waves of enemies to fight. If I want to change things up or make those NPCs fight each other, this lets me pause the game and replace NPCs instead of noclipping mid fight, flying around the map with the remover tool to remove select NPCs and spawn them in with the Q menu. It also removes the need to clean the map of NPCs if some get lost, but you have others set up just the way you like.

[b][u]How do I know what name to put in the weapon section?[/u][/b]
Open Q Menu - Weapons - Right click on the weapon you want the NPC to have - copy to clipboard. Just know the weapon you select must support NPCs!

[b][u]Does this work in multiplayer?[/u][/b]
I exclusively tested it in singleplayer cause that's where I use it. If it does, you probably want an addon that will restrict who can use this command. It could lead to other players replacing NPCs they didn't spawn. Also, since the replacement NPCs aren't spawned by a player they can't be deleted with the Z (Undo) key. Oh, and it could be used to bypass NPC spawn limits.

[b][u]What are the restricted classes?[/u][/b]
I play on maps that spawn NPCs themselves and use a npc_enemyfinder class that kept getting counted. Probably would break the map if that was changed, so ya. That's pretty much it.

[b][u]I just turned an NPC into an entity![/u][/b]
Ya, I found that out too just before posting this. I was able to turn NPCs into helicopter bombs to effectively delete them without knowing where they were. Bonus feature I guess? I haven't tested this, so prepare for unforeseen consequences...

[b][u]Which AIs did you use to make these commands and how much work did you really do on this tool?[/u][/b]
Deepseek. Mainly because it has a lot less limits for free users and is comperable to ChatGPT. I spent time troubleshooting lua errors, thinking of more features to tell the AI to add, but I'm not going to act like I slaved away at these commands. It is just 2 commands after all.

[b][u]Can you update/add something to this tool for me?[/u][/b]
No. I wasn't even planning on releasing this initially. I'm only publishing it now because I spent WAY too long on it and since I spent all this time on it I might as well post it and hope someone else finds it cool/useful too. ¯\_(ツ)_/¯

[b][u] Can I change/improve this addon and upload my own version?[/u][/b]
Sure. While I did a lot of playtesting and error troubleshooting, ultimately AI made the code, and due to legal precedent (in the USA as of writing) I couldn't claim the rights to this code even if I wanted to since it wasn't made by a human. So change it yourself or shove it into your favorite AI and see what pops out!
