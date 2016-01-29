package egret.managers
{
	import egret.core.Injector;
	import egret.managers.impl.CursorManagerImpl;
	
	/**
	 * 光标样式管理器
	 * @author dom
	 */
	public class CursorManager
	{

		private static var _impl:ICursorManager;
		/**
		 * 获取单例
		 */		
		private static function get impl():ICursorManager
		{
			if (!_impl)
			{
				try
				{
					_impl = Injector.getInstance(ICursorManager);
				}
				catch(e:Error)
				{
					_impl = new CursorManagerImpl();
				}
			}
			return _impl;
		}
		
		/**
		 * 当前的光标样式
		 */	
		public static function get cursor():String
		{
			return impl.cursor;
		}
		/**
		 * 设置光标样式
		 */	
		public static function setCursor(name:String,priority:uint = 0):void
		{
			impl.setCursor(name,priority);
		}
		/**
		 * 移除之前的锁定光标的优先级设置。若没有传入大于0的优先级，不需要调用此方法。
		 * @param name 需要清除锁定的光标名称,不传入则清空所有的光标样式，还原为auto。
		 */
		public static function removeCursor(name:String=""):void
		{
			impl.removeCursor(name);
		}
	}
}