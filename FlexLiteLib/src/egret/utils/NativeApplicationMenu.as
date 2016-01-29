package egret.utils
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;

	/**
	 * 原生菜单 
	 * @author featherJ
	 * 
	 */	
	public class NativeApplicationMenu
	{
		private static var _macMenu:NativeMenu;
		
		public static function get macMenu():NativeMenu
		{
			cleanDefaultAbout();
			return NativeApplication.nativeApplication.menu;
		}
		
		public static function set macMenu(value:NativeMenu):void
		{
			_macMenu = value;
			if(!NativeApplication.supportsMenu) return;
			cleanDefaultAbout();
			while(NativeApplication.nativeApplication.menu.numItems>1)
			{
				NativeApplication.nativeApplication.menu.removeItemAt(NativeApplication.nativeApplication.menu.numItems-1);
			}
			var items:Array = [];
			while(value.numItems>0)
			{
				items.push(value.getItemAt(0));
				value.removeItemAt(0);
			}
			for(var i:int = 0;i<items.length;i++)
			{
				NativeApplication.nativeApplication.menu.addItem(items[i]);
			}
		}
		
		private static var removedFirstItem:Boolean = false;
		private static function cleanDefaultAbout():void
		{
			if(!removedFirstItem)
			{
				NativeApplication.nativeApplication.menu.getItemAt(0).submenu.removeItemAt(0);
				removedFirstItem = true;
			}
		}
	}
}