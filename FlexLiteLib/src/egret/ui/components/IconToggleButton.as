package egret.ui.components
{
	import egret.components.ToggleButton;
	import egret.components.UIAsset;

	/**
	 * 带图标的可切换状态按钮 
	 * @author 雷羽佳
	 * 
	 */	
	public class IconToggleButton extends ToggleButton
	{
		public function IconToggleButton()
		{
			
		}
		
		private var _icon:String = "";
		
		public var iconDisplay:UIAsset;
		
		
		public function get icon():String
		{
			return _icon;
		}

		public function set icon(value:String):void
		{
			_icon = value;
			if(iconDisplay)
			{
				iconDisplay.source = _icon;
			}
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance == iconDisplay)
			{
				iconDisplay.source = _icon;
			}
		}
	}
}