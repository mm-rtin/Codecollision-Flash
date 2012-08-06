/*
     File:	SoundFX.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	Oct 29, 2007
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision.collisionnav.engine {
	
	// import classes
	import flash.media.*;
	import flash.net.URLRequest;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Sound
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class SoundFX {
		
		// embed sound effects
		[Embed(source="..\\..\\..\\..\\embed\\ping.mp3")]	// assets in root
		private var ballBounce:Class;
		
		[Embed(source="..\\..\\..\\..\\embed\\ping.mp3")]	// assets in root
		private var wallBounce:Class;
		
		// ball bounce sound
		private var ballSound:Sound = new ballBounce() as Sound;
		private var ballChannel:SoundChannel;
		
		// wall bounce sound
		private var wallSound:Sound = new wallBounce() as Sound;
		private var wallChannel:SoundChannel;
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Sound constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function SoundFX() {
			
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		functionName: playBallBounce
		@param paramName
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function playBallBounce(vx:Number, vy:Number) {
			
			if (Math.abs(vx) > .1 || Math.abs(vy) > .1) {
				ballChannel = ballSound.play();
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		functionName: playWallBounce
		@param paramName
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function playWallBounce(vx:Number, vy:Number) {
			if (Math.abs(vx) > 1 || Math.abs(vy) > 1) {
				//wallChannel = wallSound.play();
			}
		}
		
	}
}