package egret.ui.skins
{
	import egret.components.Button;
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.utils.tr;
	
	/**
	 * Doc选项卡按钮
	 * @author 雷羽佳
	 */
	public class CloseTabButtonSkin extends Skin
	{
		public function CloseTabButtonSkin()
		{
			super();
			this.minHeight = 25;
			states = ["up","over","down","disabled","upAndSelected","overAndSelected","focus"
				,"downAndSelected","disabledAndSelected"];
		}
		
		private var backUI:Rect;
		private var line:Rect;
		private var focusRect:Rect;
		
		public var labelDisplay:Label;
		public var closeButton:Button;
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
			
			line = new Rect();
			line.fillColor = 0x29323B;
			line.bottom = 0;
			line.height = 1;
			line.left = 1;
			line.right = 0;
			this.addElement(line);
			
			focusRect = new Rect();
			focusRect.mouseEnabled = false;
			focusRect.visible = false;
			focusRect.top = 1;
			focusRect.left = 1;
			focusRect.bottom = 0;
			focusRect.right = 0;
			focusRect.fillColor = 0x374552;
			this.addElement(focusRect);
			
			labelDisplay = new Label();
			labelDisplay.verticalCenter = 0;
			labelDisplay.left = 10;
			labelDisplay.right = 26;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.textColor = 0xfefefe;
			this.addElement(labelDisplay);
			
			closeButton = new Button();
			closeButton.verticalCenter = 0;
			closeButton.toolTip = tr("CloseTabButtonSkin.CloseButton.ToolTip");
			closeButton.right = 4;
			closeButton.skinName = DocCloseButtonSkin;
			this.addElement(closeButton);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			closeButton.visible = false;
			backUI.fillColor = 0x22282e;
			if(currentState == "upAndSelected" || currentState == "overAndSelected" || currentState == "focus" ||
				currentState == "downAndSelected" || currentState == "disabledAndSelected" ||  currentState == "down")
			{
				closeButton.visible = true;
				backUI.fillColor = 0x29323B;
				labelDisplay.textColor = 0xfefefe;
				if(currentState == "down")
				{
					backUI.fillColor = 0x12161B;
					line.visible = false;
				}
				else
					line.visible = true;
			}
			else
			{
				line.visible = false;
				if(currentState == "over")
				{
					closeButton.visible = true;
					labelDisplay.textColor = 0xfefefe;
				}
				else
					labelDisplay.textColor = 0x64696d;
			}
			if(currentState == "focus")
			{
				focusRect.visible = true;
			}
			else
			{
				focusRect.visible = false
			}
		}
	}
}