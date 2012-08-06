/*
     File:	Projects.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	Feb 22, 2008
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision.projects {
	
	// import classes
	import flash.display.Sprite;
	
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import com.codecollision.collisionnav.CollisionNav;
	import com.codecollision.collisionnav.engine.Ball;

	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Projects
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Projects {
		
		// class references
		private var classRef:Object;
		
		// containers
		private var projectsContainer:Sprite = new Sprite();
		
		// objects
		private var projects:XML;
		private var collisionNav:CollisionNav;
		
		private var xmlRequest:URLRequest;
		private var xmlLoader:URLLoader;
		
		// constants
		private const XML_FILE:String = "projects.xml";
		
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Projects constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function Projects(classRef:Object) {
			this.classRef = classRef;
		}
		public function initialize():void {
						
			// position projectsContainer
			projectsContainer.y = 150;
			projectsContainer.x = 205;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getContainer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	
		public function getContainer():Sprite {
			return projectsContainer;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		loadProject
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function loadProjects():void {
			
			collisionNav:CollisionNav;
			
			// load projects.xml
			xmlRequest = new URLRequest(XML_FILE);
			xmlLoader = new URLLoader();
			xmlLoader.load(xmlRequest);
			xmlLoader.addEventListener(Event.COMPLETE, xmlCompleteListener);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		close: end projects content, remove sprites and data
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function close():void {
			
			try {
				projectsContainer.removeChildAt(0);	// remove entryContainer sprite
			}
			catch (error:RangeError) {
			}
			
			// remove objects
			collisionNav = null;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		xmlCompleteListener
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function xmlCompleteListener(e:Event):void {
			
			// create XML object from data
			projects = new XML(xmlLoader.data);
			
			// load collisionNav
			collisionNav = new CollisionNav();
			collisionNav.loadNavigation(projects); 	// create ball menu
			
			projectsContainer.addChild(collisionNav);
		}		
	}
}