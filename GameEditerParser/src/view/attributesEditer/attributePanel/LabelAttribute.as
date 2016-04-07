package view.attributesEditer.attributePanel
{
	import main.data.parsers.ReaderBase;
	
	import view.attributesEditer.attributes.TextAttribute;
	import view.component.data.LabelData;

	public class LabelAttribute extends AttributePanelBase
	{
		public function LabelAttribute(data:LabelData,reader:ReaderBase)
		{
			super(data,reader);
			
			var text:TextAttribute = new TextAttribute(data,reader);
			text.y = startY;
			this.addElement(text);
			startY += text.height + 10;
		}
	}
}