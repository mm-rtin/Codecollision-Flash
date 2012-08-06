/*
     File:	Sounds.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	June 02, 2008
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision {
	
	// import classes
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Sound
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Sounds {
		
		// tek
		[Embed(source="..\\..\\embed\\Tek Bounce.mp3")]
		private static var tek:Class;
		private static var tekSound:Sound = new tek() as Sound;
		private static var tekChannel:SoundChannel;
		
		// pulse
		[Embed(source="..\\..\\embed\\Nav2.mp3")]
		private static var pulse:Class;
		private static var pulseSound:Sound = new pulse() as Sound;
		private static var pulseChannel:SoundChannel;
		
		// ping
		[Embed(source="..\\..\\embed\\Ping9.mp3")]
		private static var ping:Class;
		private static var pingSound:Sound = new ping() as Sound;
		private static var pingChannel:SoundChannel;
		
		// beep
		[Embed(source="..\\..\\embed\\Ridge Beep 2.mp3")]
		private static var beep:Class;
		private static var beepSound:Sound = new beep() as Sound;
		private static var beepChannel:SoundChannel;

		// revo
		[Embed(source="..\\..\\embed\\Revo.mp3")]
		private static var revo:Class;
		private static var revoSound:Sound = new revo() as Sound;
		private static var revoChannel:SoundChannel;
		
		// tick
		[Embed(source="..\\..\\embed\\Single Tick2.mp3")]
		private static var tick:Class;
		private static var tickSound:Sound = new tick() as Sound;
		private static var tickChannel:SoundChannel;
		
		// click
		[Embed(source="..\\..\\embed\\Sharp Click.mp3")]
		private static var click:Class;
		private static var clickSound:Sound = new click() as Sound;
		private static var clickChannel:SoundChannel;
		
		// tap
		[Embed(source="..\\..\\embed\\Tone4.mp3")]
		private static var tap:Class;
		private static var tapSound:Sound = new tap() as Sound;
		private static var tapChannel:SoundChannel;
		
		// zip
		[Embed(source="..\\..\\embed\\Umod Fido2.mp3")]
		private static var zip:Class;
		private static var zipSound:Sound = new zip() as Sound;
		private static var zipChannel:SoundChannel;
		
		// link
		[Embed(source="..\\..\\embed\\LinkNav2.mp3")]
		private static var link:Class;
		private static var linkSound:Sound = new link() as Sound;
		private static var linkChannel:SoundChannel;	
		
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		playSound
		@param sound - sound class to play
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function playSound(sound:String):void {
			
			// cut-off sound from existing soundChannel if any
			try {
				Sounds[sound + "Channel"].stop();	
			} catch (error:Error) {
			}
			
			Sounds[sound + "Channel"] = Sounds[sound + "Sound"].play();
		}
		
	}
}