#MediaWiki Setup Script

This is a basic little shell script used to setup a new MediaWiki
environment. There are better ways to do this I'm sure. I run through
this script with nearly every update. Since we use WMF builds of
MediaWiki I often find myself updating many extensions to keep up with
changes. To make it a little easier to update and add changes (like a
new extension) I use this.

It does a few things 
*Download a specific MediaWiki branch - say
1.25wmf10 
*Download Extensions - some in gerrit, some elseware 
*Install skins
*Download Parsoid
*Install dependencies (composer) and submodules (git) for the MW Core,
 extensions, and Parsoid

