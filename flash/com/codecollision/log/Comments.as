/*
     File:	Comments.as
 Revision:	0.5.0
  Purpose:	
  Authors:	
  Created:	May 19, 2007
   Edited:  June 13, 2008
    Notes:	
Functions:

*/

package com.codecollision.log {
	
	import flash.geom.*;
	import flash.text.*;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import flash.utils.getTimer;
	import flash.geom.ColorTransform;
	
	// custom
	import com.codecollision.graphics.Styles;
	import com.codecollision.graphics.Input;
	import com.codecollision.graphics.Draw;
	import com.codecollision.graphics.Text;
	
	import com.codecollision.data.RemotingService;
	import com.codecollision.data.DataService;

	import com.codecollision.Animate;
	import com.codecollision.Sounds;
	
	import com.codecollision.navigation.page.PageNavigation;
	import com.codecollision.navigation.page.PageEvent;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Comments
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Comments {
		
		// class references
		private var classRef:Object;
		
		// clases
		private var remotingService:RemotingService;
		private var pageNavigation:PageNavigation;
		
		// animations
		private var commentsAnimation:Animate;
		private var commentInputAnimation:Animate;
		private var inputAnimation:Animate;
				
		// containers
		private var discussionContainer:Sprite;	// holds commentsContainer, inputContainer
		
		// comment sprites
		private var commentsContainer:Sprite;	// container commentsBlock and inputContainer
		private var commentsHeader:Sprite;		// header for commentsBlock
		private var commentsBlock:Sprite;		// contains commentSprites
		// comment items
		private var headerText:TextField;
		private var tabBitmap:Bitmap;
		
		// page navigation
		private var pageNavTop:Sprite;			// page navigation controls above comments
		private var pageNavBottom:Sprite;		// page navigation controls below comments
		
		// input sprites
		private var inputContainer:Sprite;		// container for inputBlock and input headers
		private var inputHeader:Sprite;			// header for inputBlock
		private var inputBlock:Sprite;			// contains input fields
		private var replyContainer:Sprite;		// holds reply information
		// input fields
		private var nameField:Sprite;			// Fields contain bg sprites, textFields, titles
		private var commentField:Sprite;
		private var URLField:Sprite;
		private var submitButton:Sprite;
		
		// data objects
		private var comments:Array;				// all comments and replies array
				
		private var postID:uint;				// load comments for this post
		private var postIndex:uint;				// Index of post Array for updating comment count data
		
		private var lastDisplayedIndex:uint;	// index number of last comment which is displayed
		private var lastCommentID:uint;			// last comment_id loaded for passing to database for loading recent data
		private var userComment:String;			// last comment posted by client - used to display users last comment

		// page properties		
		private var pageNumber:uint;			// current page of comments
		private var maxPageNumber:uint;			// current max number of pages
		
		// properties
		private var comments_y:int;				// y coordinate of comments, used to scroll to comments position
		private var replyID:uint;				// commentID of post for comment reply submit
		private var currentDate:Date;			// current date, for selecting comment date/time style
		private var contentType:String;			// type of content 'post' or 'page'
		private var commentCount:uint;			// number of comments
		private var commentsWidth:Number;		// global width of comments
		
		// static properties
		private static const INITIAL_COMMENT_DELAY:uint = 5;
		private static const DELAY_BETWEEN_COMMENTS:uint = 1;		// animation delay between comments
		private static const COMMENT_ANIMATION_SPEED:uint = 15;		// speed of comment animation
		
		// text input constants
		private static const MAX_COMMENT_CHARS:uint = 1024;
		private static const MAX_COMMENT_LINES:uint = 20;
		private static const FIELD_ALPHA:Number = .7;
		private static const FIELD_ALPHA_ACTIVE:Number = 1;
		
		// comment display constants
		private static const MAX_COMMENTS:uint = 15;// maximum number of comments to load per page
		private static const ELEMENT_PAD:uint = 20; // space between major comment elements (comments and input)
		private static const HEADER_PAD:uint = 10;	// space between header and major element
		private static const COMMENT_PAD:uint = 4; 	// spacing between comments
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Comments constructor
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function Comments(classRef:Object, commentsWidth:Number) {

			// class references
			this.classRef = classRef;
			this.commentsWidth = commentsWidth;
			
			remotingService = new RemotingService();	// comments remoting
			discussionContainer = new Sprite();			// main container
			tabBitmap = Draw.getBitmap("tab");			// draw tab bitmap
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		loadComments: remove existing comment objects/data, create and load new comments by postID
		@param postID - retrieve only comments by postID
		@param postIndex - index of post object, used to update comment count in posts array
		@param contentType - select between post and page comments - effects comments display
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function loadComments(postID:Number, postIndex:Number, contentType:String, y:int = 0):Sprite {
			
			this.postID = postID;
			this.postIndex = postIndex;
			this.contentType = contentType;
			
			close();		// delete and reset any existing comment instances
			getComments();	// get comments data
			
			// set y position, save to comments instance for scrolling to comments y location
			comments_y = y;
			discussionContainer.y = y;
						
			return discussionContainer;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		close: remove all existing comment objects
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function close():void {
			// remove discussionContainer sprite
			try {
				discussionContainer.removeChildAt(0);	// remove commentsContainer
				discussionContainer.removeChildAt(1);	// remove inputContainer
			}
			catch (error:RangeError) {
			}
			
			// animations
			commentsAnimation = null;
			commentInputAnimation = null;
			inputAnimation = null;
					
			// comments sprites
			commentsContainer = null;
			commentsHeader = null;
			commentsBlock = null;
			headerText = null;
			
			pageNavigation = null;
			
			// input sprites
			inputContainer = null;
			inputHeader = null;
			inputBlock = null;
			replyContainer = null;
			
			nameField = null;
			commentField = null;
			URLField = null;
	
			// reset properties
			replyID = 0;
			lastCommentID = 0;
			lastDisplayedIndex = 0;
			pageNumber = 1;
			maxPageNumber = 1;
			
			// reset data objects
			comments = new Array();
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		newComments: create comments system, draw comments, headers and comment input
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function newComments():void {
			
			// new pageNavigation
			pageNavigation = new PageNavigation(pageNumber, maxPageNumber);
			// listen for pageChanged even from PageNavigation
			pageNavigation.addEventListener(PageEvent.PAGE_CHANGED, onPageChanged);
			
			// reset sprites
			commentsContainer = new Sprite();
			commentsHeader = new Sprite();
			commentsBlock = new Sprite();
			
			pageNavTop = new Sprite();
			pageNavBottom = new Sprite();
			
			inputContainer = new Sprite();
			inputHeader = new Sprite();
			inputBlock = new Sprite();
			replyContainer = new Sprite();
			
			/* draw comment, input and page navigation elements
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			commentsHeader = drawCommentsHeader();
			commentsBlock = displayComments();
			
			pageNavTop = pageNavigation.drawPageNavigation(commentsWidth, false, true, "top");
			pageNavBottom = pageNavigation.drawPageNavigation(commentsWidth, true, true, "bottom");
			
			inputHeader = drawInputheader();
			inputBlock = displayInput();
			
			// add elements to display list
			discussionContainer.addChild(commentsContainer);
			discussionContainer.addChild(inputContainer);
			
			commentsContainer.addChild(commentsHeader);
			commentsContainer.addChild(commentsBlock);
			
			commentsContainer.addChild(pageNavTop);
			commentsContainer.addChild(pageNavBottom);
			
			inputContainer.addChild(inputHeader);
			inputContainer.addChild(inputBlock);
			inputContainer.addChild(replyContainer);
			
			// set element properties
			commentsBlock.y = int(commentsHeader.height + HEADER_PAD);
			
			pageNavTop.visible = false;
			pageNavTop.alpha = 0;
			pageNavTop.y = 8;
			
			pageNavBottom.visible = false;
			pageNavBottom.alpha = 0;
			pageNavBottom.y = int(commentsBlock.y + commentsBlock.height);
			
			inputContainer.y = int(commentsContainer.height + ELEMENT_PAD);
			inputHeader.alpha = 0;
			inputBlock.y = int(inputHeader.height + HEADER_PAD);
			inputBlock.alpha = 0;
			
			// entry animations for elements
			Animate.animateAlpha(inputHeader, 1, 20, null, 20);	// inputHeader	
			Animate.animateAlpha(inputBlock, 1, 20, null, 30);	// commentInput
			
			// update SWF height
			classRef.siteConfig.updateFlashHeight();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getComments: loads data from comments table through remoting cfc
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function getComments():void {
			// get comments from database
			remotingService.getComments(onCommentsResult, postID, lastCommentID);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onCommentsResult: query data loaded through remotingService returned here
		@param result - converted and returned query data
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onCommentsResult(result:Object):void {
	
			DataService.traceObjectData(result);
			
			processComments(result);			// processComments and save to comments array
			commentCount = comments.length;		// set count	
			newComments();						// start new comments
			
			// update comments count in log posts
			classRef.log.updateCommentCount(postIndex, commentCount, contentType);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		processComments: add data to result object and push to comments array. For updates
						 new results are sorted into the array based on comment_order
		@param result - raw result data from remoting call
		@param update - true = iterate through comments array, adjust page numbers and reposition new update
		@return userCommentPage - user submitted comment page number
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function processComments(result:Object, update:Boolean = false):uint {
			
			var page:uint = 1;
			var userCommentPage:uint = 0;
			
			// iterate through results
			for (var key:String in result) {
				
				var stop:Boolean = false; 							// allow only 1 splice insert per result
				
				if (result[key].comment_id > lastCommentID) {
					lastCommentID = result[key].comment_id;			// set latest commentID
				}
				
				if (uint(key) == page * MAX_COMMENTS) page++;		// calculate new page number for next set
				result[key].page = page;							// give each comment an associated page number
				result[key].commentNumber = comments.length;		// set ordered comment index
				result[key].highlight = false;						// initial load, do not flag as new
				comments.push(result[key]);							// add entry to comments array

				// if updating comments array, splice new entries to the array in order and update page numbers
				if (update) {
					comments[comments.length - 1].highlight = true;	// flag comment as new
					page = 1;										// reset page number
					
					for (var ckey:String in comments) {
						
						if (!stop && comments[ckey].comment_order > result[key].comment_order) {
							comments.splice(int(ckey), 0, comments.pop());
							stop = true;
						}
						
						if (uint(ckey) == page * MAX_COMMENTS) page++;	// recalulate page number
						comments[ckey].page = page;						// set updated page numbers
						
						// get clients last posted comment's page number if any
						if (comments[ckey].comment_content == userComment) {
							userCommentPage = comments[ckey].page;
						}
					}
				}
				
				// only set new maxPageNumber if there is 1 or more new comment results
				maxPageNumber = page;
			}
			
			return userCommentPage;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		displayComments: draws text frames and comment data into discussionContainer
		@param parents - array of parent comments
		@param replies - array of replies to parent comments
		@param update - true = update existing comments
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function displayComments(update:Boolean = false, pageChange:Boolean = false):Sprite {		
			
			// display properties
			var commentsBlock:Sprite = new Sprite();		// container
			if (update) commentsBlock = this.commentsBlock;	// set commentsBlock to existing sprite
			var commentSprite:Sprite;						// sprite reference
			
			var colorKey:uint = 0;							// alternate color index
			var highlight:Boolean = false;					// true = highlight newly drawn entries
			var alphaDelay:Number = INITIAL_COMMENT_DELAY;	// delay increment for alpha animation
			var totalCommentHeight:int = 0;					// tally of comment heights for positioning
			var ybase:int = 0;								// new y coordinate of pageNavBottom
			currentDate = new Date();						// set new currentDate
			
			// calculate index of last displayed comment
			lastDisplayedIndex = (comments.length > MAX_COMMENTS) ? (pageNumber) * MAX_COMMENTS - 1 : comments.length - 1;
			lastDisplayedIndex = (lastDisplayedIndex > comments.length - 1) ? comments.length - 1 : lastDisplayedIndex;
			
			// add extra delay and highlight new comments if not changing pages and updating
			if (!pageChange && update) {
				highlight = true;
				alphaDelay = 20;
			}
			
			/* generate comments
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			for (var key:String in comments) {
	
				commentSprite = comments[key].commentSprite;		// attempt to get existing commentSprite, else null
				if (comments[key].comment_parent == 0) colorKey++;	// if comment is root (parent) increment alternate row key
				
				// only display entries which belong to the current page
				if (comments[key].page == pageNumber) {
					// create new comment if existing does not exist, else update existing
					if (!commentSprite) {
						// draw comment
						commentSprite = drawComment(key, colorKey, false, (comments[key].comment_parent == 0) ? false : true, highlight);
						setupCommentSprite(commentsBlock, commentSprite, key, colorKey, alphaDelay);
						// increment properties
						alphaDelay += DELAY_BETWEEN_COMMENTS;
					} else {
						updateCommentSprite(key);
					}
					
					totalCommentHeight = updateCommentPosition(comments[key], totalCommentHeight);
					ybase += commentSprite.height;
					
				// delete entries which do not belong on current page
				} else if (commentSprite) {
					commentsBlock.removeChild(commentSprite);	// remove commentSprite from block
					comments[key].commentSprite = null;			// null sprite reference
					comments[key].highlight = false;			// reset comment as old
				}

			}
			
			// update pageButtons and animate new 'y' position for inputContainer and pageNavigation
			if (update) {
				ybase += commentsBlock.y;
				Animate.animatePosition(pageNavBottom, 0, ybase, 20, false, "easeOutExpo", classRef.siteConfig.updateFlashHeight);
				Animate.animatePosition(inputContainer, 0, ybase + pageNavBottom.height + ELEMENT_PAD, 15, false, "easeOutExpo", classRef.siteConfig.updateFlashHeight);
			} 
			return commentsBlock;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		setupCommentSprite: sets newly drawn commentSprite properties and animation
		@param target - sprite object to add commentSprite to
		@param commentSprite - result of drawComment
		@param datasource - parents/replies source selection
		@param key - index of comment object
		@param colorKey - for replies, matches reply color to parent color
		@param delay - time to delay enter Animation
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function setupCommentSprite(target:Sprite, commentSprite:Sprite, key:String, colorKey:uint, delay:uint):void {	
			
			commentSprite.cacheAsBitmap = true;					// cache vector as bitmap for performance
			var commentID:uint = comments[key].comment_id;		// get commentID

			// save sprite data to comments array
			comments[key].commentSprite = commentSprite;		// save reference to commentSprite
			comments[key].height = commentSprite.height;		// save commentSprite height, initial value is saved as height may change with animation
			comments[key].colorKey = colorKey;					// save color key for replies
			
			// commentSprite enter animation
			commentSprite.alpha = 0;
			target.addChild(commentSprite);
			Animate.animateAlpha(commentSprite, 1, COMMENT_ANIMATION_SPEED, (lastDisplayedIndex == uint(key)) ? commentsDisplayComplete : null, delay);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		updateCommentSprite: updates date link within commentSprite and commentBG.name with new key value
		@param key - comments array index
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function updateCommentSprite(key:String):void {	
			
			var comment:Object = comments[key];
			var commentSprite:Sprite = comment.commentSprite;
			
			// update date TextField
			var dateText:TextField = commentSprite.getChildByName("dateText") as TextField;
			var date:Date = new Date(comment.comment_date);	
			var dateObject:Object = formatDate(date);
			dateText.htmlText = "<a href='Event:" + dateObject.subDate + "'>" + dateObject.date + "</a>";
			
			// update commentBG.name
			var commentBG:Sprite = commentSprite.getChildAt(0) as Sprite;
			commentBG.name = key;
		}	
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		updateCommentPosition: updates commentSprite y position and returns comment height + y for new totalHeight
		@param comment - comment object from a comments array
		@param y - 'y' position to place commentSprite
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function updateCommentPosition(comment:Object, y:int):uint {	
			
			var commentSprite:Sprite = comment.commentSprite;
			
			if (commentSprite.y == 0) {
				commentSprite.y = y;
			} else {
				var rand:int = int(Math.random() * 10);
				Animate.animatePosition(commentSprite, 0, y, rand + 5, false, "easeInOut", null, rand);
			}
			return y + comment.height;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		commentsDisplayComplete: run when last commentID has finished 'entry animation'
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function commentsDisplayComplete():void {	
			
			// show pageNavigation sprites
			if (pageNavTop.alpha == 0 && maxPageNumber > 1) {
				Animate.animateAlpha(pageNavTop, 1, 20);
				Animate.animateAlpha(pageNavBottom, 1, 20);
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawCommentsHeader: draws comment headerText and addCommentLink
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawCommentsHeader():Sprite {	
			
			var commentsHeader:Sprite = new Sprite();							// create header container
			var commentsTitle:String = getCommentHeaderString(commentCount);	// get title string
			
			headerText = Text.drawTextField(commentsTitle, "global", false, true);
			commentsHeader.addChild(headerText);
			
			// draw add comment link
			if (commentCount > 5) {
				var addCommentLink:TextField = Text.drawEventLink("[ ADD COMMENT ]", null, "linkButton", onAddCommentClick, onLinkOver);
				
				addCommentLink.x = int(headerText.width + 15);
				addCommentLink.y = 5;
				commentsHeader.addChild(addCommentLink);
			}
			
			return commentsHeader;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getCommentHeaderString: creates and returns complete comment header text
		@param commentCount - count to insert into header title
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function getCommentHeaderString(commentCount:uint):String {	
			
			var commentsTitle:String;
			if (commentCount == 0) {
				commentsTitle = "No Comments";
			} else if (commentCount == 1) {
				commentsTitle = commentCount + " comment";
			} else {
				commentsTitle = commentCount + " comments";
			}
			
			return "<span class='subHeader'>" + commentsTitle + "</span>";
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawComment: draws single comment entry sprite
		@param key - comments data row to populate comment
		@param colorKey - user colorkey to select alternate background color
		@param replyDisplay - if true omit features for reply display only
		@param reply - true = comment is a reply to another comment
		@param update - true = comment is a new update
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawComment(key:String, colorKey:uint, replyDisplay:Boolean = false, reply:Boolean = false, update:Boolean = false):Sprite {
			
			var width:uint = commentsWidth;
			var xOffset:uint = 0;
			
			// select properties based on comment or reply
			if (reply) {
				width = commentsWidth - 40;
				xOffset = 40;
			}
			
			var commentNum:uint = comments[key].commentNumber; 
			var colorIndex:uint = colorKey;
			var commentID:uint = comments[key].comment_id;
			var commentAuthor:String = comments[key].comment_author;
			var authorEmail:String =  comments[key].comment_author_email;
			var authorURL:String =  comments[key].comment_author_url;
			var commentContent:String = comments[key].comment_content;
			// coldfusion passes date with server timezone, actionscript converts timezone to client time o.O
			var commentDate:Date =  new Date(comments[key].comment_date);	
			
			var commentSprite:Sprite = new Sprite();		// create sprite, holds individual comment
			// draw comment number
			var number:uint = commentNum + 1;
			var commentNumber:TextField = Text.drawTextField("<h4>" + number + ".</h4>");
			commentNumber.name = "commentNumber";	
			
			// draw author link (name, url)
			var authorLink:TextField = new TextField();
			authorLink = drawAuthorLink(commentAuthor, authorURL);
			
			// draw date text
			var dateText:TextField = new TextField();
			dateText = drawCommentDate(commentDate);
			dateText.name = "dateText";
			
			// draw comment body (content)
			var commentBody:TextField = new TextField();
			commentBody = drawCommentBody(colorIndex, commentContent, commentsWidth - xOffset - 25);
			
			// draw comment background
			var commentBG:Sprite = new Sprite();
			commentBG.name = key;							// save key as name property for reply linking
			
			commentBG.addChild(commentBody);				// child 0 of comemntBG
			// add to commentSprite
			commentSprite.addChild(commentBG);				// child 0 (contains bodyText) !!! this is referenced by updateSprite() as child 0
			commentSprite.addChild(commentNumber);			// child 1
			commentSprite.addChild(authorLink);				// child 2
			commentSprite.addChild(dateText);				// child 3
			
			// set positions & sizes
			commentNumber.x = 8 + xOffset;
			commentNumber.y = 6;
			authorLink.x = commentNumber.width + 6 + xOffset;
			authorLink.y = 6;
			dateText.x = dateText.x -7;
			dateText.y = 8;
			commentBody.x = authorLink.x - xOffset;
			commentBody.y = 27;
			commentBG.x = xOffset;
			
			// draw commentBG last to get total commentSprite height
			drawCommentBG(commentBG, colorIndex, width, commentSprite.height + 10);
			
			// add events for replyDisplay and comments which are not replies
			if (replyDisplay) {
				commentBG.addEventListener(MouseEvent.ROLL_OVER, onReplyCommentOver, false, 0, true);
				commentBG.addEventListener(MouseEvent.ROLL_OUT, onCommentOut, false, 0, true);
			} else if (!reply) {
				// add comment button event listeners
				commentBG.addEventListener(MouseEvent.ROLL_OVER, onCommentOver, false, 0, true);
				commentBG.addEventListener(MouseEvent.ROLL_OUT, onCommentOut, false, 0, true);
			}
			
			// update colors
			if (comments[key].highlight) {
				commentSprite.transform.colorTransform = new ColorTransform(1, 1.3, 1.3, 1, 0, 0, 0, 0);
			}
			
			return commentSprite;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawAuthorLink: draws author name textField with authorURL
		@param commentAuthor - author name
		@param authorURL - optional author link
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawAuthorLink(commentAuthor:String, authorURL:String):TextField {
			
			var authorText:TextField = new TextField();
			
			// only add <a> link and events if URL exists
			if (authorURL != "") {
				// check for http:// and add if missing
				var httpPattern:RegExp = /http:\/\//;
				var match:Boolean = httpPattern.test(authorURL);
				if (!match) authorURL = "http://" + authorURL; 
				authorText = Text.drawEventLink(commentAuthor.toUpperCase(), authorURL, "commentAuthor", onAuthorClick, onAuthorOver, onTooltipLinkOut);
			} else {
				authorText = Text.drawTextField("<span class='commentAuthor'>" + commentAuthor.toUpperCase() + "</span>", "commentAuthor");
			}

			return authorText;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawCommentDate: draws comment date textField
		@param commentDate - date of comment
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawCommentDate(commentDate:Date):TextField {
			
			var dateObject:Object = formatDate(commentDate);	// format date
			var dateText:TextField = Text.drawEventLink(dateObject.date, dateObject.subDate, "commentDate", null, onDateOver, onTooltipLinkOut, false, commentsWidth, TextFieldAutoSize.RIGHT);
			return dateText;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawCommentDate: formats date object and returns new date string
		@param commentDate - date of comment
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function formatDate(date:Date):Object {
			
			// returned postDate example: mon may 7 20:06:25 gmt-0700 2007
			// array index				   0   1  2     3        4     5
			
			// split commentDate into individual elements
			var dateString:String = date.toString();
			var dArray:Array = dateString.split(" ");
			
			/* convert to 12-hour format
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var hour:Number = date.getHours() // hour
			var tt:String; // am or pm
			
			if (hour > 12) {
				tt = "pm";
				hour -= 12;
			} else if (hour == 12) {
				tt = "pm";
			} else if (hour == 0) {
				tt = "am";
				hour = 12;
			} else {
				tt = "am";
			}
			
			/* 'Sun Dec 2.2007 7:40pm'
			dateString =  date.getDate() + " " + dArray[1] + " / " + time;
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
			var timeMinutes:String = (date.getMinutes() < 10) ? "0" + date.getMinutes() : date.getMinutes().toString();
			var time:String = hour + ":" + timeMinutes + " " + tt;
			var subDate:String = time;	// default subDate
			
			// get differences
			var diff:int = currentDate.valueOf() - date.valueOf();
			var sameYear:int = currentDate.fullYear - date.fullYear;	// 0 = year is same
			var sameDate:int = currentDate.getDate() - date.getDate();	// 0 = day of month is the same
			var hours:int = diff / 3600000;		// hours
			var minutes:int = diff / 60000;		// minutes
			var seconds:int = diff / 1000;		// seconds		
			
			if (sameYear != 0) {
				dateString =  date.getDate() + " " + dArray[1] + "." + date.fullYear;
			} else if (sameDate != 0 || hours > 24) {
				dateString = date.getDate() + " " + dArray[1];
			} else if (hours > 0) {
				dateString = time;
				subDate = date.getDate() + " " + dArray[1];
			} else if (minutes > 0) {
				dateString = minutes + " minutes ago";
				if (minutes == 1) dateString = "1 minute ago";
			} else {
				dateString = "&lt; 1 minute";
			}
			
			// create formated date object
			var dateObject:Object = new Object();
			dateObject.date = dateString;
			dateObject.subDate = subDate;
			
			return dateObject;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawCommentBody: draws comment content
		@param commentIndex - select comment text color for alternating rows
		@param commentContent - content
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawCommentBody(commentIndex:uint, commentContent:String, width:uint):TextField {
			var commentClass:String;
			
			// bitwise AND with index, 0=even 1=odd
			if (commentIndex & 1) {
				commentClass = "comment1";
			} else {
				commentClass = "comment2";
			}
			
			// multiline text field
			var bodyText:TextField = Text.drawMultiLineTextField("<span class='" + commentClass + "'>" + commentContent + "</span>", "global", true, false, width, 15);  
			return bodyText;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawCommentBG: draws shaded bitmap behind comments
		@param commentIndex - used to choose alternating color
		@param width - width of BG
		@param height - height of BG
		@param update - true = highlight comment to make it stand out from old comments
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawCommentBG(commentBG:Sprite, commentIndex:Number, width:Number, height:Number):void {
			
			var graphicsStyle:Object = Styles.getGraphicsStyle("comment");
			
			// bitwise AND with index, 0=even 1=odd
			var color1:Number;
			var color2:Number;
			if (commentIndex & 1) {
				color1 = graphicsStyle.boxGradientStart1;
				color2 = graphicsStyle.boxGradientEnd1;
			} else {
				color1 = graphicsStyle.boxGradientStart2;
				color2 = graphicsStyle.boxGradientEnd2;
			}
			
			// draw gradientFill on commentBG
			Draw.drawGradientFill(commentBG, width, height, color1, color2);
			// draw round rectangle
  			Draw.drawRoundRect(commentBG, width, height, 0, 0);
			
			// draw gap filler, used to add spacing between comments
			commentBG.graphics.moveTo(0, height + COMMENT_PAD);
			commentBG.graphics.lineTo(0, height + COMMENT_PAD);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		displayTabMenu: display comment tab menu
		@param commentSprite - display tab menu over commentSprite
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function displayTabMenu(commentBG:Sprite, link:String = "reply"):void {
			
			// get comment number, comment data key was set as commentBG.name property
			var key:String = commentBG.name;

			// draw tab
			var tabContainer:Sprite = drawTab();
			tabContainer.name = "tabContainer";
			
			// create tab menu
			var tabMenu:Sprite = new Sprite();
			tabMenu.name = "tabMenu";
			tabMenu.x = int((commentsWidth - tabContainer.width) / 2);
			
			// draw link
			var tabLink:TextField = new TextField();
			if (link == "reply") {
				tabLink = Text.drawEventLink("REPLY", key, "linkButton", onReplyClick, onLinkOver);
			} else if (link == "close") {
				tabLink = Text.drawEventLink("CLOSE", key, "linkButton", onCloseClick, onLinkOver);
			}
			
			tabLink.visible = false;
			tabLink.alpha = 0;
			tabLink.x = 20;
			tabLink.y = -2;
			
			// add to display list
			tabMenu.addChild(tabContainer);
			tabMenu.addChild(tabLink);
			commentBG.addChild(tabMenu);
			
			// animate
			var tab:Bitmap = tabContainer.getChildByName("tab") as Bitmap;
			Animate.animatePosition(tab, 0, tabBitmap.height, 15, true, "easeOutExpo", null, 10, "click");
			Animate.animateAlpha(tabLink, 1, 10, null, 13);
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		removeTabMenu: remove comment tab menu
		@param commentSprite - commentSprite to remove tab menu from
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function removeTabMenu(commentSprite:Sprite):void {
			
			try {
				var tabMenu:Sprite = commentSprite.getChildByName("tabMenu") as Sprite;
				var tabContainer:Sprite = tabMenu.getChildByName("tabContainer") as Sprite;
				var tab:Bitmap = tabContainer.getChildByName("tab") as Bitmap;
				commentSprite.removeChild(tabMenu);
			} catch (error:Error) {
			}
			
			Animate.stopAnimation(tab, "position");		// stop tab animation
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawTab: draw tab menu bitmap with mask
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawTab():Sprite {
			
			var tabContainer:Sprite = new Sprite();
			
			// draw mask
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0x000000);
			mask.graphics.drawRect(0, 0, 80, 19);
			mask.graphics.endFill();

			// draw tab
			var tab:Bitmap = new Bitmap(tabBitmap.bitmapData);
			tab.name = "tab";
			tab.y = -tabBitmap.height;
			tab.mask = mask;
			
			// add to display list
			tabContainer.addChild(tab);
			tabContainer.addChild(mask);
			
			return tabContainer;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~s
		getUpdatedComments: loads only updated comment data from comments table through remoting cfc
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function getUpdatedComments(postID:Number, lastCommentID:Number = 0):void {
			// get updated comments from database
			remotingService.getComments(onUpdateResult, postID, lastCommentID);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onUpdateResult: query data loaded through remotingService returned here
		@param result - converted and returned query data
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onUpdateResult(result:Object):void {
			
			var userCommentPage:uint = processComments(result, true);		// processComments and save to comments array
			commentCount = comments.length;									// set number of comments

			// update pageButtons in PageNavigation
			pageNavigation.updatePageButtons(maxPageNumber);
			// update comments count in log posts
			classRef.log.updateCommentCount(postIndex, commentCount, contentType);
			// update comment count in commentsHeader
			headerText.htmlText = getCommentHeaderString(commentCount);
			
			// update comments
			trace(userCommentPage);
			if (userCommentPage != 0) {
				pageNavigation.changePage(userCommentPage.toString());
			} else {
				displayComments(true);
			}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		displayInput: draws inputBlock with input fields and submit button
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function displayInput():Sprite {		
			
			// create inputBlock
			var inputBlock:Sprite = new Sprite();
			
			/* draw fields
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// draw name field
			nameField = Input.drawField(160, 21, "NAME", "input1", 20, 2, 0);
			// draw URL field
			URLField = Input.drawField(180, 21, "URL", "input2", 50, 2, 0);
			URLField.x = int(nameField.width);
			// draw comment field
			commentField = Input.drawField(commentsWidth, 120, "COMMENT", "input2", MAX_COMMENT_CHARS, 2, 0, true);
			commentField.y = 24;
			// draw submit button
			submitButton = Input.drawButton(onSubmitClick, true);
			submitButton.y = int(commentField.y + commentField.height + 2);
			
			// add to inputBlock
			inputBlock.addChild(nameField);
			inputBlock.addChild(URLField);
			inputBlock.addChild(commentField);
			inputBlock.addChild(submitButton);
			
			// add commentField > textField listener
			var commentText:TextField = commentField.getChildByName("text") as TextField;
			commentText.addEventListener(TextEvent.TEXT_INPUT, onCommentInput, false, 0, true);
			
			// if button was left disabled, disable submit button again for remaining time
			if (Input.isDisabled()) Input.disableButton(submitButton);
			
			inputBlock.cacheAsBitmap = true;	// cache vector as bitmap for performance
			return inputBlock;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		drawInputheader: draws header title and refreshLink for input
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function drawInputheader():Sprite {
			
			var inputHeader:Sprite = new Sprite();
			
			// draw post comment header
			var inputTitle:TextField = Text.drawTextField("<span class='subHeader'>post comment</span>", "global", false, true);
			inputTitle.name = "inputTitle";
			
			// draw refresh comments link
			var refreshLink:TextField = Text.drawEventLink("[ REFRESH COMMENTS ]", null, "linkButton", onRefreshClick, onLinkOver);
			refreshLink.x = 160;
			refreshLink.y = 5;
			
			inputHeader.addChild(inputTitle);
			inputHeader.addChild(refreshLink);
			
			inputHeader.cacheAsBitmap = true;	// cache vector as bitmap for performance
			return inputHeader;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onSubmitClick: submit button click
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onSubmitClick(Event:MouseEvent):void {
			
			// get textfields
			var nameText:TextField = nameField.getChildByName("text") as TextField;
			var URLText:TextField = URLField.getChildByName("text") as TextField;
			var commentText:TextField = commentField.getChildByName("text") as TextField;
			
			submitComment(this.postID, commentText, nameText, URLText);
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		openReplyReference: draw the comment user is replying to as reference
		@param key - comment index of reply to source
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function openReplyReference(key:String):void {
			
			closeReplyReference();	// close any existing reply references
			
			var commentID:uint = comments[key].comment_id;	// get commentID
			var colorKey:uint = comments[key].colorKey;		// colorKey
			replyID = commentID;							// set replyID for submitComment
			
			// draw comment
			var commentSprite:Sprite = drawComment(key, colorKey, true);
			replyContainer.addChild(commentSprite);
			
			// set new title for inputHeader > postHeader
			var inputTitle:TextField = inputHeader.getChildByName("inputTitle") as TextField;
			inputTitle.htmlText = "<span class='subHeader'>post response</span>";
			
			// replyContainer properties
			replyContainer.alpha = 0;
			replyContainer.y = int(inputHeader.height) + HEADER_PAD;

			// enter animations
			Animate.animateAlpha(replyContainer, 1, 20, null, 10);
			Animate.animatePosition(inputBlock, 0, replyContainer.y + replyContainer.height + inputHeader.y + HEADER_PAD, 10, false, "easeOut", onReplyDone, 0, "zip");
		
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		closeReplyReference: remove reply reference, reset replyID and revert inputBlock to original position
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function closeReplyReference():void { 
			
			replyID = 0;	// reset replyID
			
			// set new title for inputHeader > postHeader
			var inputTitle:TextField = inputHeader.getChildByName("inputTitle") as TextField;
			inputTitle.htmlText = "<span class='subHeader'>post comment</span>";
			
			// animate inputBlock to original position
			Animate.animatePosition(inputBlock, 0, int(inputHeader.height + HEADER_PAD), 10, false, "easeOut", classRef.siteConfig.updateFlashHeight, 0, "zip");
			
			// remove commentSprite
			try {
				replyContainer.removeChildAt(0);
			} catch (error:RangeError) {
			}
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onReplyDone: scroll to bottom and update flash height when reply animation complete
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onReplyDone():void {
			classRef.siteConfig.updateFlashHeight();	// update swf height
			classRef.siteConfig.scroll("bottom");		// scroll to bottom
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		submitComment: submit comment to comments table through remoting cfc
		@param postID - post ID associate comment with
		@param comment - comment body
		@param name - author name
		@param URL - author site
		@param disabledTime - time comment input is disabled after post
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function submitComment(	postID:Number, 
										commentText:TextField, 
										nameText:TextField,
										URLText:TextField):void {

			// get index of first character past MAX_COMMENT_LINES line
			try {
				var startIndex:uint = commentText.getLineOffset(MAX_COMMENT_LINES);
			} catch (error:Error) {
				
			}
			
			// clean comment first for submit requirements
			var cleanComment:Object = DataService.checkFormInput(commentText.text, startIndex);
			
			// only if comment not empty and timeout == false
			if (!cleanComment.empty && !Input.isDisabled()) {
				
				// clean remaining inputs
				var cleanName:Object = DataService.checkFormInput(nameText.text);
				var cleanURL:Object = DataService.checkFormInput(URLText.text);
				
				// save comment input for returning user to page containing comment
				userComment = cleanComment.input; 
				
				Input.newMessage(commentField, "TRANSMITTING...", true, commentText);	// Sending message box
				remotingService.submitComment(onSubmitResult, postID, cleanComment.input, cleanName.input, cleanURL.input, replyID, Input.DISABLED_TIME);
			
			} else if (!Input.isDisabled()) {
				Input.newMessage(commentField, "ERROR: NO MESSAGE");		// Field Error message box
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onSubmitResult: status of submitComment remoting call
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onSubmitResult(result:Object):void {
			// if comment sucessful, start commentTimeout DISABLED_TIME second timer
			if (result) {

				closeReplyReference();	// close and reset reply reference window			
				
				// show message box > success
				Input.newMessage(commentField, "COMMENT POSTED");
				
				var commentText:TextField = commentField.getChildByName("text") as TextField;
				commentText.text = "";						// clear comment field
				Input.unfocus(commentField);				// reset comment alpha
				
				getUpdatedComments(postID, lastCommentID);	// update comments
				Input.disableButton(submitButton);			// disable submit button
			
			} else {
				
				// show message box > TIME FAILURE
				Input.newMessage(commentField, "POSTED WITHIN " + Input.DISABLED_TIME + " SECONDS");
			}
		}
		
		/* MOUSE EVENTS
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onCommentOver - handles hover over commentSprite background button
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onCommentOver(Event:MouseEvent):void {
			displayTabMenu(Event.target as Sprite);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onReplyCommentOver - handles hover over commentSprite as a reply reference
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onReplyCommentOver(Event:MouseEvent):void {
			displayTabMenu(Event.target as Sprite, "close");
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onCommentOut - handles mouse out from commentSprite button
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onCommentOut(Event:MouseEvent):void {
			removeTabMenu(Event.target as Sprite);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onCommentInput - handles event for input into commentField textField
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onCommentInput(Event:TextEvent):void {
			
			var commentText:TextField = Event.target as TextField;
			
			// check if max lines reached > display error
			if (commentText.numLines == MAX_COMMENT_LINES + 1) {
				Input.newMessage(commentField, "WARNING: " + MAX_COMMENT_LINES + " LINE LIMIT REACHED", false, commentText);
			} else if (commentText.numLines > MAX_COMMENT_LINES + 1) {
				Input.newMessage(commentField, "TEXT BELOW LINE " + MAX_COMMENT_LINES + " MAY BE REMOVED", false, commentText);
			}
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onAuthorOver - handles event mouse over for comment authorLink
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onAuthorOver(Event:MouseEvent):void {

			// use regex to match Event.text in htmlText, set to text string
			// since the event is not returning MouseEvent and not a TextEvent		
			var linkPattern:RegExp = /'Event:(.*)'/g;
			var linkResult:Object = linkPattern.exec(Event.target.htmlText);
			
			if (linkResult) {
				var text:String = linkResult[1];
				classRef.tooltip.newTooltip(Event.target, Event.target.parent, text, "right", Event.target.y);
			}
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onAuthorClick - handles event for authorLink click
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onAuthorClick(Event:TextEvent):void {
			navigateToURL(new URLRequest(Event.text), "_blank");	// go to URL
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onDateOver - handles event for date mouse over
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onDateOver(Event:MouseEvent):void {
			
			// use regex to match Event.text in htmlText, set to text string			
			var linkPattern:RegExp = /'Event:(.*)'/g;
			var linkResult:Object = linkPattern.exec(Event.target.htmlText);
			var text:String = linkResult[1];
			
			classRef.tooltip.newTooltip(Event.target, Event.target.parent, text, "left", Event.target.y);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onTooltipLinkOut - handles event for links using tooltip on mouse out 
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onTooltipLinkOut(Event:MouseEvent):void {
			classRef.tooltip.close();			
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onRefreshClick - handles event for refresh comments link on click
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onRefreshClick(Event:TextEvent):void {
			getUpdatedComments(postID, lastCommentID);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onAddCommentClick - handles event for add comment link on click
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onAddCommentClick(Event:TextEvent):void {
			classRef.siteConfig.scroll("bottom");
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onLinkOver - handles event for generic link on mouse over
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onLinkOver(Event:MouseEvent):void {
			Sounds.playSound("beep");
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onReplyClick - handles event for reply button on click
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onReplyClick(Event:TextEvent):void {
			openReplyReference(Event.text);
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onCloseClick - handles event for close button on click
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onCloseClick(Event:TextEvent):void {
			closeReplyReference();
		}
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		onPageChanged - handles event for PageNavigation class 'pageChanged' custom event
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private function onPageChanged(Event:PageEvent):void {
			trace(Event.ID);
			// scroll to top only if page is different and navigation ID is "bottom"
			if (pageNumber != uint(Event.page) && Event.ID == "bottom") {
				classRef.siteConfig.scroll("custom", comments_y);
			}
					
			pageNumber = Event.page;		// get new page number from Event and save
			displayComments(true, true);	// update comments with new page
			Sounds.playSound("zip");
		}
	}
}