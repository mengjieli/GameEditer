package view.component
{
	
	import view.component.data.GroupData;
	import view.events.ComponentAttributeEvent;
	import view.events.GroupEvent;

	public class Group extends ComponentBase
	{
		
		public function Group(data:GroupData)
		{
			super(data);
			
			this.numChildren
			for(var i:int = 0; i < data.numChildren; i++) {
				var component:ComponentBase = ComponentParser.getComponentByData(data.getChildAt(i));
				childContainer.addElement(component);
			}
			
			data.addEventListener(GroupEvent.ADD_CHILD,onAddChild);//2f4da421
			data.addEventListener(GroupEvent.REMOVE_CHILD,onRemoveChild);
			data.addEventListener(GroupEvent.SET_CHILD_INDEX,onSetChildIndex);
			
		}
		
		private function onAddChild(e:GroupEvent):void {
			var component:ComponentBase = ComponentParser.getComponentByData(e.child);
			childContainer.addElement(component);
		}
		
		private function onRemoveChild(e:GroupEvent):void {
			for(var i:int = 0; i < this.numElements; i++) {
				var component:ComponentBase = childContainer.getElementAt(i) as ComponentBase;
				if(component.data == e.child) {
					childContainer.removeElementAt(i);
					break;
				}
			}
		}
		
		private function onSetChildIndex(e:GroupEvent):void {
			for(var i:int = 0; i < this.numElements; i++) {
				var component:ComponentBase = childContainer.getElementAt(i) as ComponentBase;
				if(component.data == e.child) {
					childContainer.setElementIndex(component,e.index);
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