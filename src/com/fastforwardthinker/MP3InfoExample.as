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
package com.fastforwardthinker
{	
	import com.fastforwardthinker.util.mp3.MP3InfoUtil;
	import com.fastforwardthinker.util.mp3.interfaces.IMP3Responder;
	import com.fastforwardthinker.util.mp3.vo.MP3InfoVO;
	import mx.utils.ObjectUtil;
	
	public class MP3InfoExample implements IMP3Responder
	{
		/**
		 * Constructor
		 */  
		public function MP3InfoExample( url:String = 'http://www.yourdomain.com/mp3/foo.mp3' )
		{
			trace( 'Processing MP3 Info for: ' + url )
			MP3InfoUtil.getInfo( url , this )
		}
		
		/**
		 * Handles results from the MP3InfoUtil
		 */  
		public function onMP3InfoResult( data:MP3InfoVO ):void
		{
			trace( ObjectUtil.toString( data ) );
		}
		
		/**
		 * Handles faults from the MP3InfoUtil
		 */  
		public function onMP3InfoFault( info:Object ):void
		{
			trace( info.toString() )
		}
		
	}
}