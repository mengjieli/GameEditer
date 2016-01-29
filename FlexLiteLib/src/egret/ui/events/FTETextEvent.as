package egret.ui.events
{
	import flash.events.Event;

	/**
	 * 文本变化事件 
	 * @author featherJ
	 * 
	 */	
	public class FTETextEvent extends Event
	{
		/**
		 * 文本变化的时候 
		 */		
		public static const FTE_TEXT_CHANGED:String = "fteTextChanged";
		/**
		 * 将要输入一个文本，该事件可以阻止 
		 */		
		public static const FTE_TEXT_INPUTING:String = "fteTextInputing";
		public function FTETextEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type,bubbles,cancelable);
		}
		/**
		 * 修改前的起始位置 
		 */		
		public var beforeStart:int = 0;
		/**
		 * 修改前的结束位置 
		 */		
		public var beforeEnd:int = 0;
		/**
		 * 修改完的起始位置
		 */		
		public var afterStart:int = 0;
		/**
		 * 修改完的结束位置 
		 */		
		public var afterEnd:int = 0;
		/**
		 * 修改之前的局部文本 
		 */		
		public var beforeStr:String = "";
		/**
		 * 修改之后的局部文本 
		 */		
		public var afterStr:String = "";
		/**
		 * 是否需要创建历史记录 
		 */		
		public var createHistory:Boolean = false;
		/**
		 * 是否为手动输入的 
		 */		
		public var textInputed:Boolean = false;
	}
}