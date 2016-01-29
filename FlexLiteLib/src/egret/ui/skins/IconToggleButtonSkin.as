package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;

	/**
	 * 图标的切换状态的按钮皮肤(只显示图标)
	 * @author 雷羽佳
	 * 
	 */	
	public class IconToggleButtonSkin extends Skin
	{
		public function IconToggleButtonSkin()
		{
			super();
			states = ["up","over","down","disabled","upAndSelected","overAndSelected"
				,"downAndSelected","disabledAndSelected"];
			this.currentState = "up";
		}
		
		private var ui:Rect;
		
		public var iconDisplay:UIAsset;
		
		private var group:Group;
		override protected function createChildren():void
		{
			super.createChildren();
			
			group = new Group();
			group.clipAndEnableScrolling = true;
			this.addElement(group);
			
			group.width = 24;
			group.height = 24;
			
			ui = new Rect();
			ui.percentWidth = ui.percentHeight = 100;
			ui.fillColor = 0xffffff;
			ui.fillAlpha = 0;
			group.addElement(ui);
			
			iconDisplay = new UIAsset();
			iconDisplay.verticalCenter = 0;
			iconDisplay.horizontalCenter = 0;
			group.addElement(iconDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "up" || currentState == "disabled")
			{
				ui.fillColor = 0xffffff;
				ui.fillAlpha = 0;
			}else if(currentState == "over")
			{
				ui.fillColor = 0x34464e;
				ui.fillAlpha = 1;
			}else if(currentState == "down" ||
				currentState == "upAndSelected" ||
				currentState == "overAndSelected" ||
				currentState == "downAndSelected" ||
				currentState == "disabledAndSelected")
			{
				ui.fillColor = 0x1b2124;
				ui.fillAlpha = 1;
			}
			
			if(currentState == "disabled")
			{
				group.alpha = 0.5;
			}else
			{
				group.alpha = 1;
			}
		}
	}
}