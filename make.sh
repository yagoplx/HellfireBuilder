#!/bin/bash
# AS-1.14.4/ObserverLib portable developer environment
# Complies with HellFirePvP's LICENSE.

setup(){
    echo "AS-1.14.4/ObserverLib portable developer environment"
    echo "Complies with HellFirePvP's LICENSE."
    echo "Grabbing code from upstream..."
    git clone https://github.com/HellFirePvP/AstralSorcery.git
    git clone https://github.com/HellFirePvP/ObserverLib.git
    echo ""
    echo "OK. You'll still have to manually pull updates yourself."
    echo "Setting up build environment... (this can take a while)"
    mkdir baked-jars 2>/dev/null
    mkdir MirrorAstralSorcery 2>/dev/null
    mkdir MirrorObserverLib 2>/dev/null
    cp -r AstralSorcery/* MirrorAstralSorcery/
    cp -r ObserverLib/* MirrorObserverLib/
    cp -r gradle/* MirrorAstralSorcery/
    cp -r gradle/* MirrorObserverLib/
    echo ""
    echo "All done!"
    echo "Run \"./make.sh all\" to build both Astral Sorcery and ObserverLib."
    echo "Run \"./make.sh for help.\""
    echo "Optional: make a symlink called \"mc-live\" in this folder to your .minecraft/mods folder,"
    echo "          this allows the script to place the new jars directly in there."
    echo "Regardless, new valid jars will be placed on the baked-jars folder."
    touch .firstrun
    exit 0
      }

        # Setup build env
    if [ ! -f ".firstrun" ]; then
       setup;
    fi

case $1 in
	as) makeAS="true" ;;
	ol) makeOL="true" ;;
	all) makeAS="true"; makeOL="true" ;;
	*) echo "Nothing to do. Valid options: as, ol, all" ;; 
esac

    if [ "$makeAS" == "true" ]; then
echo "Making Astral Sorcery"
cp -rv gradle/* MirrorAstralSorcery
cd MirrorAstralSorcery
./gradlew build
echo "Syncing src to git"
cp -r src ../AstralSorcery/
echo "Packaging Astral Sorcery to test env"
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../mc-live/mods/ || echo "mc-live should point to your mods folder. Make a symlink!"
echo "Packaging Astral Sorcery to baked-jars folder"
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../baked-jars/
echo "Astral Sorcery is ready."
cd ..
    fi

    if [ "$makeOL" == "true" ]; then
echo "Making ObserverLib"
cp -rv gradle/* MirrorObserverLib
cd MirrorObserverLib
./gradlew build
echo "Syncing src to git"
cp -r src ../ObserverLib/
echo "Packaging ObserverLib to test env" 
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../mc-live/mods/ || echo "mc-live should point to your mods folder. Make a symlink!"
echo "Packaging ObserverLib to baked-jars folder"
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../baked-jars/
echo "ObserverLib is ready."
cd ..
    fi

unset makeOL
unset makeAS
exit 0
