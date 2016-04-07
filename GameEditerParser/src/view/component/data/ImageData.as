package view.component.data
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import egret.utils.FileUtil;
	
	import main.data.ToolData;
	
	import utils.FileHelp;
	import utils.PNGDecoder;
	
	import view.events.ComponentAttributeEvent;

	public class ImageData extends ComponentData
	{
		private var _url:String = "";
		
		public function ImageData()
		{
			super("Image");
			sizeSet = true;
			this.setWidth(0);
			this.setHeight(0);
		}
		
		public function get url():String {
			return _url;
		}
		
		public function set url(val:String):void {
			if(_url == val) {
				return;
			}
			_url = val;
			
			if(val != "") {
				var file:File = new File(ToolData.getInstance().project.getResURL(val));
				var stream:FileStream = new FileStream();
				stream.open(file,FileMode.READ);
				var bytes:ByteArray = new ByteArray();
				stream.position = 0;
				stream.readBytes(bytes,0,stream.bytesAvailable);
				stream.close();
				
				var size:Object;
				if(FileHelp.getURLEnd(_url) == "png") {
					size = PNGDecoder.getPNGSize(bytes);
				} else if(FileHelp.getURLEnd(_url) == "jpg") {
					size = PNGDecoder.getJPGSize(bytes);
				}
				this.setWidth(size.width);
				this.setHeight(size.height);
				sizeSet = false;
			} else {
				sizeSet = true;
			}
			
			this.dispatchEvent(new ComponentAttributeEvent("url",val));
		}
		
		public function setWidth(val:int):void {
			super.width = val;
		}
		
		public function setHeight(val:int):void {
			super.height = val;
		}
		
		override public function set width(val:int):void {
			if(scaleX == val/this.width) {
				return;
			}
			this.scaleX = val/this.width;
		}
		
		override public function set height(val:int):void {
			if(scaleY == val/this.height) {
				return;
			}
			this.scaleY = val/this.height;
		}
		
		override public function encode():Object {
			var json:Object = super.encode();
			json.url = url;
			return json;
		}
		
		override public function parser(json:Object):void {
			super.parser(json);
			this.url = json.url;
			if(url == "" && json.width) {
				this.setWidth(json.width);
			}
			if(url == "" && json.height) {
				this.setHeight(json.height);
			}
		}
	}
}