package egret.ui.skins
{
	import flash.text.TextFormatAlign;
	
	import egret.components.Label;
	import egret.components.Skin;
	import egret.layouts.VerticalAlign;
	
	/**
	 * DataGrid项呈示器的皮肤
	 * @author 雷羽佳
	 */
	public class GridItemRendererSkin extends Skin
	{
		public function GridItemRendererSkin()
		{
			super();
			this.states = ["up","over","down"];
			this.minHeight = 25;
		}
		
		public var labelDisplay:Label;
		
		override protected function createChildren():void
		{
			super.createChildren();

			labelDisplay = new Label();
			labelDisplay.left = labelDisplay.right = 5;
			labelDisplay.textAlign = TextFormatAlign.LEFT;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.size = 12;
			labelDisplay.verticalCenter = 0;
			this.addElement(labelDisplay);
		}
	}
}


