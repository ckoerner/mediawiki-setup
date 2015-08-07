#!/bin/bash
#title			:gitMediawiki.sh
#description	:This script is used to download (via 'git clone') a release of MediaWiki and extensions used at Mercy. It asks for the WMF branch to install, then installs MediaWiki and all extensions from their master branch into the directory it is run from.
#author			:Chris Koerner
#date			:20141103
#version		:0.5
#usage			:bash gitMediawiki.sh
#notes			:This does not setup LocalSettings.php, Localsettings.js (parsoid) or any other config/tweaks. Those are handled seperately
#				Check https://mtswiki.mercy.net/wiki/MediaWiki/2013_Upgrade for those settings.
#				This is set to run from ~/ but should run from any directory.
#prerequisites	:This script also assumes you have git, svn, composer and npm (for parsoid) installed :/

#prompt for release you'd like. We'll then use that as the name of our directory (without the period in the directory name)
echo "Which branch to you want? (i.e. 1.25wmf6)"
read release
echo "getting $release"
#get rid of that nasty period for our install directory
releaseDir="$(echo "$release"|tr -d '.')"
mkdir "$releaseDir"
#ok, time to pull down the mediawiki core repository. Probably an easier way to do this without all of core.
git clone https://gerrit.wikimedia.org/r/p/mediawiki/core.git
cd core
git checkout -b origin/wmf/"$release"
git archive origin/wmf/"$release" | tar -x -C ~/"$releaseDir"
cd ..
#Now we're in the folder you ran this script from ~/
cd $releaseDir
#Now let's install mediawiki core dependencies via composer - https://www.mediawiki.org/wiki/Download_from_Git#Fetch_external_libraries
#this is not working ATM, do it manually after script runs. Blargh.
composer install --no-dev
composer update
#now install  extensions via git that don't require additional steps
repoDir=https://gerrit.wikimedia.org/r/p/mediawiki/extensions/
echo "Installing extensions in $releaseDir/extensions"
echo "from" $repoDir
echo "installing.."
#this is the long list of extensions - CamelCase, separated by a space
for extension in Arrays CategoryTree CirrusSearch Cite cldr ContributionScores CSS DataTransfer Echo ExternalData Flow Gadgets Graph googleAnalytics HeaderTabs InputBox Interwiki JsonConfig LdapAuthentication Lockdown MobileFrontend MultiBoilerplate MultimediaViewer NoTitle Nuke ParserFunctions Renameuser ReplaceText Scribunto SemanticCompoundQueries SemanticDrilldown SemanticForms SemanticFormsInputs SemanticInternalObjects SpamBlacklist SyntaxHighlight_GeSHi TemplateData TextExtracts Thanks TitleKey UniversalLanguageSelector UploadWizard Variables WatchSubpages WhoIsWatching WikiEditor HitCounters
do
git clone "$repoDir$extension.git" "extensions/$extension"
FILE=composer.json

if [ -f $FILE ];
then
   composer install
   composer update
else
   echo "File $FILE does not exist. Skipping composer install"
fi
done
cd ..
echo "Done installing vanilla extensions"
#now we're going to install the few that have submodules
echo "Installing extensions with submodules in /extensions"
echo "installing.."
cd $releaseDir/extensions/
#Widgets
git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/Widgets.git
cd Widgets
git submodule init
git submodule update
cd ..
#VisualEditor
git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git
cd VisualEditor
git submodule update --init
cd ..
#Elastica
##Not used ATM
#git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/Elastica.git
#cd elastica
#git submodule init
#git submodule update
#cd..
#let's go back up and take care of the few installed via composer
cd ..
echo "Done installing extensions with submodules!"
echo "Installing extensions via composer"
echo "installing..."
for extension in image-map semantic-media-wiki semantic-maps maps semantic-result-formats parser-hooks semantic-watchlist
do
#this gets the latest 'dev' version of each extension
composer require mediawiki/"$extension" @dev --update-no-dev
done
#Validator
cd extensions/
cd Validator
composer install
cd ..
#how about those  extensions that live in other corners of the web?
#ExternalLinks
git clone https://github.com/roman-1983/mediawiki-ExternalLinks.git ExternalLinks
#SemanticFormsSelect
git clone https://code.google.com/p/semanticformsselect/ SemanticFormsSelect
#lets go get the Vector skin - make sure to initialize in LocalSettings.php!
cd ..
cd skins
git clone https://gerrit.wikimedia.org/r/p/mediawiki/skins/Vector.git
echo "Vector Installed!"
#Foreground too
git clone https://github.com/thingles/foreground.git
echo "Foreground Installed!"
#now get parsoid all setup - in the ~/ directory
cd ../../
git clone https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid
cd parsoid
npm install
#for some reason node-gyp always fails for me. Let's install it manually
#NOTE: Seems like running of node-gyp requires root access
#NOTE: Maybe node-gyp is no longer needed?
npm install node-gyp
#
#Add some fancy script to create the /log directory
mkdir log
#
echo "Parsoid Installed!"
cat << "EOF"
 __  __          _ _     __        ___ _    _
|  \/  | ___  __| (_) __ \ \      / (_) | _(_)
| |\/| |/ _ \/ _` | |/ _` \ \ /\ / /| | |/ / |
| |  | |  __/ (_| | | (_| |\ V  V / | |   <| |
|_|  |_|\___|\__,_|_|\__,_| \_/\_/  |_|_|\_\_|
 ___           _        _ _          _ _
|_ _|_ __  ___| |_ __ _| | | ___  __| | |
 | || '_ \/ __| __/ _` | | |/ _ \/ _` | |
 | || | | \__ \ || (_| | | |  __/ (_| |_|
|___|_| |_|___/\__\__,_|_|_|\___|\__,_(_)   
EOF                                               
