/*
     File:	SiteConfig.as
 Revision:	0.0.2
  Purpose:	
  Authors:	
  Created:	May 11, 2007
   Edited:	June 08, 2008
    Notes:	
Functions:

*/

package com.codecollision {

	import com.codecollision.Animate;
	import com.millermedeiros.swffit.SWFFit;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class SiteConfig
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class SiteConfig {
		
		// graphics loaders	
		private var logoLoader:ContentLoader;			// loads site logo
		private var bgLoader:ContentLoader;				// loads site background
		private var techLoader:ContentLoader;			// loads extra 'tech' graphic
		
		// sprites
		private var graphicsContainer:Sprite;			// holds background, logo and extra graphics
		private var background:Sprite;					// background graphics
		
		// properties
		private var contentReference:Sprite;			// references entire site content for retrieving height
		
		// constants
		private const TILE_HEIGHT:uint = 320;			// height of tile in background image
		private const VERTICAL_COPIES:uint = 9; 		// TILE * VERTICAL COPIES = MAX_BITMAP_SIZE
		private const MAX_BITMAP_SIZE:uint = 2880;		// max size (height/width) supported by BitmapData
		private const PAD:Number = 200;			// space to add at end of flash height
		
		/* select source for all images on codecollision.com
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
		// Amazon S3 = http://media.codecollision.com/
		// web host  = cc_assets/
		public const MEDIA_SOURCE:String = "cc_assets/";
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		SiteConfig constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function SiteConfig(contentContainer:Sprite) {
			// get content height
			contentReference = contentContainer;
			
			graphicsContainer = new Sprite();
			background = new Sprite();
			background.alpha = 0;
		}
		public function initialize():void {
			// load logo
			logoLoader = new ContentLoader(MEDIA_SOURCE + "logo.png", "regular", onLogoComplete);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getContainer: return graphicsContainer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getContainer():Sprite {
			return graphicsContainer;
		}	
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getMediaSource: returns MEDIA_SOURCE
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getMediaSource():String {	
			return MEDIA_SOURCE;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getBackgroundHeight: returns height of background or max vertical limit of content
		@return height - current height of site
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getBackgroundHeight():Number {	
			return graphicsContainer.height;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		updateFlashHeight: calls JS function to set new .swf height
		@param height - current height of site
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function updateFlashHeight():void {
			
			var height:Number = Math.round(contentReference.height);
			
			SWFFit.fit("codecollision", 760 + PAD, height + PAD);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		scroll: scroll browser window to top or bottom of page, using javascript command
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function scroll(type:String = "top", y:int = 0):void {	
			if (ExternalInterface.available) {
				ExternalInterface.call("scroll", type, y);
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onLogoComplete: logo downloading complete
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onLogoComplete():void {
			initializeSiteGraphics();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		initializeSiteGraphics: finish loading site graphics and animate logo to stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function initializeSiteGraphics():void {
			drawLogo();
			bgLoader = new ContentLoader(MEDIA_SOURCE + "background.jpg", "regular", drawBackground);
		}
			
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawTechExtra: tech shape downloading complete, position, and draw to the stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawTechExtra():void {
			
			// draw tech shape
			techLoader.x = 879;
			techLoader.y = 66;
			techLoader.alpha = 0;
			
			graphicsContainer.addChild(techLoader);				// tech shape - child 4
			Animate.animateAlpha(techLoader, 1, 10, null, 70, "easeOutBounce", "revo");
			Animate.animateBlur(techLoader, 20, 20, -20, -20, 20, 1, "easeOutBounce", null, 50);
		}	

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawBackground - add bgLoader to graphicsContainer and create vertical tile
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawBackground():void {

			// load background tech graphic
			techLoader = new ContentLoader(MEDIA_SOURCE + "tech.gif", "regular", drawTechExtra);

			// extend background vertically
			var verticalBG:Sprite = extendBackgroundVertical(bgLoader);
			verticalBG.y = bgLoader.height;
			
			// add tiles to background container
			background.addChild(bgLoader);					// background (child 0)
			background.addChild(verticalBG);				// background (child 1)
			graphicsContainer.addChildAt(background, 0);	// ensure background is at lowest depth
			
			// animate background
			Animate.animateAlpha(background, 1, 10, null, 40, "easeOut", "pulse");
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawLogo: draw logo to stage
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawLogo():void {
			
			// position
			logoLoader.x = 127;
			logoLoader.y = 15;
			logoLoader.alpha = 0;
			
			graphicsContainer.addChild(logoLoader);
			Animate.animateAlpha(logoLoader, 1, 10, null, 10, "easeOutBounce", "tek");
			Animate.animateBlur(logoLoader, 20, 20, -20, -20, 20, 1, "easeOutBounce", null, 10);
		}	

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		extendBackgroundVertical: copy 'tile' pixels of loaded background and tile vertically
		@param bgLoader - loaded background from contentLoader
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function extendBackgroundVertical(bgLoader:ContentLoader):Sprite {
			
			// create bitmapData from bgLoader
			var bgBitmap:BitmapData = new BitmapData(bgLoader.width, bgLoader.height, false);
			bgBitmap.draw(bgLoader);
			
			// create sourceTile from bgBitmap
			var sourceTile:BitmapData = new BitmapData(bgLoader.width, TILE_HEIGHT, false);
			var sourceArea:Rectangle = new Rectangle(0, bgLoader.height - TILE_HEIGHT, bgLoader.width, TILE_HEIGHT); 
			var sourceStart:Point = new Point(0, 0);
			sourceTile.copyPixels(bgBitmap, sourceArea, sourceStart);
			
			// create verticalBG tile
			var verticalBG:Sprite = new Sprite();
			// draw bitmap tile on verticalBG
    		verticalBG.graphics.beginBitmapFill(sourceTile, null, true);
            verticalBG.graphics.drawRect(0, 0, bgLoader.width, MAX_BITMAP_SIZE * 2);
            verticalBG.graphics.endFill();
			
			return verticalBG;
		}
	}
}