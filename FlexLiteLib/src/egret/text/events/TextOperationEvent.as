package egret.text.events
{
	import flash.events.Event;
	
	import egret.text.operations.TextOperation;

	/**
	 * 文本操作事件，还没有执行的时间可以进行取消 
	 * @author featherJ
	 * 
	 */	
	public class TextOperationEvent extends Event
	{
		/**
		 * 正要执行某个操作 ,该操作可以取消
		 */		
		public static const OPERATION_DOING:String = "operationDoing";
		/**
		 * 执行完毕某个操作 
		 */		
		public static const OPERATION_DONE:String = "operationDone";
		
		public function TextOperationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=true)
		{
			super(type,bubbles,cancelable);
		}
		/**
		 * 相关的操作 
		 */		
		public var relateOperation:TextOperation;
		
		override public function clone():Event
		{
			var event:TextOperationEvent = new TextOperationEvent(type,bubbles,cancelable);
			event.relateOperation = relateOperation;
			return event;
			
		}
	}
}