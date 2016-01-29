package egret.ui.components
{
	import egret.components.TabBarButton;
	import egret.components.UIAsset;

	/**
	 * 图标的切换按钮 
	 * @author 雷羽佳
	 * 
	 */	
	public class IconTabBarButton extends TabBarButton
	{
		public function IconTabBarButton()
		{
			super();
		}
		
		public var iconDisplay:UIAsset;

		override public function set data(value:Object):void
		{
			super.data = value;
			if(iconDisplay != null && value.hasOwnProperty("icon"))
				iconDisplay.source = value.icon;
			
			if(value.hasOwnProperty("toolTip"))
				this.toolTip = value.toolTip;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(data && instance == iconDisplay)
			{
				iconDisplay.source = data.icon;
			}
		}
	}
}