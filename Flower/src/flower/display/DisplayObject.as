package flower.display
{
	import flower.events.Event;
	import flower.events.EventDispatcher;
	import flower.geom.Matrix;

	public class DisplayObject extends EventDispatcher
	{
		private var _id:int;
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _width:int = 0;
		protected var _height:int = 0;
		protected var _alpha:Number = 1;
		/**从父类传来的透明度，外部对象无需调用，调用会导致错误**/
		protected var _parentAlpha:Number = 1;
		protected var _visible:Boolean = true;
		protected var _touchEnabled:Boolean = true;
		protected var _mutiplyTouchEnabled:Boolean = true;
		protected var _parent:Sprite;
		protected var _touchX:int = 0;
		protected var _touchY:int = 0;
		protected var _DisplayObject:Object;
		protected var _displayFlags:uint;
		protected var _stage:Stage;
		protected var _nestLevel:uint = 0;
		protected var _show:*;
		protected static var showProperty:Object = System.DisplayObject;
		
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
		public function $setFlag(pos:int,value:Boolean):void {
			if(value) {
				this._displayFlags |= pos;
			} else {
				this._displayFlags &= ~pos;
			}
		}
		
		public function $addFlag(pos:int):void {
			this._displayFlags |= pos;
		}
		
		public function $removeFlag(pos:int):void {
			this._displayFlags &= ~pos;
		}
		
		public function $getFlag(pos:int):Boolean {
			return _displayFlags&pos?true:false;
		}
		
		/**
		 * @private
		 * 设置父级显示对象
		 */
		public function $setParent(parent:Sprite):void {
			var p:DisplayObjectContainer = this._parent;
			this._parent = parent;
			if(parent) {
				this._parent["$nativeShow"].addChild(this._show);
			} else {
				p["$nativeShow"].removeChild(this._show);
			}
		}
		
		/**
		 * @private
		 * 显示对象添加到舞台
		 */
		public function $onAddToStage(stage:Stage, nestLevel:Number):void {
			this._stage = stage;
			this._nestLevel = nestLevel;
//			Sprite._EVENT_ADD_TO_STAGE_LIST.push(this);
		}
		
		/**
		 * @private
		 * 显示对象从舞台移除
		 */
		public function $onRemoveFromStage():void {
			this._stage = null;
			this._nestLevel = 0;
//			Sprite._EVENT_REMOVE_FROM_STAGE_LIST.push(this);
		}
		
		protected function _setX(val:Number):void {
			this._x = val;
			var p:Object = showProperty.x;
			if(p.func) {
				_show[p.func](_x);
			} else {
				_show[p.atr] = _x;
			}
		}
		
		protected function _setY(val:Number):void {
			_y = val;
			var p:Object = showProperty.y;
			if(p.func) {
				_show[p.func](System.receverY?-y:_y);
			} else {
				_show[p.atr] = _y;
			}
		}
		
		protected function _setScaleX(val:Number):void {
			_DisplayObject[0] = val;
			var p:Object = showProperty.scaleX;
			if(p.func) {
				_show[p.func](_DisplayObject[0]);
			} else {
				_show[p.atr] = _DisplayObject[0];
			}
		}
		
		protected function _setScaleY(val:Number):void {
			_DisplayObject[1] = val;
			var p:Object = showProperty.scaleY;
			if(p.func) {
				_show[p.func](_DisplayObject[1]);
			} else {
				_show[p.atr] = _DisplayObject[1];
			}
		}
		
		protected function _setRotation(val:Number):void {
			_DisplayObject[4] = val;
			var p:Object = showProperty.rotation;
			if(p.func) {
				_show[p.func](_DisplayObject[4]*p.scale);
			} else {
				_show[p.atr] = _DisplayObject[4]*p.scale;
			}
		}
		
		protected function _setAlpha(val:Number):void {
			_alpha = val;
			this._alphaChange();
		}
		
		protected function _alphaChange():void {
			var p:Object = showProperty.alpha;
			if(p.func) {
				_show[p.func](_alpha*_parentAlpha*p.scale);
			} else {
				_show[p.atr] = _alpha*_parentAlpha*p.scale;
			}
		}
		
		protected function _setParentAlpha(val:Number):void {
			this._parentAlpha = val;
			this._alphaChange();
		}
		
		protected function _setWidth(val:Number):void {
			_width = val;
		}
		
		protected function _setHeight(val:Number):void {
			_height = val;
		}
		
		public function $isMouseTarget(matrix:Matrix,mutiply:Boolean):Boolean
		{
			if(touchEnabled == false || _visible == false) return false;
			matrix.save();
			matrix.translate(-_x,-_y);
			if(rotation) matrix.rotate(-radian);
			if(scaleX != 1 || scaleY != 1) matrix.scale(1/scaleX,1/scaleY);
			_touchX = matrix.tx;// + _anchorX*_width;
			_touchY = matrix.ty;// + _anchorY*_height;
			if(_touchX >= 0 && _touchY >= 0 && _touchX < _width && _touchY < _height)
			{
				return true;
			}
			matrix.restore();
			return false;
		}
		
		/**
		 * 验证尺寸
		 */
		protected function $getSize():void {
			
		}
		
		/**
		 * 一帧结束，用于验证一些属性
		 */
		public function $onFrameEnd():void {
			
		}
		
		override public function dispatch(event:Event):void {
			super.dispatch(event);
			if(!event.isPropagationStopped && this._parent) {
				this._parent.dispatch(event);
			}
		}
		
		override public function dispose():void {
			if(this.parent) {
				this.parent.removeChild(this);
			}
			super.dispose();
			x = 0;
			y = 0;
			scaleX = 1;
			scaleY = 1;
			alpha = 1;
			visible = true;
			rotation = 0;
			this.$setFlag(1,true);
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
			val = +val||0;
			if(_x == val) {
				return;
			}
			_setX(val);
		}
		
		public function get y():Number {
			return _y;
		}
		
		public function set y(val:Number):void {
			val = +val||0;
			if(_y == val) {
				return;
			}
			_setY(val);
		}
		
		public function get width():int {
			if($getFlag(1)) {
				this.$getSize();
			}
			return _width;
		}
		
		public function set width(val:int):void {
			val = +val&~0;
			if(_width == val) {
				return;
			}
			_setWidth(val);
		}
		
		public function get height():int {
			if($getFlag(1)) {
				this.$getSize();
			}
			return _height;
		}
		
		public function set height(val:int):void {
			val = +val&~0;
			if(_height == val) {
				return;
			}
			_setHeight(val);
		}
		
		public function get scaleX():Number {
			return _DisplayObject[0];
		}
		
		public function set scaleX(val:Number):void {
			val = +val||0;
			if(_DisplayObject[0] == val) {
				return;
			}
			_setScaleX(val);
		}
		
		public function get scaleY():Number {
			return _DisplayObject[1];
		}
		
		public function set scaleY(val:Number):void {
			val = +val||0;
			if(_DisplayObject[1] == val) {
				return;
			}
			_setScaleY(val);
		}
		
		public function get rotation():Number {
			return _DisplayObject[4];
		}
		
		public function set rotation(val:Number):void {
			val = +val||0;
			_setRotation(val);
		}
		
		public function get radian():Number {
			return _DisplayObject[4]*Math.PI/180;
		}
		
		public function get alpha():Number {
			return this._alpha;
		}
		
		public function set alpha(val:Number):void {
			val = +val||0;
			if(val < 0) {
				val = 0;
			}
			if(val > 1) {
				val = 1;
			}
			_setAlpha(val);
		}
		
		public function get $parentAlpha():Number {
			return this._parentAlpha;
		}
		
		public function set $parentAlpha(val:Number):void {
			_setParentAlpha(val);
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
		
		public function get touchEnabled():Boolean {
			return _touchEnabled;
		}
		
		public function set touchEnabled(val:Boolean):void {
			_touchEnabled = !!val;
		}
		
		public function get mutiplyTouchEnabled():Boolean {
			return _mutiplyTouchEnabled;
		}
		
		public function set mutiplyTouchEnabled(val:Boolean):void {
			_mutiplyTouchEnabled = !!val;
		}
		
		public function get touchX():int {
			return _touchX;
		}
		
		public function get touchY():int {
			return _touchY;
		}
		
		public function get parent():DisplayObjectContainer {
			return this._parent;
		}
		
		public function get stage():Stage {
			return this._stage;
		}
		
		public function get disposeFlag():Boolean {
			return this.$getFlag(1);
		}
		
		public function get $nativeShow():*
		{
			return this._show;
		}
		//////////////////////////static//////////////////////////////
		private static var id:uint = 0;
	}
}