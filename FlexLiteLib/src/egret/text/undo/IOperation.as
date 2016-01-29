package egret.text.undo
{
	/**
	 * 可以撤销和重做的操作对象接口
	 * @author dom
	 */	
	public interface IOperation
	{
		/**
		 * 执行重做
		 */		
		function redo():void;
		/**
		 * 执行撤销
		 */		
		function undo():void;
		/**
		 * 执行撤销或者重做后是否继续执行下一个操作
		 */
		function get doNext():Boolean;
		function set doNext(value:Boolean):void;
	}
}
