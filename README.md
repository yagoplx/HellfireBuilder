# HellfireBuilder
A portable script for building HellFirePvP's mods to assist in debugging and development. For *nix OSes only!

It setups an environment that facilitiates development of Astral Sorcery and ObserverLib.
Make your changes to MirrorAstralSorcery and MirrorObserverLib, and run.  
The debug-ready mod jar will be served warm to you (or Minecraft).  
Plus, the changes will be placed in the git repo src folder, for commiting and pushing changes. This is most useful if you replace the repos with your own fork, to later make a PR.

**Installation**  
Run `./make.sh`, for initial setup.  

**Usage**  
Run `./make.sh as` to build Astral Sorcery.  
Run `./make.sh ol` to build ObserverLib.  
Run `./make.sh all` to build both.  

**Special Thanks/Credits**  
https://github.com/HellFirePvP for making awesome mods.  
https://github.com/gradle/gradle for baking delicious jars.  
