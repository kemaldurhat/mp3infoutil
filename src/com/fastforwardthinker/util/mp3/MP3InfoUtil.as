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
package com.fastforwardthinker.util.mp3
{
	/**
	 * MP3InfoUtil is a static utility class which extracts and analyzes 
	 * the binary header data from an MP3 file. A small portion 
	 * of data is used (48bytes) in order to determine mpeg 
	 * metadata (see below)
	 * 
	 * Portions of this code were ported to actionscript from 
	 * open-source C++ / C# mpeg libraries.
	 * 
	 * The value object returned to the responder contains the following 
	 * properties which describe the mpeg file that was analyzed:
	 * 
	 * bitRate 			: int 		- the bit rate, in Kbps, of the mpeg file (e.g. 192, 128, etc) 
	 * sampleRate 		: int 		- the sample rate, in Hz, of the mpeg file (e.g. 44100)  
	 * mpegLayer 		: int 		- the mpeg layer ( 1, 2 or 3 )
	 * mpegVersion 		: Number 	- the mpeg version ( 1 , 2, or 2.5 )
	 * channelMode 		: String 	- type of channel mode used ( 'mono', 'stereo', 'joint stereo' or 'dual channel')
	 * channels 		: int 		- the number of channels ( 1 or 2 )
	 * lengthBytes 		: int 		- the length of the file, in bytes
	 * lengthSeconds 	: int 		- the playback length of the file, in seconds
	 * lengthFormatted 	: String 	- human-readable time string, in the format [hh:]mm:ss
	 * frameCount		: int 		- the number of frames in the mpeg file 
	 * isVBR 			: Boolean	- does the mpeg file employ varible bit-rate encoding?
	 * isCBR 			: Boolean	- does the mpeg file employ constant bit-rate encoding? 
	 * 
	 */	

	import com.fastforwardthinker.util.mp3.constants.MpegBitRates;
	import com.fastforwardthinker.util.mp3.constants.MpegChannelModes;
	import com.fastforwardthinker.util.mp3.constants.MpegSampleRates;
	import com.fastforwardthinker.util.mp3.constants.MpegVersions;
	import com.fastforwardthinker.util.mp3.events.MP3InfoEvent;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import mx.rpc.IResponder;
	
	[Event(name="complete",type="com.fastforwardthinker.util.mp3.events.MP3InfoEvent")]
	[Event(name="error",type="com.fastforwardthinker.util.mp3.events.MP3InfoEvent")]
	
	public class MP3InfoUtil
	{

		
	    //------------------
		// PRIVATE VARIABLES
		//------------------
		
		/**
	     * Holds the mpeg file header on which analysis 
	     * will be performed
	     */
	    static private var _currentChunk:uint;
	    /**
	     * Flag which stores whether or not the mpeg
	     * employs variable bit rate encoding
	     */
	    static private var _isCBR:Boolean;
	    /**
	     * Holds the number of frames of variable bit rate 
	     * mpeg files
	     */
	    static private var _vbrFrames:int;
	    /**
	     * Holds the the size, in bytes, of the mpeg file
	     */
		static private var _lenBytes:int;
		/**
	     * Holds URLStream object which loads the mpeg file
	     */ 
		static private var _loader:URLStream;
		/**
	     * Class implementing the IResponder interface 
	     * to which the result or fault are returned
	     */ 
		static private var _responder:IResponder;
		/**
	     * Holds the url to the mp3
	     */ 
		static private var _url:String;
		/**
	     * Disptaches events from this static class
	     */ 
		static private var _dispatcher:EventDispatcher;

		//------------------
		// PUBLIC METHODS
		//------------------
						                          
		/**
		 * Utility method used to load and extract metadata from the 
		 * header data of a valid mpeg file 
		 * 
		 * The file on which to perform analysis must be a valid mpeg file 
		 * (MPEG-Layer 1, MPEG-Layer 2 or MPEG-Layer 3)
		 * 
		 * The domain in which the mpeg file resides must employ either  
		 * a valid cross-domain policy file OR the file must reside 
		 * in the same security sandbox (same-domain) as the calling swf 
		 * in order to allow raw data access.
		 * 
		 * @param url the path to the mpeg file to load and analyze. 
		 * 
		 * @param responder the optional class instance which implements the 
		 * IResponder interface to which the result (or fault) will be returned. 
		 * 
		 */
		public static function getInfo( url:String, responder:IResponder=null ):void
		{
			_responder = responder;
			
			if( url == null || url == '' ){
				handleError( new Error('URL is undefined') );
			}
			
			_url = url;
			
			_loader = new URLStream();
			_loader.addEventListener(IOErrorEvent.IO_ERROR, handleError);
			_loader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress)
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError)
			_loader.load( new URLRequest( url ) );
		}
		
		
      	
		//------------------
		// INTERNAL METHODS
		//------------------
		
		/**
		 * 
		 * Handles the loading progress of the URLStream 
		 * and closes the loader once enough data has been
		 * obtained to perform an analysis
		 * 
		 */	
		internal static function onLoadProgress( event:ProgressEvent ):void
		{
			
			if( event.bytesLoaded < 48 )  
				return; // you have a realllly slow connection! wait for more data.
				
			var ba:ByteArray = new ByteArray();
			_loader.readBytes(ba, 0, 48)
			_lenBytes = event.bytesTotal;
				
			destroyLoader();
				
			var result:Object = analyze( ba );
				
			if( result == null ) // threw and caught an exception
				return;
				
			if( _responder != null )
				_responder.result( result );
					
			dispatchEvent( new MP3InfoEvent(MP3InfoEvent.COMPLETE, result ) );
		}
		/**
		 * 
		 * Handles errors for the class
		 * 
		 * @param errorEvent the error object or fault event
		 * 
		 */	
		internal static function handleError( e:*, info:Object = null ):void
		{
			destroyLoader();
			
			if( !info ) 
				info = {};
			
			info.url = _url;
			
			if( e is Event )
				info[e.type] = e;
	
			if( e is Error )
				info.message = e.message;
					
			dispatchEvent( new MP3InfoEvent( MP3InfoEvent.ERROR, info ) );
			
			if( _responder != null )
				_responder.fault( info );

			
		}
		/**
		 * Destroys the URLStream once enough data has
		 * been obtained to perform analysis or when
		 * a fault or error is encountered 
		 * 
		 */	
		internal static function destroyLoader():void
		{
			if( _loader == null )
				return;
				
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
			_loader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress)
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError)
			_loader.close();
			_loader = null; 
		}
		
	    /**
	     * 
	     * Performs analysis on on an mpeg header byte array
	     * 
	     * @param ba - bytearray containing mp3 header data
	     * 
	     * @return MP3InfoVO value object containg the results
	     * 
	     */	
	    internal static function analyze( bytes:ByteArray ):Object
	    {
			var offsetPos:int = 0;
			 	
	        var chunk:ByteArray = new ByteArray();
	        	chunk.writeByte(4);
	        try
			{  
		        do
		        {
		            bytes.position = offsetPos;
		            bytes.readBytes( chunk, 0, 4 );
		            offsetPos++;
		            loadNextChunk( chunk );
		        }
		        while( !isValidHeader && ( bytes.position != bytes.length ) );
	        		
		        if( bytes.position == bytes.length ) {
		        	
		      		throw new  IOError('File not found or file is not an mp3 or the data is corrupt' );
		      	}

		        offsetPos += 3;
				
				if(versionIndex == 3) 
		        	offsetPos += (modeIndex == 3)? // found MPEG Version 1
		        		17 : 32;    
		        else 
		            offsetPos += (modeIndex == 3)?	// found MPEG Version 2.0 or 2.5
		            	9 : 17;   
		               
		        	
		        bytes.position = offsetPos;
		        
		        // 'Xing' is key in the header data indicating vbr
		        var xingBytes:ByteArray = new ByteArray();
		        	xingBytes.writeByte(12);
		        	
		        bytes.readBytes( xingBytes, 0, 12);
		        
		        _isCBR = isCBRHeader( xingBytes );

		       	var	result:Object = {};
					result.bitRate 			= bitRate;
					result.channelMode 		= channelMode;
					result.channels			= channels;
					result.isCBR 			= isCBR;
					result.isVBR 			= isVBR;
					result.lengthBytes 		= lengthBytes;
					result.lengthFormatted 	= lengthFormatted;
					result.lengthSeconds 	= lengthSeconds;
					result.mpegLayer 		= mpegLayer;
					result.mpegVersion 		= mpegVersion;
					result.frameCount 		= frameCount;
					result.sampleRate 		= sampleRate;
					
				return result;
	        
	        }catch( e:Error ){
	        	bytes.position = 0;
	        	
	        	// decodes to human readable if we loaded an html/xml/text or 404 page, etc
	        	var utf:String = bytes.readUTFBytes( bytes.bytesAvailable ); 
	        	
	        	handleError( e, { utf:utf } );
	        }
	        return null
	    }
	   /**
	    * 
	    * Determines if our '_currentChunk' of data is the valid 
	    * mpeg header as we loop our bytes through looking for it. 
	    * 
	    * @return true when a valid header is found
	    */ 
		internal static function get isValidHeader():Boolean 
	    {
	        return (((frameSync      & 2047)==2047) &&
	                ((versionIndex   &    3)!=   1) &&
	                ((layerIndex     &    3)!=   0) && 
	                ((bitrateIndex   &   15)!=   0) &&
	                ((bitrateIndex   &   15)!=  15) &&
	                ((sampleRateIndex&    3)!=   3) &&
	                ((emphasisIndex  &    3)!=   2) );
	    }
	   /**
	    * 
	    * Loads a chuck of mpeg header data into the private 
	    * '_currentChunk' variable by bit-shifting the raw data
	    * 
	    * this thing is quite interesting, it works as follows:
	    * 
	    * ba[0] = 00000011
	    * ba[1] = 00001100
	    * ba[2] = 00110000
	    * ba[3] = 11000000
	    * 
	    * the operator '<< n' means bit-shift to left by 'n' bits:
	    * 
	    * 00000011 << 24 = 	00000011000000000000000000000000
	    * 00001100 << 16 =         	000011000000000000000000
	    * 00110000 << 8  =                 	0011000000000000
	    * 11000000       =                         	11000000
	    * 				 +__________________________________
	    * 					00000011000011000011000011000000
	    * 
	    * @param bytes 
	    */
	    internal static function loadNextChunk( bytes:ByteArray ):void
	    {
	        _currentChunk = (((bytes[0] & 255) << 24 ) | 
	        			 	( (bytes[1] & 255) << 16 ) | 
	        			 	( (bytes[2] & 255) <<  8 ) | 
	        			 	( (bytes[3] & 255))); 
	    }
	   /**
	    * 
	    * Determines if the mpeg employs varible bit rate encoding
	    * 
	    * The first 4 bytes of variable bit-rate mpegs will parse to 
	    * the utf string 'Xing', a reference to the group responsible 
	    * for adding variable bitrate mpeg encoding to the mpeg standard
	    * 
	    * Xing
	    * 88  == X
	    * 105 == i
	    * 110 == n
	    * 103 == g
	    * 
	    * @return boolean true when CBR is used, false when VBR is used
	    * @param ba the source header byte array
	    */	 
	    internal static function isCBRHeader( bytes:ByteArray ):Boolean
	    {
	    	try{
			        if( bytes[0] == 88  && bytes[1] == 105 && 
			            bytes[2] == 110 && bytes[3] == 103 )
			        {
			            var flags:int = (   ((bytes[4] & 255) << 24) | 
			            				 	((bytes[5] & 255) << 16) | 
			            				 	((bytes[6] & 255) <<  8) | 
			            				 	((bytes[7] & 255) )   );
			            				 
			            if( (flags & 0x0001) == 1 )
			            {
			                _vbrFrames = (	((bytes[8] & 255) << 24) | 
			                				((bytes[9] & 255) << 16) | 
			                				((bytes[10] & 255) << 8) | 
			                				((bytes[11] & 255))	);
			                return false; 
			            }
			            else
			            {
			                _vbrFrames = -1;
			                return false;
			            }
			        }
			   }catch( e:Error ){ //possibly corrupt data
			   		
			   		handleError( e );
			   }
			   
			   return true; 
	    }
		
		
		//------------------
		// INTERNAL GETTERS - Edit at your own risk!
	    //------------------
	    
	    /**
		 * 
		 * @return string Human-readable string of the 
		 * total mpeg duration, in the format [hh]:mm:ss
		 * 
		 */	
		internal static function get lengthFormatted():String
	    {
	        var totalSeconds:uint = lengthSeconds;
	        
			var h :uint = Math.floor( totalSeconds / 3600 );
			var hours :String = h<10 ? "0"+h.toString() : h.toString();
			
			var m :uint = Math.floor( totalSeconds / 60 );
			var minutes :String = m<10 ? "0"+m.toString() : m.toString();
			
			var s :uint = totalSeconds % 60;
			var seconds :String = s<10 ? "0"+s.toString() : s.toString();
				
			return h>0?hours+":":"" + minutes + ":" + seconds;
		
	    }
	    /**
		* @return Boolean is the file variable bit rate?
		*/	
	    internal static function get isVBR():Boolean
	    {
	    	return !_isCBR;
	    }
	    /**
		* @return Boolean is the file constant bit rate?
		*/	
	    internal static function get isCBR():Boolean
	    {
	    	return _isCBR;
	    }
	   /**
		* @return int the length, in bytes, of the file
		*/	
	    internal static function get lengthBytes():int
	    {
	    	return _lenBytes;
	    }
	    /**
	     * 
	     * @return the mpeg version of the file
	     * @see com.beatport.framework.tool.util.audio.mp3.constants.MpegVersions
	     */
	    internal static function get mpegVersion():Number 
	    {
	        return MpegVersions.list[ versionIndex ];
	    }
		/**
	     * 
	     * @return the sample mpeg layer of the file
	     * 
	     */
	    internal static function get mpegLayer():int 
	    {
	        return ( 4 - layerIndex );
	    }
		/**
	     * 
	     * @return the bit rate of the mpeg file
	     * @see com.fastforwardthinker.util.mp3.constants.MpegBitRates
	     */
	    internal static function get bitRate():int
	    {
	        // For VBR mpegs, we return an average bitrate
	        // 
	        // For CBR mpegs, we instead use a lookup table 
	        // to return the actual constant bitrate
	        if( isVBR )
	        {
	            var medFrameSize:Number = _lenBytes / frameCount;
	            return ( (medFrameSize * sampleRate) / (1000.0 * ((layerIndex==3) ? 12.0 : 144.0)) );
	        }
	        else
	        {
	            return MpegBitRates.list[ (versionIndex & 1) ][ layerIndex-1 ][ bitrateIndex ];
	        }
	    }
		/**
	     * 
	     * @return the sample rate of the mpeg file
	     * @see com.fastforwardthinker.util.mp3.constants.SampleRates
	     */
	    internal static function get sampleRate():int 
	    {
	        return MpegSampleRates.list[ versionIndex ][ sampleRateIndex ];
	    }
		/**
	     * 
	     * @return the channel mode of the mpeg file
	     * @see com.fastforwardthinker.util.mp3.constants.ChannelMode
	     */
	    internal static function get channelMode():String
	    {
	        switch( modeIndex ) 
	        {
	            default:
	                return MpegChannelModes.STEREO;
	            case 1:
	                return MpegChannelModes.JOINT_STEREO;
	            case 2:
	                return MpegChannelModes.DUAL_CHANNEL;
	            case 3:
	                return MpegChannelModes.MONO;
	        }
	    }
	    /**
	     * 
	     * @return the number of channels in the mpeg file ( 2 || 1 )
	     * 
	     */
	     internal static function get channels():int
	     {
	        switch( modeIndex ) 
	        {
	            case 1:
	            case 2:
	            default:
	                return 2; // stereo, joint stereo or dual
	            case 3:
	                return 1; // mono
	        }
	     }
	    
	   /**
	    * 
	    * @return the length in seconds of the mpeg file
	    * 
	    */	
	    internal static function get lengthSeconds():int 
	    {
	        // divide the file size by 1000 to match the Kbps
	        var sizeInKilobits:int = ( (8 * _lenBytes) / 1000 );
	        return ( sizeInKilobits / bitRate );
	    }
	
	   /**
	    * 
	    * @return the number of frames in the mpeg file
	    * 
	    */		
	    internal static function get frameCount():int
	    {
	        // The number MPEG frames is dependant on whether the mpeg has CBR or VBR encoding
	        if ( !isVBR ) 
	        {
	            var medFrameSize:Number = ( (layerIndex==3) ? 12 : 144) * ( (1000*bitRate)/sampleRate );
	            return ( _lenBytes/medFrameSize );
	        }
	        else 
	            return _vbrFrames;
	    }
	    
	    //-------------------
		// EventDispatcher
		//-------------------
	    
	    /**
		 * addEventListener
		 */
		public static function addEventListener( type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
      			if ( _dispatcher == null ) { _dispatcher = new EventDispatcher(); }
      			_dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference);
      	}
      	/**
		 * removeEventListener
		 */
    	public static function removeEventListener( type:String, listener:Function, useCapture:Boolean=false):void {
      			if ( _dispatcher == null){ return; }
      			_dispatcher.removeEventListener(type, listener, useCapture);
      	}
      	/**
		 * dispatchEvent
		 */
    	public static function dispatchEvent(event:Event):void {
      			if ( _dispatcher == null ){ return; }
      			_dispatcher.dispatchEvent(event);
      	}
      	
      	
		//--------------
		// Index getters
		//--------------
		
	    internal static function get versionIndex() :int 	{ 	return ((_currentChunk>>19) & 3);  	} // mpeg version
	    internal static function get layerIndex():int    	{ 	return ((_currentChunk>>17) & 3);  	} // mpeg layer
	    internal static function get modeIndex():int     	{ 	return ((_currentChunk>>6) & 3);  		} // channel mode
	    internal static function get bitrateIndex():int  	{ 	return ((_currentChunk>>12) & 15); 	} // mpeg bit rate
	    internal static function get sampleRateIndex():int	{ 	return ((_currentChunk>>10) & 3);  	} // mpeg sample rate
	    internal static function get emphasisIndex():int 	{ 	return ( _currentChunk & 3 );  		}
	    internal static function get frameSync():int  		{	return ((_currentChunk>>21) & 2047); 	}
	    
	    internal static function get paddingBit():int    	{ 	return ((_currentChunk>>9) & 1);  		} // not yet utlized
		internal static function get privateBit():int    	{ 	return ((_currentChunk>>8) & 1);  		} // not yet utlized
	    internal static function get modeExtIndex():int  	{ 	return ((_currentChunk>>4) & 3);  		} // not yet utlized
	    internal static function get copyrightBit():int   	{ 	return ((_currentChunk>>3) & 1);  		} // not yet utlized
	    internal static function get orginalBit():int    	{ 	return ((_currentChunk>>2) & 1);  		} // not yet utlized
	    internal static function get protectionBit():int 	{ 	return ((_currentChunk>>16) & 1);  	} // not yet utlized
	    
	
	}//end class
	
}// end package
