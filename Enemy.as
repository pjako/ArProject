package
{
	import flash.geom.Vector3D;
	
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	
	import awayphysics.dynamics.AWPRigidBody;

	public class Enemy
	{
		private var mesh : Mesh;
		private var collision:AWPRigidBody;
		private var movementSpeed:Number;
		public function Enemy(_mesh:Mesh, spawnPoint:Vector3D, _movementSpeed:Number)
		{
			trace('new enemy');
			ArtMobile.enemies.push(this);
			mesh = new Mesh(_mesh.geometry, _mesh.material);
			mesh.scale(4);
			mesh.position = spawnPoint.clone();
			ArtMobile.currentScene.addChild(mesh);
			//mesh.translate(mesh.position, 3);
		}
		public function update(delta:Number):void {
			mesh.translate(mesh.position, -3);
			if(mesh.position.length < 1.5) {
				ArtMobile.enemies.splice(ArtMobile.enemies.indexOf(this),1);
				ArtMobile.currentScene.removeChild(mesh);
				
			}
			
			//trace('dööörb');
		}
	}
}