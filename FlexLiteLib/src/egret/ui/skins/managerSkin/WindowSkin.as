package egret.ui.skins.managerSkin
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import egret.components.Button;
	import egret.components.Group;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.layouts.HorizontalLayout;
	import egret.ui.components.RollOverButton;
	import egret.ui.skins.macAppButton.MacCloseButtonSkin;
	import egret.ui.skins.macAppButton.MacMaximizeButtonSkin;
	import egret.ui.skins.macAppButton.MacMinimizeButtonSkin;
	import egret.utils.SystemInfo;
	
	public class WindowSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/manager/back.png")]
		private var backRes:Class;
		
		public function WindowSkin()
		{
			super();
			this.states = ["normal","maximized","minimized","disabled","normalAndInactive","maximizedAndInactive"];
		}
		
		public var moveArea:Group;
		public var minimizeButton:Button;
		public var maxAndRestoreButton:RollOverButton;
		public var closeButton:Button;
		public var contentGroup:Group;
		
		public var modalMask:UIAsset;
		public var shadow:UIAsset;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			var backUI:UIAsset = new UIAsset();
			backUI.source = backRes;
			backUI.scale9Grid = new Rectangle(9,9,22,22);
			backUI.left = 0;
			backUI.right = 0;
			backUI.top = 0;
			backUI.bottom = 0;
			this.addElement(backUI);
			
			var group:Group = new Group();
			this.addElement(group);
			group.left = 9;
			group.right = 9;
			group.bottom = 9;
			group.top = 9;
			
			moveArea = new Group();
			group.addElement(moveArea);
			moveArea.top = 0;
			moveArea.left = 0;
			moveArea.right = 0;
			moveArea.bottom = 0;
			
			contentGroup = new Group();
			contentGroup.mouseEnabled = false;
			contentGroup.clipAndEnableScrolling = true;
			contentGroup.top = 0;
			contentGroup.left = 0;
			contentGroup.right = 0;
			contentGroup.bottom = 0;
			group.addElement(contentGroup);
			
			var buttonGroup:Group = new Group();
			group.addElement(buttonGroup);
			if(SystemInfo.isMacOS)
			{
				buttonGroup.x = 7;
				minimizeButton = new RollOverButton();
				minimizeButton.skinName = MacMinimizeButtonSkin;
				minimizeButton.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
				minimizeButton.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
				minimizeButton.x = 34;
				minimizeButton.y = 14;
				buttonGroup.addElement(minimizeButton);
				
				maxAndRestoreButton = new RollOverButton();
				maxAndRestoreButton.skinName = MacMaximizeButtonSkin;
				maxAndRestoreButton.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
				maxAndRestoreButton.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
				maxAndRestoreButton.x = 54;
				maxAndRestoreButton.y = 14;
				maxAndRestoreButton.enabled = false;
				buttonGroup.addElement(maxAndRestoreButton);
				
				closeButton = new RollOverButton();
				closeButton.skinName = MacCloseButtonSkin;
				closeButton.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
				closeButton.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
				closeButton.x = 14;
				closeButton.y = 14;
				buttonGroup.addElement(closeButton);
			}
			else
			{
				buttonGroup.top = 12;
				buttonGroup.right = 12;
				var buttonLayout:HorizontalLayout = new HorizontalLayout();
				buttonLayout.gap = 8;
				buttonGroup.layout = buttonLayout;
				
				minimizeButton = new Button();
				minimizeButton.skinName = MinButtonSkin;
				
				closeButton = new Button();
				closeButton.skinName = CloseButtonSkin;
				buttonGroup.addElement(minimizeButton);
				buttonGroup.addElement(closeButton);
			}
			
			modalMask = new UIAsset();
			modalMask.visible = false;
			this.addElement(modalMask);
			
			shadow = new UIAsset();
			shadow.visible = false;
			this.addElement(shadow);
		}
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			RollOverButton(closeButton).keepOver = false;
			RollOverButton(minimizeButton).keepOver = false;
		}
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			RollOverButton(closeButton).keepOver = true;
			RollOverButton(minimizeButton).keepOver = true;
		}
	}
}