package view.component.data
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import main.data.ToolData;
	
	import utils.PNGDecoder;
	
	import view.events.ComponentAttributeEvent;

	public class ImageData extends ComponentData
	{
		private var _url:String = "";
		
		public function ImageData()
		{
			super("Image");
			sizeSet = false;
		}
		
		public function get url():String {
			return _url;
		}
		
		public function set url(val:String):void {
			_url = val;
			
			if(val != "") {
				var file:File = new File(ToolData.getInstance().project.getResURL(val));
				var stream:FileStream = new FileStream();
				stream.open(file,FileMode.READ);
				var bytes:ByteArray = new ByteArray();
				stream.position = 0;
				stream.readBytes(bytes,0,stream.bytesAvailable);
				stream.close();
				
				var size:Object = PNGDecoder.getImageSize(bytes);
				this.width = size.width;
				this.height = size.height;
			}
			
			this.dispatchEvent(new ComponentAttributeEvent("url",val));
		}
		
		override public function encode():Object {
			var json:Object = super.encode();
			json.url = url;
			return json;
		}
		
		override public function parser(json:Object):void {
			super.parser(json);
			this.url = json.url;
		}
	}
}