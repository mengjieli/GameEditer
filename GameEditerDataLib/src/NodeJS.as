package 
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import egret.utils.SystemInfo;

	public class NodeJS
	{
		private var process:NativeProcess;
		public function NodeJS(url,params:Array=null)
		{
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var nodeFile:File;
			if(SystemInfo.isMacOS) {
				nodeFile = File.applicationDirectory.resolvePath("nodejs/mac/node");
			} 
			else {
				nodeFile = File.applicationDirectory.resolvePath("nodejs/win/node.exe");
			}
			processInfo.executable = nodeFile;
			
			var jsPath:String = File.applicationDirectory.resolvePath(url).nativePath;
			var arg:Vector.<String> = new Vector.<String>();
			arg[0] = jsPath;
			if(params) {
				for(var i:int = 0; i < params.length; i++) {
					arg.push(params[i]);
				}
			}
//			arg[1] = GlobalData.asversion;
//			arg[2] = name;
//			arg[3] = exportURL;
//			arg[4] = this.type + "";
//			if(this.type == 1 || this.type == 2) arg[5] = this.sourceURL;
//			if(this.type == 3)
//			{
//				arg[5] = this.srcURL;
//				arg[6] = this.startURL;
//				arg[7] = this.resURL;
//			}
			processInfo.arguments = arg;
			processInfo.workingDirectory = File.applicationDirectory.resolvePath("nodejs");
			
			process = new NativeProcess();
			process.start(processInfo);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,dataOut);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,dataOut);
			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,error);
			process.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR,error);
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,error);
			process.addEventListener(NativeProcessExitEvent.EXIT,processExit);
		}
		
		private function dataOut(e:ProgressEvent):void {
			var standard:IDataInput;
			switch(e.type)
			{
				case ProgressEvent.STANDARD_ERROR_DATA:
				{
					standard=process.standardError;
				}
					break;
				case ProgressEvent.STANDARD_OUTPUT_DATA:
					standard=process.standardOutput;
					break;
			}
			var message:String=standard.readUTFBytes(standard.bytesAvailable);
			trace(message);
		}
		
		private function error(e:IOErrorEvent):void {
			
		}
		
		private function processExit(e:NativeProcessExitEvent):void {
			
		}
	}
}