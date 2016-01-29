package egret.ui.skins
{
	import flash.geom.Rectangle;
	
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	
	/**
	 * 下拉菜单的按钮
	 * @author 雷羽佳
	 */
	public class DropDownListButtonSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/arrowNormal.png")]
		private var arrowNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/arrowNormal_r.png")]
		private var arrowNormalRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/bgHover.png")]
		private var bgHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/bgDown.png")]
		private var bgDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/bgNormal.png")]
		private var bgNormalRes:Class;
		
		public function DropDownListButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"]
		}
		
		
		private var backUI:UIAsset;
		private var arrowUI:UIAsset;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			backUI = new UIAsset();
			backUI.top = backUI.bottom = backUI.left = backUI.right = 0;
			backUI.source = bgNormalRes;
			backUI.scale9Grid = new Rectangle(2,2,1,1);
			this.addElement(backUI);
			
			arrowUI = new UIAsset();
			arrowUI.right = 6;
			arrowUI.verticalCenter = 0;
			arrowUI.source = new BitmapSource(arrowNormalRes,arrowNormalRes_r);
			this.addElement(arrowUI);
			
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			switch(currentState)
			{
				case "up":
				{
					backUI.source = bgNormalRes;
					break;
				}
				case "over":
				{
					backUI.source = bgHoverRes;
					break;
				}
				case "down":
				{
					backUI.source = bgDownRes;
					break;
				}
				case "disabled":
				{
					backUI.source = bgNormalRes;
					break;
				}
			}
		}
	}
}