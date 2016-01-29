package egret.net.protocol
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * 协议发送器 
	 * @author 雷羽佳
	 * 
	 */
	public class ProtocolNetBase
	{
		protected var action:String = "";
		public function ProtocolNetBase()
		{
		}
		
		private var _onRespond:Function;
		private var _onError:Function;
		private var urlLoader:URLLoader;
		private var timeoutId:int = -1;
		/**
		 * 发送请求
		 * @param onRespond 得到回应，onRespondHandler(data:Object):void
		 * @param onError 请求失败，onErrorHandler(error:String):void
		 * @param timeOut 超时时常，单位毫秒，默认为-1
		 */		
		public function request(onRespond:Function,onError:Function,timeOut:int = -1):void
		{
			_onRespond = onRespond;
			_onError = onError;
			var urlRequest:URLRequest = new URLRequest(ProtocolConfig.PROTOCOL_URL);
			try
			{
				var variables:URLVariables = getVariables()
				urlRequest.data = variables;
				if(ProtocolConfig.PROTOCOL_LOG)
				{
					var showStr:String = "----------------Send "+action+"----------------\n";
					for(var key:String in variables) 
					{
						if(key != "cookie")
							showStr += key+":"+getDecrypt(variables[key])+"\n";
						else
							showStr += key+":"+variables[key]+"\n";
					}
					trace(showStr);
				}
			} 
			catch(error:Error) 
			{
			}
			urlRequest.method = URLRequestMethod.POST;
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE,requestCompleteHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,requestErrorHandler);
			urlLoader.load(urlRequest);
			if(timeOut != -1)
			{
				timeoutId = setTimeout(requestTimeOut,timeOut);
			}
		}
		
		private function requestCompleteHandler(e:Event):void
		{
			var str:String = e.target.data;
			var arr:Array = str.split("<&>");
			if(ProtocolConfig.PROTOCOL_LOG)
			{
				var showStr:String = "---------------Recive "+action+"---------------\n";
			}
			if(arr.length > 0)
			{
				var data:Object = {};
				for(var i:int = 0;i<arr.length;i++)
				{
					data[String(arr[i]).split(/(.*?)=(.*)/)[1]] = String(arr[i]).split(/(.*?)=(.*)/)[2];
					if(ProtocolConfig.PROTOCOL_LOG)
					{
						showStr += String(arr[i]).split(/(.*?)=(.*)/)[1]+":"+String(arr[i]).split(/(.*?)=(.*)/)[2]+"\n";
					}
				}
			}
			if(ProtocolConfig.PROTOCOL_LOG)
			{
				trace(showStr);
			}
			if(_onRespond!=null)
				_onRespond(data);
			if(timeoutId != -1)
			{
				clearTimeout(timeoutId);
			}
			
		}
		
		private function requestErrorHandler(e:IOErrorEvent):void
		{
			if(_onError!=null)_onError(e.errorID+" "+e.text);
			if(timeoutId != -1)
			{
				clearTimeout(timeoutId);
			}
		}
		
		private function requestTimeOut():void
		{
			urlLoader.removeEventListener(Event.COMPLETE,requestCompleteHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,requestErrorHandler);
			if(_onError!=null)
				_onError("timeout");
		}
		
		/**
		 * 子类重写，获得协议包数据 
		 * @return 
		 * 
		 */		
		protected function getVariables():URLVariables
		{
			return null;
		}
		
		/**
		 * 得到密文 
		 * @param value
		 * @return 
		 */		
		protected function getEncrypt(value:String):String
		{
			if(!value) return "";
			return  "";
		}
		/**
		 * 得到明文 
		 * @param value
		 * @return 
		 */		
		protected function getDecrypt(value:String):String
		{
			if(!value) return "";
			return "";
		}
	}
}