/*
     File:	PageNavigation.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	June 13, 2008
   Edited:	
    Notes:	
Functions:

*/

package com.codecollision.navigation.page {
	
	import flash.text.*;
	import flash.events.*;
	import flash.display.Sprite;
	
	// custom
	import com.codecollision.graphics.Styles;
	import com.codecollision.graphics.Draw;
	import com.codecollision.graphics.Text;
	
	import com.codecollision.Animate;
	import com.codecollision.Sounds;

	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class PageNavigation
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class PageNavigation extends EventDispatcher {
		
		// data objects
		private var pageLinks:Array;			// reference to each pageLink button
		
		// sprites
		private var pageNavContainer:Sprite;	// navigation controls container for changing comments page
		private var navigateButtons:Sprite;		// container for next/previous, first/last page buttons
		private var pageButtons:Sprite;			// container for pageLink buttons 
		
		// properties
		private var pageNumber:uint;			// current page of comments
		private var maxPageNumber:uint;			// current max number of pages based on (comments / MAX_COMMENTS)
		
		// constants
		private static const BUTTON_PAD:uint = 4;		// horizontal spacing between button links
		private static const NAVIGATION_PAD:uint = 5;	// horizontal spacing between navigation links
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		PageNavigation constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function PageNavigation(pageNumber:uint, maxPageNumber:uint) {
			
			this.pageNumber = pageNumber;
			this.maxPageNumber = maxPageNumber;
			
			// init pageLinks array
			pageLinks = new Array();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawPageNavigation: draws navigation elements for changing comments page
		@param width - width of containing object, used to right align navigateButtons
		@param addPageButtons - true = add pageButtons to container
		@param addNavigateButtons - true = add navigateButtons to container
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function drawPageNavigation(width:uint, addPageButtons:Boolean = true, addNavigateButtons:Boolean = true, navID:String = null):Sprite {	
			
			// pageNavigation sprites
			pageNavContainer = new Sprite();
			navigateButtons = new Sprite();
			pageButtons = new Sprite();

			// draw pageLink buttons
			if (addPageButtons) {
				drawPageButtons(pageButtons, navID);
				pageNavContainer.addChild(pageButtons);
			}
			
			// draw navigate buttons
			if (addNavigateButtons) {
				drawNavigateButtons(navigateButtons, width, navID);
				pageNavContainer.addChild(navigateButtons);
			}
			
			pageNavContainer.cacheAsBitmap = true;
			
			return pageNavContainer;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		changePage - calls functions to handle navigating between pages
		@param page - supports relative page direction or exact pageNumber values
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function changePage(page:String, navID:String = null):void {		

			// select previously selected pageLink for current page highlight
			var pageLink:Sprite = pageLinks[pageNumber - 1];
			var pageLinkSelected:TextField = pageLink.getChildByName("pageLinkSelected") as TextField;
			Animate.animateAlpha(pageLinkSelected, 0, 20);

			// relative direction
			if (page == "next") {
				pageNumber ++;
			} else if (page == "previous") {
				pageNumber --;
			
			// last/first page
			} else if (page == "last") {
				pageNumber = maxPageNumber;
			} else if (page == "first") {
				pageNumber = 1;
			
			// exact page
			} else {
				pageNumber = int(page);
			}
			
			// limit pageNumber
			if (pageNumber > maxPageNumber) {
				pageNumber = maxPageNumber;
			} else if (pageNumber < 1) {
				pageNumber = 1;
			}	
			
			// animate showing new pageLinkSelected
			pageLink = pageLinks[pageNumber - 1];
			pageLinkSelected = pageLink.getChildByName("pageLinkSelected") as TextField;
			Animate.animateAlpha(pageLinkSelected, 1, 20, null);

			// dispatch event pageChanged
			dispatchEvent(new PageEvent(PageEvent.PAGE_CHANGED, true, false, pageNumber, navID));
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		updatePageButtons: update and draw new pageButtons based on new maxPageNumber
		@param maxPageNumber - new maxPageNumber
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function updatePageButtons(maxPageNumber:uint):void {
			
			this.maxPageNumber = maxPageNumber;
			drawPageButtons(pageButtons);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawNavigateButtons: draws link buttons which navigate relative to page and to first and last page
		@param target - draw buttons to target sprite
		@param width - width of containing object, used to right align navigateButtons
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawNavigateButtons(target:Sprite, width:uint, navID:String = null):void {
			
			// draw next/previus page links
			var nextLink:TextField = Text.drawEventLink("NEXT &gt;", "next&" + navID, "linkButtonBright", onPageChange, onLinkOver);
			var previousLink:TextField = Text.drawEventLink("&lt; PREVIOUS", "previous&" + navID, "linkButtonBright", onPageChange, onLinkOver);
			
			// draw first/last page links
			var firstLink:TextField = Text.drawEventLink("&lt;&lt;", "first&" + navID, "linkButton", onPageChange, onLinkOver);
			var lastLink:TextField = Text.drawEventLink("&gt;&gt;", "last&" + navID, "linkButton", onPageChange, onLinkOver);
			
			// add to display list
			target.addChild(nextLink);
			target.addChild(previousLink);
			target.addChild(firstLink);
			target.addChild(lastLink);
			
			// positioning
			firstLink.x = 0;
			previousLink.x = int(lastLink.width + NAVIGATION_PAD);
			nextLink.x = int(previousLink.x + previousLink.width + NAVIGATION_PAD);
			lastLink.x = int(nextLink.x + nextLink.width + NAVIGATION_PAD);
			target.x = width - target.width;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawPageButtons: draws buttons which navigate directly between pages
		@param target - draw buttons to target sprite
		@param navID - name of drawn navigation buttons
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawPageButtons(target:Sprite, navID:String = null):void {
			
			var i:int = 0;
			var gap:int = 0;
			var totalWidth:int = 0;
			var totalHeight:int = 0;
			var pageLink:Sprite = new Sprite();
			
			for (i; i < maxPageNumber; i ++) {
				
				// set x,y properties every 5 iterations, creates 1 new row of 5
				if (i % 5 == 0) {
					gap = 0;
					totalWidth = 0;			
					totalHeight += int(pageLink.height);
				}
				
				// draw new pageLink
				pageLink = drawPageLink(i + 1, navID);		// drawLink (add 1 since index starts at 0)
				
				// only add pageLink to displayList if new
				if (i > pageLinks.length - 1) {
					pageLink.y = totalHeight + int(i / 5) * BUTTON_PAD;
					pageLink.x = totalWidth + gap;
					target.addChild(pageLink);
					pageLinks.push(pageLink);		// save pageLink sprite reference to array
				}
				totalWidth += int(pageLink.width);
				gap += BUTTON_PAD;
			}
		}
			
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawPageLink: draws small link direct to displayed page number
		@param page - the page number to change to and display in link text
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawPageLink(page:uint, navID:String = null):Sprite {

			// draw page number text fields
			var pageLinkButton:TextField = Text.drawEventLink("PAGE " + page.toString(), page.toString() + "&" + navID, "linkButton", onPageChange, onLinkOver);
			pageLinkButton.x = 2;
			pageLinkButton.y = 0;
			
			// page selected text
			var pageLinkSelected:TextField = Text.drawTextField("<h5>PAGE " + page.toString() + "</h5>", "global", false); 
			pageLinkSelected.name = "pageLinkSelected";
			if (page != pageNumber) {
				pageLinkSelected.alpha = 0;
				pageLinkSelected.visible = false;
			}
			pageLinkSelected.x = 2;
			pageLinkSelected.y = 0;
			
			// draw pageLink background
			var graphicsStyle:Object = Styles.getGraphicsStyle("comment");
			var pageLink:Sprite = new Sprite();
			// draw gradientFill on pageLink
			Draw.drawGradientFill(pageLink, pageLinkButton.width + 2, pageLinkButton.height, graphicsStyle.boxGradientStart2, graphicsStyle.boxGradientEnd2);
			// draw round rectangle on pageLink
  			Draw.drawRoundRect(pageLink, pageLinkButton.width + 2, pageLinkButton.height, 0, 0);
			
			pageLink.addChild(pageLinkButton);
			pageLink.addChild(pageLinkSelected);
						
			return pageLink;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onPageChange - handles event for PageNavigation onClick
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onPageChange(Event:TextEvent):void {
			
			// parse event text and get page string, ID string
			var eventText:Array = Event.text.split("&");
			changePage(eventText[0], eventText[1]);		// get new page number, send to changePage
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onLinkOver - handles event for PageNavigation Mouse over
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onLinkOver(Event:MouseEvent):void {
			Sounds.playSound("beep");
		}
		
	}
}