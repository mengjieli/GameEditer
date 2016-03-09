package view.component
{
	import egret.components.Label;
	
	import view.component.data.LabelData;

	public class Label extends ComponentBase
	{
		private var label:egret.components.Label;
		
		
		public function Label(data:LabelData)
		{
			super(data);
			
			label = new egret.components.Label();
			this.addElement(label);
			label.text = data.text;
			label.textColor = data.color;
			label.size = data.size;
		}
	}
}