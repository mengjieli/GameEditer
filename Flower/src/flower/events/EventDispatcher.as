package flower.events
{
	public class EventDispatcher
	{
		private var _events:Object;
		
		public function EventDispatcher()
		{
			_events = {};
		}
		
		public function once(type:String,listener:Function,thisObject:*):void {
			this._addListener(type,listener,thisObject,true);
		}
		
		public function addListener(type:String,listener:Function,thisObject:*):void {
			this._addListener(type,listener,thisObject,false);
		}
		
		private function _addListener(type:String, listener:Function, thisObject:*,once:Boolean):void {
			if(!_events) {
				return;
			}
			if(!_events[type]) {
				_events[type] = [];
			}
			var list:Array = _events[type];
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].listener == listener && list[i].thisObject == thisObject && list[i].del == false) {
					return;
				}
			}
			list.push({
				"listener":listener,
				"thisObject":thisObject,
				"once":once,
				"del":false
			});
		}
		
		public function removeListener(type:String,listener:Function,thisObject:*):void {
			if(!_events) {
				return;
			}
			var list:Array = _events[type];
			if(!list) {
				return;
			}
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].listener == listener && list[i].thisObject == thisObject && list[i].del == false) {
					list[i].listener = null;
					list[i].thisObject = null;
					list[i].del = true;
					break;
				}
			}
		}
		
		public function removeAllListener():void {
			_events = {};
		}
		
		public function hasListener(type:String):Boolean {
			if(!_events) {
				return false;
			}
			var list:Array = _events[type];
			if(!list) {
				return false;
			}
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].del == false) {
					return true;
				}
			}
			return false;
		}
		
		public function dispatch(event:Event):void {
			if(!_events) {
				return;
			}
			var list:Array = _events[event.type];
			if(!list) {
				return;
			}
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].del == false) {
					var listener:Function = list[i].listener;
					var thisObj:* = list[i].thisObject;
					if(event.$target == null) {
						event.$target = this;
					}
					event.$currentTarget = this;
					if(list[i].once) {
						list[i].listener = null;
						list[i].thisObject = null;
						list[i].del = true;
					}
					listener.call(thisObj,event);
				}
			}
			for(i = 0; i < list.length; i++) {
				if(list[i].del == true) {
					list.splice(i,1);
					i--;
				}
			}
		}
		
		public function dispatchWidth(type:String,data:*=null):void {
			if(!_events) {
				return;
			}
			var e:Event = Event.create(type,data);
			this.dispatch(e);
		}
		
		public function dispose():void {
			_events = null;
		}
	}
}