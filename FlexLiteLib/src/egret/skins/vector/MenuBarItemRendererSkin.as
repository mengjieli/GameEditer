package egret.skins.vector
{
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;

	/**
	 * 菜单栏按钮皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class MenuBarItemRendererSkin extends Skin
	{
		public function MenuBarItemRendererSkin()
		{
			super();
			this.states = ["up","down","over"];
		}
		
		public var iconDisplay:UIAsset;
		public var labelDisplay:Label;
		
		private var group:Group;
		public var ui:Rect;
		
		private var contentGroup:Group;
		override protected function createChildren():void
		{
			super.createChildren();
			
			group = new Group();
			this.addElement(group);
			group.top = 0;
			group.bottom = 0;
			ui = new Rect();
			group.addElement(ui);
			ui.top = 0;
			ui.bottom = 1;
			ui.left = ui.right = 0;
			ui.fillColor = 0xffffff;
			ui.fillAlpha = 0;
			iconDisplay = new UIAsset();
			
			
			contentGroup = new Group();
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.verticalAlign = VerticalAlign.CONTENT_JUSTIFY;
			layout.gap = 0;
			contentGroup.top = contentGroup.bottom = 0;
			contentGroup.layout = layout;
			
			group.addElement(contentGroup);
			iconDisplay = new UIAsset();
			iconDisplay.verticalCenter = 0;
			contentGroup.addElement(iconDisplay);
			labelDisplay = new Label();
			labelDisplay.percentHeight = 100;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			contentGroup.addElement(labelDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "up")
			{
				ui.fillAlpha = 0;
				ui.strokeAlpha = 0;
			}else if(currentState == "over")
			{
				ui.fillColor = 0xd5e7f8;
				ui.fillAlpha = 1;
				ui.strokeAlpha = 1;
				ui.strokeWeight = 1;
				ui.strokeColor = 0x7ab1e8;
			}else if(currentState == "down")
			{
				ui.fillColor = 0x7cb9f8;
				ui.fillAlpha = 1;
				ui.strokeAlpha = 1;
				ui.strokeWeight = 1;
				ui.strokeColor = 0x336ea9;
			}
			
		}
	}
}