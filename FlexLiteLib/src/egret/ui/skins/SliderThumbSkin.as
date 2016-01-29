package egret.ui.skins
{
	import egret.components.Rect;
	import egret.components.Skin;
	
	public class SliderThumbSkin extends Skin
	{
		public function SliderThumbSkin()
		{
			super();
			states = ["up","over","down","disabled"];
			this.currentState = "up";
			this.minHeight = 12;
			this.minWidth = 12;
		}
		
		public var rect:Rect;
		
		override protected function createChildren():void
		{
			super.createChildren();
			rect = new Rect();
			rect.width = 10;
			rect.height = 10;
			rect.fillColor = 0xffffff;
			rect.radius = 5;
			this.addElement(rect);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			rect.alpha = 1;
			switch(currentState)
			{
				case "up":
				{
					rect.fillColor = 0xffffff;
					break;
				}
				case "over":
				{
					rect.fillColor = 0xf7f7f7;
					break;
				}
				case "down":
				{
					rect.fillColor = 0xffffff;
					break;
				}
				case "disabled":
				{
					rect.fillColor = 0xffffff;
					rect.alpha = 0.5;
					break;
				}
			}
		}
	}
}