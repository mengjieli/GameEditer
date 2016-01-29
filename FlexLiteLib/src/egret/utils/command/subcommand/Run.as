package egret.utils.command.subcommand
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import egret.utils.FileUtil;
	import egret.utils.PathFormat;
	import egret.utils.SystemInfo;
	import egret.utils.command.CommandEvent;
	import egret.utils.command.IAsynCommand;
	
	/**
	 * 参数+w 表示命令行的工作目录，+charset表示命令行输出使用的编码格式
	 * @author xzper
	 */
	public class Run extends EventDispatcher implements IAsynCommand
	{
		/**
		 * 全局的输出编码
		 */
		public static var globalCharset:String = "utf-8";
		
		/**
		 * 工作目录
		 */
		protected var workingDirectory:File;
		
		/**
		 * 输出的编码格式
		 */
		protected var charset:String = globalCharset;
		
		protected var exeArgs:Vector.<String> = new Vector.<String>();
		
		public function initialize(args:Array):void
		{
			var foundWork:Boolean;
			var foundCharset:Boolean;
			
			for (var i:int = 1; i < args.length; i++) 
			{
				if(foundWork)
				{
					try
					{
						workingDirectory = new File(PathFormat.clearQuotes(args[i]));
					} 
					catch(error:Error) 
					{
						workingDirectory = null;
					}
					foundWork = false;
				}
				else if(foundCharset)
				{
					charset = args[i];
					foundCharset = false;
				}
				else
				{
					if(args[i] == "+w")
						foundWork = true;
					else if(args[i] == "+charset")
						foundCharset = true;
					else
						exeArgs.push(PathFormat.clearQuotes(args[i]));
				}
			}
			
			if(!workingDirectory || !workingDirectory.exists)
			{
				workingDirectory = new File(File.applicationDirectory.nativePath);
			}
			
			if(!charset)
				charset = globalCharset;
		}
		
		private var nativeProcess:NativeProcess;
		public function run():void
		{
			if(exeArgs.length<1)
				dispatchEvent(new Event(Event.COMPLETE));
			var exePath:String = exeArgs.shift();
			if(!SystemInfo.isMacOS && !FileUtil.getExtension(exePath))
				exePath += ".exe";
			
			var exeFile:File = workingDirectory.resolvePath(exePath);
			
			nativeProcess = new NativeProcess();
			var nativeProcessInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var args:Vector.<String> = new Vector.<String>();
			nativeProcessInfo.executable = exeFile;
			args = args.concat(exeArgs);
			nativeProcessInfo.workingDirectory = workingDirectory;
			nativeProcessInfo.arguments = args;
			var onExit:Function = function(event:NativeProcessExitEvent):void
			{
				nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onStandardOutput);
				nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA,onStandardOutput);
				nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT , onExit);
				nativeProcess = null;
				_exitCode = event.exitCode;
				dispatchEvent(new Event(Event.COMPLETE));
			};
			nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onStandardOutput);
			nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,onStandardOutput);
			
			nativeProcess.addEventListener(NativeProcessExitEvent.EXIT , onExit);
			try
			{
				nativeProcess.start(nativeProcessInfo);
			} 
			catch(error:Error) 
			{
				dispatchEvent(new CommandEvent(CommandEvent.ERROR , error.message));
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		protected function onStandardOutput(event:ProgressEvent):void
		{
			var loggerEvent:CommandEvent;
			if(event.type==ProgressEvent.STANDARD_OUTPUT_DATA)
			{
				loggerEvent = new CommandEvent(CommandEvent.OUTPUT);
				
				var data:IDataInput = event.target.standardOutput;
				loggerEvent.text = data.readMultiByte(data.bytesAvailable,charset);
			}
			else
			{
				loggerEvent = new CommandEvent(CommandEvent.ERROR);
				
				var error:IDataInput = event.target.standardError;
				loggerEvent.text = error.readMultiByte(error.bytesAvailable,charset);
			}
			loggerEvent.text = loggerEvent.text.split("\r\n\r\n").join("\n");
			loggerEvent.text = loggerEvent.text.split("\r\n").join("\n");
			if(loggerEvent.text.lastIndexOf("\n") == loggerEvent.text.length-1)
				loggerEvent.text = loggerEvent.text.substr(0,loggerEvent.text.length-1);
			this.dispatchEvent(loggerEvent);
		}
		
		/**
		 * 尝试退出正在运行的程序
		 */
		public function exit(force:Boolean=false):void
		{
			if(nativeProcess)
			{
				nativeProcess.exit(force);
			}
		}
		
		private var _exitCode:int = -1;
		/**
		 * 程序退出码 
		 */
		public function get exitCode():int
		{
			return _exitCode;
		}
		
		public function stop():void
		{
			exit(true);
		}
	}
}