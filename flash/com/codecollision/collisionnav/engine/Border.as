/*

     File:	GameBorder.as
 Revision:	0.0.1
  Purpose:	
  Authors:	
  Created:	Mar 15, 2007
   Edited:	
    Notes:	
Functions:	

*/


package com.codecollision.collisionnav.engine {

/* -------------------------------
   class Ball
   ------------------------------- */
	public class Border extends Ball {
		/* -------------------------------
		   static variables
		   ------------------------------- */
		   
		/* -------------------------------
		   instance variables
		   ------------------------------- */
			
		   
		/* -------------------------------
		   Ball Constructor
		   ------------------------------- */
		public function Border(radius:Number, xPos:Number, yPos:Number, color:Number, borderColor:Number, alpha:Number, borderAlpha:Number) {
			// call Ball class constructor
			super(0, radius, 0, xPos, yPos, 0, 0, color, borderColor, alpha, borderAlpha, "", "", "");
		}
		///////////////////////////////////////////////////////////////////////////////
		//
		//		public functions
		//
		///////////////////////////////////////////////////////////////////////////////


		///////////////////////////////////////////////////////////////////////////////
		//
		//		private functions
		//
		///////////////////////////////////////////////////////////////////////////////


	}
}