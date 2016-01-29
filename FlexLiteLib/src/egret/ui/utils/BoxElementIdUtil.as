package egret.ui.utils
{
	/**
	 * IBoxElement的ID工具类 
	 * @author 雷羽佳
	 * 
	 */	
	public class BoxElementIdUtil
	{
		private static var idArr:Array = [];
		
		/**
		 * 得到一个新的id 
		 * @return 
		 * 
		 */		
		public static function newId():int
		{
			var id:int = 0;
			while(checkHas(id))
			{
				id++;
			}
			addId(id);
			return id;
		}
		
		private static function checkHas(id:int):Boolean
		{
			for(var i:int = 0;i<idArr.length;i++)
			{
				if(id == idArr[i])
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 添加一个已存在的id 
		 * @param id
		 * 
		 */		
		public static function addId(id:int):void
		{
			if(checkHas(id) == false)
			{
				idArr.push(id);
			}
		}
	}
}