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

	import com.fastforwardthinker.util.mp3.vo.MP3InfoVO;
	import com.fastforwardthinker.util.mp3.interfaces.IMP3Responder; 
	import com.fastforwardthinker.util.mp3.constants.MpegChannelModes;
	import com.fastforwardthinker.util.mp3.constants.MpegBitRates;
	import com.fastforwardthinker.util.mp3.constants.MpegVersions;
	import com.fastforwardthinker.util.mp3.constants.MpegSampleRates;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	
	public class MP3InfoUtil
	{
		
		//------------------
		// PRIVATE CONSTANTS
		//------------------
		
 		/**
	     * Stores a reference table of mpeg bitrates
	     */
		static private const MPEG_BITRATES:Array =  MpegBitRates.toArray();
		/**
	     * Stores a reference table of mpeg versions
	     */                            				
	    static private const MPEG_VERSIONS:Array = MpegVersions.toArray();
	    /**
	     * Stores a reference table of sample rates
	     */  
	   	static private const MPEG_SAMPLE_RATES:Array = MpegSampleRates.toArray();
	   	
	    //------------------
		// PRIVATE VARIABLES
		//------------------
		
		/**
	     * Holds the mpeg file header on which analysis 
	     * will be performed
	     */
	    static private var _bitHeader:uint;
	    /**
	     * Flag which stores whether or not the mpeg
	     * employs variable bit rate encoding
	     */
	    static private var _isVarBitRate:Boolean;
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
		static private var _responder:IMP3Responder;
		/**
	     * Holds a list of property names to be returned
	     * to the responder
	     */ 
		static private var _props:Array;
		
		
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
		 * @param responder the calling class which implements the 
		 * IMP3Responder interface to which the result (or fault) 
		 * will be returned. 
		 * 
		 * @see com.fastforwardthinker.util.mp3.interfaces.IMP3Responder
		 */
		public static function getInfo( url:String, responder:IMP3Responder ):void
		{
			// set the responder
			_responder = responder;
			
			// ensure the url is not empty
			if( !url || url=='' )
			{
				_responder.onMP3InfoFault( 'Error! URL must not be empty!' );
				return;
			}
			
			// load the file	
			load( url );
		}
		
		//------------------
		// INTERNAL METHODS
		//------------------
		
		
		/**
		 * 
		 * Adds listeners to the URLStream and begins
		 * loading the mpeg file
		 * 
		 * @param url to the mpeg file to analyze
		 * 
		 */			 				                          
		internal static function load( url:String ):void
		{
			// add listeners
			_loader = new URLStream();
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress)
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError)
			
			// Load the mp3
			_loader.load( new URLRequest(url) );
		}
		/**
		 * 
		 * Handles the loading progress of the URLStream 
		 * and closes the loader once enough data has been
		 * obtained to perform an analysis
		 * 
		 */	
		internal static function onLoadProgress( event:ProgressEvent ):void
		{
			// 48 bytes is all the data required to perform analysis 
			if( event.bytesLoaded >= 48 ) 
			{
				// read the bytes into a byte array
				var ba:ByteArray = new ByteArray();
				_loader.readBytes(ba, 0, 48)
				
				// set the lenth in bytes
				_lenBytes = event.bytesTotal;
				
				// process the result
				var result:MP3InfoVO = analyze( ba );
					
				// return result to responder
				_responder.onMP3InfoResult( result );
				
				// kill the loader
				destroyLoader();
			}
		}
		/**
		 * 
		 * Handles exceptions from the URLLoader and 
		 * returns the event to the faultHandler method
		 * if one was supplied to the public getInfo() 
		 * function
		 * 
		 * @param info the error object or fault event
		 * 
		 */	
		internal static function onError( info:* ):void
		{
			// return faults to the responder
			_responder.onMP3InfoFault( info )
			destroyLoader();
		}
		/**
		 * Destroys the URLStream once enough data has
		 * been obtained to perform analysis or when
		 * a fault or error is encountered 
		 * 
		 */	
		internal static function destroyLoader():void
		{
			// tear down the loader
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress)
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError)
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
	    internal static function analyze( ba:ByteArray ):MP3InfoVO
	    {
			// Raw header of CBR mepgs
	        var bytHeader:ByteArray = new ByteArray();
	        bytHeader.writeByte(4);
	        
	        // Raw header of VBR mepgs
	        var bytVBitRate:ByteArray = new ByteArray(); 
	        bytVBitRate.writeByte(12);
	        
	        // Offset position used during data access
	        var offsetPos:int = 0;
	        
	        // Read 4 bytes intervals from the header until 
	        // we can determine the file is a valid mpeg
	        do
	        {
	            ba.position = offsetPos;
	            ba.readBytes( bytHeader, 0, 4 );
	            offsetPos++;
	            // Set the new data chunck
	            loadMP3Header( bytHeader );
	        }
	        while( !isValidHeader && ( ba.position != ba.length ) );
	        
	        // If the byte array position is equal to the length, 
	        // we've read the entire file and it's NOT a valid mpeg!
	        if( ba.position != ba.length )
	        {
	            offsetPos += 3;
				
				// Determine the mpeg version of the file
	            if(versionIndex == 3) 
	                offsetPos += (modeIndex == 3)? 
	                17 : // MPEG Version 1
	                32;    
	            
	            else 
	                offsetPos += (modeIndex == 3)?	
	                9  : // MPEG Version 2.0 or 2.5
	                17;   
	               
	            
	            // Determine if the mpeg employs variable bitrate encoding (VBR)
	            ba.position = offsetPos;
	            ba.readBytes(bytVBitRate,0,12);
	            _isVarBitRate = loadVBRHeader(bytVBitRate);
				
	            return populatedResults();
	        }
	        
	        // NOT a valid MP3 file!
	        throw new Error('Invalid file type or corrupt mpeg header' );
	        
	        return null
	        
	    }
	    /**
		 * Populates the MP3InfoVO value object with 
		 * the mpeg properties from the analysis
		 * 
		 */	
		internal static function populatedResults():MP3InfoVO
		{
			var resultVO:MP3InfoVO 		= new MP3InfoVO();
			
			resultVO.bitRate 			= bitRate;
			resultVO.channelMode 		= channelMode;
			resultVO.channels			= channels;
			resultVO.isCBR 				= isCBR;
			resultVO.isVBR 				= isVBR;
			resultVO.lengthBytes 		= lengthBytes;
			resultVO.lengthFormatted 	= lengthFormatted;
			resultVO.lengthSeconds 		= lengthSeconds;
			resultVO.mpegLayer 			= mpegLayer;
			resultVO.mpegVersion 		= mpegVersion;
			resultVO.frameCount 		= frameCount;
			resultVO.sampleRate 		= sampleRate;
			
			return resultVO;
		}
		
	   /**
	    * 
	    * Determines if the loaded data is a valid mpeg header
	    * 
	    */ 
		internal static function get isValidHeader():Boolean 
	    {
	        return (((frameSync      & 2047)==2047) &&
	                ((versionIndex   &    3)!=   1) &&
	                ((layerIndex     &    3)!=   0) && 
	                ((bitrateIndex   &   15)!=   0) &&
	                ((bitrateIndex   &   15)!=  15) &&
	                ((sampleRateIndex &    3)!=   3) &&
	                ((emphasisIndex  &    3)!=   2)    );
	    }
	   /**
	    * 
	    * Loads a chuck of mpeg header data into the private 
	    * '_bitHeader' variable by bit-shifting the raw data
	    * 
	    * @param ba the source header byte array
	    */
	    internal static function loadMP3Header( ba:ByteArray ):void
	    {
	        // this thing is quite interesting, it works as follows:
	        // c[0] = 00000011
	        // c[1] = 00001100
	        // c[2] = 00110000
	        // c[3] = 11000000
	        // the operator << means that we'll move the bits in that direction
	        // 00000011 << 24 = 00000011000000000000000000000000
	        // 00001100 << 16 =         000011000000000000000000
	        // 00110000 << 24 =                 0011000000000000
	        // 11000000       =                         11000000
	        //                +_________________________________
	        //                  00000011000011000011000011000000
	        
	        _bitHeader = ( 	( (ba[0] & 255) << 24 ) | 
	        			 	( (ba[1] & 255) << 16 ) | 
	        			 	( (ba[2] & 255) <<  8 ) | 
	        			 	( (ba[3] & 255) )	); 
	    }
	   /**
	    * 
	    * Determines if the mpeg employs varible bit rate encoding
	    * 
	    * @return boolean true when VBR is used, false when CBR is used
	    * @param ba the source header byte array
	    */	 
	    internal static function loadVBRHeader( ba:ByteArray ):Boolean
	    {
	        // The first 4 bytes of variable bit-rate mpegs will parse to 
	        // the utf string 'Xing', a reference to the group responsible 
	        // for adding variable bitrate mpeg encoding to the mpeg standard
	    	// 88  == X
	    	// 105 == i
	    	// 110 == n
	    	// 103 == g
	        if( ba[0] == 88  && ba[1] == 105 && 
	            ba[2] == 110 && ba[3] == 103 )
	        {
	            var flags:int = (   ((ba[4] & 255) << 24) | 
	            				 	((ba[5] & 255) << 16) | 
	            				 	((ba[6] & 255) <<  8) | 
	            				 	((ba[7] & 255) )   );
	            				 
	            if( (flags & 0x0001) == 1 )
	            {
	                _vbrFrames = (	((ba[8] & 255) << 24) | 
	                				((ba[9] & 255) << 16) | 
	                				((ba[10] & 255) << 8) | 
	                				((ba[11] & 255))	);
	                return true;
	            }
	            else
	            {
	                _vbrFrames = -1;
	                return true; // It's a VBR mpeg
	            }
	        }
	        return false; // NOT a VBR mpeg
	    }
		
		
		//------------------
		// INTERNAL GETTERS
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
	    	return _isVarBitRate;
	    }
	    /**
		* @return Boolean is the file constant bit rate?
		*/	
	    internal static function get isCBR():Boolean
	    {
	    	return !_isVarBitRate;
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
	        return MPEG_VERSIONS[ versionIndex ];
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
	            return MPEG_BITRATES[ (versionIndex & 1) ][ layerIndex-1 ][ bitrateIndex ];
	        }
	    }
		/**
	     * 
	     * @return the sample rate of the mpeg file
	     * @see com.fastforwardthinker.util.mp3.constants.SampleRates
	     */
	    internal static function get sampleRate():int 
	    {
	        return MPEG_SAMPLE_RATES[ versionIndex ][ sampleRateIndex ];
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
	                return 2;
	            case 3:
	                return 1;
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
	    
		//--------------
		// Index getters
		//--------------
		
	    internal static function get versionIndex() :int 	{ 	return ((_bitHeader>>19) & 3);  	} // mpeg version
	    internal static function get layerIndex():int    	{ 	return ((_bitHeader>>17) & 3);  	} // mpeg layer
	    internal static function get modeIndex():int     	{ 	return ((_bitHeader>>6) & 3);  		} // channel mode
	    internal static function get bitrateIndex():int  	{ 	return ((_bitHeader>>12) & 15); 	} // mpeg bit rate
	    internal static function get sampleRateIndex():int	{ 	return ((_bitHeader>>10) & 3);  	} // mpeg sample rate
	    internal static function get emphasisIndex():int 	{ 	return ( _bitHeader & 3 );  		}
	    internal static function get frameSync():int  		{	return ((_bitHeader>>21) & 2047); 	}
	    
	    internal static function get paddingBit():int    	{ 	return ((_bitHeader>>9) & 1);  		} // not yet utlized
		internal static function get privateBit():int    	{ 	return ((_bitHeader>>8) & 1);  		} // not yet utlized
	    internal static function get modeExtIndex():int  	{ 	return ((_bitHeader>>4) & 3);  		} // not yet utlized
	    internal static function get copyrightBit():int   	{ 	return ((_bitHeader>>3) & 1);  		} // not yet utlized
	    internal static function get orginalBit():int    	{ 	return ((_bitHeader>>2) & 1);  		} // not yet utlized
	    internal static function get protectionBit():int 	{ 	return ((_bitHeader>>16) & 1);  	} // not yet utlized
	    
	
	}//end class
	
}// end package
