package egret.ui.components.boxClasses
{
	import egret.core.ns_egret;
	import egret.ui.components.DropDownList;

	use namespace ns_egret;
	/**
	 * 文档下拉框
	 */
	public class DocDropDownList extends DropDownList
	{
		public function DocDropDownList()
		{
			super();
		}
		
		private var _label:String;
		private var labelChanged:Boolean;
		/**
		 * 显示的文字
		 */
		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			if(_label == value)
				return;
			_label = value;
			labelChanged = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(labelChanged)
			{
				labelChanged = false;
				labelDisplay.text = _label;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override ns_egret function updateLabelDisplay(displayItem:* = undefined):void
		{
		}
		
	}
}