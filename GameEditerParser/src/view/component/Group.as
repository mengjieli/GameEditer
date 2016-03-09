package view.component
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import egret.components.Group;
	import egret.components.UIAsset;
	
	import view.component.data.GroupData;
	import view.events.ComponentAttributeEvent;
	import view.events.GroupEvent;

	public class Group extends ComponentBase
	{
		private var bgContainer:egret.components.Group;
		private var container:egret.components.Group;
		
		public function Group(data:GroupData)
		{
			super(data);
			
			bgContainer = new egret.components.Group();
			this.addElement(bgContainer);
			
			container = new egret.components.Group();
			this.addElement(container);
			
			data.addEventListener(GroupEvent.ADD_CHILD,onAddChild);//2f4da421
			data.addEventListener(GroupEvent.REMOVE_CHILD,onRemoveChild);
			data.addEventListener(GroupEvent.SET_CHILD_INDEX,onSetChildIndex);
			
		}
		
		private function onAddChild(e:GroupEvent):void {
			var component:ComponentBase = ComponentParser.getComponentByData(e.child);
			container.addElement(component);
		}
		
		private function onRemoveChild(e:GroupEvent):void {
			for(var i:int = 0; i < this.numElements; i++) {
				var component:ComponentBase = container.getElementAt(i) as ComponentBase;
				if(component.data == e.child) {
					container.removeElementAt(i);
					break;
				}
			}
		}
		
		private function onSetChildIndex(e:GroupEvent):void {
			for(var i:int = 0; i < this.numElements; i++) {
				var component:ComponentBase = container.getElementAt(i) as ComponentBase;
				if(component.data == e.child) {
					container.setElementIndex(component,e.index);
					break;
				}
			}
		}
		
		override public function onPropertyChange(e:ComponentAttributeEvent):void {
			super.onPropertyChange(e);
			switch(e.type) {
			}
		}
		
		override public function dispose():void {
			data.removeEventListener(GroupEvent.ADD_CHILD,onAddChild);
			data.removeEventListener(GroupEvent.REMOVE_CHILD,onRemoveChild);
			data.removeEventListener(GroupEvent.SET_CHILD_INDEX,onSetChildIndex);
			
			super.dispose();
		}
	}
}