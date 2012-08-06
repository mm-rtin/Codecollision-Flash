/*
     File:	PageEvent.as
 Revision:	0.0.1
  Purpose:	Custom Event for handling events for PageNavigation class
  Authors:	
  Created:	June 13, 2008
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision.navigation.page {
	
	import flash.events.*;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class PageEvent
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class PageEvent extends Event {
		
		// PageEvent type constants
		public static const PAGE_CHANGED:String = "pageChanged";
		
		// PageEvent parameters
		public var ID:String;			// ID of calling PageNavigation
		public var page:uint;			// new page number		
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		PageEvent constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function PageEvent(	type:String,
									bubbles:Boolean = false,
									cancelable:Boolean = false,
									page:uint = 0,
									ID:String = null) {
			
			super(type, bubbles, cancelable);	// pass Event parameters to superclass
			this.ID = ID;					
			this.page = page;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		clone: custom events must override clone
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public override function clone():Event {
			return new PageEvent(type, bubbles, cancelable, page, ID);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		toString: custom events must override toString
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public override function toString():String {
			return formatToString("PageEvent", "type", "bubbles", "cancelable", "eventPhase", "page", "ID");
		}
		
	}
}