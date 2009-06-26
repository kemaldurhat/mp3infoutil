package com.fastforwardthinker.util.mp3.constants
{
	/**
	 * Holds constants defining all the possible mpeg versions
	 * 
	 * @see com.fastforwardthinker.util.mp3.MP3InfoUtil
	 */	
	public class MpegVersions
	{
		public static const MPEG_2_5:Number = 2.5;
		public static const MPEG_2:Number 	= 2;
		public static const MPEG_1:Number 	= 1;
		
		public static function toArray():Array
		{
			return [ MPEG_2_5, 	// MPEG 2.5
    				 0, 		// reserved
    				 MPEG_2, 	// MPEG 2
    				 MPEG_1 ];	// MPEG 1
		}
		
	}
}