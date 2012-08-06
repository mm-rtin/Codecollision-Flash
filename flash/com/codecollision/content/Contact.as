/*
     File:	Contact.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	May 21, 2008
   Edited:	June 03, 2008
    Notes:	
Functions:

*/

package com.codecollision.content {
	
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	// custome
	import com.codecollision.graphics.Styles;
	import com.codecollision.graphics.Input;
	import com.codecollision.data.RemotingService;
	import com.codecollision.data.DataService;
	
	import com.codecollision.Animate;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Contact
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Contact extends Sprite {
		
		// containers
		private static var contactForm:Sprite;
		private static var inputBlock:Sprite;
		
		// contact sprites
		private static var subjectField:Sprite;
		private static var emailField:Sprite;
		private static var messageField:Sprite;
		private static var sendButton:Sprite;
		
		private static var remotingService:RemotingService = new RemotingService();
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		displayContactForm: 
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function displayContactForm():Sprite {
			
			// close any existing Contact instances
			close();
			
			// containers
			Contact.contactForm = new Sprite();
			Contact.inputBlock = new Sprite();
			
			// contact sprites
			Contact.subjectField = new Sprite();
			Contact.emailField = new Sprite();
			Contact.messageField = new Sprite();
			Contact.sendButton = new Sprite();
			
			// set inputContainer properties
			contactForm.alpha = 0;
			
			/* draw comment input box
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// create sprite, holds input
			inputBlock.x = 3;
			
			// draw name field
			subjectField = Input.drawField(160, 21, "SUBJECT", "input1", 20, 2, 0);
			// draw URL field
			emailField = Input.drawField(180, 21, "EMAIL", "input2", 50, 2, 0);
			emailField.x = Math.round(subjectField.width);
			// draw comment field
			messageField = Input.drawField(490, 120, "MESSAGE", "input2", 0, 2, 0, true);
			messageField.y = 24;
			// draw send button
			sendButton = Input.drawButton(onSendClick, true);
			sendButton.y = Math.round(messageField.y + messageField.height + 2);
			
			// add to contactForm
			inputBlock.addChild(subjectField);
			inputBlock.addChild(emailField);
			inputBlock.addChild(messageField);
			inputBlock.addChild(sendButton);
			
			// add as child to inputContainer, set position of inputBlock
			contactForm.addChild(inputBlock);

			// commentInput display animation
			Animate.animateAlpha(contactForm, 1, 20)
			
			// if button was left disabled, redisable send button
			if (Input.isDisabled()) Input.disableButton(sendButton);
			
			return contactForm;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		close: close contact form, remove sprites 
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function close():void {
			
			// containers
			Contact.contactForm = null;
			Contact.inputBlock = null;
			
			// contact sprites
			Contact.subjectField = null;
			Contact.emailField = null;
			Contact.messageField = null;
			Contact.sendButton = null;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onSendClick: 
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function onSendClick(event:MouseEvent):void {
			
			// get textfields
			var subjectText:TextField = subjectField.getChildByName("text") as TextField;
			var emailText:TextField = emailField.getChildByName("text") as TextField;
			var messageText:TextField = messageField.getChildByName("text") as TextField;
			
			var subject:String = subjectText.text;
			var email:String = emailText.text;
			var message:String = messageText.text;
			
			// clean inputs
			var cleanSubject:Object = DataService.checkFormInput(subject);
			var cleanEmail:Object = DataService.checkFormInput(email);
			var cleanMessage:Object = DataService.checkFormInput(message);
			
			if (!cleanMessage.empty && !Input.isDisabled()) {
				// SENDING message box
				Input.newMessage(messageField, "SENDING...", true);
				
				// call remoting function
				remotingService.submitComment(onSendResult, 41, cleanMessage.input, cleanSubject.input, cleanEmail.input, 0, Input.DISABLED_TIME);
			
			} else if (!Input.isDisabled()) {
				// MISSING FIELD message box
				Input.newMessage(messageField, "ERROR: NO MESSAGE");
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onSendResult: status of submitComment remoting call
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function onSendResult(result:Object):void {
			// if successful
			if (result) {
				// show message box
				Input.newMessage(messageField, "MESSAGE SENT");
				
				// get textfields
				var subjectText:TextField = subjectField.getChildByName("text") as TextField;
				var emailText:TextField = emailField.getChildByName("text") as TextField;
				var messageText:TextField = messageField.getChildByName("text") as TextField;
				
				// clear fields
				subjectText.text = "";	
				emailText.text = "";
				messageText.text = "";
	
				// unfocus all fields
				Input.unfocus(subjectField);
				Input.unfocus(emailField);
				Input.unfocus(messageField);
				
				Input.disableButton(sendButton);		// disable send button
				
			} else {
				// show message box > TIME FAILURE
				Input.newMessage(messageField, "POSTED WITHIN " + Input.DISABLED_TIME + " SECONDS");
			}
		}
	}
}