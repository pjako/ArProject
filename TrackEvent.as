package
{
	import flash.events.Event;
	import flash.geom.*;
	
	public class TrackEvent extends Event
	{
		//the event type ON_LOCATION is used when a contact is added to our list
		public static const ON_MARKER_FRAME:String = "onMarkerFrame";
		
		/*customMessage is the property will contain the message for each event type dispatched */
		public var customMessage:String = "";
		public var m1:Matrix3D;
		public var m2:Matrix3D;
		public var m3:Matrix3D;
		
		public function TrackEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			m1 = new Matrix3D();
			m2 = new Matrix3D();
			m3 = new Matrix3D();
			//we call the super class Event
			super(type, bubbles, cancelable);
		}
	}
}