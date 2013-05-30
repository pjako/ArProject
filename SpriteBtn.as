package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.*;
	
	import away3d.containers.*;
	
	
	
	public class SpriteBtn extends Sprite {
		private var url:String = "";
		private var btnText:String = "";
		private var textFormat:TextFormat;
		public var textField:TextField;
		private var image:Bitmap;
		private var done:Function;
		
		[Embed(source="arial.ttf", fontFamily="Arial",fontWeight="bold", fontStyle="normal", advancedAntiAliasing="true",  embedAsCFF="false")]
		private var MyFont:Class;
		
		public function SpriteBtn(_url:String, _text:String, _textSize:int) {
			Font.registerFont(MyFont);
			url = _url;
			textFormat = new TextFormat();
			textFormat.color = 0xFFFFFF;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.font = "MyFont"
			textFormat.size = _textSize;
			
			textField = new TextField();
			textField.embedFonts = true;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.text =  _text;
			textField.defaultTextFormat = textFormat;
			loadBackgroundImage();
		}
		
		private function loadBackgroundImage():void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, done);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			var request:URLRequest = new URLRequest(url);
			loader.load(request);
			this.addChild(loader);
		}
		
		private function completeHandler(event:Event):void {
			var loader:Loader = Loader(event.target.loader);
			image = Bitmap(loader.content);
			//addChild(image);
			this.addChild(textField);
			trace("Loaded: "+event.toString());
			
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("Unable to load image: " + url);
		}
		
		public function resize(x:int, y:int, w:int, h:int):void
		{
			if(image == null) return;
			
			this.x = x;
			this.y = y;
			this.width = w;
			this.height = h;
			this.scaleX = 1;
			this.scaleY = 1;
			
			image.width = w;
			image.height = h;
			
			this.graphics.clear();
			this.graphics.beginBitmapFill(image.bitmapData,null,false,false);
			this.graphics.drawRect(0, 0, w, h);
			this.graphics.endFill();
			
			textField.setTextFormat(textFormat);
			textField.background = false;
			textField.selectable = false;
			
			textField.multiline = true;
			textField.wordWrap = true;
			textField.width = w * 0.8;
			textField.height = h *0.8;
			textField.x = w * 0.1;
			textField.y = h * 0.1;
		}
		
		public function setText(text:String):void
		{
			textField.text =  text;
		}
		
	}
}