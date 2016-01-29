package egret.text.events
{
	import flash.events.Event;
	
	
	/**
	 * 文本行内容更新事件
	 * @author dom
	 */
	public class TextFlowEvent extends Event
	{
		/**
		 * 文本行内容更新事件，外部容器应监听此事件触发重新布局。
		 */		
		public static const TEXT_CHANGED:String = "textChangd";
		/**
		 * 文本行数据内容更新，外部通过监听此事件改变渲染风格。 
		 */		
		public static const TEXT_CHANGING:String = "textChanging";
		/**
		 * 设置text的时候会抛出此事件
		 */		
		public static const TEXT_INITED:String = "textInited";
		/**
		 * 设置text的且更新文本内容之前时候会抛出此事件
		 */		
		public static const TEXT_INITING:String = "textIniting";
		/**
		 * 文本行对象销毁事件，外部容器应监听此事件从而从显示列表移除关联的TextLine对象。
		 */		
		public static const TEXT_LINE_RELEASE:String = "textLineRelease";
		
		public function TextFlowEvent(type:String,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		/**
		 * 需要销毁的TextLine对象列表
		 */		
		public var textLines:Array = [];
		
		/**
		 * 内容更新部分的起始索引。 
		 */		
		public var startIndex:int = -1;
		/**
		 * 内容更新部分的结束索引。 
		 */		
		public var endIndex:int = -1;
		/**
		 * 内容更新部分的新文本。 
		 */		
		public var newText:String = "";
		
		override public function clone():Event
		{
			var evt:TextFlowEvent = new TextFlowEvent(type,bubbles,cancelable);
			evt.textLines = this.textLines;
			evt.startIndex = this.startIndex;
			evt.endIndex = this.endIndex;
			evt.newText = this.newText;
			return evt;
		}
	}
}