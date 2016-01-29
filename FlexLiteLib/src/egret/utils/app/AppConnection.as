package egret.utils.app
{
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.net.LocalConnection;
	import flash.utils.setTimeout;
	
	import egret.utils.FileUtil;
	import egret.utils.SystemInfo;
	
	/**
	 * 应用程序通讯工具
	 */
	public class AppConnection extends EventDispatcher
	{
		public function AppConnection()
		{
		}
		
		/**
		 * 事件派发器
		 */
		public static function get eventDispatcher():EventDispatcher
		{
			return instance;
		}
		
		private static var instance:AppConnection;
		
		/**
		 * 独有本地连接
		 */
		private var localConnection:LocalConnection;
		
		/**
		 * 初始化
		 */
		public static function initialize():void
		{
			if(instance)
				return;
			instance = new AppConnection();
			instance.initialize();
		}
		
		private function initialize():void
		{
			localConnection = new LocalConnection();
			localConnection.allowDomain("*");
			localConnection.client = this;
			localConnection.addEventListener(StatusEvent.STATUS , onStatus);
			try
			{
				localConnection.connect("_"+NativeApplication.nativeApplication.applicationID);
			} 
			catch(error:Error) {};
			this.addEventListener(AppConnectionEvent.RECEIVE , onReceive);
		}
		
		/**
		 * 默认响应命令
		 */
		protected function onReceive(event:AppConnectionEvent):void
		{
			if(event.messageName == "exit")
			{
				NativeApplication.nativeApplication.exit();
			}
		}
		
		protected function onStatus(event:StatusEvent):void
		{
			var result:Boolean;
			if(event.level == "error")
				result = false;
			else
				result = true;
			var messageName:String = sendingMessage.messageName;
			var appID:String = sendingMessage.appID;
			var args:Array = sendingMessage.args;

			var appEvent:AppConnectionEvent = new AppConnectionEvent(AppConnectionEvent.SEND,messageName,args);
			appEvent.appID = appID;
			appEvent.result = result;
			eventDispatcher.dispatchEvent(appEvent);
			
			sendingMessage = null;
			
			if(messages.length>0)
			{
				sendingMessage = messages.shift();
				localConnection.send("_"+sendingMessage.appID , "handle"  , sendingMessage.messageName , sendingMessage.args);
			}
		}
		
		/**
		 * 应用程序管理器的路径
		 * <br/>mac下为/Library/Egret/EgretAppManager.app/Contents/Resources/
		 * <br/>windows下为%system%/Program Files/Common Files/Egret/EgretAppManager/
		 */
		public static function get appManagerPath():String
		{
			if(SystemInfo.isMacOS)
				return "/Library/Egret/EgretAppManager.app/Contents/Resources/";
			else
			{
				var userPath:String = FileUtil.escapePath(File.userDirectory.nativePath);
				var systemPath:String = userPath.substring(0 , userPath.indexOf("/"));
				return systemPath + "/Program Files/Common Files/Egret/EgretAppManager/";
			}
		}
		
		/**
		 * 启动应用程序管理器
		 */
		private function openAppManager():Boolean
		{
			var path:String = "";
			if(SystemInfo.isMacOS)
				path = new File(appManagerPath).parent.parent.nativePath+"/";
			else
				path = appManagerPath+"EgretAppManager.exe";

			var file:File = new File(path);
			try
			{
				file.openWithDefaultApplication();
			} 
			catch(error:Error) 
			{
				return false;
			}
			return true;
		}
		
		/**
		 * 发送消息到AppManager
		 */
		public static function sendToManager(messageName:String , ...args):void
		{
			if(!instance.openAppManager())
				return;
			
			var _send:Function = function():void
			{
				var arr:Array = [];
				arr.push("EgretAppManager");
				arr.push(messageName);
				arr = arr.concat(args);
				AppConnection.send.apply(null , arr);
			}
			
			var tryTimes:int = 0;
			var onSend:Function = function(event:AppConnectionEvent):void
			{
				if(event.appID!="EgretAppManager" || event.messageName!=messageName)
					return;
				tryTimes++;
				if(!event.result&& tryTimes<20)
				{
					setTimeout(_send,100);
				}
				else
				{
					eventDispatcher.removeEventListener(AppConnectionEvent.SEND , onSend);
				}
			}
			eventDispatcher.addEventListener(AppConnectionEvent.SEND , onSend);
			setTimeout(_send,100);
		}
		
		/**
		 * 队列中的消息
		 */
		private var messages:Array = [];
		
		/**
		 * 正在发送的消息
		 */
		private var sendingMessage:Object;
		
		
		/**
		 * 发送消息到其他的应用程序， 请确保其他的应用程序AppConnection初始化完毕。其他程序通过监听
		 * AppConnectionEvent.RECEIVE事件来接收消息
		 * @param appID 要调用的应用程序 ID（在应用程序描述符文件中定义）
		 * @param messageName 消息名称
		 * @param args 其他参数
		 */
		public static function send(appID:String  ,messageName:String , ...args):void
		{
			if(!instance)
				initialize();
			
			var message:Object = {"appID":appID,"messageName":messageName,"args":args};
			if(instance.sendingMessage)
			{
				instance.messages.push(message);
			}
			else
			{
				instance.sendingMessage = message;
				instance.localConnection.send("_"+appID , "handle"  , messageName , args);
			}
		}
		
		public function handle(messageName:String , args:Array):void
		{
			var event:AppConnectionEvent = new AppConnectionEvent(AppConnectionEvent.RECEIVE , messageName , args);
			eventDispatcher.dispatchEvent(event);
		}
	}
}