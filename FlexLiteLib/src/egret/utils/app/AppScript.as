package egret.utils.app
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import egret.utils.AppVersion;
	import egret.utils.FileUtil;
	import egret.utils.SystemInfo;

	/**
	 * 指示脚本程序已经准备完毕
	 */
	[Event(name="init", type="flash.events.Event")]

	/**
	 * 命令运行完成
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * 进度事件
	 */	
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	/**
	 * 错误事件
	 */
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	
	/**
	 * 脚本执行器
	 */
	public class AppScript extends EventDispatcher
	{
		/**
		 * 申请脚本管理器权限文件夹路径，不设置则使用默认 SystemInfo.nativeStoragePath+"/Egret/script/app/"
		 */
		public static var scriptFolderPath:String;
		
		public function AppScript()
		{
			super();
			uid = NativeApplication.nativeApplication.applicationID;
			uid = uid + "_" +int(Math.random()*10000).toString();
		}
		
		/**
		 * 生成脚本运行环境
		 */
		public static function createRuntime():void
		{
			var file:File;
			if(scriptFolderPath)
				file = new File(scriptFolderPath);
			else
				file = new File(SystemInfo.nativeStoragePath+"/Egret/script/app/");
			var scriptFile:File = File.applicationDirectory.resolvePath("bin/script/");
			if(file.exists)
			{
				var globalVersion:String = getScriptVersion(file.nativePath);
				var selfVersion:String = getScriptVersion(scriptFile.nativePath);
				if(globalVersion)
				{
					if(!selfVersion || selfVersion==globalVersion || AppVersion.compareVersion(selfVersion,globalVersion))
						return;
				}
			}
			if(scriptFile.exists)
			{
				FileUtil.copyTo(scriptFile.nativePath,file.nativePath,true);
				var runtimeFile:File;
				var targetRuntimeFile:File;
				if(SystemInfo.isMacOS)
				{
					runtimeFile = new File(File.applicationDirectory.nativePath).parent.resolvePath("Frameworks");
					targetRuntimeFile = file.resolvePath("EgretScriptManager.app/Contents/Frameworks");
				}
				else
				{
					runtimeFile = File.applicationDirectory.resolvePath("Adobe AIR");
					targetRuntimeFile = file.resolvePath("EgretScriptManager/Adobe AIR");
				}
				FileUtil.copyTo(runtimeFile.nativePath,targetRuntimeFile.nativePath);
			}
		}
		
		/**
		 * 用于标识当前脚本运行的唯一标示
		 */
		private var uid:String;
		
		private var isRun:Boolean;
		private var nativeProcess:NativeProcess;
		private var cmd:String;
		
		/**
		 * 运行脚本，注意在上次脚本运行停止或者完成之前重复调用此方法无效
		 */
		public function run(cmd:String):void
		{
			if(isRun)
				return;
			var scriptFolder:File = getScriptFolder();
			if(!scriptFolder)
				return;
			this.isRun = true;
			this.isWaiting = true;
			this.cmd = cmd;
			
			AppConnection.initialize();
			AppConnection.eventDispatcher.addEventListener(AppConnectionEvent.RECEIVE , onReceive);
			
			nativeProcess = new NativeProcess();
			var nativeProcessInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var args:Vector.<String> = new Vector.<String>();
			if(SystemInfo.isMacOS)
			{
				nativeProcessInfo.executable = new File("/usr/bin/osascript");
				args.push(scriptFolder.resolvePath("elevate.scpt").nativePath);
				args.push(scriptFolder.nativePath+"/EgretScriptManager.app/Contents/MacOS/EgretScriptManager");
				args.push(NativeApplication.nativeApplication.applicationID);
			}
			else
			{
				if(Capabilities.os.indexOf("XP")<0)
				{
					nativeProcessInfo.executable = scriptFolder.resolvePath("elevate.exe");
					args.push(scriptFolder.nativePath+"\\EgretScriptManager\\EgretScriptManager.exe");
					args.push(NativeApplication.nativeApplication.applicationID);
				}
				else
				{
					nativeProcessInfo.executable = scriptFolder.resolvePath("EgretScriptManager/EgretScriptManager.exe");
					args.push(NativeApplication.nativeApplication.applicationID);
				}
			}
			nativeProcessInfo.workingDirectory = scriptFolder;
			nativeProcessInfo.arguments = args;
			nativeProcess.start(nativeProcessInfo);
		}
		
		/**
		 * 获取申请脚本管理器权限文件夹
		 */
		private function getScriptFolder():File
		{
			if(scriptFolderPath && FileUtil.exists(scriptFolderPath))
				return new File(scriptFolderPath);
			
			var file:File = new File(SystemInfo.nativeStoragePath+"/Egret/script/app/");
			if(file.exists)
			{
				return file;
			}
			return null;
		}
		
		/**
		 * 获取应用程序版本号
		 */
		private static function getScriptVersion(scriptFolder:String):String
		{
			scriptFolder = FileUtil.escapePath(scriptFolder);
			if(SystemInfo.isMacOS)
				scriptFolder+="EgretScriptManager.app/Contents/Resources/";
			else
				scriptFolder+="EgretScriptManager/";
			
			var str:String = FileUtil.openAsString(scriptFolder+"META-INF/AIR/application.xml");
			if(!str)
				return null;
			try
			{
				var appXml:XML = XML(str);
				var ns:Namespace = appXml.namespace();  
				return appXml.ns::versionNumber[0].toString();  
			} 
			catch(error:Error) 
			{
			}
			return null;	
		}
		
		/**
		 * 恢复脚本运行
		 */
		public function restore():void
		{
			if(isRun)
				AppConnection.send("EgretScriptManager","restoreScript",uid);
		}
		
		/**
		 * 停止脚本的运行
		 */
		public function stop():void
		{
			isRun = false;
			isWaiting = false;
			AppConnection.eventDispatcher.removeEventListener(AppConnectionEvent.RECEIVE , onReceive);
			AppConnection.eventDispatcher.removeEventListener(AppConnectionEvent.SEND , onSend);
			AppConnection.send("EgretScriptManager","stopScript",uid);
			
			var tempScript:File = new File(scriptPath);
			if(tempScript.exists)
			{
				FileUtil.moveTo(scriptPath , tempScript.parent.resolvePath("command.txt").nativePath , true);
			}
		}
		
		private function onSend(event:AppConnectionEvent):void
		{
			if(!event.result && event.args[0]==uid)
			{
				stop();
			}
		}
		
		/**
		 * 是否正在等待脚本启动
		 */
		private var isWaiting:Boolean;
		protected function onReceive(event:AppConnectionEvent):void
		{
			if(event.messageName == "ScriptManagerReady")
			{
				if(isWaiting && isRun)
				{
					isWaiting = false;
					AppConnection.eventDispatcher.addEventListener(AppConnectionEvent.SEND , onSend);
					this.dispatchEvent(new Event(Event.INIT));
					runProxy();
				}
				return;
			}
			
			var eventUid:String = event.args[0];
			if(eventUid != uid)
			{
				return;
			}
			else if(event.messageName == "scriptProgress")
			{
				var bytesLoaded:Number = event.args[1];
				var bytesTotal:Number = event.args[2];
				this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,false,false,bytesLoaded,bytesTotal));
			}
			else if(event.messageName == "scriptComplete")
			{
				if(this.dispatchEvent(new Event(Event.COMPLETE,false,true)))
				{
					stop();
				}
			}
			else if(event.messageName == "scriptError")
			{
				var text:String = event.args[1];
				var errorID:int = event.args[2];
				var errorEvent:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR,false,true,text,errorID);
				if(this.dispatchEvent(errorEvent))
				{
					stop();
				}
			}
		}
		
		/**
		 * 缓存脚本的路径
		 */
		private function get scriptPath():String
		{
			return FileUtil.escapeUrl(SystemInfo.nativeStoragePath)+"Egret/script/"+uid+".txt";
		}
		
		/**
		 * 代理方式运行脚本
		 */
		private function runProxy():void
		{
			FileUtil.save(scriptPath , cmd);
			var proxyCmd:String = "bash \""+scriptPath+"\"";
			AppConnection.send("EgretScriptManager","runScript",uid,proxyCmd);
		}
		
		/******************************************************************************
		 * *****************************************************************************
		 * 以下为创建脚本命令的快捷方法
		 * *****************************************************************************
		 ******************************************************************************/
		
		/**
		 *  复制文件
		 */
		public static function copyFile(sourcePath:String , targetPath:String):String
		{
			var cmd:String = "";
			cmd+="copy ";
			cmd+="\""+sourcePath+"\" ";
			cmd+="\""+targetPath+"\"";
			cmd = wrap(cmd);
			return cmd;
		}
		
		/**
		 * 移动文件
		 */
		public static function moveFile(sourcePath:String , targetPath:String):String
		{
			var cmd:String = "";
			cmd+="move ";
			cmd+="\""+sourcePath+"\" ";
			cmd+="\""+targetPath+"\"";
			cmd = wrap(cmd);
			return cmd;
		}
		
		/**
		 * 删除文件
		 */
		public static function deleteFile(deletePath:String):String
		{
			var cmd:String = "";
			cmd+="del ";
			cmd+="\""+deletePath+"\"";
			cmd = wrap(cmd);
			return cmd;
		}
		
		/**
		 * 打开应用程序
		 */
		public static function open(sourcePath:String,args:Array=null):String
		{
			var cmd:String = "";
			cmd+="run ";
			cmd+="\""+sourcePath+"\"";
			if(args && args.length>0)
			{
				for (var i:int = 0; i < args.length; i++) 
				{
					cmd+=" \""+args[i]+"\"";
				}
			}
			cmd = wrap(cmd);
			return cmd;
		}
		
		/**
		 * 换行
		 */
		private static function wrap(cmd:String):String
		{
			if(SystemInfo.isMacOS)
				cmd+="\n";
			else
				cmd+="\r\n";
			return cmd;
		}
	}
}