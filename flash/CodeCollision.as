/*
     File:	CodeCollision.as
 Revision:	0.5.0
  Purpose:	
  Authors:	
  Created:	May 05, 2007
   Edited:	May 23, 2008
    Notes:	
Functions:

*/

package {
	
	// import classes
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Stage;

	// custom classes
	import com.codecollision.SiteConfig;
	import com.codecollision.ContentLoader;
	import com.codecollision.graphics.Styles;
	import com.codecollision.graphics.Draw;
	import com.codecollision.graphics.Tooltip;
	import com.codecollision.Animate;
	
	// navigation
	import com.codecollision.navigation.IconNavigation;
	import com.codecollision.navigation.Navigator;
	import com.codecollision.navigation.MicroNavigation;
	import com.codecollision.navigation.SubNavigation;
	
	// content
	import com.codecollision.log.Log;
	import com.codecollision.projects.Projects;
	
	// test
	import flash.system.*;
	import flash.events.KeyboardEvent;

    // metadata
    [SWF(width="988", height="650", backgroundColor="#08151f", frameRate="32")]
    
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class CodeCollision
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class CodeCollision extends Sprite {
		
		// holds site class references
		private var classRef:Object;	
		
		// site classes
		private var siteConfig:SiteConfig;
		private var tooltip:Tooltip;
		private var animate:Animate;
		// navigation classes
		private var navigate:Navigator;
		private var iconNav:IconNavigation;
		private var microNav:MicroNavigation;
		private var subNav:SubNavigation;
		// content classes
		private var log:Log;
		private var projects:Projects;
		
		// container sprites
		private var siteContainer:Sprite;			// entire site container
		private var interfaceContainer:Sprite; 		// container for interface
		private var navigationContainer:Sprite;		// container for navigation elements
		private var contentContainer:Sprite;		// container for site content
		private var backgroundContainer:Sprite;		// container for background
		
		// content sprites
		private var logContainer:Sprite;
		private var projectsContainer:Sprite;
		private var iconNavContainer:Sprite;
		private var microNavContainer:Sprite;
		private var subNavContainer:Sprite;
		private var tooltipContainer:Sprite
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		CodeCollision constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function CodeCollision() {
			
			/** site properties
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.showDefaultContextMenu = true;
			stage.align = StageAlign.TOP_LEFT;	// setup stage
			stage.quality = "high";
			
			/** create sprites
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// container sprites
			siteContainer = new Sprite();
			interfaceContainer = new Sprite();
			navigationContainer = new Sprite();
			contentContainer = new Sprite();
			backgroundContainer = new Sprite();
			
			/** create class objects
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// holds site class references
			classRef = new Object();	
			
			// site classes
			siteConfig = new SiteConfig(siteContainer);
			tooltip = new Tooltip(classRef);
			// navigation classes 
			navigate = new Navigator(classRef);
			iconNav = new IconNavigation(classRef);
			microNav = new MicroNavigation(classRef);
			subNav = new SubNavigation(classRef);
			// content classes
			log = new Log(classRef);
			projects = new Projects(classRef);
			
			/** add class objects to classRef
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// site
			classRef.main = this;
			classRef.stage = stage;
			classRef.siteConfig = siteConfig;
			classRef.tooltip = tooltip;
			// navigation
			classRef.navigate = navigate;
			classRef.iconNav = iconNav;
			classRef.microNav = microNav;
			classRef.subNav = subNav;
			// content
			classRef.log = log;
			classRef.projects = projects;
			
			/** get content containers and set to defined sprite objects
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			backgroundContainer = siteConfig.getContainer();
			logContainer = log.getContainer();
			projectsContainer = projects.getContainer();
			iconNavContainer = iconNav.getContainer();
			microNavContainer = microNav.getContainer();
			subNavContainer = subNav.getContainer();
			
			/** add containers to display list
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// add containers to display list
			this.addChild(backgroundContainer);				// child 0 of root
			this.addChild(siteContainer);					// child 1 of root
			
			// add site elements to siteContainer
			siteContainer.addChild(navigationContainer); 	// child 0 of siteContainer
			siteContainer.addChild(contentContainer); 		// child 1 of siteContainer
			siteContainer.addChild(interfaceContainer); 	// child 2 of siteContainer
			
			// add to navigationContainer
			navigationContainer.addChild(iconNavContainer);	// child 0
			navigationContainer.addChild(subNavContainer);	// child 1
			navigationContainer.addChild(microNavContainer);// child 2
			
			// add to contentContainer
			contentContainer.addChild(logContainer);		// log
			contentContainer.addChild(projectsContainer);	// projects
			
			// position site elements
			backgroundContainer.x = -35;
			siteContainer.x = -35;

			// initialize static classes
			Styles.initialize();
			Draw.initialize();
			Animate.initialize(20);
			
			/** initialize navigation
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// begin site navigation after log has initialized
			log.initialize(navigate.initialize);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		initializeSite
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function initializeSite():void {
			trace(">> initializeSite");
			
			// site
			siteConfig.initialize();
			// navigation
			iconNav.initialize();
			microNav.initialize();
			subNav.initialize();
			// content
			projects.initialize();
		}
	}
}