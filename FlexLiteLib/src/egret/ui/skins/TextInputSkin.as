package egret.ui.skins
{
	import flash.geom.Rectangle;
	
	import egret.components.Label;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.IEditableText;
	import egret.ui.components.FTEEditableText;
	
	/**
	 * 文本输入框的皮肤
	 * @author 雷羽佳
	 */
	public class TextInputSkin extends Skin
	{
		
		[Embed(source="/egret/ui/skins/assets/textInput/unSelect.png")]
		private var unSelectRes:Class;
		[Embed(source="/egret/ui/skins/assets/textInput/select.png")]
		private var selectRes:Class;
		
		
		
		public function TextInputSkin()
		{
			super();
			this.states = ["normal","disabled","normalWithPrompt","disabledWithPrompt"];
			this.minHeight = 23;
		}
		
		public var bgUnselect:UIAsset;
		public var bgSelect:UIAsset;
		public var textDisplay:IEditableText;
		public var promptDisplay:Label;
		
		override protected function createChildren():void
		{
			super.createChildren();
			bgUnselect = new UIAsset();
			bgUnselect.left = bgUnselect.right = bgUnselect.top = bgUnselect.bottom = 0;
			bgUnselect.scale9Grid = new Rectangle(2,2,1,1);
			bgUnselect.source = unSelectRes;
			this.addElement(bgUnselect);
			
			bgSelect = new UIAsset();
			bgSelect.left = bgSelect.right = bgSelect.top = bgSelect.bottom = 0;
			bgSelect.scale9Grid = new Rectangle(2,2,1,1);
			bgSelect.visible = false;
			bgSelect.source = selectRes;
			this.addElement(bgSelect);
			
			textDisplay = new FTEEditableText();
			this.addElement(textDisplay);
			textDisplay.widthInChars = 10;
			textDisplay.multiline = false;
			textDisplay.left = 3;
			textDisplay.right = 3;
			textDisplay.verticalCenter = 0;
			addElement(textDisplay);
			
			promptDisplay = new Label();
			promptDisplay.textColor = 0x64696D;
			promptDisplay.maxDisplayedLines = 1;
			promptDisplay.left = 1;
			promptDisplay.right = 4;
			promptDisplay.verticalCenter = 0;
			promptDisplay.verticalAlign = "middle";
			promptDisplay.mouseEnabled = false;
			promptDisplay.mouseChildren = false;
			this.addElement(promptDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			switch(currentState)
			{
				case "normal":
				{
					promptDisplay.visible = false;
					break;
				}
				case "disabled":
				{
					promptDisplay.visible = false;
					break;
				}
				case "normalWithPrompt":
				{
					promptDisplay.visible = true;
					break;
				}
				case "disabledWithPrompt":
				{
					promptDisplay.visible = true;
					break;
				}
				default:
				{
					break;
				}
			}
		}
	}
}