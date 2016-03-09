package view.attributesEditer.attributes
{
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.UIAsset;

	public class AttributeBase extends Group
	{
		private var container:Group;
		
		public function AttributeBase(title:String)
		{
			this.percentWidth = 100;
			
			var label:Label = new Label();
			label.textColor = 0xc7c7c7;
			label.text = title;
			this.addElement(label);
			
			var line:UIAsset = new UIAsset("assets/line/attributeLine.png");
			line.y = 10;
			line.left = 55;
			line.right = 5;
			this.addElement(line);
		}
	}
}