package
{
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import away3d.cameras.Camera3D;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.events.MouseEvent3D;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.LineSegment;
	
	import awayphysics.math.AWPTransform;
	
	
	/**********************************************************
	 * Every (touch) Input goes into here
	 * ********************************************************/

	public class Controller
	{
		private var camera:Camera3D;
		private var usedBullets:Array;
		private var bullets:Array;
		
		public function Controller() {
			camera = ArtMobile.currentCamera;
			ArtMobile.view.addEventListener(MouseEvent.CLICK, onMouseDown );
			//trace('init controller');
			//camera.addEventListener(MouseEvent3D.MOUSE_UP, onObjectMouseDown );
		}
		
		private function onMouseDown( event:MouseEvent ):void {
			//trace('pew pew!' + ArtMobile.view.mouseX + " " + ArtMobile.view.mouseY);
			var relX:Number = ((ArtMobile.view.mouseX / ArtMobile.view.width) - 0.5) * 2;
			var relY:Number = ((ArtMobile.view.mouseY / ArtMobile.view.height) - 0.5) * 2;
			var origin:Vector3D = camera.unproject(relX,relY,0.0); //camera.unproject(0.0,0.0,0.0);
			var direction:Vector3D = camera.unproject(relX,relY,1.0); 
			var dir:Vector3D = direction.clone();
			direction.subtract(origin);
			direction.normalize();
			var impulse:Vector3D = direction;//camera.forwardVector.clone();
			impulse.scaleBy(1.0);

			var bullet:Bullet = ArtMobile.usableBullets.pop() as Bullet;
			bullet.reset( origin, impulse);
			return;
			/*
			//var b2:CollisionObject = new CollisionObject();
			//b2.mesh.position = camera.unproject(relX,relY,1.0)
			
			var bullet:CollisionObject = new CollisionObject();
			bullet.setLight(ArtMobile.lightPicker);
			var origin:Vector3D = camera.unproject(relX,relY,0.0); //camera.unproject(0.0,0.0,0.0);
			var direction:Vector3D = camera.unproject(relX,relY,1.0); 
			var dir:Vector3D = direction.clone();
			direction.subtract(origin);
			direction.normalize();
			var impulse:Vector3D = direction;//camera.forwardVector.clone();
			impulse.scaleBy(2.0);
			//impulse.negate();
			//bullet.mesh.transform.pointAt(origin,dir);
			//bullet.collision.
			bullet.collision.position = origin;
			bullet.collision.friction = 1.0;
			bullet.collision.linearDamping = 0.1;
			bullet.collision.restitution = 2.0;
			bullet.collision.mass = 0.1;
			bullet.collision.applyCentralImpulse(impulse);
			
			var line:LineSegment = new LineSegment(camera.unproject(relX,relY,0.0),camera.unproject(relX,relY,100.0));
			//var lineSet:SegmentSet = new SegmentSet();
			//lineSet.addSegment(line);
			var lines:SegmentSet = new SegmentSet();
			lines.addSegment(line);
			ArtMobile.currentScene.addChild(lines);
			

			
			//event.stageX;
			//event.stageY;
			return;
			//camera.position = new Vector3D(100,100,100);
			//camera.lookAt(new Vector3D(0,0,0), new Vector3D(0,1,0));
			//var bullet:CollisionObject = new CollisionObject();
			//bullet.setLight(ArtMobile.lightPicker);
			
			//bullet.collision.position = camera.position;
			return;
			var impulse:Vector3D = camera.forwardVector.clone();
			impulse.scaleBy(3.0);
			impulse.negate();
			bullet.collision.applyCentralForce(impulse);
			*/
/*
			camera.forwardVector
			trace( event.sceneNormal + "  " + event.scenePosition );
			var bullet:Mesh = new Mesh(new CubeGeometry(60, 60, 2));
			bullet.transform.position = event.scenePosition;*/
		}
		private function onObjectMouseDownCamera( event:MouseEvent3D ):void {
			trace('Camera');
		}
	}
}