package egret.ui.skins
{
	import flash.events.FocusEvent;
	import flash.geom.Rectangle;
	
	import egret.components.Button;
	import egret.components.DataGroup;
	import egret.components.Group;
	import egret.components.PopUpAnchor;
	import egret.components.Rect;
	import egret.components.RectangularDropShadow;
	import egret.components.Scroller;
	import egret.components.UIAsset;
	import egret.components.supportClasses.ItemRenderer;
	import egret.core.PopUpPosition;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.VerticalLayout;
	import egret.skins.VectorSkin;
	import egret.ui.components.TextInput;
	
	/**
	 * ComboBox默认皮肤
	 * @author 雷羽佳
	 */
	public class ComboBoxSkin extends VectorSkin
	{
		
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/bg.png")]
		private var uiRes:Class;
		
		
		public function ComboBoxSkin()
		{
			super();
			this.states = ["normal","open","disabled"];
		}
		
		public var dataGroup:DataGroup;
		
		public var dropDown:Group;
		
		public var popUp:PopUpAnchor;
		
		public var scroller:Scroller;
		
		public var textInput:TextInput;
		
		public var openButton:Button;
		
		public var border:Rect;
		
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
			dataGroup.layout = layout;
			
			//scroller
			scroller = new Scroller();
			scroller.left = scroller.right = scroller.top = scroller.bottom = 1;
			scroller.minViewportInset = 1;
			scroller.viewport = dataGroup;
			//dropShadow
			var dropShadow:RectangularDropShadow = new RectangularDropShadow();
			dropShadow.mouseEnabled = false;
			dropShadow.mouseChildren = false;
			dropShadow.tlRadius=dropShadow.tlRadius=dropShadow.trRadius=dropShadow.blRadius=dropShadow.brRadius = 3;
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
			if(hostComponent)
				hostComponent.findSkinParts();
			dataGroup.maxHeight = 400;
			dataGroup.itemRenderer = ItemRenderer;
			
			textInput = new TextInput();
			textInput.skinName = TextInputSkin;
			textInput.addEventListener(FocusEvent.FOCUS_IN , onFocusIn);
			textInput.addEventListener(FocusEvent.FOCUS_OUT , onFocusOut);
			textInput.left = 0;
			textInput.right = 22;
			textInput.top = 0;
			textInput.bottom = 0;
			addElement(textInput);
			
			openButton = new Button();
			openButton.right = 1;
			openButton.top = 1;
			openButton.bottom = 1;
			openButton.width = 22;
			openButton.skinName = ComboBoxButtonSkin;
			addElement(openButton);
			
			border = new Rect();
			border.strokeAlpha = 1;
			border.fillAlpha = 0;
			border.strokeColor = 0x191e23;
			border.mouseEnabled = false;
			border.left = border.top = 0;
			border.bottom = border.right = 0;
			this.addElement(border);
			
			var hline:Rect = new Rect();
			hline.fillColor = 0x2b353e;
			hline.mouseEnabled = false;
			hline.right = 23;
			hline.width = 1;
			hline.verticalCenter = 0;
			hline.percentHeight = 70;
			this.addElement(hline);
		}
		
		protected function onFocusOut(event:FocusEvent):void
		{
			border.strokeColor = 0x191e23;
		}
		
		protected function onFocusIn(event:FocusEvent):void
		{
			border.strokeColor = 0x65819b;
		}
		
		private var backgroud:UIAsset;
		
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
					if(popUp)
						popUp.displayPopUp = false;
					break;
				case "disabled":
					break;
			}
		}
	}
}


