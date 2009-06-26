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
	 * Holds constants defining alll the possible mpeg bitrates of MP3 files
	 * 
	 * @see com.fastforwardthinker.util.mp3.MP3InfoUtil
	 */	
	public class MpegBitRates
	{
		public static const Kbps_8:int =  8;
		public static const Kbps_16:int = 16;
		public static const Kbps_24:int = 24;
		public static const Kbps_32:int = 32;
		public static const Kbps_40:int = 40;
		public static const Kbps_48:int = 48;
		public static const Kbps_56:int = 56;
		public static const Kbps_64:int = 64;
		public static const Kbps_80:int = 80;
		public static const Kbps_96:int = 96;
		public static const Kbps_112:int = 112;
		public static const Kbps_128:int = 128;
		public static const Kbps_144:int = 144;
		public static const Kbps_160:int = 160;
		public static const Kbps_176:int = 176;
		public static const Kbps_192:int = 192;
		public static const Kbps_224:int = 224;
		public static const Kbps_256:int = 256;
		public static const Kbps_288:int = 288;
		public static const Kbps_320:int = 320;
		public static const Kbps_352:int = 352; 
		public static const Kbps_384:int = 384;
		public static const Kbps_416:int = 416;
		public static const Kbps_448:int = 448; 
		
		static public function toArray():Array
		{
			return [
					    [ // MPEG 2 & 2.5
					        [0,  8, 16, 24, 32, 40, 48, 56, 64, 80, 96,112,128,144,160,0], // Layer III
					        [0,  8, 16, 24, 32, 40, 48, 56, 64, 80, 96,112,128,144,160,0], // Layer II
					        [0, 32, 48, 56, 64, 80, 96,112,128,144,160,176,192,224,256,0]  // Layer I
					    ],
					    [ // MPEG 1
					        [0, 32, 40, 48, 56, 64, 80, 96,112,128,160,192,224,256,320,0], // Layer III
					        [0, 32, 48, 56, 64, 80, 96,112,128,160,192,224,256,320,384,0], // Layer II
					        [0, 32, 64, 96,128,160,192,224,256,288,320,352,384,416,448,0]  // Layer I
					    ]
   					];
		}
	}
}