package
{
	import away3d.textures.*;
	import away3d.tools.utils.TextureUtils;
	
	import flash.display.BitmapData;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.media.Camera;
	import flash.media.Video;
	
	public class ARTexture
	{
		private var _materialSize : uint;
		private var _video : Video;
		private var _camera : Camera;
		private var _matrix:Matrix;
		private var _matrixBmp:Matrix;
		private var _smoothing : Boolean;
		private var _playing : Boolean;
		private var _autoUpdate : Boolean;
		
		public var bitmapTexture:BitmapTexture;
		public var bitmapData : BitmapData;
		
		public function ARTexture( cameraWidth : uint = 320, cameraHeight : uint = 240, trackWidth : uint = 320, trackHeight : uint = 240, bmpTextureSize : uint = 128, camera : Camera = null, smoothing : Boolean = true )
		{
			bitmapData = new BitmapData(320, 240, false, 0);
			bitmapTexture = new BitmapTexture(new BitmapData(bmpTextureSize, bmpTextureSize, false, 0));
			// Use default camera if none supplied
			_camera = camera || Camera.getCamera();
			_camera.setQuality(0, 80);
			_camera.setMode(cameraWidth, cameraHeight, 20, true);
			_video = new Video( cameraWidth, cameraHeight );
			
			_matrix = new Matrix();
			_matrix.scale(  trackWidth / cameraWidth, trackHeight / cameraHeight );
			
			_matrixBmp = new Matrix();
			_matrixBmp.scale(  bmpTextureSize / cameraWidth, bmpTextureSize / cameraHeight );
			
			_video.attachCamera( _camera );
			
			_smoothing = smoothing;
		}

		public function get camera():Camera
		{
			return _camera;
		}
		
		public function get smoothing():Boolean
		{
			return _smoothing;
		}
		
		public function set smoothing(value:Boolean):void
		{
			_smoothing = value;
		}
		
		
		public function stop():void
		{
			_video.attachCamera( null );
		}
		
		public function update() : void
		{
			// draw track texture
			bitmapData.lock();
			bitmapData.draw(_video, _matrix, null, null, bitmapData.rect, _smoothing);
			bitmapData.unlock();
			
			// draw video background texture
			bitmapTexture.bitmapData.lock();
			bitmapTexture.bitmapData.draw(_video, _matrixBmp, null, null, bitmapTexture.bitmapData.rect, _smoothing);
			bitmapTexture.bitmapData.unlock();
			bitmapTexture.invalidateContent();
		}
		
		
		/**
		 * Flips the image from the webcam horizontally
		 */
		public function flipHorizontal():void
		{
			_matrixBmp.a=-1*_matrixBmp.a;
			_matrixBmp.a > 0 ? _matrixBmp.tx = _video.x - _video.width * Math.abs( _matrixBmp.a ) : _matrixBmp.tx = _video.width * Math.abs( _matrixBmp.a ) +  _video.x;
		}
		
		/**
		 * Flips the image from the webcam vertically
		 */
		public function flipVertical():void
		{
			_matrixBmp.d=-1*_matrixBmp.d;
			_matrixBmp.d > 0 ? _matrixBmp.ty = _video.y - _video.height * Math.abs( _matrixBmp.d ) : _matrixBmp.ty = _video.height * Math.abs( _matrixBmp.d ) +  _video.y;
		}
		
		
		/**
		 * Clean up used resources.
		*/
		public function dispose() : void
		{
			super.dispose();
			stop();
			bitmapData.dispose();
			_video.attachCamera( null );
			_camera = null;
			_video = null;
			_matrix = null;
		}
	}
}
