package egret.ui.core.FTEText.info
{
	/**
	 * 文本行的数据单元 
	 * @author featherJ
	 * 
	 */	
	public class TextDataInfo
	{
		private var _content:String = "";
		
		/**
		 * 首字符在全文中的索引 
		 */		
		public var firstAtomIndex:int;
		/**
		 * 对应的显示行的索引 
		 */		
		public var textLineIndex:int;

		/**
		 * 数据 
		 */
		public function get content():String
		{
			return _content ? _content : "";
		}

		/**
		 * @private
		 */
		public function set content(value:String):void
		{
			_content = value?value:"";
		}

		/**
		 * 本行文本数据的长度 
		 */		
		public function get length():int
		{
			return content.length;
		}
	}
}