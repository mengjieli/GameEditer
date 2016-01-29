package egret.utils.command.subcommand
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import egret.utils.FileUtil;
	import egret.utils.PathFormat;
	import egret.utils.command.ICommand;
	
	/**
	 * @author xzper
	 */
	public class Delete extends EventDispatcher implements ICommand
	{
		private var source:String;
		public function initialize(args:Array):void
		{
			source = PathFormat.formatPath(args[1]);
		}
		
		public function run():void
		{
			FileUtil.deletePath(source);
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}