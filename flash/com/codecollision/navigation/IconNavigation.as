/*
     File:	IconNavigation.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	May 09, 2007
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision.navigation {
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	
	// custom
	import com.codecollision.Animate;
	import com.codecollision.ContentLoader;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class IconNavigation
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class IconNavigation {
		
		// class references
		private var classRef:Object;
		
		// icon container
		private var iconNavContainer:Sprite;
		private var iconBarAnimation:Animate;
		
		// icon sprites
		private var logIcon:Sprite;
		private var projectsIcon:Sprite;
		private var sourceIcon:Sprite;
		private var aboutIcon:Sprite;
		
		// icon hitArea sprites
		private var logHit:Sprite;
		private var projectsHit:Sprite;
		private var sourceHit:Sprite;
		private var aboutHit:Sprite;
		
		// icon loaders
		private var logLoader:ContentLoader;
		private var projectLoader:ContentLoader;
		private var sourceLoader:ContentLoader;
		private var aboutLoader:ContentLoader;
		
		// icon animations
		private var logAnimation:Animate;
		private var projectsAnimation:Animate;
		private var sourceAnimation:Animate;
		private var aboutAnimation:Animate;
		
		// properties
		private var mediaSource:String;
		private var iconsLoaded:uint;
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		IconNavigation constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function IconNavigation(classRef:Object) {
			this.classRef = classRef;
			
			iconNavContainer = new Sprite();	// icon container
			
			// create sprites
			logIcon = new Sprite();
			projectsIcon = new Sprite();
			sourceIcon = new Sprite();
			aboutIcon = new Sprite();
			
			// icon hitArea sprites
			logHit = new Sprite();
			projectsHit = new Sprite();
			sourceHit = new Sprite();
			aboutHit = new Sprite();
		
			// icon container
			iconNavContainer.x = 905;
			iconNavContainer.y = 161;
			
			// properties
			iconsLoaded = 0;
		}
		public function initialize():void {
			
			mediaSource = classRef.siteConfig.MEDIA_SOURCE;
			
			// load assets and draw icon navigation
			loadIcons();
		}
			
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getContainer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	
		public function getContainer():Sprite {
			return iconNavContainer;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		loadIcons
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function loadIcons():void {
			
			// draw icon hit areas
			drawHitAreas();
			
			// load log icon
			logLoader = new ContentLoader(mediaSource + "icon_log.png", "regular", activateIconBar);
			logIcon.hitArea = logHit;
			logHit.buttonMode = true;
			logIcon.x = 20;
			logIcon.y = 0;
			logIcon.alpha = 0;
			iconNavContainer.addChild(logIcon);
			iconNavContainer.addChild(logHit);
			logIcon.addChild(logLoader);
			
			// load project icon
			projectLoader = new ContentLoader(mediaSource + "icon_projects.png", "regular", activateIconBar);
			projectsIcon.hitArea = projectsHit;
			projectsHit.buttonMode = true;
			projectsIcon.x = 20;
			projectsIcon.y = 83;
			projectsIcon.alpha = 0;
			projectsHit.y = 83;
			iconNavContainer.addChild(projectsIcon);
			iconNavContainer.addChild(projectsHit);
			projectsIcon.addChild(projectLoader);
		
			// load source icon
			sourceLoader = new ContentLoader(mediaSource + "icon_services.png", "regular", activateIconBar);
			sourceIcon.hitArea = sourceHit;
			sourceHit.buttonMode = true;
			sourceIcon.x = 20;
			sourceIcon.y = 170;
			sourceIcon.alpha = 0;
			sourceHit.y = 170;
			iconNavContainer.addChild(sourceIcon);
			iconNavContainer.addChild(sourceHit);
			sourceIcon.addChild(sourceLoader);
			
			// load about icon - call activateIconBar() when about icon loaded
			aboutLoader = new ContentLoader(mediaSource + "icon_about.png", "regular", activateIconBar);
			aboutIcon.hitArea = aboutHit;
			aboutHit.buttonMode = true;
			aboutIcon.x = 20;
			aboutIcon.y = 255;
			aboutIcon.alpha = 0;
			aboutHit.y = 255;
			iconNavContainer.addChild(aboutIcon);
			iconNavContainer.addChild(aboutHit);
			aboutIcon.addChild(aboutLoader);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawHitAreas
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawHitAreas():void {
			
			// draw icon hitAreas			
			// log
			logHit.graphics.beginFill(0xffffff, 0);
			logHit.graphics.drawRect(0, 0, 58, 62);
			logHit.graphics.endFill();
			// projects
			projectsHit.graphics.beginFill(0xffffff, 0);
			projectsHit.graphics.drawCircle(32, 35, 35);
			projectsHit.graphics.endFill();
			projectsHit.graphics.beginFill(0xffffff, 0);
			projectsHit.graphics.drawRect(45, 5, 65, 30);
			projectsHit.graphics.endFill();
			// source
			sourceHit.graphics.beginFill(0xffffff, 0);
			sourceHit.graphics.drawRect(3, 0, 55, 73);
			sourceHit.graphics.endFill();
			sourceHit.graphics.beginFill(0xffffff, 0);
			sourceHit.graphics.drawRect(50, 5, 60, 25);
			sourceHit.graphics.endFill();
			// about
			aboutHit.graphics.beginFill(0xffffff, 0);
			aboutHit.graphics.drawCircle(35, 35, 35);
			aboutHit.graphics.endFill();
			aboutHit.graphics.beginFill(0xffffff, 0);
			aboutHit.graphics.drawRect(40, 2, 45, 30);
			aboutHit.graphics.endFill();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		activateIconBar
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function activateIconBar():void {
			
			iconsLoaded ++;			
			if (iconsLoaded != 4) return;
			
			// create mouse event listeners
			logHit.addEventListener(MouseEvent.CLICK, onLogClick);
			logHit.addEventListener(MouseEvent.ROLL_OVER, onLogOver);
			logHit.addEventListener(MouseEvent.ROLL_OUT, onLogOut);
			
			projectsHit.addEventListener(MouseEvent.CLICK, onProjectsClick);
			projectsHit.addEventListener(MouseEvent.ROLL_OVER, onProjectsOver);
			projectsHit.addEventListener(MouseEvent.ROLL_OUT, onProjectsOut);
			
			sourceHit.addEventListener(MouseEvent.CLICK, onSourceClick);
			sourceHit.addEventListener(MouseEvent.ROLL_OVER, onSourceOver);
			sourceHit.addEventListener(MouseEvent.ROLL_OUT, onSourceOut);
			
			aboutHit.addEventListener(MouseEvent.CLICK, onAboutClick);
			aboutHit.addEventListener(MouseEvent.ROLL_OVER, onAboutOver);
			aboutHit.addEventListener(MouseEvent.ROLL_OUT, onAboutOut);
			
			
			// start iconBar entrance animation
			var i:Number = 20;
			var delay:Number = 5;
			
			Animate.animateAlpha(logIcon, .8, 20, null, i, "easeOut", "ping");
			Animate.animatePosition(logIcon, -20, 0, 10, true, "easeOutBounce", null, i);
			Animate.animateBlur(logIcon, 20, 4, -20, -4, 12, 4, "easeOutExpo", null, i);
			
			i += delay;
			Animate.animateAlpha(projectsIcon, .8, 20, null, i, "easeOut", "ping");
			Animate.animatePosition(projectsIcon, -20, 0, 10, true, "easeOutBounce", null, i);
			Animate.animateBlur(projectsIcon, 20, 4, -20, -4, 12, 4, "easeOutExpo", null, i);
			
			i += delay;
			Animate.animateAlpha(sourceIcon, .8, 20, null, i, "easeOut", "ping");
			Animate.animatePosition(sourceIcon, -20, 0, 10, true, "easeOutBounce", null, i);
			Animate.animateBlur(sourceIcon, 20, 4, -20, -4, 12, 4, "easeOutExpo", null, i);
			
			i += delay;
			Animate.animateAlpha(aboutIcon, .8, 20, null, i, "easeOut", "ping");
			Animate.animatePosition(aboutIcon, -20, 0, 10, true, "easeOutBounce", null, i);
			Animate.animateBlur(aboutIcon, 20, 4, -20, -4, 12, 4, "easeOutExpo", null, i);
			
		}
					
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		icon buttons mouse events
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		
		// log events
		private function onLogClick(Event:MouseEvent):void {		
			classRef.navigate.changeAddress("/");
		}
		private function onLogOver(Event:MouseEvent):void {		
			Animate.animatePosition(logIcon, -10, logIcon.y, 4, false, "easeOut", null, 0, "ping");
			Animate.animateBlur(logIcon, 22, 4, -22, -4, 20, 6, "easeOutExpo");
			Animate.animateAlpha(logIcon, 1, 20, null, 0, "easeOut");
		}
		private function onLogOut(Event:MouseEvent):void {
			Animate.animatePosition(logIcon, 0, logIcon.y, 4);
			Animate.animateAlpha(logIcon, .8, 20, null, 0, "easeOut");
		}
 
		// projects events
		private function onProjectsClick(Event:MouseEvent):void {		
			classRef.navigate.changeAddress("/page/projects");
		}
		private function onProjectsOver(Event:MouseEvent):void {		
			Animate.animatePosition(projectsIcon, -10, projectsIcon.y, 4, false, "easeOut", null, 0, "ping");
			Animate.animateBlur(projectsIcon, 22, 4, -22, -4, 20, 6, "easeOutExpo");
			Animate.animateAlpha(projectsIcon, 1, 20, null, 0, "easeOut");
		}
		private function onProjectsOut(Event:MouseEvent):void {
			Animate.animatePosition(projectsIcon, 0, projectsIcon.y, 4);
			Animate.animateAlpha(projectsIcon, .8, 20, null, 0, "easeOut");
		}
		
		// services events
		private function onSourceClick(Event:MouseEvent):void {		
			classRef.navigate.changeAddress("/page/services");	
		}
		private function onSourceOver(Event:MouseEvent):void {		
			Animate.animatePosition(sourceIcon, -10, sourceIcon.y, 4, false, "easeOut", null, 0, "ping");
			Animate.animateBlur(sourceIcon, 22, 4, -22, -4, 20, 6, "easeOutExpo");
			Animate.animateAlpha(sourceIcon, 1, 20, null, 0, "easeOut");
		}
		private function onSourceOut(Event:MouseEvent):void {
			Animate.animatePosition(sourceIcon, 0, sourceIcon.y, 4);
			Animate.animateAlpha(sourceIcon, .8, 20, null, 0, "easeOut");
		}

		// about events
		private function onAboutClick(Event:MouseEvent):void {		
			classRef.navigate.changeAddress("/page/about");	
		}
		private function onAboutOver(Event:MouseEvent):void {		
			Animate.animatePosition(aboutIcon, -10, aboutIcon.y, 4, false, "easeOut", null, 0, "ping");
			Animate.animateBlur(aboutIcon, 22, 4, -22, -4, 20, 6, "easeOutExpo");
			Animate.animateAlpha(aboutIcon, 1, 20, null, 0, "easeOut");
		}
		private function onAboutOut(Event:MouseEvent):void {
			Animate.animatePosition(aboutIcon, 0, aboutIcon.y, 4);
			Animate.animateAlpha(aboutIcon, .8, 20, null, 0, "easeOut");
		}
	}
}