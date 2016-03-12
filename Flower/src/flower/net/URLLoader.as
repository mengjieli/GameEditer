package flower.net
{
	import flower.events.Event;
	import flower.events.EventDispatcher;
	import flower.events.IOErrorEvent;
	import flower.res.ResType;
	import flower.utils.CallLater;

	public class URLLoader extends EventDispatcher
	{
		private var _url:String;
		private var _type:String;
		private var _isLoading:Boolean = false;
		private var _data:*;
		
		/**
		 * @url 路径
		 * @type 类型,Bitmap Text Json
		 */
		public function URLLoader(url:String,type:String)
		{
			this._url = url;
			this._type = type;
		}
		
		public function get url():String {
			return _url;
		}
		
		public function get type():String {
			return _type;
		}
		
		public function get data():* {
			return _data;
		}
		
		public function load():void {
			if(_isLoading) {
				return;
			}
			_isLoading = true;
			var func:Function;
			var sync:Boolean;
			if(this._type == ResType.BITMAP) {
			} else {
				func = System.URLLoader.loadText.func;
				sync = System.URLLoader.loadText.sync;
			}
			var _this:URLLoader = this;
			func(this._url,function(d:*):void{
				if(_this.type == ResType.JSON) {
					d = flower.utils.JSON.parser(d);
				}
				_this._data = d;
				if(sync) {
					new CallLater(_this.dispatchWidth,this,[Event.COMPLETE,d]);
				} else {
					_this.dispatchWidth(Event.COMPLETE,d);
				}
			},
			function():void{
				if(sync) {
					new CallLater(_this.dispatch,this,[new IOErrorEvent(IOErrorEvent.ERROR)]);
				} else {
					_this.dispatch(new IOErrorEvent(IOErrorEvent.ERROR));
				}
			});			
		}
		
	}
}