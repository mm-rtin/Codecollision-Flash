/*

     File:	CollideNav.as
 Revision:	0.0.5
  Purpose:	
  Authors:	
  Created:	Mar 13, 2007
   Edited:	Mar 06, 2008
    Notes:	
Functions:

*/


package com.codecollision.collisionnav {
	
	// import classes
	import flash.display.Sprite;	
	import flash.events.TimerEvent
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	
	// custom classes
	import com.codecollision.collisionnav.engine.Physics;
	import com.codecollision.collisionnav.engine.Ball;
	import com.codecollision.collisionnav.engine.Border;
	import com.codecollision.collisionnav.engine.SoundFX;
	import com.codecollision.Animate;
	import com.codecollision.data.DataService;
		
/* -------------------------------
   class FlashGame
   ------------------------------- */
	public class CollisionNav extends Sprite {
		
		   /* static variables
		   ------------------------------- */
			private const INTERVAL:uint = 20; 				// (1000 / interval = FPS)
			private const SUB_INTERVAL:uint = 500;			// interval to spawn balls
			private const PROJ_INTERVAL:uint = 100;
			private const BORDER_RADIUS:uint = 280;			// radius of boundry border
			private const CENTER_X:uint  = 250;				// center of stage x
			private const CENTER_Y:uint = 250;				// center of stage y
			private const LETTER_SIZE = 8;					// approx pixel size of each character
			private const BORDER_PAD:Number = 1.5; 			// padding radius to compensate for border
			private const DRAG_TIMEOUT:Number = .5			// timeout for when a ball will navigate
			
			// user ball
			private const USER_BALL_RADIUS:uint = 10;
			private const USER_BALL_MASS:uint = 50;
			private const USER_BALL_VELOCITY:Number = .35;
		   
		  /* instance variables
		   ------------------------------- */
			// class init
			private var physics:Physics = new Physics();			// init physics class
			private var soundFX:SoundFX = new SoundFX();
		  	
		  	// sprites
		   	private var navContainer:Sprite = new Sprite();			// container for all CollisionNav elements
		   	private var overlay:Sprite = new Sprite();				// overlay container misc objects
		   
		  	// timers
			private var motionLoop:Timer = new Timer(INTERVAL); 		// main game loop
			private var projectsLoop:Timer = new Timer(PROJ_INTERVAL);	// ball queue for projects
			private var subLoop:Timer = new Timer(SUB_INTERVAL);		// ball queue for subs
			private var clickTimer:Timer = new Timer(250);
			
			// navigation properties
			private var ballCount:uint = 0;
			
			// ball highlight properties
			private var highlightTarget:Ball;
			private var highlightReciever:Ball;
			private var activateHighlight:Boolean = false;
			
			// mouse properties
			private var stagePress_x:Number;
			private var stagePress_y:Number;
			private var ballPress_x:Number;
			private var ballPress_y:Number;
						
			// objects
			private var menu:XML;									// menu XML data
			private var catActivationList:Array = new Array()		// category objects to recreate
			private var subActivationList:Array = new Array()		// subCategory objects to recreate
			private var subDeletionList:Array = new Array()			// subCategory objects to remove
			private var projectDeletionList:Array = new Array()		// project objects to remove
			private var currentCategory:Ball;
			private var currentSubcategory:Ball;
			private var queueCount:uint;
			
			private var queue:Array = new Array();					// holds Ball object for timed release
			private var ballList:Array = new Array();				// holds all ball objects
			private var border:Border; 								// create game object 'border'
			private var userBall:Ball;								// user controlled ball
			
			// time control
			private var pause:Boolean = false;
			private var oneFrame:Boolean = false;
			

		/* -------------------------------
		   CollisionNav Constructor
		   ------------------------------- */
		public function CollisionNav() {

		/*  create assets
			------------------------------- */
			this.addChild(navContainer);	// add navContainer to class (sprite)
			generateAssets();
			
		/*  start motion loop
			------------------------------- */
			motionLoop.addEventListener(TimerEvent.TIMER, motionTick); 	// designates listeners for the interval event
			motionLoop.start(); 										// start motionLoop
			
		/*  start mouse listener
			------------------------------- */
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
		}
		
				
		///////////////////////////////////////////////////////////////////////////////
		//
		//		object functions
		//
		///////////////////////////////////////////////////////////////////////////////

		/* -------------------------------
		   loadNavigation ()
		   initilize CollisionNav navigation system, create category balls
		   ------------------------------- */
		public function loadNavigation(menu:XML):void {
		
			this.menu = menu;	// save menu XMl data
		
			/* create initial categories
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			for each (var category:XML in menu.*) {
				
				ballCount++;

				// set category item properties
				var name:String = category.attribute("name");
				var color:Number = category.attribute("color");
				var borderColor:Number = color;
				var diameter:uint = name.length * LETTER_SIZE;
				var radius:uint = diameter / 2;
				var x:Number = Math.random() * 500;
				var y:Number = Math.random() * 500;
				var vx:Number = Math.random() * 10;
				var vy:Number = Math.random() * 10;
				
				// add category ball
				var ball:Ball = addBall(ballCount, radius, radius, x, y, vx, vy, color, borderColor, 1, .5, "category", name);
				activate(ball);
				
			}
		}
		
		/* -------------------------------
		   createSubs ()
		   ------------------------------- */
		public function createSubs(menu:XMLList):void {
			
			// normalized direction vector
			var dx:Number;
			var dy:Number;
			
			// number of children elements
			var childNumber:uint = menu.(@name == currentCategory.ballName).@childNumber;
			var increment:Number = 360 / childNumber;
			
			if (childNumber > 2) {
				var angle:uint = Math.floor(Math.random() * 360);
			
			} else {
			
				var x:Number = currentCategory.x - CENTER_X;
				var y:Number = currentCategory.y -  CENTER_Y;
				
				var len:Number = Math.sqrt((x * x) + (y * y));
				
				dx = -(x / len);
				dy = -(y / len);
			}

			
			/* create subcategory balls
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			for each (var subcategory:XML in menu.*) {
				
				ballCount++;

				// set category item properties
				var name:String = subcategory.attribute("name");
				var color:Number = subcategory.attribute("color");
				var borderColor:Number = color;
				var diameter:uint = name.length * LETTER_SIZE;
				var radius:uint = diameter / 2;
				var newRadius:Number = currentCategory.radius + radius + 10;
				
				// position, velocity
				var x:Number;
				var y:Number;
				var vx:Number;
				var vy:Number;
				
				// if more than 2 subs, use random position/velocity
				if (childNumber > 2) {
					angle += increment;
					var radians:Number = angle * (Math.PI/180);
					dx = Math.cos(radians);
					dy = -Math.sin(radians);
				}
				
				// set x,y and velocity
				x = currentCategory.x + (dx * newRadius);
				y = currentCategory.y + (dy * newRadius);
				vx = dx * 5;
				vy = dy * 5;

				// add category ball
				var ball:Ball = addBall(ballCount, radius, radius, x, y, vx, vy, color, borderColor, 1, .5, "subcategory", name);
				ball.alpha = 0;
				queue.push(ball);
								
				subDeletionList.push(ball);
			}
			
			queueCount = 0;
			subLoop.addEventListener(TimerEvent.TIMER, activateQueue); 	// designates listeners for the interval event
			subLoop.start(); 
		}
			
		/* -------------------------------
		   createProjects ()
		   ------------------------------- */
		public function createProjects(menu:XMLList):void {
		
			// get number of children elements
			var childNumber:uint = menu.(@name == currentSubcategory.ballName).@childNumber;
			var increment:Number = 360 / childNumber;
			var angle:uint = 0;
		
			/* create project balls
			~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
			for each (var project:XML in menu.*) {
				
				ballCount++;

				// set category item properties
				var name:String = project.attribute("name");
				var color:Number = project.attribute("color");
				var borderColor:Number = color;
				var diameter:uint = name.length * LETTER_SIZE;
				var radius:uint = diameter / 2;
				var newRadius:Number = currentSubcategory.radius + radius + 10;
				var radians:Number = angle * (Math.PI/180);
				
				// position, velocity
				var dx:Number = Math.cos(radians);
				var dy:Number = -Math.sin(radians);
				var x:Number = currentSubcategory.x + (dx * newRadius);
				var y:Number = currentSubcategory.y + (dy * newRadius);
				var vx:Number = dx * 5;
				var vy:Number = dy * 5;
				
				angle += increment;

				// add category ball
				var ball:Ball = addBall(ballCount, radius, radius, x, y, vx, vy, color, borderColor, 1, .5, "project", name);
				ball.alpha = 0;
				queue.push(ball);
				
				projectDeletionList.push(ball);
				
				/*trace("    >> " + project.attribute("name"));
				trace("        >>> " + project.THUMBNAIL);		// access project item
				trace("        >>> " + project.LOCATION);		
				trace("        >>> " + project.OPENPROJECT);		
				trace("        >>> " + project.DESCRIPTION);*/
				
			}
			
			queueCount = 0;
			projectsLoop.addEventListener(TimerEvent.TIMER, activateQueue); 	// designates listeners for the interval event
			projectsLoop.start(); 	
		}	
		
		/* -------------------------------
		   addBall ()
		   create new Ball object, return ball
		   ------------------------------- */
		private function addBall(	ballID:uint, 
									radius:Number, 
									mass:Number, 
									xPos:Number, 
									yPos:Number, 
									vx:Number, 
									vy:Number, 
									color:Number, 
									borderColor:Number, 
									alpha:Number, 
									borderAlpha:Number, 
									ballCategory:String,
									title:String
									):Ball {
			
			// create new ball
			var ball:Ball = new Ball(ballID, radius, mass, xPos, yPos, vx, vy, color, borderColor, alpha, borderAlpha, ballCategory, title, "");

			// add to Display object
			navContainer.addChild(ball);
			//trace("ADD INDEX: " + navContainer.getChildIndex(ball));
			
			// add mouseEvent listener to ball object
			ball.addEventListener(MouseEvent.CLICK, ballClick);
			ball.addEventListener(MouseEvent.ROLL_OVER, ballOver);
			ball.addEventListener(MouseEvent.ROLL_OUT, ballOut);
			ball.addEventListener(MouseEvent.MOUSE_DOWN, ballDown);
			
			ball.buttonMode = true;
			ball.mouseChildren = false;
			
			return ball;
		}	
		
		/* -------------------------------
		   activateQueue ()
		   add ball to ballList, display 
		   ------------------------------- */
		private function activateQueue(evt:TimerEvent):void {
			activate(queue[queueCount]);
			queueCount++;
			
			if (queueCount == queue.length) {
				stopQueue();
			}
		}
		
		/* -------------------------------
		   stopQueue ()
		   clear queue and prevent any more from being processed
		   ------------------------------- */
		private function stopQueue():void {
			projectsLoop.stop();
			subLoop.stop();
			queue.splice(0, queue.length);		
		}
		
		/* -------------------------------
		   activate ()
		   add ball to ballList, display 
		   ------------------------------- */
		private function activate(ball:Ball):void {

			ball.alpha = 0;
			
			ball.addEventListener(MouseEvent.CLICK, ballClick);
			ball.buttonMode = true;
			ball.mouseChildren = false;
			
			// add to ballList
			ballList.push(ball);
			
			navContainer.addChild(ball);
			fade(ball, 1);
		}
		
		/* -------------------------------
		   deactivate ()
		   remove ball from ballList
		   ------------------------------- */
		private function deactivate(ball:Ball):void {
			
			// remove from ballList
			for (var i:Number = 0; i < ballList.length; i++) {
				if (ball.ballID == ballList[i].ballID) {
					ballList.splice(i, 1);
				}
			}
			
			ball.removeEventListener(MouseEvent.CLICK, ballClick);
			ball.buttonMode = false;
			ball.mouseChildren = true;
		}
		
		/* -------------------------------
		   drawHighlight ()
		   highlight and draw line between two navigation objects
		   ------------------------------- */
		private function drawHighlight(target:Ball, reciever:Ball):void {
			
			clearHighlight();
			overlay.graphics.moveTo(reciever.x, reciever.y);
			overlay.graphics.lineStyle(2, 0xA8EEFB, .5);
			overlay.graphics.lineTo(target.x, target.y);
			
		}
		
		/* -------------------------------
		   clearHighlight ()
		   clear drawn highlight
		   ------------------------------- */
		private function clearHighlight():void {
			
			overlay.graphics.clear();
		}
		
		/* -------------------------------
		   generateAssets ()
		   create all general objects
		   ------------------------------- */
		private function generateAssets():void {
		
			var centerx:Number = CENTER_X;
			var centery:Number = CENTER_Y;
			
			//var colors:Array = [0xDDFFFF, 0x79D8DC, 0x82DAEB, 0x48EBFF, 0xFFFB05, 0x045059];
			
			/*	border
			------------------------------- */
			border = new Border(BORDER_RADIUS, centerx, centery, 0xffffff, 0xffffff, 0, 0);
			navContainer.addChild(border);
			
			navContainer.addChild(overlay);
			
			/*	user ball
			------------------------------- */
			//userBall = new Ball(500, USER_BALL_RADIUS, USER_BALL_MASS, centerx, centery - 50, 0, 0, 0x03181D, 0x000000, 1, 0, "", "");		
			//ballList.push(userBall);	
			//navContainer.addChild(userBall);
		}
		
		///////////////////////////////////////////////////////////////////////////////
		//
		//		debug interaction
		//
		///////////////////////////////////////////////////////////////////////////////
		/* -------------------------------
		   mouseMove ()
		   recieves mouse move
		   ------------------------------- */
		private function mouseMove(evt:MouseEvent):void {
		}
		/* -------------------------------
		   mouseDown ()
		   recieves mouse down events
		   ------------------------------- */
		private function mouseDown(evt:MouseEvent):void {
			//pause = true;
		}
		/* -------------------------------
		   mouseUp ()
		   recieves mouse up events
		   ------------------------------- */
		private function mouseUp(evt:MouseEvent):void {
			userBall = null;
		}
		/* -------------------------------
		   mouseWheel ()
		   recieves mouse wheel events
		   ------------------------------- */
		private function mouseWheel(evt:MouseEvent):void {
			oneFrame = true;
			pause = true;
		}
		
		///////////////////////////////////////////////////////////////////////////////
		//
		//		navigation functions
		//
		///////////////////////////////////////////////////////////////////////////////
		
		/* -------------------------------
		   ball mouseEvents
		   functions called for mouseEvents on ball object
		   ------------------------------- */
		private function ballClick(Event:MouseEvent):void {	
			
			var ball:Ball = Event.currentTarget as Ball;	// cast target as Ball
			
			// must have held mouse on ball for less than 3 seconds
			if (clickTimer.currentCount < DRAG_TIMEOUT 
				|| (stagePress_x == this.mouseX && stagePress_y == this.mouseY)) {
				
				navigate(ball);	// call navigate and pass Ball object
			}	
				
			// reset timer
			clickTimer.reset();
			clickTimer.stop();							
		}
		
		private function ballDown(Event:MouseEvent):void {
			clickTimer.start();
			userBall = Event.currentTarget as Ball;
			
			// set initial offset
			ballPress_x = userBall.mouseX;
			ballPress_y = userBall.mouseY;
			
			// set stage mouse position
			stagePress_x = this.mouseX;
			stagePress_y = this.mouseY;
		} 
		
		private function ballOver(Event:MouseEvent):void {	
			
			var ball = Event.currentTarget as Ball;	
			
			trace(ball.ballType);
			
			if (ball.ballType == "subcategory") {
				highlightParent(ball, currentCategory);
				
			} else if (ball.ballType == "project") {
				highlightParent(ball, currentSubcategory);
			}
		}
		
		private function ballOut(Event:MouseEvent):void {
			
			clearHighlight();
			activateHighlight = false;
		}
		
		/* -------------------------------
		   showParent()
		   highlights and draws line to parent navigation item
		   ------------------------------- */
		private function highlightParent(ball:Ball, target:Ball):void {
			
			highlightTarget = target;
			highlightReciever = ball;
			
			activateHighlight = true;
			
			overlay.alpha = 0;
			Animate.animateAlpha(overlay, .5, 20);
		}
		
		/* -------------------------------
		   navigate()
		   method for when a ball object is clicked
		   ------------------------------- */
		private function navigate(ball:Ball):void {
			
			stopQueue();											// stop any queues in progress
			fade(ball, .2);											// fade clicked ball
			
			// reset velocity to 0
			ball.vx = 0;
			ball.vy = 0;
			
			// ball type handlers (category, subcategory, project)
			switch (ball.ballType) {
				
				case "category":
					currentCategory = ball;
				
					var sublist:XMLList = menu.*;					// filter list with only selected category
					sublist = sublist.(@name == currentCategory.ballName);
					
					deactivate(ball);								// remove from collision, disable button
					restartNavigation();							// run through activationList, deletionList		
					catActivationList.push(ball);					// reactivate ball on next category selection
					createSubs(sublist);							// create subCategories
					break;
					
				case "subcategory":
					currentSubcategory = ball;
				
					var sublist:XMLList = menu.*;
					sublist = sublist.(@name == currentCategory.ballName).SUBCATEGORY.(@name == currentSubcategory.ballName);
					
					deactivate(ball);								// remove from collision, disable button
					restartNavigation("projects");					// remove only project navigation items
					subActivationList.push(ball);					// reactivate sub ball on next sub selection
					createProjects(sublist);						// create projects			
					break;
					
				case "project":
					
					// TODO: navigate to project
					break;
			}
			
			//trace("---------------------");
			//for each(var traceBall:* in ballList) {
				//trace(traceBall.ballName);
			//}	
		}
		
		/* -------------------------------
		   fade()
		   method for when a ball object is clicked
		   ------------------------------- */
		private function fade(ball:Ball, target:Number):void {
			
			Animate.animateAlpha(ball, target, 20, onComplete);
			
			function onComplete():void {
				// remove child sprite from container
				if (ball.alpha == 0) {
					//trace("REMOVING: " + ball.ballName);
					var index:int = navContainer.getChildIndex(ball);
					navContainer.removeChildAt(index);					
				}
			}
		}	
		
		/* -------------------------------
		   restartNavigation ()
		   reinitilize CollisionNav navigation system, create balls on activationList, remove on deletionList
		   ------------------------------- */
		private function restartNavigation(scope:String = "all"):void {
			
			// subDeletionList, remove subcategory balls
			if (scope == "all") {
				for each(var ball:* in subDeletionList) {
					deactivate(ball);
					fade(ball, 0);	
				}
				// reset list
				subDeletionList.splice(0, subDeletionList.length);	
			}
			// projectDeletionList, remove subcategory balls
			if (scope == "projects" || scope == "all") {
				for each(var ball:* in projectDeletionList) {
					deactivate(ball);
					fade(ball, 0);	
				}
				// reset list
				projectDeletionList.splice(0, projectDeletionList.length);
			}
			
			// activationList, add balls
			if (scope == "all") {
				for each (var ball:* in catActivationList) {
					activate(ball);				
				}
				catActivationList.splice(0, catActivationList.length);
				subActivationList.splice(0, subActivationList.length);
			}
			if (scope == "projects") {
				for each (var ball:* in subActivationList) {
					activate(ball);				
				}
				subActivationList.splice(0, subActivationList.length);
			}
		}
		
		///////////////////////////////////////////////////////////////////////////////
		//
		//		motion functions
		//
		///////////////////////////////////////////////////////////////////////////////

		/* -------------------------------
		   motionTick ()
		   main game loop
		   ------------------------------- */
		private function motionTick(evt:TimerEvent):void {
			
			/* move user ball
			------------------------------- */
			if (userBall != null) {
				moveUserBall(userBall);
			}
			
			/* move balls - collisions
			------------------------------- */
			if (pause == false || oneFrame == true) {
				
				// draw highlight
				if (activateHighlight) {
					drawHighlight(highlightReciever, highlightTarget);
				}
				
				// move all balls (set potential x,y)
				for (var m:uint = 0; m < ballList.length; m++) {
					var moveBall:Ball = ballList[m];
					moveBall.move();
				}
				
				// collision detection
				for (var i:uint = 0; i < ballList.length; i++) {			
					var ball1:Ball = ballList[i]; // first ball	
					
					// loop through balls starting from ball1 + 1 (eliminates dupicate collisions for each interval)
					for (var n:uint = i + 1; n < ballList.length; n++) {
						var ball2:Ball = ballList[n]; 			// second ball
						
						ballToBallCollision(ball1, ball2); 		// ball vs ball collision
					}	
					ballToBorderCollision(ball1, border); 		// ball vs border collision
				}
				
				// render all balls
				for (var r:uint = 0; r < ballList.length; r++) {
					var renderBall:Ball = ballList[r];
					
					renderBall.render();
				}
				oneFrame = false;
			}
		}
	
		/* -------------------------------
		   moveUserBall (userBall)
		   moves user controlled ball
		   ------------------------------- */
		private function moveUserBall(userBall:Ball):void {
			
			/* calculate userBall velocity 
			------------------------------- */
			
			var centerx:Number = CENTER_X;						// stage center
			var centery:Number = CENTER_Y;
			
			var smx = this.mouseX - ballPress_x;				// x,y mouse stage position
			var smy = this.mouseY - ballPress_y;
			
			var mcx = smx - centerx;							// A,B distance mouse to center
			var mcy = smy - centery;
			
			var mclen = Math.sqrt((mcx * mcx) + (mcy * mcy));	// C distance mouse to center
			
			var mbx = smx - userBall.px;						// A,B distance mouse to ball
			var mby = smy - userBall.py;
			
			if (mclen > BORDER_RADIUS - USER_BALL_RADIUS) {
					
				var penAmt = mclen - BORDER_RADIUS + USER_BALL_RADIUS;
				
				// normalized distance of mouse to center
				var dx = mcx / mclen;
				var dy = mcy / mclen;
				
				// x,y of new mouse position adjusted for distance outside border				
				var adjustX = dx * penAmt;
				var adjustY = dy * penAmt;
				
				// change distance from mouse to ball - simulate mouse x,y to inside border
				mbx = smx - adjustX - userBall.px;
				mby = smy - adjustY - userBall.py;
			}
			
			// set userBall velocity
			var vx = mbx * USER_BALL_VELOCITY;
			var vy = mby * USER_BALL_VELOCITY;
			
			// assign velocity to userBall
			userBall.vx = vx;
			userBall.vy = vy;
		}
		   
		/* -------------------------------
		   ballToBallCollision (ball1, ball2)
		   checks ball with border and calculates new vector
		   ------------------------------- */
		private function ballToBallCollision(ball1:Ball, ball2:Ball):void {	
			
			// set object properties
			var circle1:Object = {x:ball1.px, y:ball1.py, vx:ball1.vx, vy:ball1.vy, radius:ball1.radius + BORDER_PAD, m:ball1.mass};
			var circle2:Object = {x:ball2.px, y:ball2.py, vx:ball2.vx, vy:ball2.vy, radius:ball2.radius + BORDER_PAD, m:ball2.mass};
			
			var bounceVector:Object = new Object();
			bounceVector = physics.ballCollision(circle1, circle2);
			
			// if hit - update vector, adjust x,y position of circle1, circle2
			if (bounceVector.hit) {
				
				// ofset system - ball2 x,y position is ofset negative relation to ball1
				ball2.xOfset = -bounceVector.adjustx;
				ball2.yOfset = -bounceVector.adjusty;
				
				// update ball 1 movement vector
				ball1.vx = bounceVector.vx1;
				ball1.vy = bounceVector.vy1;
				
				// update ball 2 movement vector
				ball2.vx = bounceVector.vx2;
				ball2.vy = bounceVector.vy2;

				// update potential x,y away from ball
				ball1.px += bounceVector.adjustx;
				ball1.py += bounceVector.adjusty;
				
				// sound effects
				soundFX.playBallBounce(ball2.vx, ball2.vy);
				
				//trace(count + " " + ball1.ballID + "vx: " + ball1.vx + " vy: " + ball1.vy + " and " + ball2.ballID + "vx: " + ball2.vx + " vy: " + ball2.vy);
			}
		}
		
		/* -------------------------------
		   ballToBorderCollision (ball, border)
		   checks ball with border and calculates new vector
		   ------------------------------- */
		private function ballToBorderCollision(ball:Ball, border:Border):void {		
			
			// set object properties
			var bounceObject:Object = {x:ball.px, y:ball.py, vx:ball.vx, vy:ball.vy, radius:ball.radius, ballName:ball.ballName};
			var outerCircle:Object = {x:border.x, y:border.y, radius:border.radius};
			
			var bounceVector:Object = new Object();
			bounceVector = physics.insideCircleCollision(bounceObject, outerCircle);
			
			// if hit - update vector, adjust x,y position of ball
			if (bounceVector.hit) {
				
				// update movement vector
				ball.vx = bounceVector.vx;
				ball.vy = bounceVector.vy;
				
				// update potential x,y away from border
				ball.px += bounceVector.adjustx;
				ball.py += bounceVector.adjusty;
				
				soundFX.playWallBounce(ball.vx, ball.vy);
			}
		}
	}
}