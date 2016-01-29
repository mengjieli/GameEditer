package main.events
{
	import flash.events.EventDispatcher;

	public class EventMgr extends EventDispatcher
	{
		public function EventMgr()
		{
		}
		
		private static var _ist:EventMgr;
		public static function get ist():EventMgr {
			if(_ist == null) {
				_ist = new EventMgr();
			}
			return _ist;
		}
	}
}