/*

     File:	Ball.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	Mar 13, 2007
   Edited:	Mar 20, 2007
    Notes:	
Functions:	

*/


package com.codecollision.collisionnav.engine {
	
	// import classes
	import flash.display.Sprite;
	import flash.text.*

/* -------------------------------
   class Ball
   ------------------------------- */
	public class Ball extends Sprite {
		/* -------------------------------
		   static variables
		   ------------------------------- */
		   private static var numBalls:uint; 
		   
		/* -------------------------------
		   instance variables
		   ------------------------------- */
			public var ballType:String;
			public var ballID:uint;
			public var ballName:String;
			public var xOfset:Number = 0;
			public var yOfset:Number = 0;
			public var radius:Number;			// radius
			public var mass:Number;				// mass
			
			// navigation attributes
			private var title:String;
			private var link:String;
			
			// ball objects
			private var titleText:TextField;
			
			// potential position (position of object before rendering)
			private var potential_x:Number;
			private var potential_y:Number;
			
			private var velocity_x:Number;		// velocity
			private var velocity_y:Number;
			private var friction:Number = .97;	// friction
			
			//title properties
			private var title_xOffset = 0;		// offset for title (for centering)
			private var title_yOffset = 0;
			
		   
		/* -------------------------------
		   Ball Constructor
		   ------------------------------- */
		public function Ball(ballID:uint, radius:Number, mass:Number, xPos:Number, yPos:Number, vx:Number, vy:Number, color:Number, borderColor:Number, alpha:Number, borderAlpha:Number, ballType:String, title:String, link:String) {
			// set ball properties
			this.ballType = ballType;
			this.ballID = ballID;
			this.ballName = title;
						
			// update class var ballNum
			numBalls ++;
			
			// draw ball
			drawBall(radius, color, borderColor, alpha, borderAlpha, title, link);
			
			// set ball position
			this.x = xPos;
			this.y = yPos;
			
			// update position
			this.potential_x = xPos;
			this.potential_y = yPos;
			
			// set velocity
			this.velocity_x = vx;
			this.velocity_y = vy;
			
			// update radius
			this.radius = radius;
			
			// update mass
			this.mass = mass;
		}
		
		///////////////////////////////////////////////////////////////////////////////
		//
		//		public functions
		//
		///////////////////////////////////////////////////////////////////////////////
		
		/* get x ()
		   ------------------------------- */
		public function get px():Number {
			return potential_x;
		}
		/* set x ()
		   ------------------------------- */
		public function set px(setValue:Number):void {
			potential_x = setValue;
		}
		/* get y ()
		   ------------------------------- */
		public function get py():Number {
			return potential_y;
		}
		/* set y ()
		   ------------------------------- */
		public function set py(setValue:Number):void {
			potential_y = setValue;
		}

		/* get vx ()
		   ------------------------------- */
		public function get vx():Number {
			return velocity_x;
		}
		/* set vx ()
		   ------------------------------- */
		public function set vx(setValue:Number):void {
			velocity_x = setValue;
		}
		
		/* get vy ()
		   ------------------------------- */
		public function get vy():Number {
			return velocity_y;
		}
		/* set vy ()
		   ------------------------------- */
		public function set vy(setValue:Number):void {
			velocity_y = setValue;
		}

		/* -------------------------------
		   render ()
		   render ball position
		   ------------------------------- */
		public function render():void {		
			this.x = potential_x;
			this.y = potential_y;
			
			//var xDiff:Number = Math.ceil(potential_x) - potential_x;
			//var yDiff:Number = Math.ceil(potential_y) - potential_y;
			var xDiff:Number = 0;
			var yDiff:Number = 0;
			
			titleText.x = title_xOffset + xDiff;
			titleText.y = title_yOffset + yDiff;
			
			//trace("## render ball: " + this.x + ", " + this.y);
		}
		/* -------------------------------
		   move ()
		   update movement temporary values
		   ------------------------------- */
		public function move():void {
			
			vx *= friction;
			vy *= friction;
			
			// gravity
			//vy += .1
			
			// erode ofset - slowly remove offset to return to ofset of 0
			xOfset *= .75;
			yOfset *= .75;
			
			// set ofset
			potential_x += xOfset;
			potential_y += yOfset;
			
			// update position
			potential_x += vx;
			potential_y += vy;
			
			//trace("## update ball: " + this.ballID + " actual x: " + this.x + " potential x: " + this.potential_x + " actual y: " + this.y + " potential y: " + this.potential_y);
		}
		
		///////////////////////////////////////////////////////////////////////////////
		//
		//		private functions
		//
		///////////////////////////////////////////////////////////////////////////////
		
		/* -------------------------------
		   drawBall ()
		   creates game object: ball
		   ------------------------------- */
		private function drawBall(radius:Number, color:Number, borderColor:Number, alpha:Number, borderAlpha:Number, title:String, link:String):void {
			
			// text format
			var titleFormat:TextFormat = new TextFormat();
			titleFormat.font = "PixelHeavy"
			titleFormat.color = 0xffffff;
			titleFormat.size = 8;

			// text field
			titleText = new TextField();
			titleText.embedFonts = true;
			titleText.autoSize = TextFieldAutoSize.LEFT;
			titleText.defaultTextFormat = titleFormat;
			titleText.selectable = false;
			titleText.text = title;
					
			titleText.alpha = .8;
			this.addChild(titleText);
			
			// center title
			var centerAdjust:uint = titleText.textWidth / 2;
			title_xOffset = -centerAdjust;
			title_yOffset = -16;
			titleText.x = title_xOffset;
			titleText.y = title_yOffset;

			// ball graphics
			graphics.lineStyle(4, borderColor, borderAlpha);
			graphics.beginFill(color, alpha);
			graphics.drawCircle(0, 0, radius);
		}
		
		/* -------------------------------
		   drawBorder ()
		   creates object: border
		   ------------------------------- */
		private function drawBorder(radius:Number, color:Number, borderColor:Number, alpha:Number, borderAlpha:Number):void {
			
			// border graphics
			graphics.lineStyle(1, borderColor, borderAlpha);
			graphics.beginFill(color, alpha);
			graphics.drawCircle(0, 0, radius);
		}

	}
}