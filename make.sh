#!/bin/bash
# Complies with HellFirePvP's LICENSE.
set -a

setup(){
    echo "AS/ObserverLib portable developer environment"
    echo "Complies with HellFirePvP's LICENSE."
    git help >/dev/null || echo "WARN: This script requires git!"
    echo "Grabbing code from upstream..."
    
    git clone https://github.com/HellFirePvP/AstralSorcery.git
    git clone https://github.com/HellFirePvP/ObserverLib.git
    echo ""
    echo "OK. You'll still have to manually pull updates yourself."
    echo "Setting up build environment... (this can take a while)"
    mkdir baked-jars 2>/dev/null
    mkdir baked-packs 2>/dev/null
    mkdir MirrorAstralSorcery 2>/dev/null
    mkdir MirrorObserverLib 2>/dev/null
    
    echo "Please select a mode (number) from the options below:"
    echo "1 - Sources for Master"
    echo "2 - Sources for 1.12.2"
    echo "When done, press Enter. To use another mode, you will need to install another instance of HellfireBuilder."
    read i
    
    if [ "$i" == "1" ]; then
    echo "Switching branch: Master"
    echo "master" > .branch
    cd AstralSorcery
    git branch master 2>/dev/null
    git checkout master
    cd ..
    cd ObserverLib
    git branch master 2>/dev/null
    git checkout master
    cd ..
    elif [ "$i" == "2" ]; then
    echo "Not switching branch: master"
    echo "master" > .branch
    else
    echo "Error, invalid option. Quitting."
    rm .firstrun
    exit 1
    fi
    
    cp -r AstralSorcery/* MirrorAstralSorcery/
    cp -r ObserverLib/* MirrorObserverLib/
    cp -r gradle/* MirrorAstralSorcery/
    cp -r gradle/* MirrorObserverLib/
    echo ""
    echo "All done!"
    echo "Run \"./make.sh all\" to build both Astral Sorcery and ObserverLib."
    echo "Run \"./make.sh\" for help."
    echo "Run \"./make.sh\" --build-data before building the mods or you'll end up with recipes missing."
    echo "Optional: make a symlink called \"mc-live\" in this folder to your .minecraft/mods folder,"
    echo "          this allows the script to place the new jars directly in there."
    echo "Regardless, new valid jars will be placed on the baked-jars folder."
    touch .firstrun
    exit 0
      }

updateSources(){
	touch .branch
	branch=$(cat .branch)
	echo "Starting update for AstralSorcery for branch $branch"
	cd AstralSorcery
	git pull origin $branch || git pull origin
	echo "Copying changes to mirror"
	cp -r * ../MirrorAstralSorcery/
	cd ..
	echo "Starting update for ObserverLib"
	cd ObserverLib
	git pull origin $branch || git pull origin
	echo "Copying changes to mirror"
	cp -r * ../MirrorObserverLib/
	cd ..
	echo "Starting update for HellfireBuilder"
	git pull origin master
	echo "All good!"
}

buildMCMeta(){
	if [ "$buildType" == "datapack" ]; then
		echo "{" > data-bakery/pack.mcmeta
  	 	echo "\"pack\": {" >> data-bakery/pack.mcmeta
    	  	echo "\"pack_format\": 5," >> data-bakery/pack.mcmeta
    	  	echo "\"description\": \"$target Mod Data Pack\"" >> data-bakery/pack.mcmeta
  	 	echo "  }" >> data-bakery/pack.mcmeta
		echo "}" >> data-bakery/pack.mcmeta
	elif [ "$buildType" == "resourcepack" ]; then
		echo "{" > data-bakery/pack.mcmeta
  	 	echo "\"pack\": {" >> data-bakery/pack.mcmeta
    	  	echo "\"pack_format\": 5," >> data-bakery/pack.mcmeta
    	  	echo "\"description\": \"$target Mod Resource Pack\"" >> data-bakery/pack.mcmeta
  	 	echo "  }" >> data-bakery/pack.mcmeta
		echo "}" >> data-bakery/pack.mcmeta
	fi
	echo "Made mcmeta for $target/$buildType"
}

buildData(){
	echo "Running data generators..."
	mkdir data-bakery 2>/dev/null
	echo "This will cause Minecraft to pop up for a while"
	echo "It will exit and pop out an error message. This is fine."
	sleep 1.5
	echo "Checking if Minecraft data generator instance is installed..."
	./gradlew prepareRunData
	echo "Running Minecraft data generator instance..."
	./gradlew runData 2>/dev/null
		if [ "$buildDataMethod" == "packs" ]; then
		echo "Packaging assets into baked-packs..."
		buildType="resourcepack"
		cp -r src/generated/resources/assets data-bakery/
		buildMCMeta
		echo "Zipping up $target/$buildType"
		cd data-bakery
		zip -rqDm ../../baked-packs/$target-$buildType.zip *
		cd ..
	
		echo "Packaging data into baked-packs..."
		buildType="datapack"
		cp -r src/generated/resources/data data-bakery/
		buildMCMeta
		echo "Zipping up $target/$buildType"
		cd data-bakery
		zip -rqDm ../../baked-packs/$target-$buildType.zip *
		cd ..
		else
		echo "Packaging assets into jar source."
		cp -r src/generated/resources/assets/* src/main/resources/assets/
		echo "Packaging data into jar source."
		cp -r src/generated/resources/data  src/main/resources/
		echo "Rebuilding jar with assets/data builtin..."
		./gradlew build
		fi
	
}
        # Setup build env
    if [ ! -f ".firstrun" ]; then
       setup;
    fi

case $1 in
	as) makeAS="true" ;;
	ol) makeOL="true" ;;
	all) makeAS="true"; makeOL="true" ;;
	update) updateSources; exit 0 ;;
	*) echo "HellfireBuilder/make.sh, usage: ./make.sh (TARGET) [OPTIONS]";
	echo "Nothing to do. Valid targets: update, as, ol, all; Valid options: --build-data, --build-data-in-packs" ;; 
esac

case $@ in
	*--build-data*) buildData="true"; buildDataMethod="internal" ;;
	*--build-data-in-packs*) buildData="true"; buildDataMethod="packs" ;;
	*) true ;;
esac

    if [ "$makeAS" == "true" ]; then
echo "Making Astral Sorcery"
target="AstralSorcery"
cp -rv gradle/* MirrorAstralSorcery
cd MirrorAstralSorcery
./gradlew build
	if [ "$buildData" == "true" ]; then
		buildData;
	fi
echo "Syncing src to git"
cp -r src ../AstralSorcery/
# Clean up things to conform with hellfire's branch
echo "Cleaning up tree"
rm -rf ../AstralSorcery/src/generated 2>/dev/null
rm -rf ../AstralSorcery/src/test 2>/dev/null
rm -rf ../AstralSorcery/src/main/resources/assets/astralsorcery/blockstates 2>/dev/null
rm -rf ../AstralSorcery/src/main/resources/data 2>/dev/null

echo "Packaging Astral Sorcery to test env"
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../mc-live/ || echo "mc-live should point to your mods folder. Make a symlink!"
echo "Packaging Astral Sorcery to baked-jars folder"
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../baked-jars/
	if [ "$buildData" == "true" ]; then
		if [ "$buildDataMethod" == "packs" ]; then
		echo "Astral Sorcery is ready."
		echo "Generated the mod's datapack in the folder baked-packs."
		echo "Put it in your world's datapacks folder to have additional functionality."
		echo "Generated the mod's resource pack in the folder baked-packs."
		echo "Put it in your resource packs folder so that custom blocks have models."
		else
		echo "Astral Sorcery is ready, generated assets/data builtin."
		fi
	else
	echo "Astral Sorcery is ready."
	fi
cd ..
    fi

    if [ "$makeOL" == "true" ]; then
echo "Making ObserverLib"
target="ObserverLib"
cp -rv gradle/* MirrorObserverLib
cd MirrorObserverLib
./gradlew build
	if [ "$buildData" == "true" ]; then
		buildData;
	fi
echo "Syncing src to git"
cp -r src ../ObserverLib/
echo "Cleaning up tree"
rm -rf ../ObserverLib/src/generated 2>/dev/null
rm -rf ../ObserverLib/src/test 2>/dev/null
rm -rf ../ObserverLib/src/main/resources/data 2>/dev/null

echo "Packaging ObserverLib to test env" 
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../mc-live/mods/ || echo "mc-live should point to your mods folder. Make a symlink!"
echo "Packaging ObserverLib to baked-jars folder"
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../baked-jars/
	if [ "$buildData" == "true" ]; then
		if [ "$buildDataMethod" == "packs" ]; then
		echo "ObserverLib is ready."
		echo "Generated the mod's datapack in the folder baked-packs."
		echo "Put it in your world's datapacks folder to have additional functionality."
		echo "Generated the mod's resource pack in the folder baked-packs."
		echo "Put it in your resource packs folder so that custom blocks have models."
		else
		echo "ObserverLib is ready, generated assets/data builtin."
		fi
	else
	echo "ObserverLib is ready."
	fi
cd ..
    fi

case $1 in
	as) cd MirrorAstralSorcery; ./gradlew --stop ; cd .. ;;
	ol) cd MirrorObserverLib; ./gradlew --stop ; cd .. ;;
	all) cd MirrorObserverLib; ./gradlew --stop ; cd ..;
	     cd MirrorAstralSorcery; ./gradlew --stop ; cd .. ;;
esac

unset makeOL
unset makeAS
unset buildData
unset buildDataMethod
exit 0
