package egret.ui.components
{
	import flash.utils.getQualifiedClassName;
	
	import egret.components.UIAsset;
	import egret.components.supportClasses.ItemRenderer;

	/**
	 * 含有图标的默认条目渲染器 
	 * @author 雷羽佳
	 * 
	 */	
	public class IconItemRenderer extends ItemRenderer
	{
		
		public function IconItemRenderer()
		{
			super();
		}
		
		public var iconDisplay:UIAsset;
		
		private var _icon:Object;
		/**
		 * 图标数据源
		 */		
		public function get icon():Object
		{
			return _icon;
		}
		public function set icon(value:Object):void
		{
			_icon = value;
			if(iconDisplay)
				iconDisplay.source = value;
		}
	}
}