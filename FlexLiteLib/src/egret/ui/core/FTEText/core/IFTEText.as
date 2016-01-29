package egret.ui.core.FTEText.core
{
	import flash.events.IEventDispatcher;

	/**
	 * 文本改变 
	 */	
	[Event(name="textChanged", type="egret.ui.events.FTETextEvent")]
	/**
	 * 文本选择内容改变 
	 */	
	[Event(name="textSelectionChanged", type="egret.ui.events.FTETextSelectionEvent")]
	
	
	public interface IFTEText extends IEventDispatcher
	{
		/**
		 * 替换文本 
		 * @param beginIndex 替换起点
		 * @param endIndex 替换结束
		 * @param newText 要替换的字符串
		 * @param format 是否进行格式化
		 * @param createHistory 是否创建历史记录
		 * @return 替换是否成功
		 * 
		 */		
		function replaceText(beginIndex:int, endIndex:int, newText:String,format:Boolean = true,createHistory:Boolean = true):Boolean;
	}
}