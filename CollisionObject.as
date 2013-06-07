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
	import awayphysics.events.AWPEvent;

	public class CollisionObject extends Sprite implements IRenderAble
	{
		public var mesh : Mesh;
		private var material:ColorMaterial;
		
		public var collision:AWPRigidBody;
		
		public function CollisionObject()
		{
			var scene:Scene3D = ArtMobile.currentScene;
			var physicsWorld:AWPDynamicsWorld = ArtMobile.physicsWorld;
			// Set Material
			material = new ColorMaterial(0x00CC00);
			// Set Mesh
			mesh = new Mesh(new CubeGeometry(10.0, 10.0, 10.0), material);
			var handShape:AWPBoxShape = new AWPBoxShape(4, 4, 4);
			
			collision = new AWPRigidBody(handShape, mesh, 4.1);
			
			physicsWorld.addRigidBody(collision);
			mesh.mouseEnabled = true;
			collision.addEventListener(AWPEvent.COLLISION_ADDED, onCollision);
			//mesh.addEventListener( MouseEvent3D.MOUSE_OVER, onObjectMouseOver );


			//material.lightPicker = lightPicker;
			scene.addChild(mesh);
		}
		public function onCollision(e:AWPEvent):void {
			if(ArtMobile.bullets.indexOf(e.collisionObject) != -1) {
			}
			trace('Collide');
		}
		public function setLight(lightPicker:StaticLightPicker):void {
			material.lightPicker = lightPicker;
			//trace('set light!');
		}
		private function onObjectMouseOver( event:MouseEvent3D ):void {
			//trace('hit! :o');
		}
	}
}