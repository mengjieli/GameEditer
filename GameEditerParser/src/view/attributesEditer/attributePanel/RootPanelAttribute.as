package view.attributesEditer.attributePanel
{
	import main.data.parsers.ReaderBase;
	
	import view.component.data.ComponentData;

	public class RootPanelAttribute extends AttributePanelBase
	{
		public function RootPanelAttribute(data:ComponentData,reader:ReaderBase)
		{
			super(data,reader,false);
		}
		
		override public function set x(value:Number):void {
			
		}
		
		override public function set y(value:Number):void {
			
		}
	}
}