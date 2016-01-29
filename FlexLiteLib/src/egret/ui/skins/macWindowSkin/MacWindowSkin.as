package egret.ui.skins.macWindowSkin
{
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;
	import egret.ui.components.RollOverButton;
	import egret.ui.skins.macAppButton.MacCloseButtonSkin;
	import egret.ui.skins.macAppButton.MacMaximizeButtonSkin;
	import egret.ui.skins.macAppButton.MacMinimizeButtonSkin;
	
	/**
	 * 桌面窗体的皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class MacWindowSkin extends Skin
	{
		
		[Embed(source="/egret/ui/skins/assets/window/shadow.png")]
		private var shadowRes:Class;
		[Embed(source="/egret/ui/skins/assets/window/titleIcon.png")]
		private var titleIcon:Class;
		[Embed(source="/egret/ui/skins/assets/window/titleIcon_r.png")]
		private var titleIcon_r:Class;
		
		public var shadow:UIAsset;
		public var titleDisplay:Label;
		public var moveArea:Group;
		public var minimizeButton:RollOverButton;
		public var maxAndRestoreButton:RollOverButton;
		public var closeButton:RollOverButton;
		
		public var contentGroup:Group;
		
		public var leftResize:Group;
		public var rightResize:Group;
		public var topResize:Group;
		public var bottomResize:Group;
		public var topRightResize:Group;
		public var topLeftResize:Group;
		public var bottomLeftResize:Group;
		public var bottomRightResize:Group;
		public var modalMask:UIAsset;
		
		public var appIcon:UIAsset;
		private var backUI:Rect;
		public var group:Group;
		
		public var titleLeftGroup:Group;
		public var titleRightGroup:Group;
		
		public function MacWindowSkin()
		{
			super();
			this.states = ["normal","maximized","minimized","disabled"];
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
			
			group = new Group();
			this.addElement(group);
			group.left = 7;
			group.right = 7;
			group.bottom = 7;
			group.top = 7;
			
			backUI = new Rect();
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
			group.addElement(moveArea);
			moveArea.top = 0;
			moveArea.left = 0;
			moveArea.right = 0;
			moveArea.height = 34;
			
			
			var titleContentGroup:Group = new Group();
			titleContentGroup.height = 34;
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.verticalAlign = VerticalAlign.MIDDLE;
			hlayout.gap = 4;
			titleContentGroup.left = 70;
			titleContentGroup.right = 5;
			titleContentGroup.layout = hlayout;
			group.addElement(titleContentGroup);
			
			titleLeftGroup = new Group();
			titleLeftGroup.verticalCenter = 0;
			titleLeftGroup.percentHeight = 100;
			titleContentGroup.addElement(titleLeftGroup);
			
			var titleGroup:Group = new Group();
			hlayout = new HorizontalLayout();
			hlayout.horizontalAlign = HorizontalAlign.CENTER;
			hlayout.verticalAlign = VerticalAlign.MIDDLE;
			titleGroup.layout = hlayout;
			titleGroup.percentWidth = 100;
			titleContentGroup.addElement(titleGroup);
			
			appIcon = new UIAsset();
			appIcon.source = new BitmapSource(titleIcon,titleIcon_r);
			titleGroup.addElement(appIcon);
			titleDisplay = new Label();
			titleDisplay.size = 14;
			titleDisplay.verticalAlign = VerticalAlign.BOTTOM;
			titleGroup.addElement(titleDisplay);
			
		
			titleRightGroup = new Group();
			titleRightGroup.verticalCenter = 0;
			titleRightGroup.percentHeight = 100;
			titleContentGroup.addElement(titleRightGroup);
			var buttonGroup:Group = new Group();
			var buttonLayout:HorizontalLayout = new HorizontalLayout();
			buttonLayout.gap = -1;
			group.addElement(buttonGroup);
			
			minimizeButton = new RollOverButton();
			minimizeButton.skinName = MacMinimizeButtonSkin;
			minimizeButton.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			minimizeButton.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
			minimizeButton.x = 28;
			minimizeButton.y = 10;
			buttonGroup.addElement(minimizeButton);
			
			maxAndRestoreButton = new RollOverButton();
			maxAndRestoreButton.skinName = MacMaximizeButtonSkin;
			maxAndRestoreButton.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			maxAndRestoreButton.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
			maxAndRestoreButton.x = 48;
			maxAndRestoreButton.y = 10;
			buttonGroup.addElement(maxAndRestoreButton);
			
			closeButton = new RollOverButton();
			closeButton.skinName = MacCloseButtonSkin;
			closeButton.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			closeButton.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
			closeButton.x = 8;
			closeButton.y = 10;
			buttonGroup.addElement(closeButton);
			
			contentGroup = new Group();
			contentGroup.clipAndEnableScrolling = true;
			contentGroup.top = 36;
			contentGroup.left = 1;
			contentGroup.right = 1;
			contentGroup.bottom = 1;
			group.addElement(contentGroup);
			
			leftResize = new Group();
			leftResize.top = 5;
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
			topResize.left = 5;
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
			topLeftResize.height = 5;
			topLeftResize.width = 5;
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
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			maxAndRestoreButton.keepOver = false;
			closeButton.keepOver = false;
			minimizeButton.keepOver = false;
		}
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			maxAndRestoreButton.keepOver = true;
			closeButton.keepOver = true;
			minimizeButton.keepOver = true;
		}
		
		override protected function commitCurrentState():void
		{
//			if(currentState == "maximized" || currentState == "maximizedAndInactive")
//				maxAndRestoreButton.skinName = MacRestoreButtonSkin;
//			else
//				maxAndRestoreButton.skinName = MacMaximizeButtonSkin;
			
			if(currentState == "maximized")
			{
				group.left = 0;
				group.right = 0;
				group.bottom = 0;
				group.top = 0;
			}else if(currentState == "normal")
			{
				group.left = 7;
				group.right = 7;
				group.bottom = 7;
				group.top = 7;
			}
		
		}
	}
}


