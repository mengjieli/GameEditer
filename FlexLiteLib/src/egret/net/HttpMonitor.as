package egret.net
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * http网络监控器 
	 * @author featherJ
	 * 
	 */	
	public class HttpMonitor
	{
		
		private var _pollInterval:int = 1000;
		private var _available:Boolean = false;
		
		public function get available():Boolean
		{
			return _available;
		}
		/**
		 * onStatus(available:Boolean):void 
		 */
		public var onStatus:Function;
		
		private var urlStream:URLStream;
		private var _url:String = "";
		public function HttpMonitor(url:String)
		{
			_url = url;
		}
		
		public function get pollInterval():int
		{
			return _pollInterval;
		}
		
		public function set pollInterval(value:int):void
		{
			_pollInterval = value;
		}
		
		private var timeOutId:int = -1;
		
		public function start():void
		{
			var urlRequest:URLRequest = new URLRequest(_url);
			urlRequest.method = "HEAD";
			urlStream = new URLStream();
			urlStream.addEventListener(ProgressEvent.PROGRESS,onProgressHandlerandler);
			urlStream.addEventListener(Event.COMPLETE,onCompleteHandler);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
			urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityErrorHandler);
			urlStream.load(urlRequest);
			timeOutId = setTimeout(function():void{
				try
				{
					urlStream.close();
				} 
				catch(error:Error) 
				{}
				urlStream.removeEventListener(ProgressEvent.PROGRESS,onProgressHandlerandler);
				urlStream.removeEventListener(Event.COMPLETE,onCompleteHandler);
				urlStream.removeEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
				urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityErrorHandler);
				if(timeOutId != -1) clearTimeout(timeOutId);
				if(onStatus != null)
				{
					onStatus(false)
				}
			},_pollInterval)
		}
		
		protected function onSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			urlStream.removeEventListener(ProgressEvent.PROGRESS,onProgressHandlerandler);
			urlStream.removeEventListener(Event.COMPLETE,onCompleteHandler);
			urlStream.removeEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
			urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityErrorHandler);
			if(timeOutId != -1) clearTimeout(timeOutId);
			if(onStatus != null)
			{
				onStatus(false)
			}
		}
		
		protected function onIOErrorHandler(event:IOErrorEvent):void
		{
			urlStream.removeEventListener(ProgressEvent.PROGRESS,onProgressHandlerandler);
			urlStream.removeEventListener(Event.COMPLETE,onCompleteHandler);
			urlStream.removeEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
			urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityErrorHandler);
			if(timeOutId != -1) clearTimeout(timeOutId);
			if(onStatus != null)
			{
				onStatus(false)
			}
		}
		
		protected function onCompleteHandler(event:Event):void
		{
			urlStream.removeEventListener(ProgressEvent.PROGRESS,onProgressHandlerandler);
			urlStream.removeEventListener(Event.COMPLETE,onCompleteHandler);
			urlStream.removeEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
			urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityErrorHandler);
			if(timeOutId != -1) clearTimeout(timeOutId);
			if(onStatus != null)
			{
				onStatus(true)
			}
		}
		
		protected function onProgressHandlerandler(event:ProgressEvent):void
		{
			urlStream.removeEventListener(ProgressEvent.PROGRESS,onProgressHandlerandler);
			urlStream.removeEventListener(Event.COMPLETE,onCompleteHandler);
			urlStream.removeEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
			urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityErrorHandler);
			if(timeOutId != -1) clearTimeout(timeOutId);
			if(event.bytesLoaded > 0)
			{
				if(onStatus != null)
				{
					onStatus(true)
				}
			}
		}
	}
}