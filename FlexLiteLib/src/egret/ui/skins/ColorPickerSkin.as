package egret.ui.skins
{
	import egret.components.Rect;
	import egret.components.Skin;

	/**
	 * 取色器的皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class ColorPickerSkin extends Skin
	{
		public function ColorPickerSkin()
		{
			super();
		}
		
		public var colorDisplay:Rect;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			var rect:Rect = new Rect();
			rect.strokeColor = 0x383838;
			rect.strokeAlpha = 1;
			rect.strokeWeight = 1;
			rect.fillAlpha = 0;
			rect.width = 55;
			rect.height = 20;
			this.addElement(rect);
			
			colorDisplay = new Rect();
			colorDisplay.strokeColor = 0xffffff;
			colorDisplay.strokeAlpha = 1;
			colorDisplay.strokeWeight = 2;
			colorDisplay.fillColor = 0x009aff;
			colorDisplay.x = 1;
			colorDisplay.y = 1;
			colorDisplay.width = 53;
			colorDisplay.height = 18;
			this.addElement(colorDisplay);
		}
	}
}