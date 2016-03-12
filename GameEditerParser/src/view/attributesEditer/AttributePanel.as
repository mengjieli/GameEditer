package view.attributesEditer
{
	import egret.components.Group;
	import egret.ui.components.TabPanel;
	
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
		
		public function AttributePanel()
		{
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
			container.removeAllElements();
			var data:ComponentData = e.component;
			switch(data.type) {
				case "Label":
					container.addElement(new LabelAttribute(data as LabelData));
					break;
				case "Image":
					container.addElement(new ImageAttribute(data as ImageData));
					break;
				case "Group":
					container.addElement(new GroupAttribute(data));
					break;
				case "Panel":
					container.addElement(new PanelAttribute(data));
					break;
				case "RootPanel":
					container.addElement(new RootPanelAttribute(data));
					break;
			}
		}
	}
}