package egret.display.image
{
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import egret.display.codec.IBitmapEncoder;
	
	
	/**
	 * PNG位图编码器
	 * @author dom
	 */
	public class PngEncoder implements IBitmapEncoder
	{
		/**
		 * 构造函数
		 * @param fastCompression 是否启用快速压缩，为true文件将会比较大。
		 */		
		public function PngEncoder(fastCompression:Boolean = false)
		{
			encodeOptions = new PNGEncoderOptions(fastCompression);
		}
		/**
		 * @inheritDoc
		 */
		public function get codecKey():String
		{
			return "png";
		}
		
		private var encodeOptions:PNGEncoderOptions;
		/**
		 * @inheritDoc
		 */
		public function encode(bitmapData:BitmapData):ByteArray
		{
			return bitmapData.encode(new Rectangle(0,0,bitmapData.width,bitmapData.height),new PNGEncoderOptions(true));
		}
	}
}