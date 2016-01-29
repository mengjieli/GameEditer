package egret.ui.components
{
	import flash.utils.getQualifiedClassName;
	
	import egret.components.Button;
	import egret.components.UIAsset;
	
	/**
	 *
	 * @author 雷羽佳 2014-7-8 下午12:30:13
	 */
	public class IconButton extends Button
	{
		public function IconButton()
		{
			super();
		}
		public var iconDisplay:UIAsset;
		
		private var _icon:Object
		
		public function get icon():Object
		{
			return _icon;
		}

		public function set icon(value:Object):void
		{
			_icon = value;
			if(iconDisplay != null)
			{
				iconDisplay.source = _icon;
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance == iconDisplay)
			{
				if(_icon != null)
					iconDisplay.source = _icon;
			}
		}

	}
}