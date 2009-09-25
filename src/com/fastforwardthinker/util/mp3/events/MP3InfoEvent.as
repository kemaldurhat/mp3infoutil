package com.fastforwardthinker.util.mp3.events
{
	import flash.events.Event;

	public class MP3InfoEvent extends Event
	{
		public static const COMPLETE:String = "complete";
		public static const ERROR:String = "error";
		
		public var info:*;
		
		public function MP3InfoEvent(type:String, info:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.info = info;
			
			super(type, bubbles, cancelable);
		}
		
	}
}