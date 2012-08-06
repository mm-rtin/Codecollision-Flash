/*
     File:	Tooltip.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	May 21, 2008
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision.graphics {
	
	import flash.display.Sprite;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.display.DisplayObject;
	
	// custom
	import com.codecollision.Animate;

	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Tooltip
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Tooltip {
		
		private var classRef:Object;
		
		// sprites
		private var tooltipContainer:Sprite;
		
		// properties
		private var currentSource:DisplayObject;	// source generating tooltip
		private var currentTooltiptarget:Sprite;	// target to add container as child
		
		// constants
		private const HOR_PAD:uint = 6;
		private const MAX_TIP_LENGTH:uint = 22;
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Tooltip constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function Tooltip(classRef:Object) {
			this.classRef = classRef;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		close: remove tooltip
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function close():void {
			
			// remove tooltipContainer
			try {
				Animate.stopAnimation(currentTooltiptarget.getChildByName("tooltip"), "alpha");
				currentTooltiptarget.removeChild(tooltipContainer);
			} catch (error:Error) {
			}
			
			// reset current source, target
			currentSource = null;
			currentTooltiptarget = null;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		newTooltip: create new tooltip
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function newTooltip(source:DisplayObject, tooltipTarget:Sprite, text:String, position:String = "right", yOffset:int = 0):Sprite {
			
			if (currentSource != source) {
				
				close();	// close any open tooltips
				
				// container
				tooltipContainer = new Sprite();
			
				// set properties
				currentSource = source;
				currentTooltiptarget = tooltipTarget;
				
				// tooltip text
				var tooltipText:TextField = new TextField();
				tooltipText = drawText(text);
				tooltipText.x = 2;
	
				// tooltip graphic
				var window:Sprite = new Sprite();
				window = drawTooltipBG(tooltipText.width + 4, tooltipText.height);

				// container properties
				tooltipContainer.name = "tooltip";
				tooltipContainer.alpha = 0;
				tooltipContainer.y = yOffset;
				
				// add to display list
				tooltipContainer.addChildAt(window, 0);			// child 0
				tooltipContainer.addChildAt(tooltipText, 1);	// child 1
				tooltipTarget.addChild(tooltipContainer);		// add container to tooltipTarget
				
				// set position
				switch (position) {
					case "right":
						tooltipContainer.x = Math.round(source.width + source.x) + HOR_PAD;
					break;
					
					case "left":
						tooltipContainer.x = Math.round(source.x - tooltipContainer.width) - HOR_PAD;
					break;
					
					case "above":
					break;
					
					case "below":
					break;
				}
				tooltipContainer.y = yOffset;
			}
			
			// animate
			Animate.animateAlpha(tooltipTarget.getChildByName("tooltip"), 1, 10, null, 10, "easeOut", "link");
			
			return tooltipContainer;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawTooltip: draw window sprite
		@param width - width of window
		@param height - height of window
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawTooltipBG(width:uint, height:uint):Sprite {
			
			var window:Sprite = new Sprite();
			
			//window.graphics.lineStyle(1, 0xffffff, .5);
			window.graphics.beginFill(0x668a88, .2);
			Draw.drawRoundRect(window, width, height);
			window.graphics.endFill();
			
			return window;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawText: create tooltip text field
		@param text - tooltip text
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawText(text:String):TextField {
			
			// truncate text
			if (text.length > MAX_TIP_LENGTH) {
				text = text.slice(0, MAX_TIP_LENGTH) + "..." + text.slice(-4);
			}
			
			// get stylesheet
			var style:StyleSheet = Styles.getStyle();
			
			// text field
			var tooltipText:TextField = new TextField();
			tooltipText.embedFonts = true;
			tooltipText.selectable = false;
			tooltipText.autoSize = TextFieldAutoSize.LEFT;
			tooltipText.styleSheet = style;
			tooltipText.htmlText = "<span class='tooltip'>" + text + "</span>";
			
			return tooltipText;
		}
		
	}
}