package view.component.data
{
	import flash.events.EventDispatcher;
	
	import view.events.ComponentAttributeEvent;

	public class ComponentData extends EventDispatcher
	{
		private var _type:String;
		private var _x:int = 0;
		private var _y:int = 0;
		private var _width:int = 0;
		private var _height:int = 0;
		private var _name:String = "";
		
		//编辑属性，不存储
		private var _editerFlag:Boolean = true;
		private var _selected:Boolean = false;
		private var _parent:GroupData;
		
		public function ComponentData(type:String)
		{
			this._type = type;
		}
		
		public function get type():String {
			return _type;
		}
		
		public function get x():int {
			return _x;
		}
		
		public function set x(val:int):void {
			_x = val;
			this.dispatchEvent(new ComponentAttributeEvent("x",val));
		}
		
		public function get y():int {
			return _y;
		}
		
		public function set y(val:int):void {
			_y = val;
			this.dispatchEvent(new ComponentAttributeEvent("y",val));
		}
		
		public function get width():int {
			return _width;
		}
		
		public function set width(val:int):void {
			_width = val;
			this.dispatchEvent(new ComponentAttributeEvent("width",val));
		}
		
		public function get height():int {
			return _height;
		}
		
		public function set height(val:int):void {
			this._height = val;
			this.dispatchEvent(new ComponentAttributeEvent("height",val));
		}
		
		public function get name():String {
			return this._name;
		}
		
		public function set name(val:String):void {
			this._name = val;
			this.dispatchEvent(new ComponentAttributeEvent("name",val));
		}
		
		public function get editerFlag():Boolean {
			return this._editerFlag;
		}
		
		public function set editerFlag(val:Boolean):void {
			this._editerFlag = val;
			this.dispatchEvent(new ComponentAttributeEvent("editerFlag",val));
		}
		
		public function get selected():Boolean {
			return this._selected;
		}
		
		public function set selected(val:Boolean):void {
			this._selected = val;
			this.dispatchEvent(new ComponentAttributeEvent("selected",val));
		}
		
		public function $setParent(val:GroupData):void {
			_parent = val;
			this.dispatchEvent(new ComponentAttributeEvent("parent",val));
		}
		
		public function get parent():GroupData {
			return _parent;
		}
		
		public function parser(json:Object):void {
			
		}
	}
}