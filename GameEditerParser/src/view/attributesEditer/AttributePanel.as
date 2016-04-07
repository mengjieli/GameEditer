package view.attributesEditer
{
	import flash.utils.setTimeout;
	
	import egret.components.Group;
	import egret.ui.components.TabPanel;
	
	import main.data.parsers.ReaderBase;
	import main.events.EventMgr;
	
	import view.attributesEditer.attributePanel.GroupAttribute;
	import view.attributesEditer.attributePanel.ImageAttribute;
	import view.attributesEditer.attributePanel.LabelAttribute;
	import view.attributesEditer.attributePanel.PanelAttribute;
	import view.attributesEditer.attributePanel.RootPanelAttribute;
	import view.component.data.ComponentData;
	import view.component.data.ImageData;
	import view.component.data.LabelData;
	import view.events.EditeComponentEvent;

	public class AttributePanel extends TabPanel
	{
		private var container:Group;
		private var readyShowData:ComponentData;
		private var showData:ComponentData;
		private var reader:ReaderBase;
		
		public function AttributePanel(reader:ReaderBase)
		{
			this.reader = reader;
			this.title = "属性";
			this.addElement(container = new Group());
			container.percentWidth = 100;
			container.percentHeight = 100;
			this.percentWidth = 100;
			this.percentHeight = 100;
			
			EventMgr.ist.addEventListener(EditeComponentEvent.EDITE_COMPOENET,onShowComponentAttributes);
			EventMgr.ist.addEventListener(EditeComponentEvent.SHOW_COMPONENT_ATTRIBUTE,onShowComponentAttributes);
		}
		
		private function onShowComponentAttributes(e:EditeComponentEvent):void {
			var data:ComponentData = e.component;
			readyShowData = data;
			setTimeout(this.changeShowData,0);
		}
		
		private function changeShowData():void {
			var data:ComponentData = this.readyShowData;
			if(data == showData) {
				return;
			}
			container.removeAllElements();
			switch(data.type) {
				case "Label":
					container.addElement(new LabelAttribute(data as LabelData,reader));
					break;
				case "Image":
					container.addElement(new ImageAttribute(data as ImageData,reader));
					break;
				case "Group":
					container.addElement(new GroupAttribute(data,reader));
					break;
				case "Panel":
					container.addElement(new PanelAttribute(data,reader));
					break;
				case "RootPanel":
					container.addElement(new RootPanelAttribute(data,reader));
					break;
			}
			showData = data;
		}
	}
}