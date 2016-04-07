package view.component.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import view.events.ComponentAttributeEvent;

	public class ComponentData extends EventDispatcher
	{
		private var _type:String;
		private var _x:int = 0;
		private var _y:int = 0;
		private var _width:int = 0;
		private var _height:int = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _name:String = "";
		private var _topAlgin:String = "";
		private var _top:Number = 0;
		private var _bottomAlgin:String = "";
		private var _bottom:Number = 0;
		private var _leftAlgin:String = "";
		private var _left:Number = 0;
		private var _rightAlgin:String = "";
		private var _right:Number = 0;
		private var _percentWidth:Number = -1;
		private var _percentHeight:Number = -1;
		
		//编辑属性，不存储
		private var _sizeSet:Boolean = true;
		protected var _editerFlag:Boolean = true;
		private var _inediter:Boolean = false;
		private var _selected:Boolean = false;
		private var _parent:GroupData;
		protected var _alginCount:Boolean = false;
		
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
			if(_x == val) {
				return;
			}
			_x = val;
			this.dispatchEvent(new ComponentAttributeEvent("x",val));
		}
		
		public function get y():int {
			return _y;
		}
		
		public function set y(val:int):void {
			if(_y == val) {
				return;
			}
			_y = val;
			this.dispatchEvent(new ComponentAttributeEvent("y",val));
		}
		
		public function get width():int {
			return _width;
		}
		
		public function set width(val:int):void {
			if(_width == val) {
				return;
			}
			_width = val;
			this.dispatchEvent(new ComponentAttributeEvent("width",val));
		}
		
		public function get height():int {
			return _height;
		}
		
		public function set height(val:int):void {
			if(_height == val) {
				return;
			}
			this._height = val;
			this.dispatchEvent(new ComponentAttributeEvent("height",val));
		}
		
		public function get scaleX():Number {
			return _scaleX;
		}
		
		public function set scaleX(val:Number):void {
			if(_scaleX == val) {
				return;
			}
			_scaleX = val;
			this.dispatchEvent(new ComponentAttributeEvent("scaleX",val));
		}
		
		public function get scaleY():Number {
			return _scaleY;
		}
		
		public function set scaleY(val:Number):void {
			if(_scaleY == val) {
				return;
			}
			_scaleY = val;
			this.dispatchEvent(new ComponentAttributeEvent("scaleY",val));
		}
		
		public function get sizeSet():Boolean {
			return _sizeSet;
		}
		
		public function set sizeSet(val:Boolean):void {
			if(_sizeSet == val) {
				return;
			}
			_sizeSet = val;
			this.dispatchEvent(new ComponentAttributeEvent("sizeSet",val));
		}
		
		public function get name():String {
			return this._name;
		}
		
		public function set name(val:String):void {
			if(_name == val) {
				return;
			}
			this._name = val;
			this.dispatchEvent(new ComponentAttributeEvent("name",val));
		}
		
		public function get percentWidth():Number {
			return _percentWidth;
		}
		
		public function set percentWidth(val:Number):void {
			if(_percentWidth == val) {
				return;
			}
			_percentWidth = val;
			this.dispatchEvent(new ComponentAttributeEvent("percentWidth",val));
		}
		
		public function get percentHeight():Number {
			return _percentHeight;
		}
		
		public function set percentHeight(val:Number):void {
			if(_percentHeight == val) {
				return;
			}
			_percentHeight = val;
			this.dispatchEvent(new ComponentAttributeEvent("percentHeight",val));
		}
		
		public function get leftAlgin():String {
			return _leftAlgin;
		}
		
		public function set leftAlgin(val:String):void {
			if(_leftAlgin == val) {
				return;
			}
			_leftAlgin = val;
			this.dispatchEvent(new ComponentAttributeEvent("leftAlgin",val));
		}
		
		public function get left():Number {
			return _left;
		}
		
		public function set left(val:Number):void {
			if(_left == val) {
				return;
			}
			_left = val;
			this.dispatchEvent(new ComponentAttributeEvent("left",val));
		}
		
		public function get rightAlgin():String {
			return _rightAlgin;
		}
		
		public function set rightAlgin(val:String):void {
			if(_rightAlgin == val) {
				return;
			}
			_rightAlgin = val;
			this.dispatchEvent(new ComponentAttributeEvent("rightAlgin",val));
		}
		
		public function get right():Number {
			return _right;
		}
		
		public function set right(val:Number):void {
			if(_right == val) {
				return;
			}
			_right = val;
			this.dispatchEvent(new ComponentAttributeEvent("right",val));
		}
		
		public function get topAlgin():String {
			return _topAlgin;
		}
		
		public function set topAlgin(val:String):void {
			if(_topAlgin == val) {
				return;
			}
			_topAlgin = val;
			this.dispatchEvent(new ComponentAttributeEvent("topAlgin",val));
		}
		
		public function get top():Number {
			return _top;
		}
		
		public function set top(val:Number):void {
			if(_top == val) {
				return;
			}
			_top = val;
			this.dispatchEvent(new ComponentAttributeEvent("top",val));
		}
		
		public function get bottomAlgin():String {
			return _bottomAlgin;
		}
		
		public function set bottomAlgin(val:String):void {
			if(_bottomAlgin == val) {
				return;
			}
			_bottomAlgin = val;
			this.dispatchEvent(new ComponentAttributeEvent("bottomAlgin",val));
		}
		
		public function get bottom():Number {
			return _bottom;
		}
		
		public function set bottom(val:Number):void {
			if(_bottom == val) {
				return;
			}
			_bottom = val;
			this.dispatchEvent(new ComponentAttributeEvent("bottom",val));
		}
		
		public function countAlgin():void {
			if(!this.parent) return;
			_alginCount = false;
			if(_percentWidth >= 0) {
				this.width = this.parent.width*_percentWidth/100;
			}
			if(_percentHeight >= 0) {
				this.height = this.parent.height*_percentHeight/100;
			}
			if(_topAlgin != "") {
				if(_topAlgin == "top") {
					this.y = _top;
				} else if(_topAlgin == "bottom") {
					this.y = this.parent.height - _top;
				}
				if(_bottomAlgin != "") {
					if(!(this is ImageData)) {
						this.scaleY = 1;
					}
					if(_bottomAlgin == "top") {
						this.height = bottom - this._y;
					} else if(_bottomAlgin == "bottom") {
						this.height = this.parent.height - bottom - this._y;
					}
				}
			} else {
				if(_bottomAlgin != "") {
					if(_bottomAlgin == "top") {
						this.y = _bottom - this._height*this.scaleY;
					} else if(_bottomAlgin == "bottom") {
						this.y = this.parent.height - _bottom - this._height*this.scaleY;
					}
				}
			}
			if(_leftAlgin != "") {
				if(_leftAlgin == "left") {
					this.x = _left;
				} else if(_leftAlgin == "right") {
					this.x = this.parent.width - _left;
				}
				if(_rightAlgin != "") {
					if(!(this is ImageData)) {
						this.scaleX = 1;
					}
					if(_rightAlgin == "left") {
						this.width = _right - this._x;
					} else if(_rightAlgin == "right") {
						this.width = this.parent.width - _right - this._x;
					}
				}
			} else {
				if(_rightAlgin != "") {
					if(_rightAlgin == "left") {
						this.x = _right - this._width*this.scaleX;
					} else if(_rightAlgin == "right") {
						this.x = this.parent.width - _right - this._width*this.scaleX;
					}
				}
			}
		}
		
		public function resetAlgin():void {
			_alginCount = true;
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
		
		public function get inediter():Boolean {
			return _inediter;
		}
		
		public function set inediter(val:Boolean):void {
			_inediter = val;
			this.dispatchEvent(new ComponentAttributeEvent("inediter",val));
		}
	
		public function $setParent(val:GroupData):void {
			_parent = val;
			this.dispatchEvent(new ComponentAttributeEvent("parent",val));
		}
		
		public function get parent():GroupData {
			return _parent;
		}
		
		public function encode():Object {
			var json:Object = {"type":type};
			json.name = name;
			if(x && (leftAlgin == "" || rightAlgin == "")) json.x = x;
			if(y && (topAlgin == "" || bottomAlgin == "")) json.y = y;
			if(width) json.width = width;
			if(height) json.height = height;
			if(scaleX != 1 && (leftAlgin == "" || rightAlgin == "")) json.scaleX = scaleX;
			if(scaleY != 1 && (topAlgin == "" || bottomAlgin == "")) json.scaleY = scaleY;
			if(percentWidth >= 0 && (leftAlgin == "" || rightAlgin == "")) json.percentWidth = percentWidth;
			if(percentHeight >= 0 && (topAlgin == "" || bottomAlgin == "")) json.percentHeight = percentHeight;
			if(topAlgin != "") {
				json.topAlgin = topAlgin;
				json.top = top;
			}
			if(bottomAlgin != "") {
				json.bottomAlgin = bottomAlgin;
				json.bottom = bottom;
			}
			if(leftAlgin != "") {
				json.leftAlgin = leftAlgin;
				json.left = left;
			}
			if(rightAlgin != "") {
				json.rightAlgin = rightAlgin;
				json.right = right;
			}
			return json;
		}
		
		public function parser(json:Object):void {
			this.name = json.name||"";
			this.x = json.x||0;
			this.y = json.y||0;
			this.width = json.width||0;
			this.height = json.height||0;
			this.scaleX = json.scaleX==null?1:json.scaleX;
			this.scaleY = json.scaleY==null?1:json.scaleY;
			this.percentWidth = json.percentWidth==null?-1:json.percentWidth;
			this.percentHeight = json.percentHeight==null?-1:json.percentHeight;
			this.topAlgin = json.topAlgin||"";
			this.top = json.top||0;
			this.bottomAlgin = json.bottomAlgin||"";
			this.bottom = json.bottom||0;
			this.leftAlgin = json.leftAlgin||"";
			this.left = json.left||0;
			this.rightAlgin = json.rightAlgin||"";
			this.right = json.right||0;
		}
		
		public function run():void {
			if(this._alginCount) {
				this.countAlgin();
			}
		}
		
		override public function dispatchEvent(event:Event):Boolean {
			var bool:Boolean = super.dispatchEvent(event);
			if(this.parent) {
				this.parent.dispatchEvent(new ComponentAttributeEvent(ComponentAttributeEvent.CHILD_ATTRIBUTE_CHANGE,null));
			} else {
				if(event.type != ComponentAttributeEvent.CHILD_ATTRIBUTE_CHANGE) {
					this.dispatchEvent(new ComponentAttributeEvent(ComponentAttributeEvent.CHILD_ATTRIBUTE_CHANGE,null));
				}
			}
			if(event.type == "x" || event.type == "y" || event.type == "scaleX" || event.type == "scaleY" ||
				event.type == "left" || event.type == "right" || event.type == "top" || event.type == "bottom" || 
				event.type == "width" || event.type == "height" || event.type == "percentWidth" || event.type == "percentHeight" ||
				event.type == "leftAlgin" || event.type == "rightAlgin" || event.type == "topAlgin" || event.type == "bottomAlgin") {
				this.resetAlgin();
			}
			return bool;
		}
	}
}