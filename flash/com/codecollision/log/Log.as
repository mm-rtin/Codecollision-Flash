/*
     File:	Log.as
 Revision:	1.0.0
  Purpose:	
  Authors:	
  Created:	May 11, 2007
   Edited:	July 5, 2010
    Notes:	
Functions:

*/

package com.codecollision.log {
	
	import com.codecollision.Animate;
	import com.codecollision.Sounds;
	import com.codecollision.content.Contact;
	import com.codecollision.data.DataService;
	import com.codecollision.data.RemotingService;
	import com.codecollision.graphics.Draw;
	import com.codecollision.graphics.Styles;
	import com.codecollision.graphics.Text;
	import com.codecollision.log.Comments;
	import com.codecollision.navigation.page.PageEvent;
	import com.codecollision.navigation.page.PageNavigation;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.*;

	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Log
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Log {
	
		// class references
		private var classRef:Object;
		
		private var initializeComplete:Function;		// run this function when ID list complete
		
		// classes
		private var idListRemoting:RemotingService;
		private var postRemoting:RemotingService;
		private var pageRemoting:RemotingService;
		private var comments:Comments;
		private var pageNavigation:PageNavigation;
		
		// animations
		private var logAnimation:Animate;
		
		// containers
		private var logContainer:Sprite;
		private var entryContainer:Sprite;				// child of logContainer
		
		// page navigation
		private var pageNavBottom:Sprite;				// page navigation controls below comments

		// data objects
		private var posts:Array;						// saved query data from posts
		private var pages:Array;						// saved query data from pages
		private var pageLink:Object						// reference of post_title and index links
		private var loadedPosts:Array;					// list of posts to exclude from post result download
		private var entrySprites:Array;					// list of all entry container sprites
		
		// page properties
		private var rowOffset:uint;						// first posts index to load
		private var postCounts:Object;					// number of posts for each category
		
		// display properties
		private var displayType:String;					// display type for log (all, category, single, page)
		private var showPost:String;					// single post to load
		private var showCategory:String;				// category to load
		
		// page properties
		private var page:uint;							// current log page number
		private var showPage:String;					// page to load
		private var maxPageNumber:uint;					// current max number of log pages
		
		// general properties
		private var firstLoad:Boolean;					// true = initialize rest of site
		
		// remoting control properties
		private var postsLoaded:Boolean; 				// status of query download from remoting
		private var postsLoading:Boolean				// true = currently downloading from remoting
		
		// constants
		private const PAGE_SIZE:uint = 3;				// max # posts to load at one time
		private const ENTRY_PAD_V:uint = 40; 			// padding between entries
		private const POSTS_WIDTH:uint = 505; 			// width of main log + comments content area
		private const DELAY_BETWEEN_POSTS:uint = 5;		// animation delay between post entries
		private const POST_SPEED:uint = 5;				// speed to animate post entry
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Log constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function Log(classRef:Object) {
			this.classRef = classRef;
			
			/* create objects, initialize data
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			idListRemoting = new RemotingService();
			postRemoting = new RemotingService();
			pageRemoting = new RemotingService();
			
			// containers
			logContainer = new Sprite();
			entryContainer = new Sprite();	// child of logContainer
			
			// page navigation
			pageNavBottom = new Sprite();
	
			// data objects
			posts = new Array();			
			pages = new Array();			
			pageLink = new Object();		
			entrySprites = new Array();	
			loadedPosts = new Array();
			
			postCounts = new Object();
			page = 1;
			rowOffset = 0;
			
			displayType = "all";
			showPost = null;					
			showCategory = null;			
			showPage = null;	
			
			postsLoaded = false; 	
			postsLoading = false;
			
			firstLoad = true;
			
			// position logContainer
			logContainer.y = 150;
			logContainer.x = 205;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		initialize: setup log
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function initialize(completeFunction:Function):void {
			trace("&&& INTIALIZE");
			
			initializeComplete = completeFunction;
			
			// get posts ID shell
			idListRemoting.callFunction("getPostIDList", onListResult, "post");
			
			// initialize comments
			comments = new Comments(classRef, POSTS_WIDTH);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getContainer: return logContainer
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getContainer():Sprite {
			return logContainer;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getLogStatus: return log status variables
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function getLogStatus():Object {
			
			var status:Object = new Object();
			
			// set status vars
			status.page = page;
			status.rowOffset = rowOffset;
			status.displayType = displayType;
			status.showCategory = showCategory;
			status.showPost = showPost;		
			status.showPage = showPage;
			
			status.postsLoaded = postsLoaded;
			status.postsLoading = postsLoading;
			
			return status;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		setPageStatus: return next page number
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function setPageStatus(change:int):Object {
			
			var param:Object = new Object();
			
			// set showCategory
			if (showCategory == null) {
				param.showCategory = "all";
			} else {
				param.showCategory = showCategory;
			}
			
			// check for invalid pages
			param.page = checkPage(page + change, param.showCategory);
			return param;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		checkPage: check page number for validity of current dataset and return correct page
		@param page - page to check
		@param category - used to verify page is in category range 
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function checkPage(page:int, category:String = "all"):uint {
			trace(">> checkPage" + "  page:" + page + "  category:" + category);
			
			// get maximum page number for selected category
			var maxPage:int = Math.ceil(postCounts[category] / PAGE_SIZE);
			
			// do not allow negative page numbers
			if (page < 1) {
				page = 1;
				
			// limit page to maxPage
			} else if (maxPage > 0 && page > maxPage) {
				page = maxPage;
			}
			return page;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		isPostWithinPage: check if post falls within page limit
		@param i - index of category
		@param page - page to check
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function isPostWithinPage(i:int, page:int):Boolean {
			
			if ((i > (page - 1) * PAGE_SIZE) && (i <= PAGE_SIZE * page)) return true;
			return false;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		loadLog: log starting point, load entire log
		@param displayType - how to display log entries
		@param catTitle - category to load
		@param page - page to load
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function loadLog(displayType:String = "all", categoryName:String = "all", setPage:uint = 1):void {
			// check for invalid pages
			page = checkPage(setPage, categoryName);
			trace(">> loadLog" + "  displayType:" + displayType + "  category:" + categoryName + "  page:" + page);
			
			this.displayType = displayType;
			showCategory = categoryName;	// set category to load onPostsResult
			
			// viewing all: if pageLoaded display from posts array
			if (displayType == "all" && pageLoaded(page)) {
				trace("@@@ LOCAL POSTS @@@");
				displayLog(displayType, categoryName, page);
			
			// viewing category: if categoryLoaded display from posts array
			} else if (displayType == "category" && categoryLoaded(categoryName)) {
				trace("@@@ LOCAL POSTS: category @@@");
				displayLog(displayType, categoryName, page);
		
			// download missing posts
			} else {
				trace("@@@@ DOWNLOAD POSTS @@@");
				getPosts("all", categoryName, page);
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		loadEntry: load single log entry
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function loadEntry(postName:String):void {
			trace(">> loadEntry" + "  postName:" + postName);
			
			displayType = "single"; 		// viewing single entry only
			showPost = postName;			// set showPost to load onPostsResult
			
			// if posts loaded from remoting, display entry
			var postIndex:Number = findPostIndex(postName);
			
			if (postIndex != -1) {
				displayEntry(postIndex);
			
			} else {
				getPosts("single", postName);		// request posts
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		loadPage: load single wordpress page
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function loadPage(pageName:String):void {
			
			displayType = "single";		// viewing single entry only
			showPage = pageName;		// set pageTitle
			
			// display page if previously loaded in pages array
			if (pageLink[pageName] != null) {
				var pageIndex:uint = pageLink[pageName];
				displayPage(pageIndex);
			} else {
				getPage(pageName);	// request page
			}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		updateCommentCount: update comment count in posts
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function updateCommentCount(postIndex:Number, commentCount:Number, contentType:String):void {

			if (contentType == "post") {
				try {
					posts[postIndex].post.comment_count = commentCount;
				} catch (error:Error) {
					trace("NO UPDATE");
				}
			} else if (contentType == "page") {
				pages[postIndex].post.comment_count = commentCount;
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		close: end log, remove log sprites, reset any parameters
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function close():void {
			
			comments.close();					// close comments
			
			try {
				logContainer.removeChildAt(0);	// remove entryContainer sprite
			}
			catch (error:RangeError) {
			}
			
			// remove objects
			entryContainer = null;			
			entrySprites = null;
			pageNavBottom = null;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		pageLoaded: returns true if page number supplied has been fully loaded
		@param checkPage - page to test
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function pageLoaded(page:uint):Boolean {
			
			for (var key:String in posts) {
				if (posts[key].page == page && posts[key].post == null) return false;
			}
			return true;			
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		categoryLoaded: returns true if category name supplied has been fully loaded
		@param categoryName - category name to test
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function categoryLoaded(categoryName:String):Boolean {
			
			var mergedCategories:Array;
			
			for (var i:String in posts) {
				mergedCategories = posts[i].category.mergedCategories;
				
				for (var j:String in mergedCategories) {
					if (posts[i].post == null && categoryName == mergedCategories[j]) {
						return false;
					}
				}
			}
			return true;			
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 postInCategory: returns true if post at index is in category
		 @param index - post index to check
		 @param categoryName - category name to test
		 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function postInCategory(index:int, categoryName:String):Boolean {
			
			var mergedCategories:Array = posts[index].category.mergedCategories;
			
			for (var j:String in mergedCategories) {
				if (categoryName == mergedCategories[j]) {
					return true;
				}
			}
			return false;			
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		setLoadComplete: set parameters after data load complete
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function setLoadComplete():void {
			trace(">> setLoadComplete");
			
			// initialize rest of site if log is on its first load
			if (firstLoad) {
				firstLoad = false;
				classRef.main.initializeSite();
			}
			
			postsLoaded = true;
			postsLoading = false;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getPosts: loads data from posts table through remoting cfc
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function getPosts(displayType:String = "all", postName:String = "all", page:uint = 1):void {
			trace("## getPosts" + "  category:" + postName + "  page:" + page);
			
			// filter posts by page, from (rowOffset through PAGE_SIZE)
			// page - 1 becuase page 0 is default
			this.rowOffset = (page - 1) * PAGE_SIZE;	
			
			postsLoading = true;
			this.page = page;		// set current page
			
			// select remoting function
			if (displayType == "single") {
				postRemoting.getSinglePost(onPostsResult, postName);	
			} else {
				postRemoting.getPosts(onPostsResult, rowOffset, PAGE_SIZE, postName, loadedPosts);	
			}
	}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getPage: loads data from posts table through remoting cfc
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function getPage(pageTitle:String):void {
			trace("## getPage > " + pageTitle);
			
			// call remoting function
			postRemoting.getPage(onPageResult, pageTitle);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onListResult: post ID list query data loaded through remotingService returned here
		@param result - converted and returned query data
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onListResult(result:Array):void {
			trace("### onListResult ###");
			
			// Process result shell and create posts shell
			posts = DataService.processIDList(result, postCounts, PAGE_SIZE);
			
			initializeComplete();		// log initiliazation complete, run function
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onPostsResult: getPosts query data loaded through remotingService returned here
		@param result - converted and returned query data
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onPostsResult(result:Object):void {
			trace("## onPostsResult" + "  displayType:" + displayType);
			
			/* Convert and Restructure result object
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			DataService.processPosts(result, posts, loadedPosts);
			DataService.traceObjectField(result, "post", "id", "post", "post_name", "DOWNLOADED DATA: ");
			
			DataService.traceObjectData(posts);
			
			/* display selection
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// single entry
			if (displayType == "single") {
				displayEntry(0, showPost);
			
			// category
			} else if (displayType == "category") {
				displayLog("category", showCategory, page);	
					
			// all entries
			} else if (displayType == "all") {
				displayLog("all", showCategory, page);
			}
			
			setLoadComplete();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onPageResult: getPage query data loaded through remotingService returned here
		@param result - converted and returned query data
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onPageResult(result:Object):void {
			trace("## onPageResult");
			
			/* Convert and Restructure result object
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var index:uint = DataService.processPage(result, pageLink, pages);
			
			displayPage(index);
			setLoadComplete();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		displayLog: draws text frames, post content into entryContainer
		@param catID - filter by cat_ID
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function displayLog(displayType:String, categoryName:String, page:uint):void {	
			trace(">> displayLog" + " displayType:" + displayType + "  category:" + categoryName + "  page:" + page);
			DataService.traceObjectField(posts, "post", "id", "post", "post_name", "   >>> CURRENT DATA");
			
			newLog();	// start new log - delete any existing log entries

			// get maximum page number for selected category
			var maxPage:uint = Math.ceil(postCounts[categoryName] / PAGE_SIZE);
			
			/** iterate through posts and control which post entries render to the log
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var postsRendered:uint = 0;
			var renderPost:Boolean;		// controls post entry creation
			var entryDelay:Number = -DELAY_BETWEEN_POSTS;
			
			for (var key:String in posts) {
				
				renderPost = false;
				
				// display all
				if (displayType == "all" && posts[key].page == page) {
					renderPost = true;
					
				// filter by category
				} else if (displayType == "category" && postInCategory(Number(key), categoryName)) {
					
					// check if post falls within the bounds for the current page
					postsRendered++;
					if (isPostWithinPage(postsRendered, page)) {
						renderPost = true;	
					}
				}
				
				// check for renderPost flag and if data at index is populated with post object
				if (renderPost && posts[key].post) {
					
					// create entry
					var entrySprite:Sprite = new Sprite();
					entrySprite = drawEntry(posts[key]);	
					entryContainer.addChild(entrySprite);	// add as child to entryContainer
					entryDelay += DELAY_BETWEEN_POSTS;
						
					// set initial animation properties
					entrySprite.alpha = 0;
					
					// create entry animation
					Animate.animateAlpha(entrySprite, 1, POST_SPEED, null, entryDelay);
				}
			}
			
			// set 'y' position of each entrySprite
			setEntryPosition();
			
			/** CREATE PAGE NAVIGATION PANEL
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			if (maxPage > 1) {
				pageNavigation = new PageNavigation(page, maxPage);
				pageNavigation.addEventListener(PageEvent.PAGE_CHANGED, onPageChanged);
				pageNavBottom = pageNavigation.drawPageNavigation(POSTS_WIDTH);

				pageNavBottom.y = entryContainer.height + 20;
				entryContainer.addChild(pageNavBottom);
			}
			
			// update swf height
			classRef.siteConfig.updateFlashHeight();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		displayEntry: draws text frames, post content into entryContainer (single entry)
		@param postIndex - index number of entry to display
		@param postTitle - optionally get entry by postTitle (post_title)
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function displayEntry(postIndex:Number = 0, postTitle:String = null):void {
			trace(">> displayEntry" + "  postIndex:" + postIndex + "  postTitle:" + postTitle);
			DataService.traceObjectField(posts, "post", "post_title", "post", "post_name", "   >>> DISPLAY DATA");
			
			// start new log - delete any existing log entries
			newLog();
			
			// get postIndex from postTitle
			if (postTitle != null) postIndex = findPostIndex(postTitle);
			
			/* draw post entry
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			trace(posts[postIndex].post.post_content);
			var entrySprite:Sprite = drawEntry(posts[postIndex], true);
			entryContainer.addChild(entrySprite);			// child 0
			
			/* display comments
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var discussionContainer:Sprite = comments.loadComments(posts[postIndex].id, postIndex, "post", int(entryContainer.height));
			entryContainer.addChild(discussionContainer);	// child 1
			
			// log display animation
			entryContainer.alpha = 0;
			Animate.animateAlpha(entryContainer, 1, POST_SPEED);	
			
			// update swf height
			classRef.siteConfig.updateFlashHeight();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		displayPage: draws text frames, page content into entryContainer (single page)
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function displayPage(pageIndex:uint):void {
			
			// start new log - delete any existing log entries
			newLog();		
			
			/* draw page entry
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var entrySprite:Sprite = new Sprite();
			entrySprite = drawEntry(pages[pageIndex], true, true, true);
			entryContainer.addChild(entrySprite);			// child 0
			
			// log display animation
			entryContainer.alpha = 0;
			Animate.animateAlpha(entryContainer, 1, POST_SPEED);	
			
			// update swf height
			classRef.siteConfig.updateFlashHeight();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		findPostIndex: returns postIndex by postName
		@param postTitle - title of post (post_title)
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function findPostIndex(postName:String):Number {	
			
			for (var key:String in posts) {
				if (posts[key].post && postName == posts[key].post.post_name) {
					return Number(key);
				}
			}
			return -1;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		newLog: start new log, removes any existing log sprites, log sprite arrays
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function newLog():void {
			
			close();						// close log
			entrySprites = new Array();		// start new individual post
			
			// create entry container
			entryContainer = new Sprite();
			logContainer.addChild(entryContainer);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		setEntryPosition: set entrySprite 'y' based on textHeight + padding
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function setEntryPosition():void {
			var previousHeight:Number = 0;
			
			for (var key:String in entrySprites) {
				// set new 'y' position
				entrySprites[key].y = previousHeight;
				// entry sprite height'
				previousHeight = int(entrySprites[key].height + previousHeight);
				// add padding
				previousHeight += ENTRY_PAD_V;
			}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawEntry: draws single post entry sprite
		@param entry - entry object
		@param fullPost - true=full postContent is shown; false=stops at <!--more--> tag
		@param noCategory - true = disables category links
		@param noDate - true = disables date text
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawEntry(entry:Object, fullPost:Boolean = false, noCategory:Boolean = false, noDate:Boolean = false):Sprite {
			
			trace("^^^ DRAW ENTRY : " + entry.post.post_name + " CATEGORY : " + entry.category);
			DataService.traceObjectData(entry);
			
			
			// create sprite, holds all post entry content
			var entrySprite:Sprite = new Sprite();
			
			// add sprite to entrySprites array
			entrySprites.push(entrySprite);
			
			// draw title text
			var titleText:TextField = new TextField();
			
			titleText = drawLink(entry.post.post_title, entry.post.index, "log/" + entry.post.post_name, "header");
			/// draw category links
			var catLinks:Sprite = new Sprite();
			if (!noCategory) {
				catLinks = drawCategoryLinks(entry.category.mergedCategories);
				catLinks.y = int(titleText.textHeight + 3);
			}
			
			// draw post date
			var dateText:TextField = new TextField();
			if (!noDate) {
				dateText = drawDate(entry.post.post_date, entry.post.index, "log/" + entry.post.post_name);		
				dateText.y = 3; // lower position offset (due to font size)
			}
			
			// draw post body, bodyContent may contain up to 2 objects: bodyText:TextField, continueLink:Sprite
			var bodyContent:Object = new Object();
			bodyContent = drawPostBody(entry.post.post_content, entry.post.index, entry.post.comment_count, "log/" + entry.post.post_name, fullPost);
			// offset bodyText from titleText + catLinks height
			bodyContent.bodyText.y = int(titleText.textHeight + catLinks.height + 15);
			
			entrySprite.addChild(titleText);						// child 0 of entrySprite
			entrySprite.addChild(dateText);							// child 1
			entrySprite.addChild(catLinks);							// child 2
			entrySprite.addChild(bodyContent.bodyText);				// child 3
			
			/* special entry items
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// draw comments count only when browsing all entries
			if (displayType != "single") {
				var commentsCount:TextField = new TextField();
				commentsCount = drawCommentsCount(entry.post.comment_count, entry.post.index, "log/" + entry.post.post_name);
				commentsCount.y = dateText.height;
				entrySprite.addChild(commentsCount);			// child 5
			}
			
			// continueLink
			if (bodyContent.continueLink != null) {
				bodyContent.continueLink.y = entrySprite.height;
				entrySprite.addChild(bodyContent.continueLink);		// child 6
			}
			
			// contact form
			if (entry.post.post_name == "contact") {
				
				var styleSheet:StyleSheet = Styles.getStyle();
				
				var contact:Sprite = new Sprite();
				contact = Contact.displayContactForm();
				contact.x = -2;
				contact.y = bodyContent.bodyText.textHeight + 10;
				entrySprite.addChild(contact);
			}
			
			entrySprite.cacheAsBitmap = true;	// cache vector as bitmap for performance
				
			return entrySprite;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawLink: create text field, text format for linkable text
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawLink(postTitle:String, postIndex:Number, hashLink:String, linkClass:String, align:String = TextFieldAutoSize.LEFT):TextField {
			
			var linkText:TextField = new TextField();
			
			// match [hide] signals to hide title link
			var hidePattern:RegExp = /\[hide\]/;
			var hide:Boolean = hidePattern.test(postTitle);
			if (hide) return linkText;	
			
			// get stylesheet
			var style:StyleSheet = Styles.getStyle(linkClass);
			
			// text field
			linkText.embedFonts = true;
			linkText.width = POSTS_WIDTH;
			linkText.autoSize = align;
			linkText.styleSheet = style;
			linkText.selectable = false;
			
			// antialiasing properties
			linkText.antiAliasType = AntiAliasType.ADVANCED;
			linkText.thickness = 200;
			linkText.sharpness = 0;
			
			// create link for all type except single view
			if (displayType != "single") {
				linkText.htmlText = "<a href='Event:" + hashLink + "'>" +  postTitle.toLocaleLowerCase() + "</a>";
				linkText.addEventListener(TextEvent.LINK, onLinkClick);
				linkText.addEventListener(MouseEvent.MOUSE_OVER, onLinkOver);
			} else {
				linkText.htmlText = "<h1>" + postTitle.toLocaleLowerCase() + "</h1>";
			}
			
			return linkText;
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onLinkClick
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onLinkClick(Event:TextEvent):void {
			classRef.navigate.changeAddress(Event.text);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onLinkOver
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onLinkOver(Event:MouseEvent):void {
			var linkTitle:TextField = Event.target as TextField;
			Sounds.playSound("link");
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawCategoryLinks: create text field, text format for categoryName(s)
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawCategoryLinks(mergedCategories:Array):Sprite {
			var catLinks:Sprite = new Sprite();
			
			// regex patterns
			var elementPattern:RegExp = /[A-Za-z0-9]+,?/g;
			var commaPattern:RegExp = /,{1}/g;
			
			/* draw links
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			for (var key:String in mergedCategories) {
				var catLink:Sprite = new Sprite();
				var linkText:TextField = new TextField();
				
				// icon
				var folderIcon:Bitmap = Draw.getBitmap("folderIcon");
				folderIcon.alpha = .3;
				folderIcon.x = 15;
				folderIcon.y = 3;
								
				// text field
				linkText.selectable = false;
				linkText.embedFonts = true;
		 		linkText.gridFitType = GridFitType.PIXEL;
				linkText.autoSize = TextFieldAutoSize.LEFT;
				linkText.styleSheet = Styles.getStyle();;
				linkText.htmlText = "<a href='Event:log/category/" + mergedCategories[key] + "'/>" +  mergedCategories[key] + "</a>"
				linkText.x = folderIcon.width + folderIcon.x;
				
				if (Number(key) != 0) catLink.x = catLinks.width + 10;
				
				catLink.addChild(linkText);
				catLink.addChild(folderIcon);
				
				catLinks.addChild(catLink);
				
				linkText.addEventListener(TextEvent.LINK, onLinkClick);
				linkText.addEventListener(MouseEvent.MOUSE_OVER, onLinkOver);
			}

			return catLinks;
		}
		

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawDate: create text field, text format for post date
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawDate(postDate:String, postIndex:Number, hashLink:String):TextField {
			
			// returned postDate example: mon may 7 20:06:25 gmt-0700 2007
			// array index				   0   1  2     3        4     5
			
			// split postDate into individual elements
			var dateElements:Array = postDate.split(" ");
			
			// month day.year (may 7.2007)
			var dateString:String = dateElements[1] + " " + dateElements[2] + "." + dateElements[5];
			
			var dateText:TextField = new TextField();
			dateText = drawLink(dateString, postIndex, hashLink, "date", TextFieldAutoSize.RIGHT);
			
			return dateText;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawPostBody: create text field, text format for post body
		@param postContent - data from posts.post_content field
		@param postIndex - posts[postIndex] index number
		@param fullPost - true=full postContent is shown; false=stops at <!--more--> tag
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawPostBody(postContent:String, postIndex:Number, commentCount:String, hashLink:String, fullPost:Boolean = false):Object {
			var bodyContent:Object = new Object();
			
			// find position of '<!--more-->' in postContent
			var moreTag:Number = postContent.indexOf("<!--more-->");
			
			// if more tag found and fullPost == false
			if (moreTag != -1 && !fullPost) {
				
				// replace postContent with snippet (content before tag)
				postContent = postContent.substring(0, moreTag);
				
				// draw 'Continue...' link 
				var continueLink:TextField = new TextField();
				continueLink = drawContinueLink(postIndex, hashLink);
				bodyContent.continueLink = continueLink; // add continueLink to bodyContent
							
			// fullPost, insert 'continued...' after moreTag
			
			} else if (moreTag != -1 && fullPost) {
				
				// find <!--more-->
				var morePattern:RegExp = /<!--more-->/g;
				// replace <!---more---> with 'continued...'
				postContent = postContent.replace(morePattern, "\u000d<span class='continued'>continued...</span>")
			
			}
			
			// fix image display in htmlText
			postContent = correctHtmlImageTextFlow(postContent, 8);
			
			// get stylesheet
			var style:StyleSheet = Styles.getStyle();

		 	// body text field
		 	var bodyText:TextField = new TextField();
		 	bodyText.embedFonts = true;
			bodyText.wordWrap = true;
		 	bodyText.gridFitType = GridFitType.SUBPIXEL;
		 	bodyText.antiAliasType = AntiAliasType.NORMAL;
			bodyText.width = POSTS_WIDTH;
			bodyText.styleSheet = style;
			bodyText.htmlText = "<body>" + postContent + "</body>"; // use snippet content
			bodyText.height = bodyText.textHeight + 20;
			
			bodyContent.bodyText = bodyText; // add bodyText
			
			return bodyContent;
		}

		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawContinueLink: create continue link for reading rest of postContent
		@param postIndex - posts[postIndex] index number
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawContinueLink(postIndex:Number, hashLink:String):TextField {

			/* text label
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var clText:TextField = new TextField();
			clText = drawLink("continue...", postIndex, hashLink, "date");
						
			return clText;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawCommentsCount: create comments count text field
		@param commentCount - number of comments for post entry
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawCommentsCount(commentCount:String, postIndex:Number, hashLink:String):TextField {
			
			// plural selection
			var commentString:String = commentCount + " comment";
			if (Number(commentCount) > 1 || Number(commentCount) == 0)	commentString += "s"
			
			var commentsText:TextField = new TextField();
			commentsText = drawLink(commentString, postIndex, hashLink, "comment", TextFieldAutoSize.RIGHT);
			
			return commentsText;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onPageChanged: event handler for pageEvent on PAGE_CHANGED
		@param event - event object contains new page property
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onPageChanged(event:PageEvent):void {
			classRef.navigate.changeAddress("log/category/" + showCategory + "/" + event.page);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 correctHtmlImageTextFlow
		 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	
		public function correctHtmlImageTextFlow(htmlTxt:String, fontSize:uint = 10):String {
			// remove optional break before and after the image tag (since we will add it anyway)
			htmlTxt = htmlTxt.replace(/<br>[\t ]*((<\/[^>]*>)*<img)/gsi, '$1');
			htmlTxt = htmlTxt.replace(/(<img[^>]+>(<\/[^>]*>)*)[\t ]*<br>/gsi, '$1');
			
			var currImgHeight:Number;
			while (htmlTxt.match(/<img[^>]*height=.[0-9]+.[^>]*>/si))
			{
				// get the height from the current image
				currImgHeight = parseInt(htmlTxt.replace(/^.*?<img[^>]*height=.([0-9]+).[^>]*>.*$/si, "$1"));
				/** Now, the magic:
				 * - temporarily rename <img tags to <xXxXimg tags, so we won't match the tag again
				 * - wrap the img tag inside textformat tags
				 * - give the textformat tag a 'leading' attribute width a value of: image height - fontSize
				 * - add a break before and after the img tag, to be sure it displays correctly on a line of it's own.
				 */
				htmlTxt = htmlTxt.replace(/<(img[^>]*height=.[0-9]+.[^>]*>)/si, '<br><textformat leading="'+Math.ceil(currImgHeight-fontSize)+'"><xXxX$1<br></textformat>');
			}
			// now un-rename the <xXxXimg tags
			htmlTxt = htmlTxt.replace(/<xXxXimg/gi, "<img");
			
			/** now check: if the image is the last visible thing in the html, then append a space to the html.
			 * Otherwise, the image's height won't be taken into account for the html's totalHeight, which
			 * causes part of the image to disappear below the end of the htmlText text box.
			 */
			if (htmlTxt.match(/<br><\/textformat>(<[^>]+>)*$/))
			{
				htmlTxt += ' ';
			}
			
			// remove optionally existing vspace and hspace from img tags (who uses this anyway??)
			htmlTxt = htmlTxt.replace(new RegExp("(<img[^>]*)hspace=.[0-9]+.", "gsi"), '$1');
			htmlTxt = htmlTxt.replace(new RegExp("(<img[^>]*)vspace=.[0-9]+.", "gsi"), '$1');
			// now set vspace=0 and hspace=0 in the img tags
			htmlTxt = htmlTxt.replace(new RegExp("<img", "gi"), '<img vspace="0" hspace="0"');
			// done!
			return htmlTxt;
		}
	}
}