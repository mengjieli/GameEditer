package egret.ui.skins.winWindowSkin
{
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	
	import egret.components.Button;
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.events.UIEvent;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;
	import egret.ui.skins.winAppButton.WinCloseButtonSkin;
	import egret.ui.skins.winAppButton.WinMaximizeButtonSkin;
	import egret.ui.skins.winAppButton.WinMinimizeButtonSkin;
	import egret.ui.skins.winAppButton.WinRestoreButtonSkin;
	
	/**
	 * 桌面窗体的皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class WinWindowSkin extends Skin
	{
		
		[Embed(source="/egret/ui/skins/assets/window/shadow.png")]
		private var shadowRes:Class;
		
		[Embed(source="/egret/ui/skins/assets/window/titleIcon.png")]
		private var titleIcon:Class;
		
		public var shadow:UIAsset;
		public var titleDisplay:Label;
		public var moveArea:Group;
		public var minimizeButton:Button;
		public var maxAndRestoreButton:Button;
		public var closeButton:Button;
		
		public var contentGroup:Group;
		
		public var leftResize:Group;
		public var rightResize:Group;
		public var topResize:Group;
		public var bottomResize:Group;
		public var topRightResize:Group;
		public var topLeftResize:Group;
		public var bottomLeftResize:Group;
		public var bottomRightResize:Group;
		public var appIcon:UIAsset;
		public var modalMask:UIAsset;
		public var titleGroup:Group;
		
		public var titleLeftGroup:Group;
		public var titleRightGroup:Group;
		
		public function WinWindowSkin()
		{
			super();
			this.states = ["normal","maximized","minimized","disabled","normalAndInactive","maximizedAndInactive"];
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			shadow = new UIAsset();
			shadow.source = shadowRes;
			shadow.scale9Grid = new Rectangle(8,8,3,3);
			shadow.left = 0;
			shadow.right = 0;
			shadow.top = 0;
			shadow.bottom = 0;
			this.addElement(shadow);
			
			var group:Group = new Group();
			this.addElement(group);
			group.left = 7;
			group.right = 7;
			group.bottom = 7;
			group.top = 7;
			
			var backUI:Rect = new Rect();
			backUI.strokeAlpha = 1;
			backUI.strokeColor = 0x1b2025;
			backUI.fillColor = 0x29323b;
			backUI.percentHeight = backUI.percentWidth = 100;
			group.addElement(backUI);
			
			var hLine:Rect = new Rect();
			hLine.height = 1;
			hLine.percentWidth = 100;
			hLine.top = 35;
			hLine.fillColor = 0x1b2025;
			group.addElement(hLine);
			
			moveArea = new Group();
			moveArea.height = 34;
			moveArea.left = 9;
			moveArea.right = 9;
			group.addElement(moveArea);
			
			var titleContentGroup:Group = new Group();
			titleContentGroup.height = 34;
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.verticalAlign = VerticalAlign.MIDDLE;
			hlayout.gap = 4;
			titleContentGroup.left = 5;
			titleContentGroup.right = 100;
			titleContentGroup.layout = hlayout;
			group.addElement(titleContentGroup);
			
			appIcon = new UIAsset();
			appIcon.source = titleIcon;
			titleContentGroup.addElement(appIcon);
			
			titleGroup = new Group();
			titleGroup.addEventListener(UIEvent.UPDATE_COMPLETE,titleGroupUpdateHandler);
			titleContentGroup.addElement(titleGroup);
			titleGroup.verticalCenter = 0;
			
			titleLeftGroup = new Group();
			titleLeftGroup.verticalCenter = 0;
			titleLeftGroup.percentHeight = 100;
			titleContentGroup.addElement(titleLeftGroup);
			
			var titleDisplayGroup:Group = new Group();
			titleDisplayGroup.percentHeight = 100;
			titleDisplayGroup.percentWidth = 100;
			titleContentGroup.addElement(titleDisplayGroup);
			
			titleDisplay = new Label();
			titleDisplay.size = 14;
			titleDisplay.verticalCenter = 0;
			titleDisplay.left = 5;
			titleDisplay.right = 5;
			titleDisplay.height = 20;
			titleDisplayGroup.addElement(titleDisplay);
			
			titleRightGroup = new Group();
			titleRightGroup.verticalCenter = 0;
			titleRightGroup.percentHeight = 100;
			titleContentGroup.addElement(titleRightGroup);
			
			var buttonGroup:Group = new Group();
			buttonGroup.right = 0;
			var buttonLayout:HorizontalLayout = new HorizontalLayout();
			buttonLayout.gap = -1;
			buttonGroup.layout = buttonLayout;
			group.addElement(buttonGroup);
			
			minimizeButton = new Button();
			minimizeButton.skinName = WinMinimizeButtonSkin;
			buttonGroup.addElement(minimizeButton);
			
			maxAndRestoreButton = new Button();
			maxAndRestoreButton.skinName = WinMaximizeButtonSkin;
			buttonGroup.addElement(maxAndRestoreButton);
			
			closeButton = new Button();
			closeButton.skinName = WinCloseButtonSkin;
			buttonGroup.addElement(closeButton);
			
			contentGroup = new Group();
			contentGroup.clipAndEnableScrolling = true;
			contentGroup.top = 36;
			contentGroup.left = 1;
			contentGroup.right = 1;
			contentGroup.bottom = 1;
			group.addElement(contentGroup);
			
			leftResize = new Group();
			leftResize.top = 20;
			leftResize.bottom = 20;
			leftResize.width = 4;
			group.addElement(leftResize);
			
			rightResize = new Group();
			rightResize.top = 20;
			rightResize.bottom = 20;
			rightResize.width = 4;
			rightResize.right = 0;
			group.addElement(rightResize);
			
			topResize = new Group();
			topResize.left = 20;
			topResize.right = 20;
			topResize.top = 0;
			topResize.height = 4;
			group.addElement(topResize);
			
			bottomResize = new Group();
			bottomResize.left = 20;
			bottomResize.right = 20;
			bottomResize.height = 4;
			bottomResize.bottom = 0;
			group.addElement(bottomResize);
			
			topRightResize = new Group();
			topRightResize.right = 0;
			topRightResize.height = 20;
			topRightResize.width = 4;
			group.addElement(topRightResize);
			
			topLeftResize = new Group();
			topLeftResize.left = 0;
			topLeftResize.top = 0;
			topLeftResize.height = 20;
			topLeftResize.width = 20;
			group.addElement(topLeftResize);
			
			bottomLeftResize = new Group();
			bottomLeftResize.left = 0;
			bottomLeftResize.bottom = 0;
			bottomLeftResize.height = 20;
			bottomLeftResize.width = 20;
			group.addElement(bottomLeftResize);
			
			bottomRightResize = new Group();
			bottomRightResize.right = 0;
			bottomRightResize.bottom = 0;
			bottomRightResize.height = 20;
			bottomRightResize.width = 20;
			group.addElement(bottomRightResize);
			
			modalMask = new UIAsset();
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFFFFFF);
			shape.graphics.drawRect(0,0,10,10);
			shape.graphics.endFill();
			modalMask.source = shape;
			modalMask.left = 0;
			modalMask.right = 0;
			modalMask.top = 0;
			modalMask.bottom = 0;
			modalMask.alpha = 0.1;
			group.addElement(modalMask);
		}
		
		protected function titleGroupUpdateHandler(event:UIEvent):void
		{
			if(titleGroup.numElements == 0 || titleDisplay.visible == false)
			{
				titleDisplay.textAlign = TextFormatAlign.LEFT
				titleDisplay.alpha = 1;
			}else
			{
				titleDisplay.textAlign = TextFormatAlign.CENTER
				titleDisplay.alpha = 0.8;
			}
		}		
		
		override protected function commitCurrentState():void
		{
			if(currentState == "maximized" || currentState == "maximizedAndInactive")
				maxAndRestoreButton.skinName = WinRestoreButtonSkin;
			else
				maxAndRestoreButton.skinName = WinMaximizeButtonSkin;
			
			if(currentState == "normal")
			{
				leftResize.visible = true;
				rightResize.visible = true;
				topResize.visible = true;
				bottomResize.visible = true;
				topRightResize.visible = true;
				topRightResize.visible = true;
				bottomLeftResize.visible = true;
				bottomRightResize.visible = true;
			}
			else
			{
				leftResize.visible = false;
				rightResize.visible = false;
				topResize.visible = false;
				bottomResize.visible = false;
				topRightResize.visible = false;
				topRightResize.visible = false;
				bottomLeftResize.visible = false;
				bottomRightResize.visible = false;
			}
		}
	}
}