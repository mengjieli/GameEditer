package egret.utils.command
{
	import flash.events.IEventDispatcher;

	/**
	 * 同步命令 
	 * @author xzper
	 * 
	 */	
	public interface ICommand extends IEventDispatcher
	{
		/**
		 * 初始化
		 */
		function initialize(args:Array):void;
		
		/**
		 * 执行
		 */
		function run():void;
	}
}