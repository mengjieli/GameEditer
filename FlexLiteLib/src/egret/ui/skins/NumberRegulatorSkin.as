package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Skin;
	import egret.layouts.VerticalAlign;
	import egret.ui.components.TextInput;
	
	/**
	 * 数字调节组件的皮肤
	 */
	public class NumberRegulatorSkin extends Skin
	{
		public function NumberRegulatorSkin()
		{
			super();
			this.minWidth = this.minHeight = 12;
			this.height = 23;
			this.states = ["normal" , "prompt", "edit" , "disabled"];
		}
		
		/**
		 * [SkinPart]文本输入控件
		 */
		public var editableText:TextInput;
		
		/**
		 * [SkinPart]文本显示控件
		 */
		public var labelDisplay:Label;
		
		private var rect:Rect;
		private var inputGroup:Group;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			rect = new Rect();
			rect.fillColor = 0x1e2329;
			rect.strokeAlpha = 1;
			rect.strokeWeight = 1;
			rect.strokeColor = 0x191e23;
			rect.right = rect.bottom = 1;
			rect.top = rect.left = 0;
			this.addElement(rect);
			
			inputGroup = new Group();
			inputGroup.percentWidth = inputGroup.percentHeight = 100;
			this.addElement(inputGroup);
			
			editableText = new TextInput();
			editableText.restrict = "0-9\.\\-";
			editableText.verticalCenter = 0;
			editableText.percentWidth = editableText.percentHeight = 100;
			inputGroup.addElement(editableText);
			
			labelDisplay = new Label();
			labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
			labelDisplay.percentHeight = labelDisplay.percentWidth = 100;
			this.addElement(labelDisplay);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			labelDisplay.textColor = 0xfefefe;
			if(currentState == "edit")
			{
				inputGroup.visible = true;
				labelDisplay.visible = false;
			}
			else if(currentState == "prompt")
			{
				inputGroup.visible = false;
				labelDisplay.visible = true;
				labelDisplay.textColor = 0x64696d;
			}
			else
			{
				inputGroup.visible = false;
				labelDisplay.visible = true;
			}
		}
	}
}