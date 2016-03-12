package view.attributesEditer.attributePanel
{
	import view.attributesEditer.attributes.TextAttribute;
	import view.component.data.LabelData;

	public class LabelAttribute extends AttributePanelBase
	{
		public function LabelAttribute(data:LabelData)
		{
			super(data);
			
			var text:TextAttribute = new TextAttribute(data);
			text.y = startY;
			this.addElement(text);
			startY += text.height + 10;
		}
	}
}