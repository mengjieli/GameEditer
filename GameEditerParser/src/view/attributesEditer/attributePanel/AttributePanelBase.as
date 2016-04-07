package view.attributesEditer.attributePanel
{
	import egret.components.Group;
	
	import main.data.parsers.ReaderBase;
	
	import view.attributesEditer.attributes.BaseAttribute;
	import view.attributesEditer.attributes.PositionAttribute;
	import view.component.data.ComponentData;

	public class AttributePanelBase extends Group
	{
		protected var startY:int;
		protected var data:ComponentData;
		
		public function AttributePanelBase(data:ComponentData,reader:ReaderBase,showAlgin:Boolean=true)
		{
			this.data = data;
			this.percentWidth = 100;
			this.percentHeight = 100;
			
			var base:BaseAttribute = new BaseAttribute(data,reader);
			this.addElement(base);
			startY = base.height + 10;
			
			var position:PositionAttribute = new PositionAttribute(data,reader,showAlgin);
			position.y = startY;
			this.addElement(position);
			startY += position.height + 10;
		}
	}
}