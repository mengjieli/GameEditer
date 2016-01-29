package egret.ui.skins.macWindowSkin
{
	import egret.components.Button;
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Scroller;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.ScrollBasicLayout;
	import egret.layouts.VerticalAlign;
	import egret.utils.tr;
	
	/**
	 * 提示框窗体的皮肤 
	 * @author 雷羽佳
	 */
	public class MacAlertSkin extends MacWindowSkin
	{
		public var firstButton:Button;
		public var secondButton:Button;
		public var thirdButton:Button;
		public var contentDisplay:Label;
		
		public function MacAlertSkin()
		{
			super();
			maxWidth=600;
			minWidth=400;
			minHeight=160;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			contentGroup.layout = new ScrollBasicLayout();
			var hGroup:Group = new Group();
			var h:HorizontalLayout = new HorizontalLayout();
			h.gap = 16;
			h.horizontalAlign = HorizontalAlign.CENTER;
			h.verticalAlign = VerticalAlign.MIDDLE;
			hGroup.layout = h;
			hGroup.bottom = 16;
			hGroup.y = 51;
			hGroup.horizontalCenter = 0;
			contentGroup.addElement(hGroup);
			
			firstButton = new Button();
			firstButton.label = tr("AlertWindowSkin.ButtonOne");
			firstButton.x = 96;
			firstButton.y = 67;
			firstButton.minWidth = 60;
			hGroup.addElement(firstButton);
			
			secondButton = new Button();
			secondButton.label =tr("AlertWindowSkin.ButtonTwo");
			secondButton.x = 96;
			secondButton.y = 67;
			secondButton.minWidth = 60;
			hGroup.addElement(secondButton);
			
			thirdButton = new Button();
			thirdButton.label = tr("AlertWindowSkin.ButtonThree");
			thirdButton.x = 96;
			thirdButton.y = 67;
			thirdButton.minWidth = 60;
			hGroup.addElement(thirdButton);
			
			var scroller:Scroller = new Scroller();
			scroller.left = 10;
			scroller.right = 10;
			scroller.top = 10;
			scroller.bottom = 47;
			scroller.maxHeight = 600;
			contentGroup.addElement(scroller);
			
			var group2:Group = new Group();
			group2.layout = new ScrollBasicLayout();
			scroller.viewport = group2;
			
			contentDisplay = new Label();
			contentDisplay.maxWidth = 340;
			contentDisplay.minHeight = 50;
			contentDisplay.horizontalCenter = 0;
			contentDisplay.verticalAlign = VerticalAlign.MIDDLE;
			group2.addElement(contentDisplay);
		}
	}
}