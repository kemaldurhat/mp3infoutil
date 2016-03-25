## Overview ##

---

MP3InfoUtil is an Actionscript 3 / Flex utility used to retrieve, parse and process metadata from the headers of MP3 files online **without** first waiting for the entire file to download (as is the default case in AS3)

Through a series of byte-array comparisons and bit-shifting operations (ported to Actionscript 3 from C++/C# libraries), core properties of the mpeg file (see table below) can be extracted and interpolated from a very small amount downloaded data.

Because such a small amount of data (≈ 48 bytes) is needed to perform the analysis, execution time is is quite fast... taking less than < 1 second to retrieve an mp3 from the web, parse the data and return the results.
<br />

## Metadata ##

---

The following values are returned as a result of the data analysis:
| **Variable**         | **Data Type** | **Description** |
|:---------------------|:--------------|:----------------|
| `bitRate`            |  int          | bit rate, in Kbps, of the mpeg file (i.e. 192) |
| `sampleRate`         | int           | sample rate, in Hz, of the file (i.e. 44100) |
| `mpegLayer`          |  int          | the mpeg layer of the file (layer I, II or II) |
| `mpegVersion`        |  Number       | the mpeg version (1, 2 or 2.5)|
| `channelMode`        |  String       | mono','stereo','joint stereo' or 'dual channel'|
| `channels`           |  int          | number of channels (1 or 2)|
| `lengthBytes`        |  int          | length of the mpeg, in bytes|
| `lengthSeconds`      |  int          | duration, in seconds|
| `lengthFormatted`    |  String       | duration, formatted as hh:?mm:ss|
| `frameCount`         |  int          | number of frames in the mpeg|
| `isVBR`              |  Boolean      | mp3 is variable bit-rate (VBR)|
| `isCBR`              |  Boolean      | mp3 is constant bit-rate (CBR)|
|                      |               |                               |
<br />

## Limitations ##

---

  * This utility does not extract ID3 tags or metadata and support is not planned at this time.

  * MP3 files **must** reside within the security sandbox of the calling SWF **-OR-** reside on a domain which implements a cross-domain policy allowing raw data access [more...](http://livedocs.adobe.com/flex/3/html/help.html?content=05B_Security_04.html)
<br />

## Credits ##

---

Author: Scott Paradis

Thanks to: Robert A. Wlodarczyk for his excellent C# bit-shifting code, of which portions of this utility are based.

Special thanks to my employer, **[Beatport.com](https://www.beatport.com)**, for being so cool and letting me share this code with the world.

