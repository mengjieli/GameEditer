package egret.ui.events
{
	import flash.events.Event;
	
	import egret.ui.components.IDocumentData;
	
	
	/**
	 * 文档选中项改变事件
	 * @author dom
	 */
	public class DocumentEvent extends Event
	{
		/**
		 * 选中的文档发生改变
		 */		
		public static const SELECTED_DOC_CHANGE:String = "selectedDocChange";
		/**
		 * 文档获得焦点 
		 */		
		public static const DOC_FOCUS_IN:String = "docFocusIn";
		/**
		 * 构造函数
		 */		
		public function DocumentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		/**
		 * 当前选中的文档数据
		 */		
		public var newData:IDocumentData;
		/**
		 * 上次选中的文档数据
		 */		
		public var oldData:IDocumentData;
		
		override public function clone():Event
		{
			var evt:DocumentEvent = new DocumentEvent(type,bubbles,cancelable);
			evt.newData = newData;
			evt.oldData = oldData;
			return evt;
		}
	}
}