package  egret.ui.skins
{
	import flash.display.Shape;
	import flash.text.TextFormatAlign;
	
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.layouts.VerticalAlign;

	/**
	 * 有图标的想渲染器的皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class IconItemRendererSkin extends Skin
	{
		public function IconItemRendererSkin()
		{
			super();
			states = ["up","over","down"];
			this.minHeight = 23;
			this.minWidth = 23;
		}
		
		public var iconDisplay:UIAsset;
		public var labelDisplay:Label;
		private var rect:Rect;
		override protected function createChildren():void
		{
			super.createChildren();
			rect = new Rect();
			rect.left = 0;
			rect.right = 0;
			rect.top = 0;
			rect.bottom = 0;
			this.addElement(rect);
			
			var line:Rect = new Rect();
			line.fillColor = 0x15191e;
			line.height = 1;
			line.left = 0;
			line.right = 0;
			line.bottom = 0;
			this.addElement(line);
			
			iconDisplay = new UIAsset();
			iconDisplay.x = 3;
			iconDisplay.verticalCenter = 0;
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xff0000);
			shape.graphics.drawRect(0,0,10,10);
			shape.graphics.endFill();
			
			iconDisplay.source = shape;
			this.addElement(iconDisplay);
			
			labelDisplay = new Label();
			labelDisplay.textAlign = TextFormatAlign.LEFT;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.left = 21;
			labelDisplay.top = 0;
			labelDisplay.bottom = 0;
			labelDisplay.right = 0;
			this.addElement(labelDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "up")
			{
				rect.fillColor = 0x1e2329;
			}else if(currentState == "over")
			{
				rect.fillColor = 0x384552;
			}else if(currentState == "down")
			{
				rect.fillColor = 0x396895;
			}	
		}
	}
}