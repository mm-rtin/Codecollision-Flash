/*
     File:	Navigator.as
 Revision:	0.5.0
  Purpose:	
  Authors:	
  Created:	May 11, 2007
   Edited:	May 21, 2008
    Notes:	
Functions:

*/

package com.codecollision.navigation {
	
	import flash.system.*;
	
	// content classes
	import com.codecollision.log.Log;
	import com.asual.swfaddress.*;
	import com.codecollision.Sounds;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Navigator
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Navigator {
		
		// class references
		private var classRef:Object;
		
		private var currentHash:String;		// hash of current content area
		private var className:String;		// class name of open content

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Navigator constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function Navigator(classRef:Object) {
			this.classRef = classRef;
		}
		public function initialize():void {
			// create SWFAddress eventListener
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, addressChange);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		changeAddress: navigate using SWFAddress setValue()
		@param hash: hash format string (#log/category/name)
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function changeAddress(hash:String):void {
			
			// get current log status, define return conditions
			var logStatus:Object = classRef.log.getLogStatus();
			if (logStatus.postsLoading) return;					// abort if log in process of loading data
			
			// replace all whitespace with '-' (hypen)
			var spacePattern:RegExp = /\s/g;
			var address:String = hash.replace(spacePattern, "-");
			
			SWFAddress.setValue(address);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		addressChange: address bar changed, navigate to new section
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function addressChange(event:SWFAddressEvent):void {
			var address:String = SWFAddress.getValue();
			trace("=============================");
			trace("** Memory: " + Math.round(System.totalMemory / 1048576) + " MB");
			trace(">> addressChange: " + address);
			
			hashNavigation(address);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		hashNavigation: parse hash and navigate content via hash + content class calls
		@param hash: hash format string (#/log/post_title)
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function hashNavigation(hash:String):void {
			trace(">> hashNavigation" + "  current:" + currentHash + "  hash:" + hash);
			
			if (hash == currentHash) return;					// cancel navigation for same hash, SWFAddress already knows its the same?
			if (className != null) classRef[className].close();	// [close currently open section

			currentHash = hash;	// save new hash
			var e:Array = hash.split("/");
			
			// play navigation sound
			Sounds.playSound("tick");
			
			// scroll browser to top of page
			classRef.siteConfig.scroll("top");
			
			/* content logic 
			e =  /log/category/actionscript/1
			    0  1     2         3        4
			    
			e =  /log/post_title
			    0  1     2      
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			switch(e[1]) {
						
				// log section
				case "log":
					className = "log";
					// log home
					if (e.length == 2 || e[3] == "") {
						// virtually set hash to default log page
						currentHash = "/log/category/all/1";	
						classRef.log.loadLog("all");
						break;
					}
					
					// log categories
					switch(e[2]) {
						
						// display posts by category
						case "category":
							
							// page filtering
							var page:uint = classRef.log.checkPage(uint(e[4]), e[3]);
									
							switch(e[3]) {
								
								case "all":
									classRef.log.loadLog("all", e[3], page);
								break;
								
								// filter by category
								default:
									currentHash = "/log/category/" + e[3] + "/" + page;
									classRef.log.loadLog("category", e[3], page);
								break;
							}
						break;
						
						// display post by post_name
						default:
							classRef.log.loadEntry(e[2]);
						break;
					}
					break;
					
				// load page
				case "page":
					
					// special sections
					switch(e[2]) {
						
						/*/ load projects
						case "projects":
							className = "projects";
							classRef.projects.loadProjects();
						break;*/
							
						// display page from database using log class
						default:
							trace(e[2]);
							className = "log";
							classRef.log.loadPage(e[2]);
						break;
					}
				break;
				
				// default case		
				default:
					// virtually set hash to default log page
					currentHash = "/log/category/all/1";	
					classRef.log.loadLog("all");
					className = "log";
				break;
			}
		}
	}
}