package
{
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	
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

	public class Bullet
	{
		public var mesh : Mesh;
		private var material:ColorMaterial;
		public var collision:AWPRigidBody;

		public function Bullet( bulletMesh:Mesh/*, pos:Vector3D, dir:Vector3D*/)
		{
			var scene:Scene3D = ArtMobile.currentScene;
			var physicsWorld:AWPDynamicsWorld = ArtMobile.physicsWorld;
			// Set Material
			material = new ColorMaterial(0x00CC00);
			// Set Mesh
			mesh = new Mesh(bulletMesh.geometry, bulletMesh.material);
			mesh.scale(3.0);
			var handShape:AWPBoxShape = new AWPBoxShape(20, 20, 10);
			collision = new AWPRigidBody(handShape, mesh, 0);
			
			
			collision.friction = 1.0;
			collision.linearDamping = 0.1;
			collision.restitution = 2.0;
			collision.mass = 0.1;
			//physicsWorld.addRigidBody(collision);
			//mesh.mouseEnabled = true;
			//mesh.addEventListener( MouseEvent3D.MOUSE_OVER, onObjectMouseOver );
			collision.addEventListener(AWPEvent.COLLISION_ADDED, onCollision);
			
			
			//material.lightPicker = lightPicker;
			//scene.addChild(mesh);
		}
		public function stop():void {
			var scene:Scene3D = ArtMobile.currentScene;
			var physicsWorld:AWPDynamicsWorld = ArtMobile.physicsWorld;
			scene.removeChild(mesh);
			physicsWorld.removeRigidBody(collision);
			collision.totalForce.x = 0;
			collision.totalForce.y = 0;
			collision.totalForce.z = 0;
		}
		public function reset(pos:Vector3D, dir:Vector3D):void {
			var scene:Scene3D = ArtMobile.currentScene;
			var physicsWorld:AWPDynamicsWorld = ArtMobile.physicsWorld;
			collision.position = pos;
			mesh.position = pos;
			scene.addChild(mesh);
			
			physicsWorld.addRigidBody(collision);
			collision.applyCentralImpulse(dir);
			active = true;
		}
		private var active:Boolean = false;
		public function update():void {
			if(active == false) return;
			//trace(collision.position.length);
			if(collision.position.length > 3000) {
				stop();
				ArtMobile.usableBullets.push(this);
				active = false;
			}
		}
		
		public function onCollision(e:AWPEvent):void {
			
			//trace('Collide' + e.collisionObject);
		}
	}
}