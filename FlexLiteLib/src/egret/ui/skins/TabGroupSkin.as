package egret.ui.skins
{
	import egret.components.Button;
	import egret.components.Group;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.ViewStack;
	import egret.layouts.HorizontalLayout;
	import egret.ui.components.IconButton;
	import egret.ui.components.IconTabBar;
	import egret.ui.components.boxClasses.FocusTabBarButton;
	import egret.utils.callLater;
	import egret.utils.tr;
	
	/**
	 * 选项卡组皮肤
	 * @author 雷羽佳
	 */
	public class TabGroupSkin extends Skin
	{
		public function TabGroupSkin()
		{
			super();
			this.states = ["normal","disabled","focus"];
		}
		
		public var moveArea:Group;
		public var titleTabBar:IconTabBar;
		public var titleGroup:Group;
		public var viewStack:ViewStack;
		public var menuButton:Button;
		
		public var backUI:Rect;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			var border:Rect = new Rect();
			border.strokeAlpha = 1;
			border.strokeWeight = 1;
			border.strokeColor = 0x1b2025;
			border.fillAlpha = 0;
			border.percentHeight = border.percentWidth = 100;
			this.addElement(border);
			
			backUI = new Rect();
			backUI.left = backUI.right = 1;
			backUI.top = 25;
			backUI.bottom = 1;
			backUI.fillColor = 0x232a32;
			backUI.strokeAlpha = 1;
			backUI.strokeColor = 0x29323B;
			backUI.strokeWeight = 2;
			this.addElement(backUI);
			
			var topGroup:Group = new Group();
			topGroup.percentWidth = 100;
			topGroup.height = 25;
			this.addElement(topGroup);
			
			var rect:Rect = new Rect();
			rect.left = 0;
			rect.right = 0;
			rect.percentHeight = 100;
			rect.strokeAlpha = 1;
			rect.strokeColor = 0x1b2025;
			rect.fillColor = 0x22282e;
			topGroup.addElement(rect);
			
			moveArea = new Group();
			moveArea.percentHeight = moveArea.percentWidth = 100;
			topGroup.addElement(moveArea);
			
			titleTabBar = new IconTabBar();
			titleTabBar.left = 0;
			titleTabBar.percentHeight = 100;
			titleTabBar.skinName = TabBarSkin;
			titleTabBar.itemRenderer = FocusTabBarButton;
			titleTabBar.itemRendererSkinName = IconTabBarButtonSkin;
			topGroup.addElement(titleTabBar);
			
			titleGroup = new Group();
			titleGroup.right = 25;
			titleGroup.verticalCenter = 0;
			var hl:HorizontalLayout = new HorizontalLayout();
			hl.gap = 0;
			titleGroup.layout = hl;
			topGroup.addElement(titleGroup);
			
			
			menuButton = new Button();
			menuButton.toolTip = tr("TabGroup.MenuButton");
			menuButton.right = 4;
			menuButton.verticalCenter = 0;
			menuButton.skinName = MenuButtonSkin;
			topGroup.addElement(menuButton);
			
			viewStack = new ViewStack();
			viewStack.clipAndEnableScrolling = true;
			viewStack.left = 3;
			viewStack.bottom = 3;
			viewStack.right = 3;
			viewStack.top = 27;
			this.addElement(viewStack);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			callLater(function():void{
				var selectedButton:FocusTabBarButton;
				if(titleTabBar.selectedIndex>=0)
					selectedButton = titleTabBar.dataGroup.getElementAt(titleTabBar.selectedIndex) as FocusTabBarButton;
				if(currentState == "focus")
				{
					backUI.strokeColor  = 0x374552;
					if(selectedButton)
						selectedButton.isFocus = true;
				}
				else
				{
					backUI.strokeColor  = 0x29323B;
					
					
					if(selectedButton)
						selectedButton.isFocus = false;
				}
			});
		}
	}
}