package view.component.data
{
	
	import view.component.ComponentParser;
	import view.events.GroupEvent;

	public class GroupData extends ComponentData
	{
		private var _children:Vector.<ComponentData> = new Vector.<ComponentData>();
		
		public function GroupData(type:String = "Group")
		{
			super(type);
			this.width = 480;
			this.height = 320;
		}
		
		public function get numChildren():int {
			return this._children.length;
		}
		
		public function getChildAt(index:int):ComponentData {
			return _children[index];
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
		
		override public function encode():Object {
			var json:Object = super.encode();
			json.children = [];
			for(var i:int = 0; i < _children.length; i++) {
				json.children.push(_children[i].encode());
			}
			return json;
		}
		
		override public function parser(json:Object):void {
			super.parser(json);
			for(var i:int = 0; i < json.children.length; i++) {
				var child:ComponentData = ComponentParser.getComponentDataByConfig(json.children[i]);
				this.addChild(child);
			}
		}
		
		override public function run():void {
			if(this._alginCount) {
				for(var i:int = 0; i < this._children.length; i++) {
					_children[i].resetAlgin();
				}
			}
			super.countAlgin();
			for(var i:int = 0; i < _children.length; i++) {
				_children[i].run();
			}
		}
	}
}