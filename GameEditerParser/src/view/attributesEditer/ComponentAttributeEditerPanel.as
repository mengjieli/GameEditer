package view.attributesEditer
{
	import egret.ui.components.TabGroup;

	public class ComponentAttributeEditerPanel extends TabGroup
	{
		public function ComponentAttributeEditerPanel()
		{
			this.addElement(new AttributePanel());
		}
	}
}