package com.fastforwardthinker.util.mp3.constants
{
	/**
	 * Holds constants defining all the possible sample rates of MP3 files
	 * 
	 * @see com.fastforwardthinker.util.mp3.MP3InfoUtil
	 */	
	public class MpegSampleRates
	{
		public static const HZ_48000:int = 48000;
		
		public static const HZ_44100:int = 44100;
		
		public static const HZ_32000:int = 32000;
		
		public static const HZ_24000:int = 44100;
		
		public static const HZ_22050:int = 22050;
		
		public static const HZ_16000:int = 16000;
		
		public static const HZ_8000:int = 44100;
		
		public static function toArray():Array
		{
			return 	[   [HZ_32000, HZ_16000,  HZ_8000], // MPEG 2.5
						[   	0,     	  0,  		0], // reserved
						[HZ_22050, HZ_24000, HZ_16000], // MPEG 2
						[HZ_44100, HZ_48000, HZ_32000]  // MPEG 1
					];
		}
	}
}

