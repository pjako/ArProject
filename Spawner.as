package
{
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;

	public class Spawner
	{
		private var mesh:Mesh;
		private var spawnRate:Number;
		private var spawnTimer:Timer;
		public function Spawner(_mesh:Mesh,_spawnRate:Number)
		{
			mesh = _mesh.clone() as Mesh;
			mesh.rotationZ = -50;
			ArtMobile.currentScene.addChild(mesh);
			spawnTimer = new Timer(_spawnRate);
			spawnTimer.start();
			spawnTimer.addEventListener(TimerEvent.TIMER, function (time) {
				//trace("dagdrag");
				var delta:Number = spawnTimer.delay;
				new Enemy(ArtMobile.ghost, mesh.position, 10);
			});
		}
		public function setPos(pos:Vector3D):void {
			mesh.position = pos;
		}
		// done for marker
		public function setRot(rot:Vector3D):void {

			mesh.rotateTo(rot.x + 90,rot.y,rot.z);
		}
	}
}