package egret.skins.vector
{

	
	import egret.core.ns_egret;
	import egret.components.EditableText;
	import egret.components.Label;
	import egret.skins.VectorSkin;
	
	use namespace ns_egret;
	/**
	 * ComboBox的textInput部件默认皮肤
	 * @author dom
	 */
	public class ComboBoxTextInputSkin extends VectorSkin
	{
		public function ComboBoxTextInputSkin()
		{
			super();
			this.states = ["normal","disabled","normalWithPrompt","disabledWithPrompt"];
		}
		
		public var textDisplay:EditableText;
		/**
		 * [SkinPart]当text属性为空字符串时要显示的文本。
		 */		
		public var promptDisplay:Label;
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			textDisplay = new EditableText();
			textDisplay.widthInChars = 10;
			textDisplay.heightInLines = 1;
			textDisplay.multiline = false;
			textDisplay.left = 1;
			textDisplay.right = 1;
			textDisplay.verticalCenter = 0;
			addElement(textDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			if(currentState=="disabledWithPrompt"||currentState=="normalWithPrompt")
			{
				if(!promptDisplay)
				{
					createPromptDisplay();
				}
				if(!promptDisplay.parent)
					addElement(promptDisplay);
			}
			else if(promptDisplay&&promptDisplay.parent)
			{
				removeElement(promptDisplay);
			}
		}
		
		private function createPromptDisplay():void
		{
			promptDisplay = new Label();
			promptDisplay.maxDisplayedLines = 1;
			promptDisplay.verticalCenter = 0;
			promptDisplay.x = 1;
			promptDisplay.textColor = 0xa9a9a9;
			promptDisplay.mouseChildren = false;
			promptDisplay.mouseEnabled = false;
			if(hostComponent)
				hostComponent.findSkinParts();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateDisplayList(w:Number,h:Number):void
		{
			super.updateDisplayList(w, h);
			
			graphics.clear();
			var radius:Object = {tl:cornerRadius,tr:0,bl:cornerRadius,br:0};
			drawCurrentState(0,0,w,h,borderColors[0],bottomLineColors[0],
				0xFFFFFF,radius);
		}
	}
}