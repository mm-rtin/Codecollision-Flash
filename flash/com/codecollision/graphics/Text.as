/*
     File:	Text.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	June 08, 2008
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision.graphics {
	
	import flash.text.*;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Text
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Text {
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawTextField: draw customizable textField
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawTextField(	htmlText:String = null,
												styleSheet:String = "global",
												selectable:Boolean = true,
												antiAlias:Boolean = false,
												width:uint = 0,
												align:String = TextFieldAutoSize.LEFT,
												antiAliasThickness:uint = 200,
												antiAliasSharpness:uint = 100):TextField {
			
			// textField
			var textField:TextField = new TextField();
			textField.embedFonts = true;
			textField.selectable = selectable;
			textField.width = width;
			textField.autoSize = align;
			textField.styleSheet = Styles.getStyle(styleSheet);
			if (htmlText) textField.htmlText = htmlText;
			
			// antialiasing properties
			if (antiAlias) {
				textField.antiAliasType = AntiAliasType.ADVANCED;
				textField.thickness = antiAliasThickness;
				textField.sharpness = antiAliasSharpness;
			} else {
				textField.gridFitType = GridFitType.PIXEL;
			}
			
			return textField;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawMultiLineTextField: draw customizable multiline textField
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawMultiLineTextField(	htmlText:String = null,
														styleSheet:String = "global",
														selectable:Boolean = true,
														antiAlias:Boolean = false,
														width:uint = 0,
														height:uint = 0,
														relativeHeight:Boolean = true,
														antiAliasThickness:uint = 200,
														antiAliasSharpness:uint = 100):TextField {

			// multiline text field
			var textField:TextField = new TextField();
			textField.embedFonts = true;
			textField.wordWrap = true;
			textField.selectable = selectable;
			if (width) textField.width = width;
			textField.styleSheet = Styles.getStyle(styleSheet);
			if (htmlText) textField.htmlText = htmlText;
			if (height && relativeHeight)textField.height = textField.textHeight + height;
			if (height && !relativeHeight)textField.height = height;
			
			// antialiasing properties
			if (antiAlias) {
				textField.antiAliasType = AntiAliasType.ADVANCED;
				textField.thickness = antiAliasThickness;
				textField.sharpness = antiAliasSharpness;
			} else {
				textField.gridFitType = GridFitType.PIXEL;
			}
			
			return textField;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawLink: draws customizable link text
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawEventLink(	text:String = null,
												eventText:String = null,
												styleSheet:String = "global",
												onClick:Function = null,
												onOver:Function = null,
												onOut:Function = null,
												antiAlias:Boolean = false,
												width:uint = 0,
												align:String = TextFieldAutoSize.LEFT,
												antiAliasThickness:uint = 200,
												antiAliasSharpness:uint = 100):TextField {
			
			// draw textField
			var linkText:TextField = drawTextField(	null,
													styleSheet,
													false,
													antiAlias,
													width,
													align,
													antiAliasThickness,
													antiAliasSharpness);
			
			// link text
			if (text) linkText.htmlText = "<a href='Event:" + eventText + "'>" + text + "</a>";
			
			// Events
			if (onClick != null) linkText.addEventListener(TextEvent.LINK, onClick, false, 0, true);
			if (onOver != null) linkText.addEventListener(MouseEvent.ROLL_OVER, onOver, false, 0, true);
			if (onOut != null) linkText.addEventListener(MouseEvent.ROLL_OUT, onOut, false, 0, true);
			
			return linkText;
		}
	}
}