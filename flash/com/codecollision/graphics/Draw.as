/*
     File:	Draw.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	May 15, 2007
   Edited:	June 07, 2008
    Notes:	
Functions:

*/

package com.codecollision.graphics {
	
	import flash.geom.*;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;

	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Draw
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Draw {

		// embed media assets
		[Embed(source="..\\..\\..\\embed\\folder_icon.gif", mimeType="image/gif")]
    	private static var folderImage:Class;
    	
		[Embed(source="..\\..\\..\\embed\\tab.gif", mimeType="image/gif")]
    	private static var tabImage:Class;
    	
    	// embed media bitmaps
    	private static var folderIcon:Bitmap;
    	private static var tab:Bitmap;
    	
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		initialize
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function initialize():void {
			
			// create bitmaps
			folderIcon = new Draw.folderImage();
			tab = new Draw.tabImage();
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getBitmap: create and return new bitmap from bitmapData source
		@param bitmap - embedded bitmap to return
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function getBitmap(bitmap:String):Bitmap {
			
			return new Bitmap(Draw[bitmap].bitmapData);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawFieldBox: draw standard input field background
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawFieldBox(width:Number, 
											height:Number,
											fieldBox:Sprite = null,
											border:Boolean = true,
											borderSize:uint = 1,
											borderColor:Number = 0x152b2f,
											borderAlpha:Number = 1):Sprite {
			
			if (!fieldBox) var fieldBox:Sprite = new Sprite();
			
			fieldBox.graphics.clear();
			
			// draw border
			if (border) fieldBox.graphics.lineStyle(borderSize, borderColor, borderAlpha);
			// draw gradientFill on fieldBox
			drawGradientFill(fieldBox, width, height, 0x25343d, 0x152b2f);
			// draw round rectangle (-borderSize to compensate for outline)
  			Draw.drawRoundRect(fieldBox, width - borderSize, height - borderSize, 0, 0);
			
			return fieldBox;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawGradientFill: draw gradientFill on target sprite
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawGradientFill(target:Sprite,
												width:Number, 
												height:Number,
												gradientStart:Number,
												gradientEnd:Number,
												alphaStart:Number = 1,
												alphaEnd:Number = 1,
												angle:int = 90):void {
													
			// gradient properties		
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [gradientStart, gradientEnd];
			var alphas:Array = [alphaStart, alphaEnd];
			var ratios:Array = [0x00, 0xFF];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(width, height, 90 * Math.PI / 180, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			target.graphics.beginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod);  
 		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawMessageBox: draws message box with visual effects
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawMessageBox(width:Number, height:Number, x:Number = 0, y:Number = 0, clear:Boolean = false, messageBox:Sprite = null):Sprite {
			
			if (!messageBox) var messageBox:Sprite = new Sprite();
			
			// message box
			messageBox.graphics.lineStyle(2, 0x6b3e3e, 1);
			messageBox.graphics.beginFill(0x452828, 1);
			drawRoundRect(messageBox, width, height, x, y, 1, clear);
			messageBox.graphics.endFill();
			
			// add glow
			var glowFilter:GlowFilter = new GlowFilter();
			glowFilter.quality = 10;
			glowFilter.color = 0xff5a00;
			glowFilter.blurX = 3;
			glowFilter.blurY = 3;
			glowFilter.alpha = .2;
			
			messageBox.filters = [glowFilter];
			
			return messageBox;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawRoundRect: draws round pixel style rectangle directly to target objects graphics
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function drawRoundRect(target:Sprite, width:Number, height:Number, x:Number = 0, y:Number = 0, c:Number = 1, clear:Boolean = false):void {
			
			if (clear) target.graphics.clear();
			
			// adjust indent values for x,y position
			var cx:Number = c + x;
			var cy:Number = c + y;
			// width and height of box offset by x,y position
			var w:Number = width + x;
			var h:Number = height + y;
			
			target.graphics.moveTo(x, cy);
			target.graphics.lineTo(cx,cy); // top left corner
			target.graphics.lineTo(cx,y);
			target.graphics.lineTo(w - c, y); // top line
			target.graphics.lineTo(w - c, cy); // top right corner
			target.graphics.lineTo(w, cy);
			target.graphics.lineTo(w, h - c); // right line
			
			target.graphics.lineTo(w - c, h - c); // bottom right corner
			target.graphics.lineTo(w - c, h)
			target.graphics.lineTo(cx, h); // bottom line
			target.graphics.lineTo(cx, h - c); // bottom left corner
			target.graphics.lineTo(x, h - c);
			target.graphics.lineTo(x, cy); // left line
		}
        
	}
}