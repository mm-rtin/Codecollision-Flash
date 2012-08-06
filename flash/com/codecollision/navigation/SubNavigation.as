/*
     File:	SubNavigation.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	May 13, 2007
   Edited:	May 17, 2008
    Notes:	
Functions:

*/

package com.codecollision.navigation {
	
	import com.codecollision.Animate;
	import com.codecollision.ContentLoader;
	import com.codecollision.Sounds;
	import com.codecollision.data.DataService;
	import com.codecollision.data.RemotingService;
	import com.codecollision.graphics.Draw;
	import com.codecollision.graphics.Styles;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.text.TextField;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class SubNavigation
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class SubNavigation extends Sprite {
		
		// class references
		private var classRef:Object;
		
		// properties
		private var postCount:uint;					// total number of posts
		private var logMenuLoaded:Boolean;
		private var mediaSource:String;				// location to load images from
		
		// Draw class
		private var remotingService:RemotingService;
		
		// container sprites
		private var subNavContainer:Sprite;
		private var catMenu:Sprite;
		private var pageMenu:Sprite;
		private var navShader:Sprite;
		
		// data objects
		private var categories:Object;				// category data from remoting
		
		// subNav loaders
		private var shaderLoader:ContentLoader;
		
		// constants
		private const CAT_PADDING:uint = 18;		// space between subNav menuItem
		private const SHADER_END_SIZE:uint = 38;	// height of nav_shader.gif curved ends
		private const MICRO_NAV_HEIGHT:uint = 75;	// height of MicroNavigation
		private const FOLDER_WIDTH:uint = 14;		// wdith of folderIcon
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		SubNavigation constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function SubNavigation(classRef:Object) {
			this.classRef = classRef;
			
			// properties
			postCount = 0;
			logMenuLoaded = false;
			
			// init class
			remotingService = new RemotingService();
			
			// container sprites
			subNavContainer = new Sprite();
			catMenu = new Sprite;
			pageMenu = new Sprite();
			navShader = new Sprite;
			
			// data objects
			categories = new Object();
			
			// set subNavContainer properties
			subNavContainer.x = 770;
			subNavContainer.y = 130;
			
			// set navShader properties
			navShader.alpha = 0;
			
			// catMenu properties
			catMenu.alpha = 0;
			catMenu.x = 11;
			catMenu.y = 117;
			
			// page menu properties
			pageMenu.alpha = 0;
			pageMenu.x = 11;
			
			subNavContainer.addChild(navShader);	// child 0
			subNavContainer.addChild(catMenu); 		// child 1
			subNavContainer.addChild(pageMenu);		// child 2
			
		}
		public function initialize():void {
			
			mediaSource = classRef.siteConfig.MEDIA_SOURCE;
			
			// load default nav content
			loadMenu("log");
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getContainer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	
		public function getContainer():Sprite {
			return subNavContainer;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		loadMenu: loads subNav menu links
		@param menu - menu to load
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function loadMenu(menu:String):void {
			switch(menu) {
				case "log":
					loadLog();
					logMenuLoaded = true;
					break;
				case "projects":

					break;
				case "source":
					
					break;
				case "about":
					
					break;			
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		loadLog: open log sub menu, loads data from getCategories table through remoting cfc
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function loadLog():void {
			
			// if logMenu alreadly loaded do nothing
			if (!logMenuLoaded) {
				remotingService.callFunction("getCategories", onCategoryResult);
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onCategoryResult: query data loaded through remotingService returned here
		@param result - converted and returned query data
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onCategoryResult(result:Object):void {
			
			// save categories data
			categories = result;
			// draw category menu
			drawCategoryMenu(categories);
			// draw page menu
			drawPageMenu();
			//create navShader sprite
			loadNavShader(catMenu.height + pageMenu.height + MICRO_NAV_HEIGHT + CAT_PADDING);
		}
		 
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawCategoryMenu: draw sub navigation menu
		@param menuData - menu titles and links
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawCategoryMenu(menuData:Object):void {
			
			/* draw 'categories' title
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// get stylesheet
			var style:StyleSheet = Styles.getStyle();
			
			// title field
			var titleText:TextField = new TextField();
			titleText.embedFonts = true;
			titleText.autoSize = TextFieldAutoSize.LEFT;
			titleText.selectable = false;
			titleText.styleSheet = style;
			titleText.htmlText = "<h3>categories</h3>";
			
			catMenu.addChild(titleText);
			
			/* loop through menuData
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			for (var key:String in menuData) {
				
				var catID:Number = Number(menuData[key].term__term_id);
				var catTitle:String = menuData[key].term__name;
				var catCount:String = menuData[key].count;
				
				// add up catCount for 'show all' category
				postCount += Number(catCount);
				
				// draw category menu link
				var menuLink:TextField = new TextField();
				menuLink = drawMenuLink(catTitle, "log/category/" + catTitle, catCount);
				menuLink.x = FOLDER_WIDTH;
				menuLink.y = (Number(key) + 2) * CAT_PADDING;
				
				// draw icon
				var itemFolder:Bitmap = Draw.getBitmap("folderIcon");
				itemFolder.alpha = .2;
				itemFolder.y = menuLink.y + 3;
				
				// add as child to catMenu
				catMenu.addChild(menuLink);
				catMenu.addChild(itemFolder);
			}

			/* create 'show all' category item
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var showAllLink:TextField = new TextField();
			showAllLink = drawMenuLink("show all", "/", String(postCount));
			showAllLink.x = FOLDER_WIDTH;
			showAllLink.y = CAT_PADDING;
			// draw icon
			var showAllFolder:Bitmap = Draw.getBitmap("folderIcon");
			showAllFolder.alpha = .2;
			showAllFolder.y = showAllLink.y + 3;
			
			// add to catMenu
			catMenu.addChild(showAllLink);
			catMenu.addChild(showAllFolder);
			
			// animate
			Animate.animateAlpha(catMenu, 1, 20);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawPageMenu: draw page navigation menu
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawPageMenu():void {
			
			/* draw 'pages' title
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// get stylesheet
			var style:StyleSheet = Styles.getStyle();
			
			// text field
			var titleText:TextField = new TextField();
			titleText.embedFonts = true;
			titleText.autoSize = TextFieldAutoSize.LEFT;
			titleText.selectable = false;
			titleText.styleSheet = style;
			titleText.htmlText = "<h3>pages</h3>";
			
			/* draw page menu links
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// next link
			var nextLink:TextField = new TextField();
			nextLink = drawMenuLink("next", "log/category/");
			nextLink.name = "next";
			nextLink.x = FOLDER_WIDTH;
			nextLink.y = CAT_PADDING;
			// icon
			var nextIcon:Bitmap = Draw.getBitmap("folderIcon");
			nextIcon.alpha = .2;
			nextIcon.y = nextLink.y + 3;
			
			// previous link
			var previousLink:TextField = new TextField();
			previousLink = drawMenuLink("previous", "log/category/");
			previousLink.name = "previous";
			previousLink.x = FOLDER_WIDTH;
			previousLink.y = CAT_PADDING * 2;
			// previous icon
			var prevIcon:Bitmap = Draw.getBitmap("folderIcon");
			prevIcon.alpha = .2;
			prevIcon.y = previousLink.y + 3;

			
			// position pageMenu
			pageMenu.y = catMenu.y + catMenu.height + CAT_PADDING;
			
			// add links to pageMenu
			pageMenu.addChild(titleText);		// child 0
			
			pageMenu.addChild(nextLink);		// child 1
			pageMenu.addChild(nextIcon);		// child 2
			
			pageMenu.addChild(previousLink);	// child 3
			pageMenu.addChild(prevIcon);
			
			// animate
			Animate.animateAlpha(pageMenu, 1, 20, null, 10);	
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawMenuLink: draw sub navigation menu link
		@param catTitle - link title
		@param hashLink - URL link
		@param catCount - link count
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawMenuLink(linkTitle:String, hashLink:String, count:String = null):TextField {
			// get stylesheet
			var style:StyleSheet = Styles.getStyle("catLink");
			
			// if defined add count text
			if (count) count = "<span class='subText'> (" + count + ")</class>";
			
			// text field
			var linkText:TextField = new TextField();
			linkText.embedFonts = true;
			linkText.gridFitType = GridFitType.PIXEL;
			linkText.autoSize = TextFieldAutoSize.LEFT;
			linkText.styleSheet = style;
			linkText.selectable = false;
			
			linkText.htmlText = "<a href='Event:" + hashLink + "'/>" + linkTitle + "</a>" + count;
			
			linkText.addEventListener(TextEvent.LINK, onLinkClick);
			
			return linkText;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onLinkClick
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onLinkClick(Event:TextEvent):void {
			
			// for other links not paged
			var linkName:String = Event.target.name;
			if (linkName != "next" && linkName != "previous") {
				classRef.navigate.changeAddress(Event.text);
				return;
			}
			
			/* next / previous 
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// set increment or decrement
			var change:int = 0;
			if (linkName == "next") {
				change = 1;
			} else if (linkName == "previous") {
				change = -1;
			}
			
			// return valid page number within page limits
			var pageStatus:Object = classRef.log.setPageStatus(change);
			classRef.navigate.changeAddress(Event.text + pageStatus.showCategory + "/" + pageStatus.page);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		loadNavShader: create subNavShader
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function loadNavShader(height:Number):void {
			// load shader
			shaderLoader = new ContentLoader(mediaSource + "nav_shader.gif", "regular", loadComplete);
			
			// shader download complete	
			function loadComplete():void {
				extendShader(shaderLoader, height);
				
				// animate
				Animate.animateAlpha(navShader, .08, 20);
			}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		setShaderHeight: redraws navShader with new size
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function setShaderHeight(height:Number):void {
			extendShader(shaderLoader, height);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		extendShader
		@param navHeight - height to extend nav_shader.gif 
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function extendShader(shaderLoader:ContentLoader, newHeight:Number):void {
			
			var width:uint = shaderLoader.width;
			var height:uint = shaderLoader.height;
			var middleHeight:uint = height - SHADER_END_SIZE * 2;
			
			// shader BitmapData
			var shaderBitmap:BitmapData = new BitmapData(width, height, true);
			var shaderAlpha:BitmapData = new BitmapData(width, height, true);
			shaderBitmap.draw(shaderLoader);
			shaderAlpha.draw(shaderLoader, null, null, "alpha");
			
			// top shader
			var topBitmap:BitmapData = new BitmapData(width, SHADER_END_SIZE, true);
			var topArea:Rectangle = new Rectangle(0, 0, width, SHADER_END_SIZE);
			topBitmap.copyPixels(shaderBitmap, topArea, new Point(0, 0), shaderAlpha, new Point(0,0), false);
			
			// middle shader (tile)
			var middleBitmap:BitmapData = new BitmapData(width, newHeight, false);
			var middleArea:Rectangle = new Rectangle(0, SHADER_END_SIZE, width, middleHeight);
			var topPoint:Point;
			for (var i:Number = 0; i < newHeight / middleHeight; i++) {
				topPoint = new Point(0, i * middleHeight);
				middleBitmap.copyPixels(shaderBitmap, middleArea, topPoint); 
			}
			
			// end of shader
			var endBitmap:BitmapData = new BitmapData(width, SHADER_END_SIZE, true);
			var endArea:Rectangle = new Rectangle(0, middleHeight + SHADER_END_SIZE, width, height);
			endBitmap.copyPixels(shaderBitmap, endArea, new Point(0, 0), shaderAlpha, new Point(0,middleHeight + SHADER_END_SIZE), false);
			
			var topShader:Bitmap = new Bitmap(topBitmap);
			var middleShader:Bitmap = new Bitmap(middleBitmap);
			var endShader:Bitmap = new Bitmap(endBitmap);
			
			// set positions
			middleShader.y = SHADER_END_SIZE;
			endShader.y = SHADER_END_SIZE + newHeight;
			
			// add to navShader sprite
			navShader.addChild(topShader);
			navShader.addChild(middleShader);
			navShader.addChild(endShader);
		}
	}
}