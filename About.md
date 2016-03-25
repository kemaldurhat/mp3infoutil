### Introduction ###
MP3Info is a static utility class for obtaining header metadata from mpeg files. A URL to an mp3 is supplied as input and the class loads a very small portion of the file data.

Through a series of byteArray calculations and bit-shifting operations (ported to actionscript from C++/C# libraries), core metadata properties of the mpeg file can be extracted and interpolated from the small amount header data.

The analysis process is very efficient as the loading process is immediately closed once enough data has been obtained to perform the operations (approximately 48 bytes of data is needed).


### Metadata ###
The following values are returned as a result of the header analysis:

  * **bitRate** - bit rate, in Kbps, of the mpeg file (i.e. 192)
  * **sampleRate** - sample rate, in Hz (i.e. 44100)
  * **mpegLayer** - the mpeg layer (1, 2 or 3)
  * **mpegVersion** - the mpeg version (1, 2 or 2.5)
  * **channelMode** - 'mono','stereo','joint stereo' or 'dual channel'
  * **channels** - number of channels (1 or 2)
  * **lengthBytes** - length of the mpeg, in bytes
  * **lengthSeconds** - duration, in seconds
  * **lengthFormatted** - duration, formatted as [hh:]mm:ss
  * **frameCount** - number of frames in the mpeg
  * **isVBR** - is mp3 variable bit-rate (VBR)?
  * **isCBR** - is the mp3 constant bit-rate (CBR)?



### Example Use Case ###
MP3InfoUtil can be used to determine the length of an MP3 without first waiting for the entire file to load.

By obtaining the MP3 header data, the length / duration of the file can quickly be calculated from a small amount of header data.

This would be useful for things like Flash mp3 players that use time displays and scrubber controls.



### Requirements ###
  * Target file must be a valid mpeg file (layer 1, 2 or 3)
  * Target file must be within the security sandbox of the calling swf OR the domain on which the file resides must have a cross-domain policy file which permits data access.
  * The calling class must implement the IMP3Responder interface (included in the package) in order for the results (or faults) of the analysis to be returned.



### Limitations ###
At this time, the MP3InfoUtil does not extract ID3 metadata from the MP3 and support for this feature is not planned at this time.