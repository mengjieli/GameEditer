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
		
		public function Event(type:String,bubbles:Boolean=false)
		{
			this.$type = type;
			$bubbles = bubbles;
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
		
		public static const COMPLETE:String = "complete";
		
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