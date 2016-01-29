package egret.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import egret.utils.FileUtil;
	import egret.utils.StringUtil;
	import egret.utils.SystemInfo;
	
	/**
	 * 系统环境变量读取工具
	 * @author dom
	 */
	public class Environment
	{
		public function Environment()
		{
		}
		
		/**
		 * 当前语言环境的编码方式,用于读取从命令行输出的字符串,默认为GBK。
		 */		
		public static var charset:String = "GBK";
		/**
		 * 获取环境变量
		 * @param key 环境变量的键，例如：EGRET_PATH
		 * @param compFunc 获取完成的回调函数,示例：compFunc(value:String)
		 */			
		public static function getValue(key:String,compFunc:Function):void
		{
			var env:Environment = new Environment();
			env.getValue(key,compFunc);
		}
		
		/**
		 * 本机进程实例
		 */		
		private var nativeProcess:NativeProcess;
		/**
		 * 本机进程启动信息对象
		 */		
		private var startupInfo:NativeProcessStartupInfo;
		
		/**
		 * 当前的回调函数
		 */		
		private var currentCompFunc:Function;
		/**
		 * 获取环境变量
		 * @param key 环境变量的键，例如：EGRET_PATH
		 * @param compFunc 获取完成的回调函数,示例：compFunc(value:String)
		 */		
		public function getValue(key:String,compFunc:Function):void
		{
			currentCompFunc = compFunc;
			if(SystemInfo.isMacOS)
			{
				var userDir:String = File.userDirectory.nativePath;
				if(FileUtil.exists(userDir+"/.bash_profile"))
				{
					var text:String = FileUtil.openAsString(userDir+"/.bash_profile");
					var lines:Array = text.split("\r\n").join("\n").split("\r").join("\n").split("\n");
					for(var i:int=lines.length-1;i>=0;i--)
					{
						if(lines[i].charAt(0)=="#")
						{
							lines.splice(i,1);
						}
					}
					text = lines.join("\n");
					var index:int = text.indexOf(key+"=");
					if(index!=-1)
					{
						text = text.substring(index+11);
						index = text.indexOf("\n");
						if(index!=-1)
							text = text.substring(0,index);
						text = StringUtil.trim(text);
						text = PathFormat.clearQuotes(text);
						compFunc(text);
						return;
					}
				}
				compFunc("");
			}
			else
			{
				if(!nativeProcess)
				{
					nativeProcess = new NativeProcess();
					nativeProcess.addEventListener(NativeProcessExitEvent.EXIT,onCompileComp);
					nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onStandardOutput);
					nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,onStandardOutput);
					nativeProcess.addEventListener(Event.STANDARD_OUTPUT_CLOSE,onOutputClose);
					nativeProcess.addEventListener(Event.STANDARD_ERROR_CLOSE,onOutputClose);
					startupInfo = new NativeProcessStartupInfo();
					var userPath:String = File.userDirectory.nativePath;
					var disk:String = userPath.charAt(0);
					startupInfo.executable = File.applicationDirectory.resolvePath(disk+":/Windows/System32/cmd.exe");
					startupInfo.workingDirectory = File.applicationDirectory;
				}
				startupInfo.arguments = getArgs(key);
				nativeProcess.start(startupInfo);
			}
		}
		/**
		 * 获取编译参数
		 */		
		private function getArgs(key:String):Vector.<String>
		{
			var args:Vector.<String> = new Vector.<String>;
			args.push("/c echo %"+key+"%");
			return args;
		}
		
		/**
		 * 命令行正常输出信息
		 */		
		private var cmdOutputStr:String = "";
		/**
		 * 命令行错误输出信息
		 */		
		private var cmdErrorStr:String = "";
		/**
		 * 记录命令行输出的信息
		 */		
		private function onStandardOutput(event:ProgressEvent):void
		{
			if(event.type==ProgressEvent.STANDARD_OUTPUT_DATA)
			{
				var data:IDataInput = nativeProcess.standardOutput;
				cmdOutputStr += data.readMultiByte(data.bytesAvailable,charset);
			}
			else
			{
				var error:IDataInput = nativeProcess.standardError;
				cmdErrorStr += error.readMultiByte(error.bytesAvailable,charset);
			}
		}		
		
		/**
		 * 命令行输出信息关闭,格式化字符串
		 */		
		private function onOutputClose(event:Event):void
		{
			if(event.type==Event.STANDARD_OUTPUT_CLOSE)
			{
				cmdOutputStr = StringUtil.trim(cmdOutputStr);
				cmdOutputStr = cmdOutputStr.split("\r\n\r\n").join("\n");
				cmdOutputStr = cmdOutputStr.split("\r\n").join("\n");
			}
			else
			{
				cmdErrorStr = StringUtil.trim(cmdErrorStr);
				cmdErrorStr = cmdErrorStr.split("\r\n\r\n").join("\n");
				cmdErrorStr = cmdErrorStr.split("\r\n").join("\n");
			}
		}
		
		/**
		 * swf文件编译完成
		 */		
		private function onCompileComp(event:NativeProcessExitEvent):void
		{
			if(cmdOutputStr.charAt(0)=="\"")
				cmdOutputStr = cmdOutputStr.substring(1);
			if(cmdOutputStr.charAt(cmdOutputStr.length-1)=="\"")
				cmdOutputStr = cmdOutputStr.substring(0,cmdOutputStr.length-1);
			var value:String = StringUtil.trim(cmdOutputStr);
			if(value.indexOf("%")!=-1)
				value = "";
			currentCompFunc(value);
			cmdOutputStr = "";
			cmdErrorStr = "";
			currentCompFunc = null;
		}
	}
}