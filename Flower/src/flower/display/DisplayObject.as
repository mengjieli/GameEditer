package flower.display
{
	import flower.events.EventDispatcher;

	public class DisplayObject extends EventDispatcher
	{
		private var _id:int;
		private var _x:Number;
		private var _y:Number;
		private var _width:int;
		private var _height:int;
		private var _alpha:Number;
		private var _visible:Boolean;
		private var _touchEnabled:Boolean;
		private var _parent:DisplayObjectContainer;
		private var _DisplayObject:Object;
		private var _displayFlags:uint;
		private var _stage:Stage;
		private var _nestLevel:uint = 0;
		protected var _show:*;
		private static var showProperty:Object = System.DisplayObject;
		
		public function DisplayObject()
		{
			_id = DisplayObject.id++;
			_displayFlags = 0;
			_DisplayObject = {
				0: 1,                //scaleX,
				1: 1,                //scaleY,
				2: 0,                //skewX,
				3: 0,                //skewY,
				4: 0,                //rotation
				5: ""               //name
//				7: new Matrix()     //matrix
//				7: new Matrix(),     //concatenatedMatrix,
//				8: new Matrix(),     //invertedConcatenatedMatrix,
			};
		}
		///////////////////////////方法/////////////////////////////
		/**
		 * @private
		 * 设置父级显示对象
		 */
		public function $setParent(parent:DisplayObjectContainer):void {
			this._parent = parent;
		}
		
		/**
		 * @private
		 * 显示对象添加到舞台
		 */
		public function $onAddToStage(stage:Stage, nestLevel:Number):void {
			this._stage = stage;
			this._nestLevel = nestLevel;
			Sprite._EVENT_ADD_TO_STAGE_LIST.push(this);
		}
		
		/**
		 * @private
		 * 显示对象从舞台移除
		 */
		public function $onRemoveFromStage():void {
			this._nestLevel = 0;
			Sprite._EVENT_REMOVE_FROM_STAGE_LIST.push(this);
		}
		
		protected function _setScaleX(val:Number):void {
			_DisplayObject[0] = +val||0;
			var p:Object = showProperty.scaleX;
			if(p.func) {
				_show[p.func](_DisplayObject[0]);
			} else {
				_show[p.atr] = _DisplayObject[0];
			}
		}
		
		protected function _setScaleY(val:Number):void {
			_DisplayObject[1] = +val||0;
			var p:Object = showProperty.scaleY;
			if(p.func) {
				_show[p.func](_DisplayObject[1]);
			} else {
				_show[p.atr] = _DisplayObject[1];
			}
		}
		
		protected function _setRoation(val:Number):void {
			_DisplayObject[4] = val;
			var p:Object = showProperty.rotation;
			if(p.func) {
				_show[p.func](_DisplayObject[4]*p.scale);
			} else {
				_show[p.atr] = _DisplayObject[4]*p.scale;
			}
		}
		
		protected function _setWidth(val:Number):void {
			_width = +val||0;
		}
		
		protected function _setHeight(val:Number):void {
			_height = +val||0;
		}
		//////////////////////////属性//////////////////////////////
		public function get id():int {
			return _id;
		}
		
		public function get name():String {
			return this._DisplayObject[5];
		}
		
		public function set name(value:String):void {
			this._DisplayObject[5] = value;
		}
		
		public function get x():Number {
			return _x;
		}
		
		public function set x(val:Number):void {
			if(_x == val) {
				return;
			}
			_x = +val;
			var p:Object = showProperty.x;
			if(p.func) {
				_show[p.func](_x);
			} else {
				_show[p.atr] = _x;
			}
		}
		
		public function get y():Number {
			return _y;
		}
		
		public function set y(val:Number):void {
			if(_y == val) {
				return;
			}
			_y = +val;
			var p:Object = showProperty.y;
			if(p.func) {
				_show[p.func](_y);
			} else {
				_show[p.atr] = _y;
			}
		}
		
		public function get width():int {
			return _width;
		}
		
		public function set width(val:int):void {
			if(_width == val) {
				return;
			}
			_setWidth(val);
		}
		
		public function get height():int {
			return _height;
		}
		
		public function set height(val:int):void {
			if(_height == val) {
				return;
			}
			_setHeight(val);
		}
		
		public function get scaleX():Number {
			return _DisplayObject[0];
		}
		
		public function set scaleX(val:Number):void {
			if(_DisplayObject[4] == val) {
				return;
			}
			_setScaleX(val);
		}
		
		public function get rotation():Number {
			return _DisplayObject[4];
		}
		
		public function set rotation(val:Number):void {
			_setRoation(val);
		}
		
		public function get visible():Boolean {
			return _visible;
		}
		
		public function set visible(val:Boolean):void {
			_visible = !!val;
			var p:Object = showProperty.visible;
			if(p.func) {
				_show[p.func](_visible);
			} else {
				_show[p.atr] = _visible;
			}
		}
		
		public function get parent():DisplayObjectContainer {
			return this._parent;
		}
		
		public function get stage():Stage {
			return this._stage;
		}
		//////////////////////////static//////////////////////////////
		private static var id:uint = 0;
	}
}