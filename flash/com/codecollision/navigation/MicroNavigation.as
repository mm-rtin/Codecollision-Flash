/*
     File:	MicroNavigation.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	May 17, 2008
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision.navigation {

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	// custom
	import com.codecollision.Animate;
	import com.codecollision.ContentLoader;

	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class MicroNavigation
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class MicroNavigation {
		
		// class references
		private var classRef:Object;
		
		// containers
		private var microNavContainer:Sprite;
		private var microIcons:Sprite;
		
		// iconMenu sprites
		private var contactIcon:Sprite;
		private var gamesIcon:Sprite;
		private var sourceIcon:Sprite;
		
		// iconMenu loaders
		private var contactLoader:ContentLoader;
		private var gamesLoader:ContentLoader;
		private var sourceLoader:ContentLoader;
		
		private var contactHoverLoader:ContentLoader;
		private var gamesHoverLoader:ContentLoader;
		private var sourceHoverLoader:ContentLoader;
		
		// icon animations
		private var contactAnimation:Animate;
		private var gamesAnimation:Animate;
		private var sourceAnimation:Animate;
		
		private var contactHoverAnimation:Animate;
		private var gamesHoverAnimation:Animate;
		private var sourceHoverAnimation:Animate;
		
		// properties
		private var mediaSource:String;
		private var iconsLoaded:uint;
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		MicroNavigation constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function MicroNavigation(classRef:Object) {
			this.classRef = classRef;		
			
			// containers
			microNavContainer = new Sprite();
			microIcons = new Sprite();
			
			// iconMenu sprites
			contactIcon = new Sprite();
			gamesIcon = new Sprite();
			sourceIcon = new Sprite();
			
			// properties
			iconsLoaded = 0;
			
			// set container position
			microNavContainer.x = 783;
			microNavContainer.y = 155;
			
			// set subNavIcons position
			microIcons.x = 0;
			microIcons.y = 0;
			
			microNavContainer.addChild(microIcons)	// child 1	
		}
		public function initialize():void {
			
			mediaSource = classRef.siteConfig.MEDIA_SOURCE;
			
			// load IconMenu
			loadIconMenu();
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getContainer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	
		public function getContainer():Sprite {
			return microNavContainer;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		loadIconMenu: loads subNav icon menu
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function loadIconMenu():void {
			
			// load contact icon
			contactLoader = new ContentLoader(mediaSource + "micro_contact.png", "regular", activateIconMenu);
			// load contact hover
			contactHoverLoader = new ContentLoader(mediaSource + "micro_contact_over.png");
			contactHoverLoader.alpha = 0;
			contactHoverLoader.x = 0;
			contactHoverLoader.y = 0;
			
			contactIcon.buttonMode = true;
			contactIcon.alpha = 0;
			contactIcon.x = 0;
			contactIcon.y = 0;
			
			// load games icon
			gamesLoader = new ContentLoader(mediaSource + "micro_games.png", "regular", activateIconMenu);
			// load games hover
			gamesHoverLoader = new ContentLoader(mediaSource + "micro_games_over.png");
			gamesHoverLoader.alpha = 0;
			gamesHoverLoader.x = 0;
			gamesHoverLoader.y = 0;

			gamesIcon.buttonMode = true;
			gamesIcon.alpha = 0;
			gamesIcon.x = 0;
			gamesIcon.y = 32;
						
			// load source icon
			sourceLoader = new ContentLoader(mediaSource + "micro_source.png", "regular", activateIconMenu);
			// load source hover
			sourceHoverLoader = new ContentLoader(mediaSource + "micro_source_over.png");
			sourceHoverLoader.alpha = 0;
			sourceHoverLoader.x = 0;
			sourceHoverLoader.y = 0;
			
			sourceIcon.buttonMode = true;
			sourceIcon.alpha = 0;
			sourceIcon.x = -2;
			sourceIcon.y = 60;
			
			// eventListeners
			contactIcon.addEventListener(MouseEvent.CLICK, onContactClick);
			contactIcon.addEventListener(MouseEvent.ROLL_OVER, onContactOver);
			contactIcon.addEventListener(MouseEvent.ROLL_OUT, onContactOut);
			
			gamesIcon.addEventListener(MouseEvent.CLICK, onGamesClick);
			gamesIcon.addEventListener(MouseEvent.ROLL_OVER, onGamesOver);
			gamesIcon.addEventListener(MouseEvent.ROLL_OUT, onGamesOut);
			
			sourceIcon.addEventListener(MouseEvent.CLICK, onSourceClick);
			sourceIcon.addEventListener(MouseEvent.ROLL_OVER, onSourceOver);
			sourceIcon.addEventListener(MouseEvent.ROLL_OUT, onSourceOut);
			
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		activateIconMenu: start display animation, and add to display list
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function activateIconMenu():void {
			
			iconsLoaded++;
			if (iconsLoaded != 3) return;
			
			// contact
			contactIcon.addChild(contactLoader);
			contactIcon.addChild(contactHoverLoader);
			microIcons.addChild(contactIcon);
			
			// games
			gamesIcon.addChild(gamesLoader);
			gamesIcon.addChild(gamesHoverLoader);
			microIcons.addChild(gamesIcon);
			
			// source
			sourceIcon.addChild(sourceLoader);
			sourceIcon.addChild(sourceHoverLoader);
			microIcons.addChild(sourceIcon);
			
			// animate
			Animate.animateAlpha(contactIcon, 1, 30, null, 0);
			Animate.animateAlpha(gamesIcon, 1, 30, null, 10);
			Animate.animateAlpha(sourceIcon, 1, 30, null, 20);
		}
		
		// contact events
		private function onContactClick(Event:MouseEvent):void {
			classRef.navigate.changeAddress("/page/contact");
		}
		private function onContactOver(Event:MouseEvent):void {
			Animate.animateAlpha(contactHoverLoader, 1, 5, null, 0, "easeOut", "beep");
		}
		private function onContactOut(Event:MouseEvent):void {
			Animate.animateAlpha(contactHoverLoader, 0, 20);	
		}
		
		// games events
		private function onGamesClick(Event:MouseEvent):void {
			classRef.navigate.changeAddress("/log/category/gaming");
		}
		private function onGamesOver(Event:MouseEvent):void {
			Animate.animateAlpha(gamesHoverLoader, 1, 5, null, 0, "easeOut", "beep");
		}
		private function onGamesOut(Event:MouseEvent):void {
			Animate.animateAlpha(gamesHoverLoader, 0, 20);
		}
		
		// source events
		private function onSourceClick(Event:MouseEvent):void {		
		}
		private function onSourceOver(Event:MouseEvent):void {
			Animate.animateAlpha(sourceHoverLoader, 1, 5, null, 0, "easeOut", "beep");
		}
		private function onSourceOut(Event:MouseEvent):void {
			Animate.animateAlpha(sourceHoverLoader, 0, 20);	
		}

	}
}