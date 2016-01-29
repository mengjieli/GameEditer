package egret.ui.core.FTEText.info
{
	import flash.text.engine.TextLine;

	/**
	 * 文本行的显示单元
	 * @author featherJ
	 * 
	 */	
	public class TextLineInfo
	{
		/**
		 * 显示的文本行 
		 */		
		public var content:TextLine;
		/**
		 * 首字符在全文中的索引 
		 */		
		public var firstAtomIndex:int;
		/**
		 * 对应的数据行的索引 
		 */		
		public var textDataIndex:int;
		/**
		 * 本行文本数据的长度 
		 */		
		public function get length():int
		{
			return content == null ? 0 : content.atomCount;
		}
	}
}