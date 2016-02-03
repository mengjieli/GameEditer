package extend.ui
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import egret.core.UIComponent;
	import egret.utils.FileUtil;

	public class ImageLoader extends UIComponent
	{
		private var loader:Loader;
		private var url:String;
		
		public function ImageLoader(url:String="")
		{		
			this.url = url;
			this.addEventListener(Event.ADDED_TO_STAGE,addToStage);
		}
		
		public function set source(val:String):void {
			this.url = val;
			if(this.parent) {
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
					this.addChild(loader);
				}
				loader.loadBytes(bytes);
			}
		}
		
		private function addToStage(e:Event):void {
			if(!loader) {
				loader = new Loader();
				this.addChild(loader);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaderComplete);
			}
			if(url != "") {
				loader.loadBytes(FileUtil.openAsByteArray(url));
			}
		}
		
		private function onLoaderComplete(e:Event):void {
			this.width = (e.currentTarget as LoaderInfo).content.width;
			this.height = (e.currentTarget as LoaderInfo).content.height;
		}
	}
}