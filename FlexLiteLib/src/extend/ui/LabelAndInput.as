package extend.ui
{
	import egret.components.Group;
	import egret.components.Label;

	public class LabelAndInput extends Group
	{
		private var input:Input;
		
		public function LabelAndInput(labelText:String,inputWidth:int=150,inputX:int=50,inputHeight:int=20)
		{
			this.height = inputHeight;
			
			var label:Label = new Label();
			label.text = "名称:";
			label.x = 5;
			label.y = 5;
			label.text = labelText;
			label.verticalCenter = 0;
			this.addElement(label);
			
			var nameTxt:Input = new Input();
			input = nameTxt;
			nameTxt.border = true;
			nameTxt.backgorund = true;
			nameTxt.width = inputWidth;
			nameTxt.height = inputHeight;
			nameTxt.x = inputX;
			nameTxt.textColor = 5;
			nameTxt.verticalCenter = 0;
			this.addElement(nameTxt);
		}
		
		public function set text(val:String):void {
			input.text = val;
		}
		
		public function get text():String {
			return input.text;
		}
	}
}