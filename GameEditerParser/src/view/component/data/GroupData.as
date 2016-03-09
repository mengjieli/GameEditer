package view.component.data
{
	import view.events.GroupEvent;

	public class GroupData extends ComponentData
	{
		private var _children:Vector.<ComponentData> = new Vector.<ComponentData>();
		
		public function GroupData(type:String = "Group")
		{
			super(type);
			this.width = 500;
			this.height = 400;
		}
		
		public function addChild(component:ComponentData):void {
			var index:int = this.getChildIndex(component);
			if(index >= 0) {
				setChildIndex(component,_children.length-1);
			} else {
				_children.push(component);
				component.$setParent(this);
				this.dispatchEvent(new GroupEvent(GroupEvent.ADD_CHILD,component,_children.length-1));
			}
		}
		
		public function removeChild(component:ComponentData):void {
			var index:int = this.getChildIndex(component);
			if(index >= 0) {
				_children.splice(index,1);
				component.$setParent(null);
				this.dispatchEvent(new GroupEvent(GroupEvent.REMOVE_CHILD,component,index));
			}
		}
		
		public function setChildIndex(component:ComponentData,childIndex:uint):void {
			var index:int = this.getChildIndex(component);
			if(index >= 0) {
				_children.splice(index,1);
				_children.splice(childIndex,0,component);
				this.dispatchEvent(new GroupEvent(GroupEvent.SET_CHILD_INDEX,component,_children.length-1));
			}
		}
		
		public function getChildIndex(component:ComponentData):int {
			for(var i:int = 0; i < _children.length; i++) {
				if(_children[i] == component) {
					return i;
				}
			}
			return -1;
		}
	}
}