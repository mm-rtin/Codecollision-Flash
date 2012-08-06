/*
     File:	DataService.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	May 12, 2007
   Edited:	May 23, 2008
    Notes:	
Functions:

*/

package com.codecollision.data {
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class DataService
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class DataService {
		
		private static var index:uint = 0;
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		updateQueryObject: updates passed in object array with result query object
		@param target - object array to add newResult data to
		@param newResult - data from newResult added to target
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function updateQueryObject(target:Object, newResult:Object):Object {
			// add updates to target
			for (var key:String in newResult) {
				
				var rowObject:Object = new Object();
				target.push(rowObject);
				
				// sample target column names at row 0
				for (var columnKey:String in target[0]) {
					rowObject[columnKey] = newResult[key][columnKey];
				}
			}
			return target;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		processIDList: processes getPostIDList data set, restructures querySet and adds fields
		@param idList - querySet object returned from idListRemoting > getPostIDList
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function processIDList(idList:Object, postCounts:Object, PAGE_SIZE:uint):Array {	
			
			var posts:Array = new Array();
			
			/** CREATE MERGED CATEGORY STRUCTURE
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var item:Object;
			
			var postID:Number;
			var categoryName:String;
			var newIDList:Object = new Object();
			var index:uint = 0;
			
			var mergedCategoryNames:Object = new Object();
			var categories:Array;
			
			for (var i:String in idList) {
				item = idList[i];
				
				postID = item.post__id;
				categoryName = item.term_taxonomy__term__name;
				
				// merge categories into single list of category names
				if (mergedCategoryNames[postID] == null) {
					
					// re-Index idList Object to account for deleted 'category entries'
					newIDList[index] = idList[i];
					index++;
					
					categories = new Array();
					categories.push(categoryName);
					mergedCategoryNames[postID] = categories;
				
				} else {
					mergedCategoryNames[postID].push(categoryName);
				}
				
				// calculate postCounts for each category
				if (postCounts[categoryName] == null) {
					postCounts[categoryName] = 1;
				} else {
					postCounts[categoryName] ++;
				}
			}
			
			/** MERGED CATEGORY Process
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var item:Object;
			var category:Object;
			var currentPageNumber:uint = 1;			// add page numbers to ID list
			
			postCounts["all"] = 0;					// init 'all' category for postCount
			
			for (var j:String in newIDList) {
				item = newIDList[j];
				
				// restructure idList structure/names to fit standard getPosts query object structure
				item.id = item.post__id;
				item.page = currentPageNumber;
				item.index = Number(j);
				
				// create Category structure
				category = new Object();
				category.name = item.term_taxonomy__term__name;
				item.category = category;
				
				// add merged category fields to item
				item.category.mergedCategories = mergedCategoryNames[item.id];
				
				// increment page number
				if (Number(j) + 1 == currentPageNumber * PAGE_SIZE) currentPageNumber++;
				
				// add idList data to posts - creates 'shell' entry for actual posts data to load in later
				posts.push(item);
				
				// Delete unused properties
				delete item.post__id;
				delete item.term_taxonomy__term__name;
				
				// increment 'all' category count
				postCounts["all"] ++;
			}
			
			return posts;
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		processPosts: processes converted posts data set, combines multiple category posts and restructures querySet
		@param cResult - object returned from convertQuery
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function processPosts(querySet:Object, posts:Array, loadedPosts:Array):void {
			
			/** RE-STRUCTURE Query Set
			 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			for (var j:String in querySet) {
				var item:Object = querySet[j];
				
				var idListItem:Object = getIDListObjectByID(posts, item.post.id);
				var index:int = idListItem.index;
				
				// convert post content
				item.post.post_content = convertPostContent(item.post.post_content);
				
				// restructure data
				posts[index].category.count = item.term_taxonomy.count;
				posts[index].category.term_id = item.term_taxonomy.term.term_id;
				posts[index].category.taxonomy = item.term_taxonomy.taxonomy;
				posts[index].category.slug = item.term_taxonomy.term.slug;
				
				// replace shell entry in posts with result object
				posts[index].post = item.post;
				
				loadedPosts.push(item.id);
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 processPage: processes converted page data set, restructures querySet
		 @param querySet - page query data
		 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function processPage(querySet:Object, pageLink:Object, pages:Array):uint {

			var newQuerySet:Object = new Object();
			
			/** RE-STRUCTURE Query Set
			 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var post:Object = new Object();
			post.post_type = querySet.post_type;
			post.post_excerpt = querySet.post_excerpt;
			post.post_date_gmt = querySet.post_date_gmt;
			post.post_title = querySet.post_title;
			post.post_password = querySet.post_password;
			post.post_parent = querySet.post_parent;
			post.post_status = querySet.post_status;
			post.guid = querySet.guid;
			post.ping_status = querySet.ping_status;
			post.post_content_filtered = querySet.post_content_filtered;
			post.post_modified_gmt = querySet.post_modified_gmt;
			post.id = querySet.id;
			post.menu_order = querySet.menu_order;
			post.post_modified = querySet.post_modified;
			post.post_author = querySet.post_author;
			post.post_date = querySet.post_date;
			post.post_mime_type = querySet.post_mime_type;
			post.post_name = querySet.post_name;
			post.post_content = querySet.post_content;
			post.pinged = querySet.pinged;
			post.comment_count = querySet.comment_count;
			post.to_ping = querySet.to_ping;
			post.comment_status = querySet.comment_status;
			
			// add page object to querySet
			newQuerySet.post = post;
			// add fields
			newQuerySet.id = post.id;
			// convert post_content
			newQuerySet.post.post_content = DataService.convertPostContent(querySet.post_content);
			
			// add object containing post_title and array index to page_reference
			pageLink[querySet.post_name] = pages.length;
			
			// push result object to pages array
			pages.push(newQuerySet);
			
			// return index of inserted page object
			return pages.length - 1;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		 getIDListObjectByID: return a specified property from the idList (ID, page)
		 @param idList - idList query object
		 @param id - post ID number
		 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function getIDListObjectByID(idList:Object, id:int):Object {
			
			for (var i:String in idList) {
				if (idList[i].id == id) return idList[i];				
			}
			return null;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		convertPostContent: removes extra carriage returns, converts tabs
		@postContent - content to convert
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function convertPostContent(postContent:String):String {					
			
			// find new lines
			var returnPattern:RegExp = /\n/g;
			// find tab (65440)
			var tabPattern:RegExp = /\t/g;
			
			
			// find <!--flashNL[10]--> used to pad paragraph to bypass text flowing around an image
			var NLPattern:RegExp = /<!--flashNL\[([\d]+)]-->/g;
			var NLResult:Object = NLPattern.exec(postContent);
			
			// create string of all new lines to replace <!--flashNL[x]-->
			if (NLResult != null) {
				var NLCount:Number = NLResult[1]; // get number of new lines to create
				var NLString:String = "";
				
				for (var i:Number = 0; i <= NLCount; i++) {
					NLString += "\n";
				}
			}
			
			// remove carriage returns
			postContent = postContent.replace(returnPattern, "")
			// replace tabs with spaces
			postContent = postContent.replace(tabPattern, " ");
			// adds new line text in place of <!--flashNL[x]-->
			postContent = postContent.replace(NLPattern, NLString);
			
			return postContent;
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		checkInput: check if input is empty and remove hazardous tags and empty trailing/leading space
		@param input - input string to check
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function checkFormInput(input:String, truncateStart:uint = 0):Object {
			
			var cleanInput:Object = new Object();
			
			// find any printable characters (non-space, tab, new line)
			var emptyPattern:RegExp = /\S/g;
			
			// remove all leading and trailing white space
			var trailingPattern:RegExp = /^\s+|\s+$/g;
			input = input.replace(trailingPattern, "");
			
			// remove excessive carriage returns (3 or more in a row) - maximum is 2 newlines in a row
			var returnPattern:RegExp = /(?:\r|\s){3,}/g;
			input = input.replace(returnPattern, "\n\n");
			
			// remove unwanted tags, except <a href> tags
			var invalidTagsPattern:RegExp = /<(?!(a\s+href.+?|\/a)).*?>/g;
			input = input.replace(invalidTagsPattern, " ");
			
			// truncate input if truncateStart != 0
			if (truncateStart != 0) input = input.slice(0, truncateStart);
			
			// set cleanInput properties
			cleanInput.input = input;
			cleanInput.empty = (input.match(emptyPattern).length == 0) ? true : false; 
			
			return cleanInput;
		}	
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		traceObjectData: recurse through an object tracing data and other objects if found
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function traceObjectData(data:Object, indent:String = " | "):void {
			for (var key:String in data) {
				
				trace(indent, key + ": " + data[key]);
				
				if (key is Object) {
					traceObjectData(data[key], indent + " | ")
				}
			} 
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		traceObjectField: recurse through an object tracing data in one field
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function traceObjectField(data:Object, object:String, field:String, object2:String, field2:String, comment:String):void {
			trace(comment);
			for (var key:String in data) {
				try {
					
					if (object2 == "root") {
						trace("       " + key + ": " + data[key][object][field] + " - " + data[key][field2]);
					} else {
						trace("       " + key + ": " + data[key][object][field] + " - " + data[key][object2][field2]);
					}
					
				} catch (error:Error) {
				}
			} 
		}

	}
}