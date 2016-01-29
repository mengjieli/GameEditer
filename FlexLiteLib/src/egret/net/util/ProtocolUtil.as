package egret.net.util
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import egret.events.CloseEvent;
	import egret.net.HttpMonitor;
	import egret.net.protocol.ProtocolCheckLogin;
	import egret.net.protocol.ProtocolConfig;
	import egret.net.protocol.ProtocolLogin;
	import egret.net.protocol.ProtocolLogout;
	import egret.net.protocol.ProtocolSoftInfo;
	import egret.net.view.LoginWindow;
	import egret.ui.components.Alert;
	import egret.utils.AppVersion;
	import egret.utils.FileUtil;
	import egret.utils.ObjectUtil;
	import egret.utils.SystemInfo;
	import egret.utils.tr;
	
	/**
	 * 协议工具 
	 * @author 雷羽佳
	 * 
	 */	
	public class ProtocolUtil
	{
		/**
		 * 本次启动的软件信息 
		 */		
		private static var currentSoftInfo:Object = {};
		/**
		 * 用户的所有数据 
		 */		
		private static var locolData:Object;
		
		/**
		 * 初始化协议工具 
		 * @param nativeWindow
		 * 
		 */		
		public static function init():void
		{
			if(!ProtocolConfig.PROTOCOL_ENABLED)
			{
				return;
			}
			locolData = read("data");
			if(!locolData)
			{
				locolData = {};
				write("data",locolData);
			}
			//上次的软件信息
			var locolSoftInfo:Object = locolData["softInfo"];
			if(locolSoftInfo) //如果存在上次的信息，则先发送出去，发送成功了就清空本地的
			{
				var protocolSoftInfo:ProtocolSoftInfo = new ProtocolSoftInfo();
				protocolSoftInfo.softid = locolSoftInfo["softid"];
				protocolSoftInfo.uid = locolSoftInfo["uid"];
				protocolSoftInfo.cookie = locolSoftInfo["cookie"];
				protocolSoftInfo.systemtype = locolSoftInfo["systemtype"];
				protocolSoftInfo.systemversion = locolSoftInfo["systemversion"];
				protocolSoftInfo.softversion = locolSoftInfo["softversion"];
				protocolSoftInfo.airversion = locolSoftInfo["airversion"];
				protocolSoftInfo.projectname = locolSoftInfo["projectname"];
				protocolSoftInfo.starttime = locolSoftInfo["starttime"];
				protocolSoftInfo.closetime = locolSoftInfo["closetime"];
				protocolSoftInfo.usedtime = locolSoftInfo["usedtime"];
				protocolSoftInfo.request(
					function(data:Object):void{
						if(data && data["rel"] == 0)//成功,删除本地数据
						{
							delete locolData["softInfo"];
							write("data",locolData);
						}else
						{
							
						}
					},
					function(error:String):void{
						
					}
				);
			}
			//初始化本次的软件信息记录
			currentSoftInfo["softid"] = NativeApplication.nativeApplication.applicationID;
			currentSoftInfo["uid"] = locolData["uid"];
			currentSoftInfo["cookie"] = locolData["cookie"];
			currentSoftInfo["systemtype"] = SystemInfo.isMacOS ? "mac" : "win";
			currentSoftInfo["systemversion"] = Capabilities.os;
			currentSoftInfo["softversion"] = AppVersion.currentVersion;
			currentSoftInfo["airversion"] = Capabilities.version.split(/.*?(\d*),.*/)[1];
			currentSoftInfo["starttime"] = new Date().time/1000;
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,activateHandler);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE,deactivateHandler);
			activateHandler(null);
		}
		
		private static var usedtime:Number = 0;
		private static var timeStamp:int = 0;
		protected static function activateHandler(event:Event):void
		{
			timeStamp = getTimer();
		}
		protected static function deactivateHandler(event:Event):void
		{
			usedtime += (getTimer()-timeStamp)/1000/60;
		}
		
		public static var isLogin:Boolean = false;
		private static var _onLoginSuccess:Function;
		/**
		 * 尝试登陆，或登陆提示  
		 * @param onLogin 登陆成功 onSuccessHandler(nickName:String):void
		 * 
		 */
		public static function login(onSuccess:Function):void
		{
			if(!ProtocolConfig.PROTOCOL_ENABLED)
			{
				return;
			}
			_onLoginSuccess = onSuccess;
			//先尝试验证 ，不行再尝试登陆
			if(locolData["uid"] && locolData["cookie"] && locolData["nickname"] && config["remember"])
			{
				var protocolCheckLogin:ProtocolCheckLogin = new ProtocolCheckLogin();
				protocolCheckLogin.uid = locolData["uid"];
				protocolCheckLogin.cookie = locolData["cookie"];
				protocolCheckLogin.request(function(data:Object):void{
					if(data && data["rel"] == 1)//成功了
					{
						isLogin = true;
						_onLoginSuccess(locolData["nickname"]);
					}else
					{
						setTimeout(function():void{
						//	promptCheckError();
						},100);
					}
				},function(error:String):void{
					var monitor:HttpMonitor = new HttpMonitor("http://www.adobe.com");
					monitor.pollInterval = 15000;
					monitor.onStatus = function(available:Boolean):void{
						if(available)
						{
						//	promptLogin();
						}
					};
					monitor.start();
				});
			}else
			{
				var monitor:HttpMonitor = new HttpMonitor("http://www.adobe.com");
				monitor.pollInterval = 15000;
				monitor.onStatus = function(available:Boolean):void{
					if(available)
					{
					//	promptLogin();
					}
				};
				monitor.start();
			}
		}
		
		private static function promptCheckError():void
		{
			Alert.show(tr("LoginWindow.AlertErrorContent"),tr("LoginWindow.AlertErrorTitle"),null,function(e:CloseEvent):void{
				if(e.detail == Alert.FIRST_BUTTON)
				{
					setTimeout(promptLogin,100);
				}else if(e.detail == Alert.SECOND_BUTTON)
				{
					e.preventDefault();
					var url:URLRequest = new URLRequest(ProtocolConfig.CHANGE_PASSWORD_URL);
					navigateToURL(url,"_blank");
				}
			},tr("LoginWindow.ReLogin"),tr("LoginWindow.ChangePassword"));
		}
		
		
		public static function promptLogin():void
		{
			isLogin = false;
			var loginWindow:LoginWindow = new LoginWindow();
			loginWindow.addEventListener("login" , requestLogin);
			loginWindow.open();
		}
		
		/**检测邮箱格式*/
		private static function checkEmail(email:String):Boolean
		{
			var pattern:RegExp=/\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+(w+([.-]\w+))*/;
			var result:Boolean = pattern.test(email);
			return result;
		}
		
		private static function requestLogin(event:Event):void
		{
			var loginWindow:LoginWindow = event.currentTarget as LoginWindow;
			var name:String = loginWindow.username;
			var password:String = loginWindow.password;
			
			if(!checkEmail(name))
			{
				Alert.show(tr("LoginWindow.ErrorEmail"),tr("LoginWindow.PromptApplyTitle"));
				loginWindow.showText("");
				return;
			}
			
			var protocolLogin:ProtocolLogin = new ProtocolLogin();
			protocolLogin.email = name;
			protocolLogin.password = password;
			protocolLogin.request(
				function(data:Object):void
				{
					if(data && data["rel"] == 0)
					{
						if(data && data["activate"] == 1)
						{
							isLogin = true;
							loginWindow.closeDirect();
							locolData["uid"] = data["uid"];
							locolData["nickname"] = data["nickname"];
							locolData["cookie"] = data["cookie"];
							currentSoftInfo["uid"] = data["uid"];
							currentSoftInfo["cookie"] = data["cookie"];
							write("data",locolData);
							if(_onLoginSuccess!=null)
								_onLoginSuccess(data["nickname"]);
						}else
						{
							isLogin = false;
							loginWindow.showText(tr("LoginWindow.NoQualification"));
							Alert.show(tr("LoginWindow.PromptApplyContent"),tr("LoginWindow.PromptApplyTitle"),null,function(e:CloseEvent):void{
								if(e.detail == Alert.FIRST_BUTTON)
								{
									var url:URLRequest = new URLRequest(ProtocolConfig.APPLY_URL);
									navigateToURL(url,"_blank");
								}
							},tr("LoginWindow.Apply"));
						}
						
					}else if(data && data["rel"] == 1)
					{
						isLogin = false;
						loginWindow.showError(tr("LoginWindow.ErrorNoUser"));
					}else if(data && data["rel"] == 2)
					{
						isLogin = false;
						loginWindow.showError(tr("LoginWindow.ErrorPassword"));
					}else
					{
						isLogin = false;
						loginWindow.showError(tr("LoginWindow.ErrorLogin"));
					}
				},
				function(error:String):void
				{
					isLogin = false;
					loginWindow.showError(tr("LoginWindow.ErrorBadNet"));
				});
		}
		
		
		/**
		 * 尝试退出登陆 
		 */		
		public static function logout():void
		{
			if(!ProtocolConfig.PROTOCOL_ENABLED)
			{
				return;
			}
			
			if(isLogin)
			{
				if(locolData["uid"] && locolData["cookie"])
				{
					var protocolLogout:ProtocolLogout = new ProtocolLogout();
					protocolLogout.uid = locolData["uid"];
					protocolLogout.cookie = locolData["cookie"];
					protocolLogout.request(null,null);
				}
				delete locolData["uid"];
				delete locolData["cookie"];
				delete locolData["nickname"];
				write("data",locolData);
				isLogin = false;
			}
		}
		
		public static function addProjectName(projectName:String):void
		{
			if(!currentSoftInfo["projectname"]) currentSoftInfo["projectname"] = [];
			(currentSoftInfo["projectname"] as Array).push(projectName);
		}
		
		/**
		 * 软件里应该监听Event.EXITING事件，并组织一下，然后调用这个exit方法进行退出
		 * 退出应用程序 
		 * 
		 */		
		public static function exit():void
		{
			if(!ProtocolConfig.PROTOCOL_ENABLED)
			{
				NativeApplication.nativeApplication.exit();
				return;
			}
			
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE,activateHandler);
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE,deactivateHandler);
			usedtime += (getTimer()-timeStamp)/1000/60;
			currentSoftInfo["usedtime"] = usedtime;
			currentSoftInfo["closetime"] = new Date().time/1000;
			
			//合并当前的用户行为和本地的用户行为
			if(!locolData.softInfo) locolData.softInfo = {};
			var locolSoftInfo:Object = locolData["softInfo"];
			locolSoftInfo["softid"] = currentSoftInfo["softid"];
			locolSoftInfo["uid"] = currentSoftInfo["uid"];
			locolSoftInfo["cookie"] = currentSoftInfo["cookie"];
			locolSoftInfo["systemtype"] = currentSoftInfo["systemtype"];
			locolSoftInfo["systemversion"] = currentSoftInfo["systemversion"];
			locolSoftInfo["softversion"] = currentSoftInfo["softversion"];
			locolSoftInfo["airversion"] = currentSoftInfo["airversion"];
			var finalProjectname:Array = [];
			var projectName:Array = [];
			if(locolSoftInfo["projectname"]) projectName = String(locolSoftInfo["projectname"]).split(",");
			if(currentSoftInfo["projectname"]) projectName = projectName.concat(currentSoftInfo["projectname"]);
			for(var i:int = 0;i<projectName.length;i++)
			{
				if(finalProjectname.indexOf(projectName[i]) == -1)
				{
					finalProjectname.push(projectName[i]);
				}
			}
			locolSoftInfo["projectname"] = finalProjectname.join(",");
			locolSoftInfo["starttime"] = currentSoftInfo["starttime"];
			locolSoftInfo["closetime"] = currentSoftInfo["closetime"];
			var newUseTime:Number = 0;
			if(!isNaN(Number(locolSoftInfo["usedtime"]))) newUseTime+= Number(locolSoftInfo["usedtime"]);
			if(!isNaN(Number(currentSoftInfo["usedtime"]))) newUseTime+= Number(currentSoftInfo["usedtime"]);
			locolSoftInfo["usedtime"] = newUseTime;
			write("data",locolData); //存下来先
			
			//尝试500毫秒内进行发送。不成功就继续缓存
			var protocolSoftInfo:ProtocolSoftInfo = new ProtocolSoftInfo();
			protocolSoftInfo.softid = locolSoftInfo["softid"];
			protocolSoftInfo.uid = locolSoftInfo["uid"];
			protocolSoftInfo.cookie = locolSoftInfo["cookie"];
			protocolSoftInfo.systemtype = locolSoftInfo["systemtype"];
			protocolSoftInfo.systemversion = locolSoftInfo["systemversion"];
			protocolSoftInfo.softversion = locolSoftInfo["softversion"];
			protocolSoftInfo.airversion = locolSoftInfo["airversion"];
			protocolSoftInfo.projectname = locolSoftInfo["projectname"];
			protocolSoftInfo.starttime = locolSoftInfo["starttime"];
			protocolSoftInfo.closetime = locolSoftInfo["closetime"];
			protocolSoftInfo.usedtime = locolSoftInfo["usedtime"];
			protocolSoftInfo.request(
				function(data:Object):void{
					if(data && data["rel"] == 0)//成功,删除本地数据
					{
						delete locolData["softInfo"];
						write("data",locolData);
					}else
					{
						
					}
					exitHandler();
				},
				function(error:String):void{
					exitHandler();
				},500
			);
		}
		
		private static function exitHandler():void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		private static var _config:Object;
		
		private static function get config():Object
		{
			if(!_config)
			{
				var configFile:File = new File(configPath);
				if(configFile.exists)
				{
					var bytes:ByteArray = FileUtil.openAsByteArray(configFile.nativePath);
					try
					{
						bytes.uncompress();
						_config = bytes.readObject();
					} 
					catch(error:Error) 
					{
						_config = {};
					}
					
				}else
				{
					_config = {};
				}
			}
			return _config;
		}
		
		public static function write(key:String,value:*):void
		{
			config[key] = ObjectUtil.clone(value);
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(config);
			bytes.compress();
			FileUtil.save(configPath,bytes);
		}
		
		/**
		 * 用户登陆信息的路径
		 */
		private static function get configPath():String
		{
			var appdata:String = FileUtil.escapeUrl(SystemInfo.nativeStoragePath);
			return appdata+"Egret/user/login.amf";
		}
		
		/**
		 * 读配置 
		 * @param key
		 * @return 
		 * 
		 */		
		public static function read(key:String):*
		{
			return config[key];
		}
	}
}