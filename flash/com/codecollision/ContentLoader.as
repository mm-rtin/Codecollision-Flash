/*
     File:	ContentLoader.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	May 09, 2007
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision {
	
	import flash.events.*;
	import flash.display.Loader;
	import flash.system.LoaderContext;

	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	import flash.utils.ByteArray;

	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class ContentLoader
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class ContentLoader extends Loader {
		private var request:URLRequest;
		
		private var stream:URLStream = new URLStream();
		private var byteArray:ByteArray = new ByteArray();
		
		// function reference to run when loading complete
		private var completeFunction:Function;
		
		// set to true when stream or regular loading is complete
		public var loadComplete:Boolean = false;	
		
		/*~~~~~~~~~~~~~~~~~~~~~~~~~~~
		ContentLoader constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function ContentLoader(contentPath:String, loadType:String = "regular", completeFunction:Function = null) {
			
			// set function reference for onComplete
			if (completeFunction != null) {
				this.completeFunction = completeFunction;
			}
			
			if (contentPath != null) {
				this.request = new URLRequest(contentPath);	// create URLRequest
			
				// select load type
				if (loadType == "stream") {
					loadStream(request); 	// use streaming loader				
				} else if (loadType == "regular") {
					loadRegular(request); 	// use regular loader (does not stream content)
				}
			
			}
		}

		/*~~~~~~~~~~~~~~~~~~~~~~~~~~~
		regular loader
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function loadRegular(request:URLRequest):void {
			
			// create loaderContext to check for crossdomain.xml
			var loaderContext:LoaderContext = new LoaderContext ();
			loaderContext.checkPolicyFile = true;

			this.load(request, loaderContext);
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		}
		
		/*~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onLoadComplete
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onLoadComplete(event:Event):void {
			// run completeFunction
			if (this.completeFunction != null) {
				this.completeFunction();
			}	
			
			// set public var when loading done
			loadComplete = true;
		}

		/*~~~~~~~~~~~~~~~~~~~~~~~~~~~
		stream loader
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function loadStream(request:URLRequest):void {
			
			// load stream, catch 404 (not found) errors
			try {
				stream.load(request);
			} catch (error:Error) {
				// trace("file not found");
			}
			
			// setup event listeners
			stream.addEventListener(Event.COMPLETE,onStreamComplete);
			stream.addEventListener(ProgressEvent.PROGRESS,onStreamProgress);
			stream.addEventListener(Event.OPEN,onStreamOpen);
			stream.addEventListener(IOErrorEvent.IO_ERROR,onStreamIOError);
			stream.addEventListener(HTTPStatusEvent.HTTP_STATUS,onStreamHTTPStatus);
			stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onStreamSecurityError);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		stream events
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onStreamProgress(event:ProgressEvent):void {
			streamBytes();
		}
		private function onStreamComplete(event:Event):void {
			streamBytes();
			
			// run completeFunction
			if (this.completeFunction != null) {
				this.completeFunction();
			}
			
			// set public var when loading done
			loadComplete = true;
		}

		private function onStreamIOError(event:IOErrorEvent):void {
		}
		private function onStreamSecurityError(event:SecurityErrorEvent):void {
		}
		private function onStreamHTTPStatus(event:HTTPStatusEvent):void {
		} 
		private function onStreamOpen(event:Event):void {
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		streamBytes: read bytes from the stream, if bytesAvailable load bytes into load from byteArray
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function streamBytes():void {
			
			// only loadBytes if stream has bytes to read
			if (stream.bytesAvailable > 0) {
				stream.readBytes(byteArray, byteArray.length);
			
				this.loadBytes(byteArray);
			}
		}
	}
}