package egret.managers
{
	/**
	 * 光标管理器
	 * @author dom
	 */
	public interface ICursorManager
	{
		/**
		 * 当前的光标样式
		 */	
		function get cursor():String;
		/**
		 * 设置光标样式
		 * @param name 光标名称
		 * @param priority 光标优先级，若需要锁定当前光标样式，设置一个大于0的数字。
		 * 并在一段时间后调用removeCursor()取消锁定。
		 */			
		function setCursor(name:String,priority:uint = 0):void;
		/**
		 * 移除之前的锁定光标的优先级设置。若没有传入大于0的优先级，不需要调用此方法。
		 * @param name 需要清除锁定的光标名称,不传入则清空所有的光标样式，还原为auto。
		 */		
		function removeCursor(name:String=""):void;
	}
}