package view.attributesEditer
{
	import egret.ui.components.TabGroup;
	
	import main.data.parsers.ReaderBase;

	public class ComponentAttributeEditerPanel extends TabGroup
	{
		public function ComponentAttributeEditerPanel(reader:ReaderBase)
		{
			this.addElement(new AttributePanel(reader));
		}
	}
}