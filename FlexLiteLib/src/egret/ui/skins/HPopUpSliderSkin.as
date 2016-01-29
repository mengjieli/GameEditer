package egret.ui.skins
{
	import egret.components.Button;
	import egret.components.Group;
	import egret.components.PopUpAnchor;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.components.SkinnableComponent;
	import egret.core.PopUpPosition;
	import egret.ui.components.TextInput;
	
	public class HPopUpSliderSkin extends Skin
	{
		public function HPopUpSliderSkin()
		{
			super();
			this.minWidth = 50;
			this.states = ["normal","open","disabled"];
		}
		
		public var thumb:Button;
		public var track:Button;
		public var trackHighlight:SkinnableComponent;
		
		public var textInput:TextInput;
		public var openButton:Button;
		public var dropDown:Group;
		public var popUp:PopUpAnchor;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			textInput = new TextInput();
			textInput.width = 50;
			textInput.skinName = TextInputSkin;
			textInput.left = 0;
			textInput.right = 12;
			textInput.top = 0;
			textInput.bottom = 0;
			addElement(textInput);
			
			openButton = new Button();
			openButton.width = 12;
			openButton.right = 0;
			openButton.top = 0;
			openButton.bottom = 0;
			openButton.skinName = ComboBoxButtonSkin;
			addElement(openButton);
			
			dropDown = new Group();
			dropDown.width = 100;
			dropDown.height = 22;
			
			var back:Rect = new Rect();
			back.percentHeight = back.percentWidth = 100;
			back.strokeColor = 0x3c4853;
			back.strokeWeight = 1;
			back.strokeAlpha = 1;
			back.fillColor = 0x384552;
			dropDown.addElement(back);
			
			var trackRect:Rect = new Rect();
			trackRect.radius = 1;
			trackRect.height = 4;
			trackRect.fillColor = 0x1e2329;
			
			track = new Button();
			track.x = 9;
			track.left = 9;
			track.right = 9;
			track.verticalCenter = 0;
			track.minWidth = 33;
			track.tabEnabled = false;
			track.skinName = trackRect;
			dropDown.addElement(track);
			
			var highLightRect:Rect = new Rect();
			highLightRect.radius = 1;
			highLightRect.height = 4;
			highLightRect.fillColor = 0x00a0f0;
			
			trackHighlight = new SkinnableComponent();
			track.x = 9;
			track.right = 9;
			trackHighlight.verticalCenter = 0;
			trackHighlight.minWidth = 33;
			trackHighlight.width = 100;
			trackHighlight.tabEnabled = false;
			trackHighlight.skinName = highLightRect;
			dropDown.addElement(trackHighlight);
			
			thumb = new Button();
			thumb.buttonMode = true;
			thumb.verticalCenter = 0;
			thumb.width = 10;
			thumb.height = 10;
			thumb.tabEnabled = false;
			thumb.skinName = SliderThumbSkin;
			dropDown.addElement(thumb);
			
			popUp = new PopUpAnchor();
			popUp.left = 0;
			popUp.right = 0;
			popUp.top = 0;
			popUp.bottom = -1;
			popUp.popUpPosition = PopUpPosition.BELOW;
			popUp.popUp = dropDown;
			this.addElement(popUp);
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