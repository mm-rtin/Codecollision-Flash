/*
     File:	Input.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	June 03, 2008
   Edited: 
    Notes:	
Functions:

*/

package com.codecollision.graphics {

	import flash.text.*
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	// custom
	import com.codecollision.Animate;
	import com.codecollision.Sounds;

	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Input
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Input {
		
		// properties
		private static var inputNumber:uint = 0;
		
		// timers
		private static var disabledTimer:Timer = new Timer(1000);
		private static var disabledButton:Sprite = new Sprite();
		private static var disabledTime:uint = 0;
		
		public static const DISABLED_TIME:uint = 2;
		private static const INACTIVE_ALPHA:Number = .7;
		private static const ACTIVE_ALPHA:Number = 1;
		
		// button properties
		private static const BUTTON_HPAD:uint = 60;
		private static const BUTTON_VPAD:uint = 0;
	
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawField: draws textField input and returns input sprite
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawField(	width:uint,
											height:uint,
											title:String,
											style:String,
											maxChars:uint,
											input_x:uint = 0,
											input_y:uint = 0,
											multiline:Boolean = false):Sprite {
			
			inputNumber++;
			
			var fieldContainer:Sprite = new Sprite();
			var field:Sprite = new Sprite();
			
			/* field box
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			field = Draw.drawFieldBox(width, height);
			field.name = "field";
			field.alpha = INACTIVE_ALPHA;
            
			/* field title
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var fieldTitle:TextField = new TextField();
			fieldTitle = drawText(title, "fieldTitle", false, 0, TextFieldAutoSize.LEFT);
			// calculate y offset to center title
			var y:Number = (!multiline) ? (height - fieldTitle.height) / 2 : -1;
			fieldTitle.x = 2;
			fieldTitle.y = y;
				
			/* input field
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// text format
			var inputFormat:TextFormat = new TextFormat();
			
			// get stylesheet
			var styleSheet:StyleSheet = Styles.getStyle();
			var styleClass:Object = styleSheet.getStyle("." + style);
            inputFormat = styleSheet.transform(styleClass);
            
			// input text field
			var inputText:TextField = new TextField();
			inputText.tabIndex = inputNumber;
			inputText.name = "text";
			inputText.embedFonts = true;
			inputText.selectable = true;
			inputText.wordWrap = true;
			if (multiline) inputText.multiline = true;
			inputText.type = TextFieldType.INPUT;
			inputText.width = width;
			inputText.height = height;
			if (maxChars != 0) inputText.maxChars = maxChars;
			inputText.defaultTextFormat = inputFormat;
			inputText.x = input_x;
			inputText.y = input_y;
			
			fieldContainer.addChild(fieldTitle);	// child 0
			fieldContainer.addChild(field);			// child 1
			fieldContainer.addChild(inputText);		// child 2
			
			// events
			inputText.addEventListener(FocusEvent.FOCUS_IN, onFieldFocus);
			inputText.addEventListener(FocusEvent.FOCUS_OUT, onFieldUnfocus);
			
			return fieldContainer;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		focus: focus field
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function focus(container:Sprite):void {
			var field:Sprite = container.getChildByName("field") as Sprite;
			Animate.animateAlpha(field, ACTIVE_ALPHA, 10, null, 0, "easeOut", "tap");
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		unfocus: unfocus field
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function unfocus(container:Sprite):void {
			var field:Sprite = container.getChildByName("field") as Sprite;
			Animate.animateAlpha(field, INACTIVE_ALPHA, 10, null, 0, "easeOut");
		}		
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onFieldFocus: set alpha of field
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function onFieldFocus(event:FocusEvent):void {
			var container:Sprite = event.target.parent as Sprite;
			Input.focus(container);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onFieldUnfocus: set alpha of field
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function onFieldUnfocus(event:FocusEvent):void {
			var container:Sprite = event.target.parent as Sprite;
						
			if (event.target.text == "") {
				Input.unfocus(container);
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawButton: draw button for input fields
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawButton(clickFunction:Function, addDisabled:Boolean = false):Sprite {
			
			var button:Sprite = new Sprite();
			button.alpha = INACTIVE_ALPHA;
			
			/* title
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var title:TextField = new TextField();
			title = drawText("SEND", "buttonTitle", false, 0, TextFieldAutoSize.LEFT);
			title.name = "title";
								
			/* button bg
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var buttonBG:Sprite = new Sprite();
			buttonBG = Draw.drawFieldBox(title.width + BUTTON_HPAD, title.height + BUTTON_VPAD, null);
			buttonBG.name = "buttonBG";
			// calculate title position
			title.x = Math.round((buttonBG.width - title.width) / 2);
			title.y = Math.round((buttonBG.height - title.height) / 2);
			
			/* disabled title
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var disabledTitle:TextField = drawText(" ", "buttonTitle", false, 0, TextFieldAutoSize.LEFT);
			disabledTitle.name = "disabledTitle";
			disabledTitle.alpha = 0;
			disabledTitle.visible = false;
			// calculate disabled title position
			disabledTitle.x = Math.round((disabledTitle.width + BUTTON_HPAD - disabledTitle.width) / 2);
			disabledTitle.y = Math.round((buttonBG.height - disabledTitle.height) / 2);

			// add to button
			button.addChild(buttonBG);							// child 0
			button.addChild(title);								// child 1
			if (addDisabled) button.addChild(disabledTitle);	// child 2
			
			button.mouseEnabled = true;
			button.buttonMode = true;
			button.mouseChildren = false;
			
			/* submit events
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			button.addEventListener(MouseEvent.CLICK, function(Event:MouseEvent):void {
				Sounds.playSound("ping");
				clickFunction(Event);
			});
			button.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			button.addEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			
			return button;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onButtonOver: over event for button
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function onButtonOver(Event:MouseEvent):void {
			var button:Sprite = Event.target as Sprite;
			Animate.animateAlpha(button, ACTIVE_ALPHA, 10, null, 0, "easeOut", "tap");
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onButtonOut: out event for button
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function onButtonOut(Event:MouseEvent):void {
			var button:Sprite = Event.target as Sprite;
			Animate.animateAlpha(button, INACTIVE_ALPHA, 10, null, 0, "easeOut");
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		disableButton: disables button, replaces text with count down timer. Restores button at timer end
		@param button - button created with drawButton() to disable
		@param time - seconds to disabled button
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function disableButton(button:Sprite):void {
			
			Input.disabledButton = button	// save disableButton
			
			// start timer
			if (disabledTime == 0) {
				// add 1 second since enter animation is behind by 1 second
				disabledTime = Input.DISABLED_TIME + 1;
				disabledTimer.addEventListener(TimerEvent.TIMER, onDisabledTick);
			}
			
			// reset timer for disabled animation
			disabledTimer.reset();
			disabledTimer.start();
		}		
		private static function onDisabledTick(Event:TimerEvent):void {
			
			// get child references inside button sprite
			var buttonBG:Sprite = disabledButton.getChildByName("buttonBG") as Sprite;
			var title:TextField = disabledButton.getChildByName("title") as TextField;
			var disabledText:TextField = disabledButton.getChildByName("disabledTitle") as TextField;
		
			disabledTime --;
			disabledText.htmlText = "<span class='buttonTitle'>DISABLED: " + disabledTime + "</span>";

			// first count - start enter animation
			if (disabledTimer.currentCount == 1) {
				// swap visibility of submitText and disabledText and resize submit button
				Animate.animateSize(buttonBG, disabledText.x + disabledText.width + (Input.BUTTON_HPAD / 2), disabledButton.height, 30, false, "easeOut", null, 0, Draw.drawFieldBox);
				Animate.animateAlpha(title, 0, 10, null, 5);
				Animate.animateAlpha(disabledText, 1, 10, null, 30);
			}
			
			// begin return to original button visuals 
			if (disabledTime == 1) {
				Animate.animateAlpha(disabledText, 0, 20, null, 0);
				Animate.animateAlpha(title, 1, 20, null, 10);
				Animate.animateSize(buttonBG, title.x + title.width + (Input.BUTTON_HPAD / 2), disabledButton.height, 30, false, "easeOut", null, 10, Draw.drawFieldBox);
			}
			
			// stop timer
			if (disabledTime == 0) {
				disabledTimer.stop();
				disabledTimer.reset();
				disabledTimer.removeEventListener(TimerEvent.TIMER, onDisabledTick);
			}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		isDisabled: checks disabled status of button
		@param button - button created with drawButton() to check status
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function isDisabled():Boolean {
			return (disabledTime > 0) ? true : false;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawText: create text field, text format for field title
		@param text - text string to display in textField
		@param textClass - CSS class to use from Global styles
		@param antiAlias - true = antiAlias text
		@param width - set width manually, use with alignment
		@param align - set alignment position
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function drawText(text:String, textClass:String, antiAlias:Boolean = true, width:uint = 0, align:String = TextFieldAutoSize.LEFT):TextField {
		
			// text field
			var titleText:TextField = new TextField();
			titleText.embedFonts = true;
			titleText.autoSize = align;
			if (width) titleText.width = width;
			titleText.styleSheet = Styles.getStyle();
			titleText.selectable = false;
			
			// antialiasing properties
			if (antiAlias) {
				titleText.antiAliasType = AntiAliasType.ADVANCED;
				titleText.thickness = 200;
				titleText.sharpness = 100;
			} else {
				titleText.gridFitType = GridFitType.PIXEL;
			}
			
			titleText.htmlText = "<span class='" + textClass + "'>" + text + "</span>";
			
			return titleText;
		}
			
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		newMessage: create message box
		@param target - sprite to draw message box over and centered
		@param message - message text
		@param stylesheet - style to apply to message text
		@param hold - keep message box open
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function newMessage(target:Sprite, message:String, hold:Boolean = false, fadeText:TextField = null):void {
			
			// remove old message box			
			try {
				var prevMessageBox:Sprite = target.getChildByName("messageBox") as Sprite;
				target.removeChild(prevMessageBox);
			} catch (error:Error) {
			}
			
			// draw messageBox
			var messageBox:Sprite = new Sprite();
			messageBox = Input.drawMessageBox(message);
			messageBox.name = "messageBox";
			
			// messageBox properties
			messageBox.alpha = 0;
			messageBox.x = Math.round((target.width - messageBox.width) / 2);
			messageBox.y = Math.round((target.height - messageBox.height) / 2) + 20;
			
			// animate in
			Animate.animateAlpha(messageBox, 1, 20, null, 0, "easeOut", "zip");
			Animate.animatePosition(messageBox, 0, -20, 20, true, "easeOutBounce"); 
			
			// fade textField
			if (fadeText) {
				fadeText.alpha = .1;
				Animate.animateAlpha(fadeText, 1, 200);
			} 
			
			// animate out
			if (!hold) {
				Animate.animateAlpha(messageBox, 0, 40, null, 80, "easeOut", null, true);
				Animate.animatePosition(messageBox, 0, 20, 35, true, "easeInExpo", null, 80, null, true);
			}
			
			target.addChild(messageBox);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawMessageBox: draw message box with message text
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawMessageBox(message:String):Sprite {
			
			var hPad:uint = 15;
			var vPad:uint = 4;
			
			// messageBox
			var messageBox:Sprite = new Sprite();

			// messageText
			var messageText:TextField = new TextField();
			messageText = drawText(message, "message", false, 0, TextFieldAutoSize.LEFT);
			
			// messageBG
			var messageBG:Sprite = new Sprite();
			messageBG = Draw.drawMessageBox(messageText.width + hPad, messageText.height + vPad);
			
			messageText.x = Math.round((messageBG.width - messageText.width) / 2);
			messageText.y = Math.round((messageBG.height - messageText.height) / 2);
			
			messageBox.addChild(messageBG);
			messageBox.addChild(messageText);
			
			return messageBox;
		}
	}
}