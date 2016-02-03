package extend.ui
{
	import egret.core.IToolTip;

	public class ImageLoaderToolTip extends ImageLoader implements IToolTip
	{
		private var data:String;
		
		public function ImageLoaderToolTip()
		{
		}
		
		
		/**
		 * 工具提示的数据对象，通常为一个字符串。
		 */		
		public function get toolTipData():Object {
			return this.data;
		}
		
		public function set toolTipData(value:Object):void {
			this.data = value as String;
			this.source = this.data;
		}
	}
}