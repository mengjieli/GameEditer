package extend.ui
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import egret.components.Group;
	import egret.core.UIComponent;
	import egret.utils.FileUtil;

	public class ImageLoader extends Group
	{
		private var loader:Loader;
		private var loaderWidth:int;
		private var loaderHeight:int;
		private var _url:String = "";
		private var ui:UIComponent;
		private var _showMaxWidth:int = 10000;
		private var _showMaxHeight:int = 10000;
		
		public function ImageLoader(url:String="")
		{
			this._url = url;
			this.addEventListener(Event.ADDED_TO_STAGE,addToStage);
			this.addElement(ui = new UIComponent());
		}
		
		public function get url():String {
			return this._url;
		}
		
		public function set source(val:String):void {
			this._url = val;
			if(val == "") {
				if(loader) loader.visible = false;
			} else if(this.parent) {
				var file:File = new File(url);
				var stream:FileStream = new FileStream();
				stream.open(file,FileMode.READ);
				var bytes:ByteArray = new ByteArray();
				stream.position = 0;
				stream.readBytes(bytes,0,stream.bytesAvailable);
				stream.close();
				if(!loader) {
					loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaderComplete);
					ui.addChild(loader);
				}
				loader.loadBytes(bytes);
				loader.visible = true;
			}
		}
		
		private function addToStage(e:Event):void {
			if(!loader) {
				loader = new Loader();
				ui.addChild(loader);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaderComplete);
			}
			if(url != "") {
				loader.loadBytes(FileUtil.openAsByteArray(url));
			}
		}
		
		private function onLoaderComplete(e:Event):void {
			loaderWidth = loader.width;
			loaderHeight = loader.height;
			checkSize();
			this.width = loaderWidth*loader.scaleX;
			this.height = loaderHeight*loader.scaleX;
		}
		
		public function set showMaxWidth(value:Number):void {
			this._showMaxWidth = value;
			checkSize();
		}
		
		public function get showMaxWidth():Number {
			return this._showMaxWidth;
		}
		
		public function set showMaxHeight(value:Number):void {
			this._showMaxHeight = value;
			checkSize();
		}
		
		public function get showMaxHeight():Number {
			return this._showMaxHeight;
		}
		
		private function checkSize():void {
			if(loader) {
				var mw:int = this._showMaxWidth;
				var mh:int = this._showMaxHeight;
				var w:int = loaderWidth;
				var h:int = loaderHeight;
				var sx:Number = 1;
				var sy:Number = 1;
				if(w > mw) sx = mw/w;
				if(h > mh) sy = mh/h;
				loader.scaleX = sx<sy?sx:sy;
				loader.scaleY = sx<sy?sx:sy;
			}
		}
	}
}