/*
MIT License

Copyright (c) 2009 Scott Paradis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package com.fastforwardthinker.util.mp3.constants
{
	/**
	 * Holds constants defining all the possible sample rates of MP3 files
	 * 
	 * @see com.fastforwardthinker.util.mp3.MP3InfoUtil
	 */	
	public class MpegSampleRates
	{
		public static const HZ_48000 : int 	= 48000;
		public static const HZ_44100 : int 	= 44100;
		public static const HZ_32000 : int 	= 32000;
		public static const HZ_24000 : int 	= 24000;
		public static const HZ_22050 : int 	= 22050;
		public static const HZ_16000 : int 	= 16000;
		public static const HZ_8000  : int 	= 8000;
		
		public static const	list:Array = [	
											[32000, 16000,  8000], // MPEG 2.5
											[   0,     	0,     0], // reserved
											[22050, 24000, 16000], // MPEG 2
											[44100, 48000, 32000]  // MPEG 1
										 ];
	}
}

