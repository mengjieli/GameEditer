package flower.net
{
	import flower.debug.DebugInfo;
	import flower.events.Event;
	import flower.events.EventDispatcher;
	import flower.events.IOErrorEvent;
	import flower.res.Res;
	import flower.res.ResItem;
	import flower.res.ResType;
	import flower.texture.Texture2D;
	import flower.texture.TextureManager;
	import flower.utils.CallLater;

	public class URLLoader extends EventDispatcher
	{
		private var _res:ResItem;
		private var _isLoading:Boolean = false;
		private var _data:*;
		private var _linkLoader:URLLoader;
		private var _links:Array;
		private var _type:String;
		
		/**
		 * 不建议直接调用，使用 Res.load 更合适
		 * @url 路径
		 * @type 类型,Bitmap Text Json
		 */
		public function URLLoader(res:*)
		{
			var val:* = res;
			if(res is String) {
				res = new ResItem();
				if(type != "") {
					res.type = type;
				} else {
					var end:String = val.split(".")[1];
					if(end == "png" || end == "jpg") {
						res.type = ResType.TEXTURE;
					} else if(end == "json") {
						res.type = ResType.JSON;
					} else {
						res.type = ResType.TEXT;
					}
				}
				res.local = Res.local;
				res.localURL = Res.localURL;
				res.serverURL = Res.serverURL;
				res.url = val;
			}
			_res = res;
			_type = res.type;
		}
		
		public function get url():String {
			return _res?_res.url:"";
		}
		
		public function get loadURL():String {
			return _res?_res.loadURL:"";
		}
		
		public function get type():String {
			return _res?_res.type:"";
		}
		
		private function addLink(loader:URLLoader):void {
			if(!_links) {
				_links = [];
			}
			_links.push(loader);
		}
		
		public function load():void {
			if(_isLoading || !_res || this._data) {
				return;
			}
			_isLoading = true;
			for(var i:int = 0; i < list.length; i++) {
				if(list[i].loadURL == this.loadURL) {
					_linkLoader = list[i];
					break;
				}
			}
			if(_linkLoader) {
				_linkLoader.addLink(this);
				return;
			}
			URLLoader.list.push(this);
			if(this.type == ResType.TEXTURE) {
				this.loadTexture();
			} else {
				this.loadText();
			}
		}
		
		//////////////////////////////////////////////加载纹理//////////////////////////////////////////////
		private function loadTexture():void {
			var texture:Texture2D = TextureManager.getInstance().getTextureByNativeURL(_res.loadURL);
			if(texture) {
				texture.$addCount();
				_data = texture;
				new CallLater(this.loadComplete,this);
			} else {
				var func:Function = func = System.URLLoader.loadTexture.func;;
				func(this._res.loadURL,this.loadTextureComplete,this.loadError,this);
			}
		}
		
		private function loadTextureComplete(nativeTexture:*,width:int,height:int):void {
			var texture:Texture2D = TextureManager.getInstance().createTexture(nativeTexture,this.url,this._res.loadURL,width,height);
			_data = texture;
			texture.$addCount();
			new CallLater(this.loadComplete,this);
		}
		
		private function setTextureByLink(texture:Texture2D):void {
			texture.$addCount();
			_data = texture;
			this.loadComplete();
		}
		
		//////////////////////////////////////////////加载文本//////////////////////////////////////////////
		private function loadText():void {
			var func:Function = func = System.URLLoader.loadText.func;
			func(this._res.loadURL,this.loadTextComplete,this.loadError,this);
		}
		
		private function loadTextComplete(content:String):void {
			if(_type == ResType.TEXT) {
				_data = content;
			} else if(_type == ResType.JSON) {
				_data = System.JSON_parser(content);
			}
			new CallLater(this.loadComplete,this);
		}
		
		private function setTextByLink(content:String):void {
			if(_type == ResType.TEXT) {
				_data = content;
			} else if(_type == ResType.JSON) {
				_data = System.JSON_parser(content);
			}
			this.loadComplete();
		}
		
		private function setJsonByLink(content:Object):void {
			_data = content;
			this.loadComplete();
		}
		//////////////////////////////////////////////加载完毕//////////////////////////////////////////////
		private function loadComplete():void {
			if(_links) {
				for(var i:int = 0; i < _links.length; i++) {
					if(_type == ResType.TEXTURE) {
						_links[i].setTextureByLink(_data);
					} else if(_type == ResType.TEXT) {
						_links[i].setTextByLink(_data);
					} else if(_type == ResType.JSON) {
						_links[i].setJsonByLink(_data);
					}
				}
			}
			_links = null;
			_isLoading = false;
			if(!_res || !_data) {
				this.dispose();
				return;
			}
			this.dispatchWidth(Event.COMPLETE,this._data);
			this.dispose();
		}
		
		private function loadError():void {
			if(this.hasListener(IOErrorEvent.ERROR)) {
				this.dispatch(new IOErrorEvent(IOErrorEvent.ERROR,"[加载纹理失败] " + this._res.localURL));
			} else {
				DebugInfo.debug("[加载纹理失败] " + this._res.localURL,DebugInfo.ERROR);
			}
		}
		
		override public function dispose():void {
			if(_data && _type == ResType.TEXTURE) {
				_data.$delCount();
				_data = null;
			}
			_res = null;
			_data = null;
			super.dispose();
			for(var i:int = 0; i < list.length; i++) {
				if(list[i] == this) {
					list.splice(i,1);
					break;
				}
			}
		}
		
		private static var list:Array = [];
		
		/**
		 * 清除所有的 URLLoader
		 */
		public static function clear():void {
			while(list.length) {
				var loader:URLLoader = list.pop();
				loader.dispose();
			}
		}
	}
}