package egret.ui.skins
{
	import flash.geom.Rectangle;
	
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	
	/**
	 * 下拉菜单的按钮
	 * @author 雷羽佳
	 */
	public class ComboBoxButtonSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/arrowNormal.png")]
		private var arrowNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/arrowNormal_r.png")]
		private var arrowNormalRes_r:Class;
		
		public function ComboBoxButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"]
		}
		private var arrow:UIAsset;
		private var backUI:Rect;

		override protected function createChildren():void
		{
			super.createChildren();
			backUI = new Rect();
			backUI.top = backUI.bottom = backUI.left = backUI.right = 0;
			this.addElement(backUI);
			
			arrow = new UIAsset();
			arrow.horizontalCenter = arrow.verticalCenter = 0;
			arrow.source = new BitmapSource(arrowNormalRes,arrowNormalRes_r);
			this.addElement(arrow);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			switch(currentState)
			{
				case "up":
				{
					backUI.fillColor = 0x1f252b;
					break;
				}
				case "over":
				{
					backUI.fillColor = 0x384450;
					break;
				}
				case "down":
				{
					backUI.fillColor = 0x15191e;
					break;
				}
				case "disabled":
				{
					backUI.fillColor = 0x1f252b;
					break;
				}
			}
		}
	}
}


