package egret.ui.skins
{
	import flash.geom.Rectangle;
	
	import egret.components.Button;
	import egret.components.DataGroup;
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.PopUpAnchor;
	import egret.components.RectangularDropShadow;
	import egret.components.Scroller;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	import egret.core.PopUpPosition;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.VerticalLayout;
	import egret.ui.components.IconButton;
	
	public class DocDropDownListSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/bg.png")]
		private var uiRes:Class;
		
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/docArrow.png")]
		private var arrow:Class;
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/docArrow_r.png")]
		private var arrow_r:Class;
		
		public function DocDropDownListSkin()
		{
			super();
			this.minHeight = 15;
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
			popUp.bottom = 0;
			popUp.width = 150;
			popUp.popUpPosition = PopUpPosition.BELOW;
			popUp.popUpWidthMatchesAnchorWidth = true;
			popUp.popUp = dropDown;
			addElement(popUp);
			
			openButton = new IconButton();
			openButton.skinName = IconButtonSkin;
			openButton.height = 23;
			openButton.left = 0;
			openButton.right = 0;
			openButton.top = 2;
			openButton.bottom = 2;
			openButton.tabEnabled = false;
			addElement(openButton);
			
			var arrowIcon:UIAsset = new UIAsset();
			arrowIcon.mouseChildren = false;
			arrowIcon.mouseEnabled = false;
			arrowIcon.x =3;
			arrowIcon.verticalCenter = 0;
			arrowIcon.source = new BitmapSource(arrow,arrow_r);
			addElement(arrowIcon);
			
			labelDisplay = new Label();
			labelDisplay.verticalAlign = "middle";
			labelDisplay.textAlign = "center";
			labelDisplay.maxDisplayedLines = 1;
			labelDisplay.mouseEnabled = false;
			labelDisplay.mouseChildren = false;
			labelDisplay.left = 12;
			labelDisplay.right = 1;
			labelDisplay.top = 1;
			labelDisplay.bottom = 1;
			addElement(labelDisplay);
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