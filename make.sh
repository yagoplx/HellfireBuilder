#!/bin/bash
# AS-1.14.4/ObserverLib portable developer environment
# Complies with HellFirePvP's LICENSE.

setup(){
    echo "AS-1.14.4/ObserverLib portable developer environment"
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
    cd AstralSorcery
    git checkout 1.14.3-indev
    cd ..
    cd ObserverLib
    git checkout 1.14.3-indev
    cd ..
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

buildMCMeta(){
	if [ "buildType" == "datapack" ]; then
		echo "{" > pack.mcmeta
  	 	echo "\"pack\": {" >> data-bakery/pack.mcmeta
    	  	echo "\"pack_format\": 5," >> data-bakery/pack.mcmeta
    	  	echo "\"description\": \"$target Mod Data Pack\"" >> data-bakery/pack.mcmeta
  	 	echo "  }" >> data-bakery/pack.mcmeta
		echo "}" >> data-bakery/pack.mcmeta
	elif [ "buildType" == "resourcepack" ]; then
		echo "{" > pack.mcmeta
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
	./gradlew prepareRunData
	./gradlew runData
	echo "Packaging assets into baked-packs..."
	buildType="resourcepack"
	cp -r src/generated/resources/assets data-bakery/
	buildMCMeta
	echo "Zipping up $target/$buildType"
	zip -r ../baked-packs/$target-$buildType.zip data-bakery/*
	
	rm -rf data-bakery/*
	
	echo "Packaging data into baked-packs..."
	buildType="datapack"
	cp -r src/generated/resources/data data-bakery/
	buildMCMeta
	echo "Zipping up $target/$buildType"
	zip -r ../baked-packs/$target-$buildType.zip data-bakery/*
}
        # Setup build env
    if [ ! -f ".firstrun" ]; then
       setup;
    fi

case $1 in
	as) makeAS="true" ;;
	ol) makeOL="true" ;;
	all) makeAS="true"; makeOL="true" ;;
	*) echo "HellfireBuilder/make.sh, usage: ./make.sh (TARGET) [OPTIONS]";
	echo "Nothing to do. Valid targets: as, ol, all; Valid options: --build-data" ;; 
esac

case $@ in
	*--build-data*) buildData="true" ;;
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
rm -rf ../AstralSorcery/src/generated
rm -rf ../AstralSorcery/src/test
echo "Packaging Astral Sorcery to test env"
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../mc-live/ || echo "mc-live should point to your mods folder. Make a symlink!"
echo "Packaging Astral Sorcery to baked-jars folder"
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../baked-jars/
echo "Astral Sorcery is ready."
	if [ "$buildData" == "true" ]; then
		echo "Generated the mod's datapack in the folder baked-packs."
		echo "Put it in your world's datapacks folder to have additional functionality."
		echo "Generated the mod's resource pack in the folder baked-packs."
		echo "Put it in your resource packs folder so that custom blocks have models."
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
rm -rf ../ObserverLib/src/generated
rm -rf ../ObserverLib/src/test
echo "Packaging ObserverLib to test env" 
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../mc-live/mods/ || echo "mc-live should point to your mods folder. Make a symlink!"
echo "Packaging ObserverLib to baked-jars folder"
cp -rv build/libs/$(ls build/libs/ | grep -vi deobf | grep -vi sources) ../baked-jars/
echo "ObserverLib is ready."
	if [ "$buildData" == "true" ]; then
		echo "Generated the mod's datapack in the folder baked-packs."
		echo "Put it in your world's datapacks folder to have additional functionality."
		echo "Generated the mod's resource pack in the folder baked-packs."
		echo "Put it in your resource packs folder so that custom blocks have models."
	fi
cd ..
    fi

unset makeOL
unset makeAS
unset buildData
exit 0
