/*
     File:	Animate.as
 Revision:	0.5.0
  Purpose:	
  Authors:	
  Created:	May 09, 2007
   Edited:	May 28, 2008
    Notes:	
Functions:

*/

package com.codecollision {
	
	import flash.filters.*;
	import flash.utils.Timer;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.display.DisplayObject;
	
	// custom
	import com.codecollision.graphics.Draw;
	import com.codecollision.Sounds;
	
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
	class Animate
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	public class Animate {
		
		private static var timer:Timer;
		
		// animation objects array
		private static var ao:Array;
			
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		initialize
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function initialize(interval:Number):void {
						
			// call Timer class - new Timer(interval);
			timer = new Timer(interval);
			
			// create objects
			ao = new Array();
			
			// begin timer based animation
			timer.addEventListener(TimerEvent.TIMER, timerTick);
			timer.start();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		animateAlpha
		@param target - target displayObject of animation
		@param value - end alpha value
		@param duration - animation time in ticks
		@param onComplete - function to execute when animation done
		@param delay - time in ticks to delay animation
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function animateAlpha(target:DisplayObject,
											value:Number,
											duration:Number = 10,
											onComplete:Function = null,
											delay:Number = 0,
											tween:String = "easeOut",
											sound:String = null,
											queue:Boolean = false):void {
			
			// create new animationObject
			var r:Object = getAnimationObject(target, "alpha");
			
			// queue
			if (queue) {
				var b:uint = r.obj.e;	// set begin value as existing animation object end value
				r = new Object();
				r.obj = new Object();
			}
			
			// set obj animation properties
			r.obj.target = target;				// target of animation
			r.obj.type = "alpha";				// property to obj
			r.obj.tween = tween;				// tween algorithm to use
			r.obj.sound = sound;				// sound to play on animation start
			r.obj.onComplete = onComplete;		// onComplete function
			r.obj.t = 0; 						// reset time
			r.obj.dlyt = 0; 					// reset delay time
			
			r.obj.b = (queue)?b:target.alpha;	// begin value
			r.obj.e = value;					// end value
			r.obj.c = value - r.obj.b; 			// change amount
			r.obj.d = duration;					// duration of animation
			r.obj.dly = delay;					// time to delay animation
			
			if (!r.exists || queue) ao.push(r.obj);		// add to animationObjects array
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		animatePosition
		@param target - target displayObject of animation
		@param x - new horizontal movement
		@param y - new vertical movement
		@param duration - animation time in ticks
		@param relative - +/- system relative to current size
		@param tween - type of tween motion to use
		@param onComplete - function to execute when animation done
		@param delay - time in ticks to delay animation
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function animatePosition(	target:DisplayObject,
												x:Number,
												y:Number,
												duration:Number = 10,
												relative:Boolean = false,
												tween:String = "easeOut",
												onComplete:Function = null,
												delay:Number = 0,
												sound:String = null,
												queue:Boolean = false):void {
													
			// set current x,y values
			var curx:Number = target.x;
			var cury:Number = target.y;
			
			// create new animationObject
			var r:Object = getAnimationObject(target, "position");
			
			// queue
			if (queue) {
				// reset current position based on anticipated end values
				curx = r.obj.ex;
				cury = r.obj.ey;
				r = new Object();
				r.obj = new Object();
			}
			
			
			// change position based on relative x,y
			if (relative) { 
				x = curx + x;
				y = cury + y;
			}
								
			// set obj animation properties
			r.obj.target = target;				// target of animation
			r.obj.type = "position";			// property to obj
			r.obj.tween = tween;				// tween algorithm to use
			r.obj.sound = sound;				// sound to play on animation start
			r.obj.onComplete = onComplete;		// onComplete function
			r.obj.t = 0; 						// reset time
			r.obj.dlyt = 0; 					// reset delay time					
			
			r.obj.bx = curx;					// begin x
			r.obj.by = cury;					// begin y
			r.obj.cx = x - r.obj.bx; 			// change x
			r.obj.cy = y - r.obj.by; 			// change y
			r.obj.ex = x;						// end x
			r.obj.ey = y;						// end y
			r.obj.d = duration;					// duration of animation
			r.obj.dly = delay;					// time to delay animation
			
			if (!r.exists) ao.push(r.obj);		// add to animationObjects array
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		animateSize
		@param target - target displayObject of animation
		@param w - new width
		@param h - new height
		@param duration - animation time in ticks
		@param relative - +/- system relative to current size
		@param tween - type of tween motion to use
		@param onComplete - function to execute when animation done
		@param delay - time in ticks to delay animation
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function animateSize(	target:DisplayObject, 
											w:Number,
											h:Number,
											duration:Number = 10,
											relative:Boolean = false,
											tween:String = "easeOut",
											onComplete:Function = null,
											delay:Number = 0,
											drawFunction:Function = null,
											sound:String = null):void {
			
			// create new animationObject
			var r:Object = getAnimationObject(target, "size");
			
			// change position based on relative x,y
			if (relative) {
				w = target.width + w;
				h = target.height + h;
			}
								
			// set obj animation properties
			r.obj.target = target;				// target of animation
			r.obj.redraw = drawFunction;		// instead of scaling, call function which redraws target
			r.obj.type = "size";				// property to obj
			r.obj.tween = tween;				// tween algorithm to use
			r.obj.sound = sound;				// sound to play on animation start
			r.obj.onComplete = onComplete;		// onComplete function
			r.obj.t = 0; 						// reset time
			r.obj.dlyt = 0; 					// reset delay time					
			
			r.obj.bw = target.width; 			// begin width
			r.obj.bh = target.height;			// begin height
			r.obj.cw = w - r.obj.bw; 			// change width
			r.obj.ch = h - r.obj.bh; 			// change height
			r.obj.d = duration;					// duration of animation
			r.obj.dly = delay;					// time to delay animation
			
			if (!r.exists) ao.push(r.obj);		// add to animationObjects array
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		animateBlur
		@param target - target displayObject of animation
		@param sx - start x blur
		@param sy - start y blur
		@param cx - change x blur
		@param cy - change y blur
		@param duration - animation time in ticks
		@quality - quality of blur
		@param tweenType - type of tween motion to use
		@param onComplete - function to execute when animation done
		@param delay - time in ticks to delay animation
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function animateBlur(	target:DisplayObject,
											bx:Number,
											by:Number,
											cx:Number,
											cy:Number,
											duration:Number = 10,
											quality:Number = 1,
											tween:String = "easeOut",
											onComplete:Function = null,
											delay:Number = 0,
											sound:String = null):void {
			
			// create new animationObject
			var r:Object = getAnimationObject(target, "blur");
			
			// set obj animation properties
			r.obj.target = target;				// target of animation
			r.obj.type = "blur";				// property to obj
			r.obj.tween = tween;				// tween algorithm to use
			r.obj.sound = sound;				// sound to play on animation start
			r.obj.quality = quality;			// quality of blur filter
			r.obj.onComplete = onComplete;		// onComplete function
			r.obj.t = 0; 						// reset time
			r.obj.dlyt = 0; 					// reset delay time					
			
			r.obj.bx = bx; 						// begin x
			r.obj.by = by; 						// begin y
			r.obj.cx = cx; 						// change x
			r.obj.cy = cy; 						// change y
			r.obj.d = duration;					// duration of animation
			r.obj.dly = delay;					// time to delay animation
			
			if (!r.exists) ao.push(r.obj);		// add to animationObjects array
		}

		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		stopAnimation - removes animation object from ao array
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		public static function stopAnimation(target:DisplayObject, type:String):void {
			var r:Object = getAnimationObject(target, type);
			
			if (r.exists) {
				ao.splice(r.index, 1);
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		timerTick - loop for all animations in animation objects array
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function timerTick(Event:TimerEvent):void {	
			
			// check if objects exist to animate
			if (ao.length == 0) return;
			
			// loop through animationObjects
			for (var key:String in ao) {
				
				var obj:Object = ao[key];
				
				// play sound
				if (obj.sound && obj.dlyt == obj.dly) {
					Sounds.playSound(obj.sound);
				}
				
				// animate
				obj.dlyt ++;
				if (obj.t < obj.d && obj.dlyt >= obj.dly) {
					obj.t ++;
					
					// alpha
					if (obj.type == "alpha") {
						
						// ensure target is visible for animation
						obj.target.visible = true;
						obj.target.alpha = Animate[obj.tween](obj.t, obj.b, obj.c, obj.d);
					
					// position
					} else if (obj.type == "position") {
						obj.target.x = Animate[obj.tween](obj.t, obj.bx, obj.cx, obj.d);
						obj.target.y = Animate[obj.tween](obj.t, obj.by, obj.cy, obj.d);
						
					// size
					} else if (obj.type == "size") {
						
						if (obj.redraw) {
							var w:Number = Animate[obj.tween](obj.t, obj.bw, obj.cw, obj.d);
							var h:Number = Animate[obj.tween](obj.t, obj.bh, obj.ch, obj.d);
							obj.redraw(w, h, obj.target);
							
						} else {
							obj.target.width = Animate[obj.tween](obj.t, obj.bw, obj.cw, obj.d);
							obj.target.height = Animate[obj.tween](obj.t, obj.bh, obj.ch, obj.d);
						}
					
					// blur
					} else if (obj.type == "blur") {
						
						// initialize blur filter
						if (obj.t == 1) {
							// create blurFilter
							var blurFilter:BlurFilter = new BlurFilter();
							blurFilter.quality = obj.quality;
							// set filter property of displayObject
							obj.target.filters = [blurFilter];
						}
						
						var blurArray:Array = obj.target.filters;
						blurArray[0].blurX = Animate[obj.tween](obj.t, obj.bx, obj.cx, obj.d);
						blurArray[0].blurY = Animate[obj.tween](obj.t, obj.by, obj.cy, obj.d);
						
						// apply filter
						obj.target.filters = blurArray;
					}
				}
				
				if (obj.t >= obj.d) {
					animationComplete(obj, key);
				}
				
			}
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		getAnimationObject - check for existing animation object and return object or create new
		@param target - animation displayObject target
		@param type - animation type (alpha, position, blur)
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function getAnimationObject(target:DisplayObject, type:String):Object {	
			
			var result:Object = new Object();
			result.exists = true;
			
			// match existing animation object by target and animation type
			for (var key:String in ao) {
				result.obj = ao[key];
				result.index = Number(key);
				if (ao[key].target == target && ao[key].type == type) return result;
			}
			
			result.obj = new Object();
			result.exists = false;
			result.index = -1;
			return result;
		}
				
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		animationComplete - run custom end events for each animation type
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		private static function animationComplete(obj:Object, key:String):void {	
			
			// remove obj from animation objects array (ao)
			ao.splice(int(key), 1);
			
			// alpha
			if (obj.type == "alpha") {
				if (obj.e == 0) obj.target.visible = false;
			}
			
			// check for onComplete function
			if (obj.onComplete != null) obj.onComplete();
		}
		
		/**~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Robert Penner equations for motion in and out (time, begin, change, duration)
		each iteration increment time by 1, change = final position - begin, duration is number total iterations of function
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
		// quadratic
		private static function easeOut(t:Number, b:Number, c:Number, d:Number):Number {
			return -c *(t/=d)*(t-2) + b;
		}
		private static function easeInOut(t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d/2) < 1) {
				return c/2*t*t + b;
			}
			return -c/2 * ((--t)*(t-2) - 1) + b;
		}
		
		// exponential
		private static function easeInExpo (t:Number, b:Number, c:Number, d:Number):Number {
			return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b;
		}
		private static function easeOutExpo (t:Number, b:Number, c:Number, d:Number):Number {
			return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;
		}
		
		// bounce
		private static function easeOutBounce (t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d) < (1/2.75)) {
				return c*(7.5625*t*t) + b;
			} else if (t < (2/2.75)) {
				return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
			} else if (t < (2.5/2.75)) {
				return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
			} else {
				return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
			}
		}
		
		// slide back
		private static function easeOutBack (t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number {
			return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
		}
	}
}