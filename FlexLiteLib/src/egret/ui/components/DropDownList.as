package egret.ui.components
{
	import egret.components.DropDownList;
	
	/**
	 * 添加最大高度限制
	 * @author 雷羽佳
	 */
	public class DropDownList extends egret.components.DropDownList
	{
		public function DropDownList()
		{
			super();
		}
		
		public var itemRendererTextAlign:String = "left";
		
		private var _maxPopHeight:Number = 300;
		/**
		 * 弹出框的最大显示高度。-1表示不限制。
		 */
		public function get maxPopHeight():Number
		{
			return _maxPopHeight;
		}
		
		public function set maxPopHeight(value:Number):void
		{
			_maxPopHeight = value;
			if(dataGroup)
			{
				if(_maxPopHeight == -1)
				{
					dataGroup.maxHeight = 10000;
				}else
				{
					dataGroup.maxHeight= _maxPopHeight;
				}
			}
		}
		
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance==dataGroup)
			{
				if(_maxPopHeight == -1)
				{
					dataGroup.maxHeight = 10000;
				}else
				{
					dataGroup.maxHeight= _maxPopHeight;
				}
			}
		}
	}
}