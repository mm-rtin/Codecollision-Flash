/*
     File:	RemotingService.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	May 11, 2007
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision.data {
	
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class RemotingService
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class RemotingService extends NetConnection {
		
		// remoting service gateway
		private const REMOTING_URL:String = "http://app.codecollision.com/gateway/";
		private const SERVICE_PATH:String = "wpService.";
		
		private var resultFunction:Function;
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		RemotingService constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function RemotingService(remotingURL:String = REMOTING_URL) {
			this.objectEncoding = 0;	// allows NetConnection to send object/array parameters
			this.connect(remotingURL);	
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		callFunction
		@param functionName - CFC and Function to load (CFC.FunctionName)
		@param resultFunction - function name outside of class to pass result back
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function callFunction(functionName:String, resultFunction:Function, parameter:String = null):void {
			trace("### callFunction " + functionName);
			
			this.resultFunction = resultFunction;
			// create responder and call functionName
			var responder:Responder = new Responder(onResult, onFault);
			
			// remoting CFC, pass paramString
			if (parameter == null) {
				this.call(SERVICE_PATH + functionName, responder);
			} else {
				this.call(SERVICE_PATH + functionName, responder, parameter);
			}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getPosts
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getPosts(resultFunction:Function, offset:Number, rowNum:Number, category:String, loadedPosts:Array):void {
			trace("### getPosts : ", offset, rowNum, category);
			
			this.resultFunction = resultFunction;
					
			// create responder and call functionName
			var responder:Responder = new Responder(onResult, onFault);
			// remoting CFC, pass parameters
			this.call(SERVICE_PATH + "getPosts", responder, category, offset, rowNum);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getSinglePost
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getSinglePost(resultFunction:Function, postName:String):void {
			trace("### getSinglePost : ", postName);
			
			// convert space to dash (-)
			var spacePattern:RegExp = /\s/g;
			postName = postName.replace(spacePattern, "-");
			postName = postName.toLocaleLowerCase();
			
			this.resultFunction = resultFunction;
			// create responder and call functionName
			var responder:Responder = new Responder(onResult, onFault);
			// remoting CFC, pass parameters
			this.call(SERVICE_PATH + "getSinglePost", responder, postName);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getPage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getPage(resultFunction:Function, pageName:String):void {
			trace("### getPage : ", pageName);
			
			this.resultFunction = resultFunction;
			// create responder and call functionName
			var responder:Responder = new Responder(onResult, onFault);
			// remoting CFC, pass parameters
			this.call(SERVICE_PATH + "getPage", responder, pageName);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getComments
		@param postID - post to retrieve comments for
		@param commentID - lastest comment loaded
		@param numRows - number of comments to retrieve
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getComments(resultFunction:Function, postID:uint, commentID:uint):void {
			trace("### getComments");
			
			this.resultFunction = resultFunction;
			
			// create responder and call functionName
			var responder:Responder = new Responder(onResult, onFault);

			// remoting CFC, pass parameters
			this.call(SERVICE_PATH + "getComments", responder, postID, commentID);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		submitComment
		@param resultFunction - function name outside of class to pass result back
		@param postID - required
		@param comment - required
		@param name - required
		@param URL - required
		@param parent - parent comment for threading
		@param disabledTime - time to disabled new comment submission
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function submitComment(	resultFunction:Function,
										postID:Number,
										commentContent:String,
										author:String,
										url:String,
										parent:uint,
										disabledTime:uint):void {
											
			trace("submitComment", postID, commentContent, author, url, parent);
			
			this.resultFunction = resultFunction;
			
			// replace empty strigns with defaults
			if (author == "") author = 'Anonymous';
			if (url == "") url = '';
				
			// create responder and call functionName
			var responder:Responder = new Responder(onResult, onFault);
			
			// remoting CFC, pass parameters
			this.call(SERVICE_PATH + "submitComment", responder, postID, commentContent, author, url, parent);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onResult: get result from remotingService and convert to more readable data
		@param result
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onResult(result:Object):void {
			
			// number type
			if (result is Number) {
				var numberResult:Number = Number(result);
				this.resultFunction(numberResult);
			
			// string type
			} else if (result is String) {

				var stringResult:String = String(result);
				this.resultFunction(stringResult);
			
			// boolean type
			} else if (result is Boolean) {

				var booleanResult:Boolean = Boolean(result);
				this.resultFunction(booleanResult);
			
			// Query type - results are array[1].attribute_name
			} else {

				this.resultFunction(result); 
			}
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onFault: 
		@param fault
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onFault(fault:Object):void {
			trace("fault");
		}
	}
}