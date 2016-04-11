package flower.ui
{
	import flower.Engine;
	import flower.binding.Binding;
	import flower.binding.compiler.Compiler;
	import flower.binding.compiler.structs.Stmts;
	import flower.data.DataManager;
	import flower.data.member.StringValue;
	import flower.debug.DebugInfo;
	import flower.display.Bitmap;
	import flower.events.Event;
	import flower.net.URLLoader;
	import flower.texture.Texture2D;
	import flower.tween.Ease;
	import flower.tween.Tween;
	import flower.utils.Formula;

	public class Image extends Bitmap
	{
		private var _loader:URLLoader;
		private var _source:*;
		
		public function Image(source:*=null)
		{
			super();
			if(source) {
				this.setSource(source);
			}
			_nativeClass = "UI";
			this.addUIEvents();
		}
		
		private function setSource(val:*):void {
			if(_loader) {
				_loader.dispose();
				_loader = null;
			}
			if(val is Texture2D) {
				this.texture = val;
			} else {
				_loader = new URLLoader(val);
				_loader.load();
				_loader.addListener(Event.COMPLETE,onLoadTextureComplete,this);
			}
		}
		
		override protected function _setTexture(val:Texture2D):void {
			super._setTexture(val);
			this.$addFlag(10);
		}
		
		override public function dispose():void {
			for(var key:String in _binds) {
				_binds[key].dispose();
			}
			_binds = null;
			super.dispose();
		}
		
		/////////////////////////////////////set && get/////////////////////////////////////
		public function set src(val:*):void {
			if(_source == val) {
				return;
			}
			_source = val;
			setSource(val);
		}
		
		public function get src():* {
			return _source;
		}
		
		private function onLoadTextureComplete(e:Event):void {
			this.texture = e.data;
		}
		
		/////////////////////////////////////////Component/////////////////////////////////////////
		//////////////////////bingding event
		protected function addUIEvents():void {
			this.addListener(Event.ADDED,this.onEXEAdded,this);
		}
		
		private var onAddedEXE:Function;
		public function set onAdded(val:Function):void {
			onAddedEXE = val;
		}
		
		public function get onAdded():Function {
			return onAddedEXE;
		}
		
		private function onEXEAdded(e:Event):void {
			if(onAddedEXE && e.target == this) {
				onAddedEXE.call(this);
			}
		}
		
		//////////////////////bingdings
		private var _binds:Object = {};
		
		public function bindProperty(property:String,content:String):void {
			if(_binds[property]) {
				_binds[property].dispose();
			}
			_binds[property] = new Binding(this,[this,DataManager.ist,Formula,Engine.global],property,content);
		}
		
		public function removeBindProperty(property:String):void {
			if(_binds[property]) {
				_binds[property].dispose();
				delete _binds[property];
			}
		}
		
		//////////////////////state
		public var $state:StringValue = new StringValue();
		public function get currentState():String {
			return $state.value;
		}
		
		public function set currentState(val:String):void {
			if($state.value == val) {
				return;
			}
			$state.value = val;
		}
		
		private var _propertyValues:Object;
		public function setStatePropertyValue(property:String,state:String,val:String):void {
			if(!_propertyValues) {
				_propertyValues = {};
				if(!_propertyValues[property]) {
					_propertyValues[property] = {};
				}
				this.bindProperty("currentState","{this.changeState($state)}");
				_propertyValues[property][state] = val;
			} else {
				if(!_propertyValues[property]) {
					_propertyValues[property] = {};
				}
				_propertyValues[property][state] = val;
			}
			if(state == currentState) {
				this.removeBindProperty(property);
				this.bindProperty(property,val);
			}
		}
		
		public function changeState(state:String):String {
			if(!_propertyValues) {
				return currentState;
			}
			for(var property:String in _propertyValues) {
				if(_propertyValues[property][state]) {
					this.removeBindProperty(property);
					this.bindProperty(property,_propertyValues[property][state]);
				}
			}
			return currentState;
		}
		//////////////////////layout
		/**顶端对齐方式，可选 top bottom 或者 空字符串**/
		private var _topAlgin:String = "";
		private var _bottomAlgin:String = "";
		/**左端对齐方式，可选 left right 或者 空字符串**/
		private var _leftAlgin:String = "";
		private var _rightAlgin:String = "";
		private var _top:Number = 0;
		private var _bottom:Number = 0;
		private var _left:Number = 0;
		private var _right:Number = 0;
		//占据父类尺寸，如果同时设置了 top 和 bottom 则以 top 和 bottom 为准
		private var _percentWidth:Number = -1;
		private var _percentHeight:Number = -1;
		
		public function get topAlgin():String {
			return _topAlgin;
		}
		
		public function set topAlgin(val:String):void {
			if(Engine.DEBUG) {
				if(val != "" && val != "top" && val != "bottom") {
					DebugInfo.debug("非法的 topAlgin 值:" + val + "，只能为 \"\" 或 \"top\" 或 \"bottom\"",DebugInfo.ERROR);
				}
			}
			_topAlgin = val;
			this.$addFlag(10);
		}
		
		public function get top():Number {
			return _top;
		}
		
		public function set top(val:Number):void {
			_top = +val||0;
			this.$addFlag(10);
		}
		
		public function get bottomAlgin():String {
			return _bottomAlgin;
		}
		
		public function set bottomAlgin(val:String):void {
			if(Engine.DEBUG) {
				if(val != "" && val != "top" && val != "bottom") {
					DebugInfo.debug("非法的 bottomAlgin 值:" + val + "，只能为 \"\" 或 \"top\" 或 \"bottom\"",DebugInfo.ERROR);
				}
			}
			_bottomAlgin = val;
			this.$addFlag(10);
		}
		
		public function get bottom():Number {
			return _bottom;
		}
		
		public function set bottom(val:Number):void {
			_bottom = +val||0;
			this.$addFlag(10);
		}
		
		public function get leftAlgin():String {
			return _leftAlgin;
		}
		
		public function set leftAlgin(val:String):void {
			if(Engine.DEBUG) {
				if(val != "" && val != "left" && val != "right") {
					DebugInfo.debug("非法的 leftAlgin 值:" + val + "，只能为 \"\" 或 \"left\" 或 \"right\"",DebugInfo.ERROR);
				}
			}
			_leftAlgin = val;
			this.$addFlag(10);
		}
		
		public function get left():Number {
			return _left;
		}
		
		public function set left(val:Number):void {
			_left = +val||0;
			this.$addFlag(10);
		}
		
		public function get rightAlgin():String {
			return _rightAlgin;
		}
		
		public function set rightAlgin(val:String):void {
			if(Engine.DEBUG) {
				if(val != "" && val != "left" && val != "right") {
					DebugInfo.debug("非法的 rightAlgin 值:" + val + "，只能为 \"\" 或 \"left\" 或 \"right\"",DebugInfo.ERROR);
				}
			}
			_rightAlgin = val;
			this.$addFlag(10);
		}
		
		public function get right():Number {
			return _right;
		}
		
		public function set right(val:Number):void {
			_right = val;
			this.$addFlag(10);
		}
		
		public function get percentWidth():Number {
			return _percentWidth<0?0:_percentWidth;
		}
		
		public function set percentWidth(val:Number):void {
			val = +val;
			val = val<0?0:val;
			_percentWidth = val;
			this.$addFlag(10);
		}
		
		public function get percentHeight():Number {
			return _percentHeight<0?0:_percentHeight;
		}
		
		public function set percentHeight(val:Number):void {
			val = +val;
			val = val<0?0:val;
			_percentHeight = val;
			this.$addFlag(10);
		}
		
		override public function $onFrameEnd():void {
			if(this.$getFlag(10) || this.parent.$getFlag(10)) {
				this.$removeFlag(10);
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
		}
		/////////////////////////////////////////Component end/////////////////////////////////////////
	}
}