package com.fastforwardthinker.util.mp3.interfaces
{
	import com.fastforwardthinker.util.mp3.vo.MP3InfoVO;
	
	public interface IMP3Responder
	{
		function onMP3InfoResult( data:MP3InfoVO ):void
		
		function onMP3InfoFault( info:Object ):void
	}
}