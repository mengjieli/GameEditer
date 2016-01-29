package egret.ui.skins
{
	import flash.geom.Rectangle;
	
	import egret.components.Button;
	import egret.components.DataGroup;
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.PopUpAnchor;
	import egret.components.Rect;
	import egret.components.RectangularDropShadow;
	import egret.components.Scroller;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.PopUpPosition;
	import egret.core.ns_egret;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.VerticalLayout;
	
	use namespace ns_egret;
	/**
	 * DropDownList默认皮肤
	 * @author 雷羽佳
	 */
	public class DropDownListSkin extends Skin
	{
		
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/bg.png")]
		private var uiRes:Class;
		
		public function DropDownListSkin()
		{
			super();
			this.minHeight = 23;
			this.states = ["normal","open","disabled"];
		}
		
		public var dataGroup:DataGroup;
		
		public var dropDown:Group;
		
		public var openButton:Button;
		
		public var popUp:PopUpAnchor;
		
		public var scroller:Scroller;
		
		public var labelDisplay:Label;
		
		private var backgroud:UIAsset;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			
			//dataGroup
			dataGroup = new DataGroup();
			var layout:VerticalLayout = new VerticalLayout();
			layout.gap = 0;
			layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
			dataGroup.maxHeight = 400;
			dataGroup.layout = layout;

			if(hostComponent)
				hostComponent.findSkinParts();
			
			//scroller
			scroller = new Scroller();
			scroller.left = scroller.right = scroller.top = scroller.bottom = 1;
			scroller.minViewportInset = 1;
			
			scroller.viewport = dataGroup;

			//dropShadow
			var dropShadow:RectangularDropShadow = new RectangularDropShadow();
			dropShadow.tlRadius=dropShadow.tlRadius=dropShadow.trRadius=dropShadow.blRadius=dropShadow.brRadius = 10;
			dropShadow.blurX = 20;
			dropShadow.blurY = 20;
			dropShadow.alpha = 0.45;
			dropShadow.distance = 7;
			dropShadow.angle = 90;
			dropShadow.color = 0x000000;
			dropShadow.left = 0;
			dropShadow.top = 0;
			dropShadow.right = 0;
			dropShadow.bottom = 0;
			//dropDown
			dropDown = new Group();
			dropDown.addElement(dropShadow);
			
			backgroud = new UIAsset;
			backgroud.left = backgroud.right = backgroud.top = backgroud.bottom = 0;
			backgroud.source = uiRes;
			backgroud.scale9Grid = new Rectangle(2,2,1,1);
			
			dropDown.addElement(backgroud);
			dropDown.addElement(scroller);
			
			//popUp
			popUp = new PopUpAnchor();
			popUp.left = 0;
			popUp.right = 0;
			popUp.top = 0;
			popUp.bottom = 0;
			popUp.popUpPosition = PopUpPosition.BELOW;
			popUp.popUpWidthMatchesAnchorWidth = true;
			popUp.popUp = dropDown;
			addElement(popUp);
			
			openButton = new Button();
			openButton.left = 0;
			openButton.right = 0;
			openButton.top = 0;
			openButton.bottom = 0;
			openButton.tabEnabled = false;
			openButton.skinName = DropDownListButtonSkin;
			addElement(openButton);
			
			labelDisplay = new Label();
			labelDisplay.verticalAlign = "middle";
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.mouseEnabled = false;
			labelDisplay.mouseChildren = false;
			labelDisplay.left = 5;
			labelDisplay.right = 25;
			labelDisplay.top = 1;
			labelDisplay.bottom = 1;
			addElement(labelDisplay);
			
			var hline:Rect = new Rect();
			hline.fillColor = 0x2b353e;
			hline.mouseEnabled = false;
			hline.right = 23;
			hline.width = 1;
			hline.verticalCenter = 0;
			hline.percentHeight = 70;
			this.addElement(hline);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			switch(currentState)
			{
				case "open":
					popUp.displayPopUp = true;
					break;
				case "normal":
					popUp.displayPopUp = false;
					break;
				case "disabled":
					break;
			}
		}
		
	}
}


