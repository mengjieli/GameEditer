package egret.managers.impl
{
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import egret.managers.ICursorManager;
	
	[ExcludeClass]
	/**
	 * 光标样式管理器默认实现
	 * @author dom
	 */
	public class CursorManagerImpl implements ICursorManager
	{
		/**
		 * 构造函数
		 */		
		public function CursorManagerImpl()
		{
		}
		/**
		 * @inheritDoc
		 */
		public function get cursor():String
		{
			return Mouse.cursor;
		}
		
		private var priorityMap:Array = [];
		
		private var nameDic:Object = {};
		/**
		 * @inheritDoc
		 */
		public function setCursor(name:String, priority:uint=0):void
		{
			priorityMap[priority] = name;
			nameDic[name] = priority;
			updateCursor();
		}
		/**
		 * @inheritDoc
		 */
		public function removeCursor(name:String=""):void
		{
			if(!name)
			{
				nameDic = {};
				priorityMap = [];
				updateCursor();
				return;
			}
			var priority:uint = nameDic[name];
			delete nameDic[name];
			if(priorityMap[priority]==name){
				delete priorityMap[priority];
				updateCursor();
			}
		}
		
		private function updateCursor():void
		{
			var length:int = priorityMap.length;
			if(length==0)
			{
				Mouse.cursor = MouseCursor.AUTO;
				return;
			}
			
			var name:String;
			for(var i:int=length;i>=0;i--)
			{
				name = priorityMap[i];
				if(name)
				{
					break;
				}
			}
			if(name)
			{
				Mouse.cursor = name;
			}
			else
			{
				Mouse.cursor = MouseCursor.AUTO;
			}
		}
	}
}