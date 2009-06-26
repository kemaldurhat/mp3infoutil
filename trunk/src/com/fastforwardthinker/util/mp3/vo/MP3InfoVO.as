package com.fastforwardthinker.util.mp3.vo
{
	[Bindable]
	public class MP3InfoVO
	{
		public var bitRate:int;
		public var sampleRate:int;
		public var mpegLayer:int;
		public var mpegVersion:Number;
		public var channelMode:String;
		public var channels:int;
		public var lengthBytes:int;
		public var lengthSeconds:int;
		public var lengthFormatted:String;
		public var frameCount:int;
		public var isVBR:Boolean;
		public var isCBR:Boolean;
	}
}