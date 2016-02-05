package uistyle
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class StyleImageData extends EventDispatcher
	{
		public var name:String;
		public var width:int;
		public var height:int;
		private var _url:String = "";
		
		public function StyleImageData(name:String)
		{
			this.name = name;
		}
		
		public function set url(val:String):void {
			this._url = val;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get url():String {
			return _url;
		}
		
		public function changeURL(val:String):void {
			this._url = val;
		}
	}
}