package egret.utils.app
{
	import flash.desktop.NativeApplication;
	import flash.utils.setTimeout;
	
	import egret.utils.app.bridge.AppBridge;
	
	/**
	 * 更新器，不同于AutoUpdater的下载整个AIR程序，这个是进行增量更新。
	 */
	public class AppUpdater
	{
		public function AppUpdater()
		{
		}
		
		private static var instance:AppUpdater;
		
		/**
		 * 启动更新器,检查更新
		 * @param neepTips 是否弹窗提示已经是最新版本。如果为true则忽略是否自动更新的设置进行强制检查更新。
		 */
		public static function start(needTips:Boolean = false):void
		{
			if(!instance)
			{
				instance = new AppUpdater();
				AppConnection.initialize();
				AppConnection.eventDispatcher.addEventListener(AppConnectionEvent.RECEIVE , instance.onReceive);
			}
			if(AppBridge.hasLoad)
				AppBridge.checkUpdate(NativeApplication.nativeApplication.applicationID,needTips);
			else
			{
				AppBridge.load(function(result:Boolean):void{
					AppBridge.checkUpdate(NativeApplication.nativeApplication.applicationID,needTips);
				});
			}
		}
		
		/**
		 * 接收到消息
		 */
		protected function onReceive(event:AppConnectionEvent):void
		{
			if(event.messageName == "reUpdate")
			{
				setTimeout(start , 2000 , event.args.shift());
			}
		}
	}
}