package main.panels.components
{
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.layouts.VerticalAlign;

	public class DirectionTreeItemSkin extends Skin
	{
		[Embed(source="/assets/bgHover.png")]
		private var uiHoverRes:Class;
		[Embed(source="/assets/bgDown.png")]
		private var uiDownRes:Class;
		
		public function DirectionTreeItemSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
			this.minHeight = 23;
		}
		
		private var backUI:UIAsset;
		
		override protected function commitCurrentState():void
		{
			labelDisplay.alpha = 1;
			switch(currentState)
			{
				case "up":
				{
					backUI.source = "";
					break;
				}
				case "over":
				{
					backUI.source = uiHoverRes;
					break;
				}
				case "down":
				{
					backUI.source = uiDownRes;
					break;
				}
				case "disabled":
				{
					backUI.source = uiDownRes;
					labelDisplay.alpha = 0.2;
					break;
				}	
			}
		}
		
		
		public var labelDisplay:Label;
		public var group:Group;
		public var floader:RectImage;
		public var icon:RectImage;
		public var nameDisplay:Label;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			backUI = new UIAsset()
			backUI.source = "";
			backUI.scale9Grid = new Rectangle(2,2,1,1);
			backUI.left = 0;
			backUI.right = 0;
			backUI.bottom = 0;
			backUI.top = 0;
			this.addElement(backUI);
			
			labelDisplay = new Label();
			labelDisplay.top = labelDisplay.bottom = 1;
			labelDisplay.left = labelDisplay.right = 10;
			labelDisplay.textAlign = TextFormatAlign.CENTER;
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.maxDisplayedLines = 1;
			this.addElement(labelDisplay);
			
			group = new Group();
			this.addElement(group);
			group.left = 0;
			group.right = 0;
			group.percentHeight = 100;
			
			floader = new RectImage(15,20);
//			floader.buttonMode = true;
			floader.left = 5;
			floader.verticalCenter = 0;
			group.addElement(floader);
			
			icon = new RectImage(20,20);
			icon.verticalCenter = 0;
			icon.left = 20;
			group.addElement(icon);
			
			nameDisplay = new Label();
			nameDisplay.x = 40;
			nameDisplay.verticalCenter = 0;
			group.addElement(nameDisplay);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			//			graphics.clear();
			//			var textColor:uint;
			//			switch (currentState)
			//			{			
			//				case "up":
			//				case "disabled":
			//					drawCurrentState(0,0,w,h,borderColors[0],bottomLineColors[0],
			//						[fillColors[0],fillColors[1]],cornerRadius);
			//					textColor = themeColors[0];
			//					break;
			//				case "over":
			//					drawCurrentState(0,0,w,h,borderColors[1],bottomLineColors[1],
			//						[fillColors[2],fillColors[3]],cornerRadius);
			//					textColor = themeColors[1];
			//					break;
			//				case "down":
			//					drawCurrentState(0,0,w,h,borderColors[2],bottomLineColors[2],
			//						[fillColors[4],fillColors[5]],cornerRadius);
			//					textColor = themeColors[1];
			//					break;
			//			}
			//			if(icon)
			//			{
			//				labelDisplay.textColor = textColor;
			//				labelDisplay.applyTextFormatNow();
			//				labelDisplay.filters = (currentState=="over"||currentState=="down")?textOverFilter:null;
			//			}
		}
	}
}