package view.component
{
	import egret.components.Label;
	
	import view.component.data.LabelData;
	import view.events.ComponentAttributeEvent;

	public class Label extends ComponentBase
	{
		private var label:egret.components.Label;
		
		
		public function Label(data:LabelData)
		{
			super(data);
			
			label = new egret.components.Label();
			this.selfContainer.addElement(label);
			label.text = data.text;
			label.textColor = data.color;
			label.size = data.size;
			
			this.data.addEventListener("text",onPropertyChange);
		}
		
		override public function onPropertyChange(e:ComponentAttributeEvent):void {
			super.onPropertyChange(e);
			switch(e.type) {
				case "text": label.text = e.value; break;
			}
		}
		
		
	}
}