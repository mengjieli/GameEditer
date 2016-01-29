package egret.utils.command
{
	/**
	 * 异步的命令，提供停止方法 
	 * @author featherJ
	 * 
	 */	
	public interface IAsynCommand extends ICommand
	{
		/**
		 * 结束命令 
		 */		
		function stop():void;
	}
}