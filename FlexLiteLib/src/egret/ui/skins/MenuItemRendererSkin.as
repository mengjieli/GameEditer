package egret.ui.skins
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.text.TextFormatAlign;
	
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.layouts.VerticalAlign;
	import egret.utils.callLater;
	
	/** 
	 * 菜单条目默认皮肤
	 * @author xzper
	 */ 
	public class MenuItemRendererSkin extends Skin
	{
		public var labelDisplay:Label;
		public var iconDisplay:UIAsset;
		public var checkDisplay:UIAsset;
		public var radioDisplay:UIAsset;
		public var separatorIcon:UIAsset;
		public var disclosureDisplay:UIAsset;
		
		public function MenuItemRendererSkin()
		{
			super();
			states = ["up","over","down","disabled"];
			this.minHeight = 11;
			this.minWidth = 21;
		}
		
		private var backUI:Rect;
		override protected function createChildren():void
		{
			super.createChildren();
		
			backUI = new Rect();
			backUI.left = backUI.right = backUI.top = backUI.bottom = 2;
			this.addElement(backUI);
			
			labelDisplay = new Label();
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.textAlign = TextFormatAlign.LEFT;
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.left = 30;
			labelDisplay.right = 15;
			labelDisplay.top = 3;
			labelDisplay.bottom = 3;
			this.addElement(labelDisplay);
			
			iconDisplay = new UIAsset();
			iconDisplay.verticalCenter = 0;
			iconDisplay.left = 10;
			this.addElement(iconDisplay);
			
			radioDisplay = new UIAsset();
			radioDisplay.left = 5;
			radioDisplay.verticalCenter = 0;
			radioDisplay.width = 5;
			radioDisplay.height = 5;
			this.addElement(radioDisplay);
			drawRadio();
			
			checkDisplay = new UIAsset();
			checkDisplay.width = 7;
			checkDisplay.height = 7;
			checkDisplay.left = 14;
			checkDisplay.verticalCenter = 0;
			this.addElement(checkDisplay);
			drawCheck();
			
			separatorIcon = new UIAsset();
			separatorIcon.horizontalCenter = 0;
			separatorIcon.verticalCenter = 0;
			separatorIcon.percentWidth = 90;
			separatorIcon.height = 1;
			this.addElement(separatorIcon);
			callLater(drawSeparator);
			
			disclosureDisplay = new UIAsset();
			disclosureDisplay.right = 2;
			disclosureDisplay.verticalCenter = 0;
			disclosureDisplay.width = 6;
			disclosureDisplay.height = 10;
			this.addElement(disclosureDisplay);
			drawArrow();
		}
		
		private function drawRadio():void
		{
			radioDisplay.graphics.clear();
			radioDisplay.graphics.beginFill(0xfefefe , 0.7);
			radioDisplay.graphics.drawEllipse(0,0,radioDisplay.width,radioDisplay.height);
			radioDisplay.graphics.endFill();
		}
		
		private function drawCheck():void
		{
			var commands:Vector.<int> = new <int>[1,2,2,2,2,2,2];
			var coord:Vector.<Number> = new <Number>[0,2,3,4.4,7,0,7,3,3,7,0,4.6,0,2];
			checkDisplay.graphics.clear();
			checkDisplay.graphics.beginFill(0xfefefe);
			checkDisplay.graphics.drawPath(commands,coord);
			checkDisplay.graphics.endFill();
		}
		
		private function drawSeparator():void
		{
			var shape:Shape = new Shape();
			shape.graphics.clear();
			shape.graphics.beginFill(0x434346);
			shape.graphics.drawRect(0,0,1,1);
			shape.graphics.endFill();
			separatorIcon.source = shape;
		}
		
		private function drawArrow():void
		{
			var g:Graphics = disclosureDisplay.graphics;
			g.clear();
			g.beginFill(0xfefefe , 0.5);
			g.moveTo(0 , 0);
			g.lineTo(disclosureDisplay.width , disclosureDisplay.height/2);
			g.lineTo(0 , disclosureDisplay.height);
			g.lineTo(0 , 0);
			g.endFill();
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			labelDisplay.textColor = 0xfefefe;
			backUI.fillAlpha = 1;
			iconDisplay.alpha = 1;
			if(this.currentState == "up")
			{
				backUI.fillAlpha = 0;
			}
			else if(this.currentState == "down" || this.currentState == "over")
			{
				backUI.fillColor = 0x396895;
			}
			else if(this.currentState == "disabled")
			{
				backUI.fillAlpha = 0;
				labelDisplay.textColor = 0x64696d;
				iconDisplay.alpha = 0.4;
			}
		}
	}
}