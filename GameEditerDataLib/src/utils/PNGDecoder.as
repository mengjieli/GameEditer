package utils
{
	import flash.utils.ByteArray;

	public class PNGDecoder
	{
		public function PNGDecoder()
		{
		}
		
		public static function getImageSize(data:ByteArray):Object {
			var size:Object = {"width":0,"height":0};
			for(var i:int = 0; i < data.length - 4; i++) {
				if(String.fromCharCode(data[i]) == "I" &&
					String.fromCharCode(data[i+1]) == "H" &&
					String.fromCharCode(data[i+2]) == "D" &&
					String.fromCharCode(data[i+3]) == "R") {
					data.position = i + 4;
					size.width = data.readUnsignedInt();
					size.height = data.readUnsignedInt();
				}
			}
			return size;
		}
	}
}