package
{
	import flash.geom.Vector3D;
	public class Tracker
	{
		public var position:Vector3D;
		public var rotation:Vector3D;
		public function Tracker()
		{
			position = new Vector3D();
			rotation = new Vector3D();
		}
	}
}