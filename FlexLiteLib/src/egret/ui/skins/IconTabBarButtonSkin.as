package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	
	/**
	 * 选项卡按钮皮肤
	 * @author 雷羽佳
	 * 
	 */	
	public class IconTabBarButtonSkin extends Skin
	{
		public function IconTabBarButtonSkin()
		{
			super();
			this.minHeight = 25;
			states = ["up","over","down","disabled","upAndSelected","overAndSelected"
				,"downAndSelected","disabledAndSelected","focus"];
		}
		
		public var backUI:Rect;
		public var bottomLine:Rect;
		
		public var focusRect:Rect;
		
		public var labelDisplay:Label;
		public var iconDisplay:UIAsset;
		protected var group:Group;
		
		override protected function createChildren():void
		{
			super.createChildren();
			backUI = new Rect();
			backUI.strokeColor = 0x1b2025;
			backUI.strokeAlpha = 1;
			backUI.fillColor = 0x22282e;
			backUI.top = 0;
			backUI.left = 0;
			backUI.right = 0;
			backUI.bottom = 0;
			this.addElement(backUI);
			
			bottomLine = new Rect();
			bottomLine.fillColor = 0x374552;
			bottomLine.bottom = 0;
			bottomLine.height = 1;
			bottomLine.left = 1;
			bottomLine.right = 1;
			this.addElement(bottomLine);
			
			focusRect = new Rect();
			focusRect.mouseEnabled = false;
			focusRect.visible = false;
			focusRect.top = 1;
			focusRect.left = 1;
			focusRect.bottom = 0;
			focusRect.right = 0;
			focusRect.fillColor = 0x374552;
			this.addElement(focusRect);
			
			group = new Group();
			group.percentWidth = 100;
			group.verticalCenter = 0;
			group.clipAndEnableScrolling = true;
			this.addElement(group);
			
			iconDisplay = new UIAsset();
			iconDisplay.x = 12;
			group.addElement(iconDisplay);
			
			labelDisplay = new Label();
			labelDisplay.left = 35;
			labelDisplay.right = 5;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.textColor = 0xfefefe;
			group.addElement(labelDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "over")
			{
				backUI.fillColor = 0x29323B;
			}
			else
			{
				backUI.fillColor = 0x22282e;
			}
			if(currentState == "upAndSelected" || currentState == "overAndSelected" || currentState == "focus" ||
				currentState == "downAndSelected" || currentState == "disabledAndSelected" ||  currentState == "down")
			{
				if(currentState=="focus"||currentState=="down")
				{
					backUI.fillColor = 0x374552;
				}
				else
				{
					backUI.fillColor = 0x29323B;
				}
				labelDisplay.textColor = 0xfefefe;
				iconDisplay.alpha = 1;
				if(currentState == "down")
				{
					bottomLine.visible = false;
				}
				else
				{
					bottomLine.visible = true;
				}
			}
			else
			{
				bottomLine.visible = false;
				if(currentState == "over")
				{
					labelDisplay.textColor = 0xfefefe;
					iconDisplay.alpha = 1;
				}
				else
				{
					labelDisplay.textColor = 0x64696d;
					iconDisplay.alpha = 0.5;
				}
			}
			if(currentState == "focus")
			{
				backUI.fillColor = 0x374552;
				focusRect.visible = true;
				bottomLine.fillColor = 0x374552;
			}
			else
			{
				bottomLine.fillColor = 0x29323B;
				focusRect.visible = false;
			}
		}
	}
}


