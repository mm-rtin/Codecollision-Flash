/*
     File:	Styles.as
 Revision:	0.2.0
  Purpose:	
  Authors:	
  Created:	May 14, 2008
   Edited:	June 05, 2008
    Notes:	
Functions:

*/

package com.codecollision.graphics {

	import flash.text.StyleSheet;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Styles
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Styles {
		
		/* embed font assets
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    	[Embed(source="..\\..\\..\\embed\\Seraphic Organism.ttf", fontName="Header", mimeType="application/x-font-truetype")]
    	private static var HeaderFont:Class;
    	
    	[Embed(source="..\\..\\..\\embed\\FFF Hero.ttf", fontName="PixelLarge", mimeType="application/x-font-truetype")]
    	private static var PixelLargeFont:Class;

        [Embed(source="..\\..\\..\\embed\\FFF Protege Extended.ttf", fontName="PixelSmall", mimeType="application/x-font-truetype")]
    	private static var PixelSmallFont:Class;
   
        [Embed(source="..\\..\\..\\embed\\FFF Bionic.ttf", fontName="PixelHeavy", mimeType="application/x-font-truetype")]
    	private static var BionicFont:Class;
  
		// global styles
		private static var global:StyleSheet;
		
		// link styles
		private static var header:StyleSheet;			// log header title
		private static var date:StyleSheet;				// log date title
		private static var comment:StyleSheet;			// log comment title
		private static var catLink:StyleSheet;			// log category links
		private static var commentDate:StyleSheet;		// comments date link
		private static var commentAuthor:StyleSheet;	// comments author link
		private static var linkButton:StyleSheet;		// link button style
		private static var linkButtonBright:StyleSheet;	// link button light style
		
		// graphics styles
		private static var commentGraphics:Object;		// comment display properties
		
		/* text property constants
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		// sizes
		private static const HEADER_SIZE:int 			= 20;			// header size			
		private static const BODY_SIZE:int 				= 8;			// body size (pixel font minimum)
		
		// header colors
		private static const HEADER_COLOR:String 		= "fac109";		// log header 1
		private static const SUBHEADER_COLOR:String 	= "ff8800";		// log header 2
		private static const BODYHEADER_COLOR:String 	= "f5a70f";		// log header 3
		
		private static const DATE_COLOR:String 			= "d1efec";		// date header
		private static const COMMENT_COLOR:String 		= "6e8489";		// comment header
		private static const FIELDTITLE_COLOR:String	= "567871";		// input field descriptions
		
		// body colors
		private static const BODY_COLOR:String 			= "668a88";		// body text default (brighter)
		private static const BODY_COLOR2:String 		= "98bbbb";		// body text default (darker)
		
		// comment colors		
		private static const COMMENT1:String 			= "608c86";		// comment body text (alternate 1)
		private static const COMMENT2:String 			= "4e7370";		// comment body text (alternate 2)
		
		// link colors
		private static const LINK_COLOR:String 			= "95eecc";		// standard link
		private static const LINK_OVER:String 			= "ef7000";		// standard link over
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		initialize
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function initialize():void {
			
			/* body - default style for log and body text
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var body:Object = new Object();
			body.fontFamily = "PixelLarge";
			body.fontSize = BODY_SIZE;
			body.leading = "5";
			body.color = "#" + BODY_COLOR;
			
			/* links - seperate link styles used due to flash limitation of 1 class per textField
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// standard link (large/bright)
			var aLink:Object = new Object();
			aLink.fontFamily = "PixelLarge";
			aLink.fontSize = BODY_SIZE;
			aLink.leading = "5";
			aLink.color = "#" + LINK_COLOR;
			
			// link button style (heavy/dark)
			var aLinkButton:Object = new Object();
			aLinkButton.fontFamily = "PixelHeavy";
			aLinkButton.letterSpacing = "1";
			aLinkButton.fontSize = BODY_SIZE;
			aLinkButton.color = "#2b3d44";
			
			// link button Bright style (heavy/light)
			var aLinkButtonBright:Object = new Object();
			aLinkButtonBright.fontFamily = "PixelHeavy";
			aLinkButtonBright.letterSpacing = "1";
			aLinkButtonBright.fontSize = BODY_SIZE;
			aLinkButtonBright.color = "#7ea698";
			
			// standard link (categories)
			var aCatLink:Object = new Object();
			aCatLink.fontFamily = "PixelSmall";
			aCatLink.fontSize = BODY_SIZE;
			aCatLink.color = "#" + "a9c5ba";
			
			// log header
			var aHeaderLink:Object = new Object();
			aHeaderLink.fontFamily = "Header";
			aHeaderLink.fontSize = HEADER_SIZE;
			aHeaderLink.color = "#" + HEADER_COLOR;
			
			// log date header
			var aDateLink:Object = new Object();
			aDateLink.fontFamily = "Header";
			aDateLink.fontSize = "16";
			aDateLink.color = "#" + DATE_COLOR;
			// h1 - substitute for link
			var dateh1:Object = new Object();
			dateh1.fontFamily = "Header";
			dateh1.fontSize = "16";
			dateh1.color = "#" + DATE_COLOR;
			
			// comment header
			var aCommentLink:Object = new Object();
			aCommentLink.fontFamily = "Header";
			aCommentLink.fontSize = "16";
			aCommentLink.color = "#" + COMMENT_COLOR;
			
			// comment date links used in log entry
			var aCommentDate:Object = new Object();
			aCommentDate.fontFamily = "PixelSmall";
			aCommentDate.fontSize = BODY_SIZE;
			aCommentDate.align = "right";
			aCommentDate.color = "#" + COMMENT1;
			
			// comment author links used in log entry
			var aCommentAuthor:Object = new Object();
			aCommentAuthor.fontFamily = "PixelHeavy";
			aCommentAuthor.letterSpacing = "1";
			aCommentAuthor.fontSize = BODY_SIZE;
			aCommentAuthor.color = "#7ea698";
			// substitue for link
			var commentAuthor:Object = new Object();
			commentAuthor.fontFamily = "PixelHeavy";
			commentAuthor.letterSpacing = "1";
			commentAuthor.fontSize = BODY_SIZE;
			commentAuthor.color = "#7ea698";
			
			// standard hover (style 1)
			var aHover:Object = new Object();
			aLink.fontFamily = "PixelLarge";
			aLink.fontSize = BODY_SIZE;
			aLink.leading = "5";
			aHover.textDecoration = "underline";
			aHover.color = "#" + LINK_OVER;
			
			// standard hover (style 2)
			var aHover2:Object = new Object();
			aHover2.textDecoration = "none";
			aHover2.color = "#" + HEADER_COLOR;
			
			/* special									
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			var img:Object = new Object();
			img.display = "none";
			
			/* format tags - used in log entries											
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// strong
			var strong:Object = new Object();
			strong.fontWeight = "bold";
			strong.display = "inline";
			strong.color = "#" + SUBHEADER_COLOR;
			// em
			var em:Object = new Object();
			em.fontFamily = "PixelLarge";
			em.display = "inline";
			em.fontSize = BODY_SIZE;
			em.color = "#" + BODY_COLOR2;
			// heading 1
			var h1:Object = new Object();
			h1.fontFamily = "Header";
			h1.fontSize = HEADER_SIZE;
			h1.color = "#" + HEADER_COLOR;
			// heading 2
			var h2:Object = new Object();
			h2.fontFamily = "PixelSmall";
			h2.display = "inline";
			h2.fontSize = 16;
			h2.color = "#" + BODYHEADER_COLOR;
			// heading 3
			var h3:Object = new Object();
			h3.fontFamily = "PixelLarge";
			h3.display = "inline";
			h3.fontSize = BODY_SIZE;
			h3.color = "#" + BODYHEADER_COLOR;
			// heading 4
			var h4:Object = new Object();
			h4.fontWeight = "bold";
			h4.display = "inline";
			h4.color = "#" + SUBHEADER_COLOR;
			// heading 5
			var h5:Object = new Object();
			h5.fontFamily = "PixelHeavy";
			h5.letterSpacing = "1";
			h5.fontSize = BODY_SIZE;
			h5.color = "#" + HEADER_COLOR;
			// p
			var p:Object = new Object();
			p.display = "inline";
			// pre
			var pre:Object = new Object();
			pre.fontFamily = "mono";
			pre.fontSize = BODY_SIZE;
			pre.color = "#" + BODY_COLOR;
			
			/* specific globalStyles
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// continued text 								- text link for viewing rest of log entry
			var continued:Object = new Object();
			continued.fontWeight = "normal";
			continued.fontStyle = "italic";
			continued.letterSpacing = "4";
			continued.leading = "10";
			continued.color = "#" + COMMENT_COLOR;
			continued.fontSize = BODY_SIZE;
			// input1 										- textField user input, link color
			var input1:Object = new Object();
			input1.fontFamily = "PixelLarge";
			input1.fontSize = BODY_SIZE;
			input1.color = "#" + COMMENT1;
			// input2										- textField user input, text color		
			var input2:Object = new Object();
			input2.fontFamily = "PixelLarge";
			input2.fontSize = BODY_SIZE;
			input2.color = "#" + COMMENT1;
			// fieldTitle									- input field description titles
			var fieldTitle:Object = new Object();
			fieldTitle.fontFamily = "PixelHeavy";
			fieldTitle.letterSpacing = "1";
			fieldTitle.fontSize = BODY_SIZE;
			fieldTitle.color = "#" + FIELDTITLE_COLOR;
			// buttonTitle									- button name 
			var buttonTitle:Object = new Object();
			buttonTitle.fontFamily = "PixelHeavy";
			buttonTitle.letterSpacing = "1";
			buttonTitle.fontSize = BODY_SIZE;
			buttonTitle.color = "#" + COMMENT1;
			// subHeader									- sub header titles for log entries
			var subHeader:Object = new Object();
			subHeader.fontFamily = "Header";
			subHeader.fontSize = HEADER_SIZE;
			subHeader.color = "#" + SUBHEADER_COLOR;
			// subText										- small and light text for descriptions
			var subText:Object = new Object();
			subText.fontFamily = "PixelSmall";
			subText.fontSize = BODY_SIZE;
			subText.color = "#4b7674";
			// comment 1									- comment body text (alternate row 1)
			var comment1:Object = new Object();
			comment1.fontFamily = "PixelLarge";
			comment1.fontSize = BODY_SIZE;
			comment1.leading = "5";
			comment1.marginRight = "25";
			comment1.color = "#" + COMMENT1;
			// comment 2									- comment body text (alternate row 1)
			var comment2:Object = new Object();	
			comment2.fontFamily = "PixelLarge";
			comment2.fontSize = BODY_SIZE;
			comment2.leading = "5";
			comment2.marginRight = "25";
			comment2.color = "#" + COMMENT2;
			// tooltip										- tooltip text used in ToolTip class
			var tooltip:Object = new Object();
			tooltip.fontFamily = "PixelSmall";
			tooltip.fontSize = BODY_SIZE;
			tooltip.color = "#" + COMMENT2;
			// message										- popup message text for Input class
			var message:Object = new Object();
			message.fontFamily = "PixelSmall";
			message.fontSize = BODY_SIZE;
			message.color = "#f8d5d5";
			
			/* create stylesheets
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			// global stylesheet
			Styles.global = new StyleSheet();

			// log entry styles
			Styles.global.setStyle("body", body);
			Styles.global.setStyle("a:link", aLink);
			Styles.global.setStyle("a:hover", aHover);
			Styles.global.setStyle("strong", strong);
			Styles.global.setStyle("em", em);
			Styles.global.setStyle("h1", h1);
			Styles.global.setStyle("h2", h2);
			Styles.global.setStyle("h3", h3);
			Styles.global.setStyle("h4", h4);
			Styles.global.setStyle("h5", h5);
			Styles.global.setStyle("img", img);
			Styles.global.setStyle("p", p);
			Styles.global.setStyle("pre", pre);
			// specific styles
			Styles.global.setStyle(".input1", input1);
			Styles.global.setStyle(".input2", input2);
			Styles.global.setStyle(".continued", continued);
			Styles.global.setStyle(".fieldTitle", fieldTitle);
			Styles.global.setStyle(".buttonTitle", buttonTitle);
			Styles.global.setStyle(".subHeader", subHeader);
			Styles.global.setStyle(".comment1", comment1);
			Styles.global.setStyle(".comment2", comment2);
			Styles.global.setStyle(".subText", subText);
			Styles.global.setStyle(".commentDate", commentDate);
			Styles.global.setStyle(".tooltip", tooltip);
			Styles.global.setStyle(".message", message);
			
			// header stylesheet
			Styles.header = new StyleSheet;
			Styles.header.setStyle("a:link", aHeaderLink);
			Styles.header.setStyle("a:hover", aHover);
			Styles.header.setStyle("h1", h1);
			
			// date stylesheet
			Styles.date = new StyleSheet();
			Styles.date.setStyle("a:link", aDateLink);
			Styles.date.setStyle("a:hover", aHover);
			Styles.date.setStyle("h1", dateh1);
			
			// comment stylesheet
			Styles.comment = new StyleSheet();
			Styles.comment.setStyle("a:link", aCommentLink);
			Styles.comment.setStyle("a:hover", aHover);
			
			// category link stylesheet
			Styles.catLink = new StyleSheet();
			Styles.catLink.setStyle("a:link", aCatLink);
			Styles.catLink.setStyle("a:hover", aHover);
			Styles.catLink.setStyle(".subText", subText);
			
			// sub link stylesheet 
			Styles.linkButton = new StyleSheet();
			Styles.linkButton.setStyle("a:link", aLinkButton);
			Styles.linkButton.setStyle("a:hover", aHover2);
			
			// sub link stylesheet 
			Styles.linkButtonBright = new StyleSheet();
			Styles.linkButtonBright.setStyle("a:link", aLinkButtonBright);
			Styles.linkButtonBright.setStyle("a:hover", aHover2);
			
			// commentDate link stylesheet
			Styles.commentDate = new StyleSheet();
			Styles.commentDate.setStyle("a:link", aCommentDate);
			Styles.commentDate.setStyle("a:hover", aHover2);
			
			// commentAuthor link stylesheet
			Styles.commentAuthor = new StyleSheet();
			Styles.commentAuthor.setStyle("a:link", aCommentAuthor);
			Styles.commentAuthor.setStyle("a:hover", aHover2);
			Styles.commentAuthor.setStyle(".commentAuthor", commentAuthor);
			
			
			/* graphic styles
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			commentGraphics = new Object();
			// comment box colors
			commentGraphics.boxGradientStart1 = 0x1a2b33;	// alternate 1
			commentGraphics.boxGradientEnd1 = 0x16252b;
			commentGraphics.boxGradientStart2 = 0x13232b;	// alternate 2
			commentGraphics.boxGradientEnd2 = 0x111f26;
			
			// comment update box colors
			commentGraphics.updateGradientStart = 0x1a3745;
			commentGraphics.updateGradientEnd = 0x172f3c;
			
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getStyle: return stylesheet, default = global
		@param stylesheet - stylesheet to return
		~~~~~~~~~~~~~~~~~~~s~~~~~~~~~~*/
		public static function getStyle(stylesheet:String = "global"):StyleSheet {
			return Styles[stylesheet];
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getGraphicsStyle: return graphics style object
		@param graphicStyle - style object to return
		~~~~~~~~~~~~~~~~~~~s~~~~~~~~~~*/
		public static function getGraphicsStyle(graphicStyle:String):Object {
			return Styles[graphicStyle + "Graphics"];
		}
		
	}
}