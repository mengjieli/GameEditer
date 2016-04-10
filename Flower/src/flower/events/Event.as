package flower.events
{
	public class Event
	{
		private var $type:String;
		private var $bubbles:Boolean;
		private var $cycle:Boolean = false;
		public var $target:* = null;
		public var $currentTarget:* = null;
		public var data:*;
		private var _isPropagationStopped:Boolean = false;
		
		public function Event(type:String,bubbles:Boolean=false)
		{
			this.$type = type;
			$bubbles = bubbles;
		}
		
		/**
		 * 停止向上传递
		 */
		public function stopPropagation():void {
			_isPropagationStopped = true;
		}
		
		/**
		 * 事件是否已经停止向上传递
		 */
		public function get isPropagationStopped():Boolean {
			return _isPropagationStopped;
		}
		
		public function get type():String {
			return $type;
		}
		
		/**
		 * 冒泡阶段是否向上传递
		 */
		public function get bubbles():Boolean {
			return $bubbles;
		}
		
		public function get target():* {
			return $target;
		}
		
		public function get currentTarget():* {
			return $currentTarget;
		}
		
		public static const READY:String = "ready";
		public static const COMPLETE:String = "complete";
		public static const ADDED:String = "added";
		public static const REMOVED:String = "removed";
		public static const ADDED_TO_STAGE:String = "added_to_stage";
		public static const REMOVED_FROM_STAGE:String = "removed_from_stage";
		public static const CONNECT:String = "connect";
		public static const CLOSE:String = "close";
		public static const ERROR:String = "error";
		
		private static var _eventPool:Vector.<Event> = new Vector.<Event>();
		
		public static function create(type:String,data:*=null):Event {
			var e:Event;
			if(!_eventPool.length) {
				e = new Event(type);
			} else {
				e = _eventPool.pop();
				e.$cycle = false;
			}
			e.$type = type;
			e.$bubbles = false;
			e.data = data;
			return e;
		}
		
		public static function release(e:Event):void {
			if(e.$cycle) {
				return;
			}
			e.$cycle = true;
			_eventPool.push(e);
		}
	}
}