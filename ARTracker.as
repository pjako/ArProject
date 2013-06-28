package
{
	
	import art.CModule;
	import art.FlashEcho;
	import art.FlashSetup;
	import art.FlashTick;
	import art.vfs.RootFSBackingStore;
	
	import away3d.textures.*;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.*;
	import flash.utils.*;
	
	
	
	public class ARTracker extends Sprite
	{
		// tracking libapi only supports 320x240
		private static var trackWidth:Number = 320;
		private static var trackHeight:Number = 240;
		// video background 
		private static var bgWidth:Number = 320;
		private static var bgHeight:Number = 240;
		private static var bgTextureResolution:Number = 128;
		// marker ids
		private static var marker1Id:Number = 6;
		private static var marker2Id:Number = 11;
		private static var marker3Id:Number = 1;
	
		private var rgbaArray:ByteArray;
		private var transformedArray:ByteArray;
		private var webcamTexture:ARTexture;
		
		public var videoBackground:BitmapTexture;
		
		private var m1:Matrix3D;
		private var m2:Matrix3D;
		private var m3:Matrix3D;
		
		public function ARTracker()
		{
			trace("ctor ARTracker");
			
			CModule.startAsync(this);
			rgbaArray = new ByteArray();
			transformedArray = new ByteArray();
			m1 = new Matrix3D();
			m2 = new Matrix3D();
			m3 = new Matrix3D();
			webcamTexture = new ARTexture(bgWidth, bgHeight,trackWidth,trackHeight,bgTextureResolution, null, true);
			videoBackground = webcamTexture.bitmapTexture;
			CModule.vfs.addBackingStore(new RootFSBackingStore(), null);
			FlashSetup("");
		}
		
		public function doTracking():void 
		{
			webcamTexture.update();
			
			var rect:Rectangle = new Rectangle(0,0,trackWidth,trackHeight);
			rgbaArray = webcamTexture.bitmapData.getPixels(rect);
			rgbaArray.position = 0;
			
			// call the tracker api
			var data:Array; 
			// Now we want a pointer to that ByteArray
			var bytesPtr:int = CModule.malloc(rgbaArray.length);
			var bytesVideoPtr:int = CModule.malloc(trackWidth*trackHeight*4);
			
			// Use CModule.writeBytes() to write the ByteArray we created into Alchemy's main memory.
			CModule.writeBytes(bytesPtr, rgbaArray.length, rgbaArray);
			var retVal:String = FlashTick(bytesPtr, rgbaArray.length, bytesVideoPtr);
			data = retVal.split(" ");
			
			CModule.free(bytesVideoPtr);
			CModule.free(bytesPtr);
			
			transformTackingDatatoEvent(data);
		}
		
		public function transformTackingDatatoEvent(r:Array) : void
		{
			
			var trackerEvent:TrackEvent = new TrackEvent(TrackEvent.ON_MARKER_FRAME);
			
			var v:Vector.<Number> = new Vector.<Number>();
			//trace('currenttracker' + r[0]);
			// First Marker we track
			if(r[0]== marker1Id)
			{
				// get inverted matrix
				v.push( r[17],r[18],r[19],r[20],
						r[21],r[22],r[23],r[24],
						r[25],r[26],r[27],r[28],
						r[29],r[30],r[31],r[32]);
				m1.rawData = v;
			}else if(r[0]== marker2Id)
			{
				//get matrix
				v.push(r[1], r[2], r[3],  r[4],
					   r[5], r[6], r[7],  r[8],
					   r[9], r[10],r[11], r[12],
					   r[13],r[14],r[15], r[16]);
				m2.rawData = v;
			}
				
			var v2:Vector.<Number> = new Vector.<Number>();
			// second marker we track
			if(r[33]== marker1Id)
			{
				// get inverted matrix
				v2.push(r[50],r[51],r[52],r[53],
						r[54],r[55],r[56],r[57],
						r[58],r[59],r[60],r[61],
						r[62],r[63],r[64],r[65]);
				m1.rawData = v2;
			}else if(r[33]== marker2Id)
			{
				//get matrix
				v2.push(r[34],r[35],r[36],r[37],r[38],r[39],r[40],r[41],r[42],r[43],r[44],r[45],r[46],r[47],r[48],r[49]);
				m2.rawData = v2;
			}
		
			var v3:Vector.<Vector3D> = new Vector.<Vector3D>(3);
			v3 = m1.decompose();
			v3[0].y = v3[0].y * -1;
			v3[0].x = v3[0].x * 1;
			v3[0].z = v3[0].z * 1;
			v3[1].x = v3[1].x * -1;
			v3[1].y = v3[1].y * 1;
			v3[1].z = v3[1].z * -1;
			trackerEvent.m1.recompose(v3);
				
			var mTmp:Matrix3D = new Matrix3D();
			var v3t:Vector.<Vector3D> = new Vector.<Vector3D>(3);
			trackerEvent.m2.recompose(v3);
			v3t = m2.decompose();
			v3t[0].y = v3t[0].y * -1;
			v3t[0].x = v3t[0].x * 1;
			v3t[0].z = v3t[0].z * 1;
			v3t[1].x = v3t[1].x * -1;
			v3t[1].y = v3t[1].y * 1;
			v3t[1].z = v3t[1].z * -1;
			mTmp.recompose(v3t);
			trackerEvent.m2.prepend(mTmp);
				
			dispatchEvent(trackerEvent);
		}
	}
}