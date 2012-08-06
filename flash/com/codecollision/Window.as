/*
     File:	Window.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	May 21, 2008
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision {
	
	import flash.display.Sprite;

	// custom
	import com.codecollision.Draw;
		
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Window
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Window extends Sprite {
		
		// sprites
		private var windowContainer:Sprite;
		
		// properties
		private var width:uint;
		private var height:uint;
		
		// constants
		private const PADDING:uint = 10;
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Window constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function Window() {
			
			// sprites
			windowContainer = new Sprite();
			
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		createWindow: functionDescription
		@param content - content sprite to insert into window
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function createWindow(content:Sprite):Sprite {
			
			width = content.width;
			height = content.height;
			
			window:Sprite = new Sprite();
			window = drawWindow(width, height);
			
			
			windowContainer.addChild(window);	// child 0
			
			return windowContainer;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawWindow: draw window sprite
		@param width - width of window
		@param height - height of window
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawWindow(width:uint, height:uint):Sprite {
			
			var window:Sprite = new Sprite();
			
			Draw.drawRoundRect(window, width, height);
			
			return window;
		}
	}
}