package
{
	
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.utils.setTimeout;
	
	import egret.components.Theme;
	import egret.core.GlobalStyles;
	import egret.core.IAssetAdapter;
	import egret.core.Injector;
	import egret.events.CloseEvent;
	import egret.managers.SystemManager;
	import egret.ui.components.Alert;
	import egret.ui.components.Application;
	import egret.ui.components.RetinaAssetAdapter;
	import egret.ui.skins.themes.EgretTheme;
	import egret.utils.SystemInfo;
	import egret.utils.app.AppUpdater;
	import egret.utils.language.AppLanguage;
	
	import extend.ui.ExtendGlobal;
	
	import main.controllers.MainViewController;
	import main.controllers.MenuController;
	import main.controllers.SystemController;
	import main.data.Config;
	import main.data.ToolData;
	import main.events.EventMgr;
	import main.events.ToolEvent;
	import main.model.ModelMgr;
	import main.model.errorTipModel.TipModel;
	import main.model.loginModel.LoginModel;
	import main.net.Server;
	import main.panels.netWaitPanel.NetWaitingPanel;
	
	import net.gimite.websocket.WebSocketEvent;
	
	public class EditerMain extends SystemManager
	{
		private var application:Application;
		
		public function EditerMain()
		{
			ExtendGlobal.stage = stage;
			
			AppLanguage.init(AppLanguage.LANGUAGE_CONFIG);
			AppUpdater.start();
			if(SystemInfo.isMacOS)
				GlobalStyles.fontFamily = "Lucida Grande";
			else
				GlobalStyles.fontFamily = "SimSun";
			GlobalStyles.size = 12;
			GlobalStyles.textColor = 0xfefefe;
			
			Injector.mapClass(Theme,EgretTheme);
			Injector.mapClass(IAssetAdapter,RetinaAssetAdapter);
			
			Config.width = stage.stageWidth;
			Config.height = stage.stageHeight;
			
//			this.stage.frameRate = 60;
			
			application=new Application();
			application.title="";
			this.addElement(application);
			
			
			//启动控制器
			new SystemController().start(application);
			new MenuController().start(application);
			new MainViewController().start(application);
			
			this.addElement(new TipModel());
			
			(new ModelLoad("models/")).addEventListener(Event.COMPLETE,onLoadParser);
		}
		
		private function onLoadParser(e:Event):void {
			(new ParserLoad("parsers/")).addEventListener(Event.COMPLETE,onLoadPanel);
		}
		
		private function onLoadPanel(e:Event):void {
			(new PanelLoad("panels/")).addEventListener(Event.COMPLETE,start);
		}
		
		private function start(e:Event):void {
			var server:Server = new Server();
			ToolData.getInstance().server = server;
			var init:Boolean = false;
			flash.utils.setTimeout(function():void{
				server.connect(ToolData.getInstance().getConfigValue("ip","server"),ToolData.getInstance().getConfigValue("port","server"));
				NetWaitingPanel.show("链接服务器中 ... " + server.ip + ":" + server.port);
				server.addEventListener(Event.CONNECT,function(e:Event):void {
					if(!init) {
						(new ModelMgr()).init();
						EventMgr.ist.dispatchEvent(new ToolEvent(ToolEvent.START));
					} else {
						init = true;
					}
					new LoginModel();
				});
				server.addEventListener(Event.CLOSE,function(e:Event):void {
					ToolData.getInstance().mobile.connected = false;
					Alert.show("无法连上服务器 " + server.ip + ":" + server.port + "\n是否重新连接?","错误",null,function(e:CloseEvent):void{
						if(e.detail == Alert.FIRST_BUTTON) {
							server.connect(ToolData.getInstance().getConfigValue("ip","server"),ToolData.getInstance().getConfigValue("port","server"));
							NetWaitingPanel.show("链接服务器中 ... " + server.ip + ":" + server.port);
						} else {
//							NativeApplication.nativeApplication.exit();
						}
					},"确定","取消");
				});
				
				server.addEventListener(WebSocketEvent.ERROR,function(e:WebSocketEvent):void {
					Alert.show("与服务器的连接出错 " + server.ip + ":" + server.port + "\n" + e.message,"错误",null,function():void{
						NativeApplication.nativeApplication.exit();
					},"确定");
					//					server.connect(ToolData.getInstance().getConfigValue("ip","server"),ToolData.getInstance().getConfigValue("port","server"));
					//					NetWaitingPanel.show("链接服务器中 ... " + server.ip + ":" + server.port);
				});
			},0);
			
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,function(e:NativeDragEvent):void{
				
				var obj:Object = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT);
				
				var file:File = obj[0];
				var files:Array = file.getDirectoryListing();
				trace(files.length);
				//				NativeDragManager.acceptDragDrop(new FocusUIComponent());
				//				trace(e);
			});
		}
	}
}