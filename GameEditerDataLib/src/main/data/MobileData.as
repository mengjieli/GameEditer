package main.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class MobileData extends EventDispatcher
	{
		private var _connected:Boolean = false;
		public var name:String;
		public var id:Number;
		
		public function MobileData()
		{
		}
		
		public function get connected():Boolean {
			return this._connected;
		}
		
		public function set connected(val:Boolean):void {
			this._connected = val;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}