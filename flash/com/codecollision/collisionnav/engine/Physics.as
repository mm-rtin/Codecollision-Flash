/*

     File:	Physics.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	Mar 16, 2007
   Edited:	Mar 20, 2007
    Notes:	
Functions:	

*/


package com.codecollision.collisionnav.engine {
	import flash.display.Sprite;

/* -------------------------------
   class Ball
   ------------------------------- */
	public class Physics extends Sprite {
		/* -------------------------------
		   static variables
		   ------------------------------- */
		   
		/* -------------------------------
		   instance variables
		   ------------------------------- */
			
		   
		/* -------------------------------
		   Physics Constructor
		   ------------------------------- */
		public function Physics() {

		}
		///////////////////////////////////////////////////////////////////////////////
		//
		//		public functions
		//
		///////////////////////////////////////////////////////////////////////////////
		/* -------------------------------
		   ballCollision (circle1, circle2)
		   detect collision and calculate new movement vector given two circle objects with x,y / vx,vy 
		   ------------------------------- */
			public function ballCollision(circle1:Object, circle2:Object):Object {
				var bounceProj:Object = new Object();
				
				// vc = vector between center of circle1 and circle2
				var vc:Object = new Object()
				vc.vx = circle1.x - circle2.x;
				vc.vy = circle1.y - circle2.y;
				
				// create vector properties - returns vector length, normalized vector, r/l normal
				vc = getVectorProperties(vc);
				
				// total radius of circle1, circle2
				var totalRadius:Number = circle1.radius + circle2.radius;
				
				// find penetration amount
				var penAmt:Number = totalRadius - vc.len;
				
				
				
				// check if circle1 has intersected circle2
				if (penAmt >= 0) {	
					
					// circle vectors
					var v1:Object = {vx:circle1.vx, vy:circle1.vy, m:circle1.m};
					var v2:Object  = {vx:circle2.vx, vy:circle2.vy, m:circle2.m};
					
					// wall vector
					var v3:Object = {dx:vc.dx, dy:vc.dy, lx:vc.dy, ly:-vc.dx};
					
					// calculate new bounce vector
					bounceProj = getBallBounce(v1, v2, v3)
				
					// set x,y adjustment values to move circle1 away from circle2 (may causes slight innacuracy in result velocity)
					bounceProj.adjustx = vc.dx * penAmt;
					bounceProj.adjusty = vc.dy * penAmt;					
					
					// set hit true
					bounceProj.hit = true;

				}
				return bounceProj;
			} 
		/* -------------------------------
		   insideCircleCollision ()
		   detect collision and calculate new movement vector given two objects: circle and outer circle, with x,y and radius of both objects
		   ------------------------------- */
			public function insideCircleCollision(bounceObject:Object, outerCircle:Object):Object {
				var bounceProj:Object = new Object();
				
				// v = vector between center of ball and center of outerCircle
				var v:Object = new Object();
				v.vx = bounceObject.x - outerCircle.x;
				v.vy = bounceObject.y - outerCircle.y;
				
				// length of vector
				v.len = Math.sqrt((v.vx * v.vx) + (v.vy * v.vy));
				
				// normalized vector
				v.dx = v.vx / v.len;
				v.dy = v.vy / v.len;
	
				// find penetration amount
				var penAmt:Number = outerCircle.radius - bounceObject.radius - v.len;
				
				// check if bounceObject has intersected outerCircle
				if (penAmt < 0) {
					
					// get normal of v (create 'wall')
					var wall:Object = {dx:-v.dy, dy:v.dx, lx:-v.dx, ly:-v.dy};
					var bounce:Object = {vx: bounceObject.vx, vy: bounceObject.vy};

					bounceProj = getWallBounce(bounce, wall);

					// set x,y adjustment values to move away from outerCircle (causes slight innacuracy in result velocity)
					bounceProj.adjustx = v.dx * penAmt;
					bounceProj.adjusty = v.dy * penAmt;
					
					// set hit true
					bounceProj.hit = true;
				}
				return bounceProj;
			}
			
		/* -------------------------------
		   getBallBounce
		   calculate bounce given two vectors, bouncing of v3
		   ------------------------------- */
			public function getBallBounce(v1:Object, v2:Object, v3:Object):Object {
				
				// projection objects
				var proj13:Object = new Object();
				var proj13n:Object = new Object();
				var proj23:Object = new Object();
				var proj23n:Object = new Object();
				
				var bounceProj:Object = new Object();
				
				// projection of v1 on v3
				proj13 = projectVector(v1, v3.dx, v3.dy);
				// projection v1 on v3 normal
				proj13n = projectVector(v1, v3.lx, v3.ly);
				// projection of v2 on v3
				proj23 = projectVector(v2, v3.dx, v3.dy);
				// projection of v2 on v3 normal
				proj23n = projectVector(v2, v3.lx, v3.ly);
					
				// get 'x' momentum
				var Px:Number = v1.m * proj13.vx + v2.m * proj23.vx; // get momentum P
				var Vx:Number = proj13.vx - proj23.vx; // get velocity V
				
				var v2fx:Number = (Px + Vx * v1.m) / (v1.m + v2.m);
				var v1fx:Number = v2fx - Vx;
				
				// get 'y' momentum
				var Py:Number = v1.m * proj13.vy + v2.m * proj23.vy;
				var Vy:Number = proj13.vy - proj23.vy;
				
				var v2fy:Number = (Py + Vy * v1.m) / (v1.m + v2.m);
				var v1fy:Number = v2fy - Vy;
		
				// add the projections for v1
				bounceProj.vx1 = proj13n.vx + v1fx;
				bounceProj.vy1 = proj13n.vy + v1fy;
				// add the projections for v2
				bounceProj.vx2 = proj23n.vx + v2fx;
				bounceProj.vy2 = proj23n.vy + v2fy;
				
				
				// softness system - reduces ball 'vibration' - kills extremely small velocities
				var softness = .2;
				
				if (Math.abs(bounceProj.vx1) < softness && Math.abs(bounceProj.vy1) < softness) {
					bounceProj.vx1 = 0;
					bounceProj.vy1 = 0;
				}
				if (Math.abs(bounceProj.vx2) < softness && Math.abs(bounceProj.vy2) < softness) {
					bounceProj.vx2 = 0;
					bounceProj.vy2 = 0;
				}
				
				return bounceProj;
			}	
		/* -------------------------------
		   getWallBounce
		   calculate bounce given two vectors, v1 bouncing off static v2
		   ------------------------------- */
			public function getWallBounce(v1:Object, v2:Object):Object {
				
				// projection objects
				var proj1:Object = new Object();
				var proj2:Object = new Object();
				var bounceProj:Object = new Object();
				
				// project v1 (object) on v2 (wall)
				proj1 = projectVector(v1, v2.dx, v2.dy);

				// project v1 (object) on v2 (wall) normal
				proj2 = projectVector(v1, v2.lx, v2.ly);
				
				// reverse projection on v2 normal
				proj2.len = Math.sqrt((proj2.vx * proj2.vx) + (proj2.vy * proj2.vy));
				proj2.vx = v2.lx * proj2.len;
				proj2.vy = v2.ly * proj2.len;
				
				// add the projections
				bounceProj.vx = proj1.vx + proj2.vx;
				bounceProj.vy = proj1.vy + proj2.vy;
				
				return bounceProj;				
			}
		/* -------------------------------
		   getVectorProperties
		   create vector length, normalized dx,dy - left/right normal of dx,dy
		   ------------------------------- */
			public function getVectorProperties(v:Object):Object {
				// vector properties object
				var vp:Object = new Object();
				
				// assign input vector (vx,vy)
				vp.vx = v.vx;
				vp.vy = v.vy;
				
				// vector length
				vp.len = Math.sqrt((vp.vx * vp.vx) + (vp.vy * vp.vy));
				
				// normalized vector
				if (vp.len > 0) {
					vp.dx = v.vx / vp.len;
					vp.dy = v.vy / vp.len;
				} else {
					vp.dx = 0;
					vp.dy = 0;
				}
				
				// right normal
				vp.rx = -vp.dy;
				vp.ry = vp.dx;

				// left normal
				vp.lx = vp.dy;
				vp.ly = -vp.dx;
				
				return vp;
			}
		/* -------------------------------
		   projectVector
		   project vector v1 on normalized vector v2 (dx, dy)
		   ------------------------------- */
			public function projectVector(v1:Object, dx:Number, dy:Number):Object {
				var newProjection:Object = new Object();
				
				// find dot product
				var dp:Number = (v1.vx * dx) + (v1.vy * dy);
				
				// projection components
				newProjection.vx = dp * dx;
				newProjection.vy = dp * dy;
				
				return newProjection;
			}
	}
}



