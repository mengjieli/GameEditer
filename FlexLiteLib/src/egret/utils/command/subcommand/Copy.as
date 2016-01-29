package egret.utils.command.subcommand
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import egret.utils.FileUtil;
	import egret.utils.PathFormat;
	import egret.utils.command.CommandEvent;
	import egret.utils.command.ICommand;
	
	/**
	 * @author xzper
	 */
	public class Copy extends EventDispatcher implements ICommand
	{
		private var source:String;
		private var destination:String;
		
		public function initialize(args:Array):void
		{
			source = PathFormat.formatPath(args[1]);
			destination = PathFormat.formatPath(args[2]);
		}
		
		public function run():void
		{
			try
			{
				var sourceFile:File = new File(source);
				var destinationFile:File = new File(destination);
			} 
			catch(error:Error) 
			{
				dispatchEvent(new CommandEvent(CommandEvent.ERROR,error.message));
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			if(PathFormat.isDirectory(source))
			{
				if(!PathFormat.isDirectory(destination))
				{
					dispatchEvent(new Event(Event.COMPLETE));
					return;
				}
				
				var list:Array = FileUtil.search(sourceFile.nativePath);
				
				for each(var file:File in list)
				{
					var relative:String = sourceFile.getRelativePath(file);
					FileUtil.copyTo(file.nativePath,destination+relative,true);
				}
			}
			else if(PathFormat.isDirectory(destination))
			{
				FileUtil.copyTo(source,destination+sourceFile.name,true);
			}
			else
			{
				FileUtil.copyTo(source,destination,true);
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}