package egret.ui.skins.managerSkin
{
	import egret.components.Rect;
	import egret.components.Skin;

	public class VScrollBarThumbSkin extends Skin
	{
		public function VScrollBarThumbSkin()
		{
			super();
		}

		override protected function createChildren():void
		{
			super.createChildren();
			var backUI:Rect = new Rect();
			backUI.fillColor= 0xf7f7f7;
			backUI.percentHeight = backUI.percentWidth = 100;
			addElement(backUI);
		}
	}
}