# HellfireBuilder
A portable script for building HellFirePvP's mods to assist in debugging and development. For \*nix OSes only!  
This requires the Java 8 JDK to be installed, along with git.

It setups an environment that facilitiates development of Astral Sorcery and ObserverLib.
Make your changes to MirrorAstralSorcery and MirrorObserverLib, and run.  
The debug-ready mod jar will be served warm to you (or Minecraft).  
Plus, the changes to src will be placed in the git repo src folder, for commiting and pushing changes. This is most useful if you replace the repos with your own fork, to later make a PR.
This also prevents dirtying up the file tree with gradlew and stuff.

**Installation**  
Clone the repo. `git clone https://github.com/yagoplx/HellfireBuilder.git; cd HellfireBuilder/`
  
Run `./make.sh`, for initial setup.  

**Usage**  
Run `./make.sh as` to build Astral Sorcery.  
Run `./make.sh ol` to build ObserverLib.  
Run `./make.sh all` to build both.  
Add the `--build-data` flag to your command to build recipes and block state data.
Add the `--build-data-in-packs` flag to your command to do the above in the "vanilla" way.

**FAQ**  
Q: Help, my recipes and textures are missing!  
A: --build-data will generate the recipes and textures you need, and automatically include them into the jar.

**Special Thanks/Credits**  
https://github.com/HellFirePvP for making awesome mods.  
https://github.com/gradle/gradle for baking delicious jars.  
