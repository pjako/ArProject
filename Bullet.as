package
{
	import flash.display.Sprite;
	
	import away3d.containers.Scene3D;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	public class Bullet
	{
		public var mesh : Mesh;
		private var material:ColorMaterial;
		public var collision:AWPRigidBody;

		public function Bullet( bulletMesh:Mesh, pos:Vector3D, dir:Vector3D)
		{
			var scene:Scene3D = ArtMobile.currentScene;
			var physicsWorld:AWPDynamicsWorld = ArtMobile.physicsWorld;
			// Set Material
			material = new ColorMaterial(0x00CC00);
			// Set Mesh
			mesh = new Mesh(new CubeGeometry(10.0, 10.0, 10.0), material);
			var handShape:AWPBoxShape = new AWPBoxShape(20, 20, 10);
			collision = new AWPRigidBody(handShape, mesh, 0);
			physicsWorld.addRigidBody(collision);
			mesh.mouseEnabled = true;
			mesh.addEventListener( MouseEvent3D.MOUSE_OVER, onObjectMouseOver );
			
			
			//material.lightPicker = lightPicker;
			scene.addChild(mesh);
		}
	}
}