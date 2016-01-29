package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalLayout;
	
	/**
	 * 选项卡面板的皮肤
	 * @author 雷羽佳
	 */
	public class TabPanelSkin extends Skin
	{
		public function TabPanelSkin()
		{
			super();
			this.states = ["normal","disabled"];
		}
		
		public var contentGroup:Group;
		public var titleGroup:Group;
		public var gapLine:Rect;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			var group:Group = new Group();
			var vl:VerticalLayout = new VerticalLayout();
			vl.gap = 0;
			group.layout = vl;
			group.left = 0;
			group.right = 0;
			group.top =0;
			group.bottom = 0;
			this.addElement(group);
			
			var group2:Group = new Group();
			group2.clipAndEnableScrolling = true;
			group2.percentWidth = 100;
			group.addElement(group2);
			
			titleGroup = new Group();
			titleGroup.clipAndEnableScrolling = true;
			var hl:HorizontalLayout = new HorizontalLayout();
			hl.gap = 0;
			titleGroup.layout = hl;
			titleGroup.right = 0;
			group2.addElement(titleGroup);
			
			gapLine = new Rect();
			gapLine.visible = false;
			gapLine.fillColor = 0x1b2025;
			gapLine.height = 1;
			gapLine.percentWidth = 100;
			group.addElement(gapLine);
			
			contentGroup = new Group();
			contentGroup.clipAndEnableScrolling = true;
			contentGroup.percentHeight = 100;
			contentGroup.percentWidth = 100;
			group.addElement(contentGroup);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "normal")
			{
				contentGroup.alpha = 1;
			}
			if(currentState == "disabled")
			{
				contentGroup.alpha = 0.5;
			}
		}
		
	}
}