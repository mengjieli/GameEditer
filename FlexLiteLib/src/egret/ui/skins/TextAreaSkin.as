package egret.ui.skins
{
	import egret.components.Scroller;
	import egret.components.Skin;
	import egret.core.ScrollPolicy;
	import egret.ui.components.FTEEditableText;
	
	
	/**
	 * TextArea默认皮肤
	 * @author dom
	 */
	public class TextAreaSkin extends Skin
	{
		public function TextAreaSkin()
		{
			super();
			this.states = ["normal","disabled","normalWithPrompt","disabledWithPrompt"];
		}
		
		public var scroller:Scroller;
		
		public var textDisplay:FTEEditableText;

		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			textDisplay = new FTEEditableText();
			textDisplay.widthInChars = 15;
			textDisplay.heightInLines = 10;
			
			scroller = new Scroller();
			scroller.left = 0;
			scroller.top = 0;
			scroller.right = 0;
			scroller.bottom = 0;
			scroller.minViewportInset = 1;
			scroller.viewport = textDisplay;
			scroller.horizontalScrollPolicy = ScrollPolicy.OFF;
			addElement(scroller);
			
		}
	}
}