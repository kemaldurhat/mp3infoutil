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