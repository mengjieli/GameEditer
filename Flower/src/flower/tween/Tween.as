package flower.tween
{
	import flower.events.EventDispatcher;
	import flower.tween.plugins.TweenCenter;
	import flower.tween.plugins.TweenPath;
	import flower.tween.plugins.TweenPhysicMove;
	import flower.utils.ObjectDo;

	public class Tween
	{
		public function Tween(target:*, time:Number, propertiesTo:Object, ease:String = "None", propertiesFrom:Object=null)
		{
			if(Tween.plugins == null) {
				Tween.registerPlugin("center",TweenCenter);
				Tween.registerPlugin("path",TweenPath);
				Tween.registerPlugin("physicMove",TweenPhysicMove);
			}
			time = +time;
			if (time < 0) {
				time = 0;
			}
			this.$time = time * 1000;
			this._target = target;
			this._propertiesTo = propertiesTo;
			this._propertiesFrom = propertiesFrom;
			this.ease = ease;
			var timeLine:TimeLine = new TimeLine();
			timeLine.addTween(this);
		}
		
		private var invalidProperty:Boolean = false;
		
		/**
		 * @private
		 */
		private var _propertiesTo:Object;
		
		public function set propertiesTo(value:Object):void {
			if (value == this._propertiesTo) {
				return;
			}
			this._propertiesTo = value;
			this.invalidProperty = false;
		}
		
		private var _propertiesFrom:Object;
		
		public function set propertiesFrom(value:Object):void {
			if (value == this._propertiesFrom) {
				return;
			}
			this._propertiesFrom = value;
			this.invalidProperty = false;
		}
		
		/**
		 * @private
		 */
		public var $time:Number;
		
		
		/**
		 * @language en_US
		 * The total transformation time.
		 * @see lark.Tween
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 总的变换时间。
		 * @see lark.Tween
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function get time():Number {
			return this.$time / 1000;
		}
		
		public function set time(value:Number):void {
			value = +value | 0;
			this.$time = (+value) * 1000;
			if (this._timeLine) {
				this._timeLine.$invalidateTotalTime();
			}
		}
		
		/**
		 * @private
		 */
		public var $startTime:Number = 0;
		
		public function get startTime():Number {
			return this.$startTime / 1000;
		}
		
		public function set startTime(value:Number):void {
			value = +value | 0;
			if (value < 0) {
				value = 0;
			}
			if (value == this.$startTime) {
				return;
			}
			this.$startTime = value * 1000;
			if (this._timeLine) {
				this._timeLine.$invalidateTotalTime();
			}
			this.invalidProperty = false;
		}
		
		/**
		 * @private
		 */
		private var _currentTime:Number = 0;
		
		/**
		 * @private
		 */
		private var _target:*;
		
		/**
		 * @language en_US
		 * The object to transform.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 要变换的对象。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function get target():* {
			return this._target;
		}
		
		public function set target(value:*):void {
			if (value == this.target) {
				return;
			}
			this.removeTargetEvent();
			this._target = value;
			this.invalidProperty = false;
			this.addTargetEvent();
		}
		
		/**
		 * @private
		 */
		private var _ease:String;
		
		/**
		 * @private
		 */
		private var _easeData:Object;
		
		/**
		 * @language en_US
		 * The type of ease.
		 * @see lark.Ease
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 缓动类型。
		 * @see lark.Ease
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function get ease():String {
			return this._ease;
		}
		
		public function set ease(val:String):void {
			if (!easeCache[val]) {
				var func:Function = EaseFunction[val];
				if (func == null) {
					/**
					 * to do
					 * warn can't find the ease function
					 */
					return;
				}
				var cache:Array = [];
				for (var i:int = 0; i <= 2000; i++) {
					cache[i] = func(i / 2000);
				}
				easeCache[val] = cache;
			}
			this._ease = val;
			this._easeData = easeCache[val];
		}
		
		private var _startEvent:String = "";
		
		public function get startEvent():String {
			return this._startEvent;
		}
		
		public function set startEvent(type:String):void {
			this.removeTargetEvent();
			this._startEvent = type;
			this.addTargetEvent();
		}
		
		private var _startTarget:EventDispatcher;
		
		public function get startTarget():EventDispatcher {
			return this._startTarget;
		}
		
		public function set startTarget(value:EventDispatcher):void {
			this.removeTargetEvent();
			this._startTarget = value;
			this.addTargetEvent();
		}
		
		/**
		 * @private
		 */
		private function removeTargetEvent():void {
			var target:EventDispatcher;
			if (this._startTarget) {
				target = this._startTarget;
			} else {
				target = this._target;
			}
			if (target && this._startEvent && this._startEvent != "") {
				target.removeListener(this._startEvent, this.startByEvent, this);
			}
		}
		
		/**
		 * @private
		 */
		private function addTargetEvent():void {
			var target:EventDispatcher;
			if (this._startTarget) {
				target = this._startTarget;
			} else {
				target = this._target;
			}
			if (target && this._startEvent && this._startEvent != "") {
				target.addListener(this._startEvent, this.startByEvent, this);
			}
		}
		
		/**
		 * @private
		 */
		private function startByEvent():void {
			this._timeLine.gotoAndPlay(0);
		}
		
		/**
		 * @private
		 */
		private var _timeLine:TimeLine;
		
		public function get timeLine():TimeLine {
			if (!this._timeLine) {
				this._timeLine = new TimeLine();
				this._timeLine.addTween(this);
			}
			return this._timeLine;
		}
		
		/**
		 * @private
		 */
		public function $setTimeLine(value:TimeLine):void {
			if (this._timeLine) {
				this._timeLine.removeTween(this);
			}
			this._timeLine = value;
		}
		
		/**
		 * @private
		 */
		private var pugins:Vector.<IPlugin> = new Vector.<IPlugin>();
		
		/**
		 * @private
		 */
		private function initParmas():void {
			var controller:IPlugin;
			var params:Object = this._propertiesTo;
			var allPlugins:* = Tween.plugins;
			if (params) {
				var keys:Vector.<String> = ObjectDo.keys(allPlugins);
				var deletes:Vector.<String> = new Vector.<String>();
				for (var i:int = 0, len:int = keys.length; i < len; i++) {
					if (keys[i] in params) {
						var plugin:* = allPlugins[keys[i]];
						controller = new plugin();
						deletes = deletes.concat(controller.init(this, params, this._propertiesFrom));
						this.pugins.push(controller);
					}
				}
				for(i = 0; i < deletes.length; i++) {
					delete params[deletes[i]];
				}
				keys = ObjectDo.keys(params);
				for (i = 0; i < keys.length; i++) {
					var key:* = keys[i];
					if (!(key is String)) {
						delete params[key];
						keys.splice(i, 1);
						i--;
						continue;
					}
					var attribute:* = params[key];
					if (!(attribute is Number) || !(key in this._target)) {
						delete params[key];
						keys.splice(i, 1);
						i--;
						continue;
					}
				}
				if (keys.length) {
					controller = new BasicPlugin();
					controller.init(this, params, this._propertiesFrom);
					this.pugins.push(controller);
				}
			}
			this.invalidProperty = true;
		}
		
		public function invalidate():void {
			this.invalidProperty = false;
		}
		
		/**
		 * @private
		 */
		private var _complete:Function;
		
		/**
		 * @private
		 */
		private var _completeThis:*;
		
		/**
		 * @private
		 */
		private var _completeParams:*;
		
		/**
		 * @language en_US
		 * Tween end callback function.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * Tween 结束回调函数。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function call(callBack:Function, thisObj:*=null, ...args):Tween {
			this._complete = callBack;
			this._completeThis = thisObj;
			this._completeParams = args;
			return this;
		}
		
		/**
		 * @private
		 */
		private var _update:Function;
		
		/**
		 * @private
		 */
		private var _updateThis:*;
		
		/**
		 * @private
		 */
		private var _updateParams:*;
		
		public function update(callBack:Function, thisObj:*=null, ...args):Tween {
			this._update = callBack;
			this._updateThis = thisObj;
			this._updateParams = args;
			return this;
		}
		
		/**
		 * @private
		 * @param time
		 * @returns {boolean}
		 */
		public function $update(time:Number):Boolean {
			if (!this.invalidProperty) {
				this.initParmas();
			}
			this._currentTime = time - this.$startTime;
			if (this._currentTime > this.$time) {
				this._currentTime = this.$time;
			}
			var length:int = this.pugins.length;
			var s:Number = this._easeData[2000 * (this._currentTime / this.$time) | 0];
			for (var i:int = 0; i < length; i++) {
				this.pugins[i].update(s);
			}
			if (this._update != null) {
				this._update.apply(this._updateThis, this._updateParams);
			}
			if (this._currentTime == this.$time) {
				if (this._complete != null) {
					this._complete.apply(this._completeThis, this._completeParams);
				}
			}
			return true;
		}
		
		/**
		 * @language en_US
		 * Create a Tween object.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 创建一个 Tween 对象。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function to(target:*, time:Number, propertiesTo:Object, ease:String="None", propertiesFrom:Object=null):Tween {
			var tween:Tween = new Tween(target, time, propertiesTo, ease, propertiesFrom);
			tween.timeLine.play();
			return tween;
		}
		
		/**
		 * @private
		 */
		private static var plugins:Object;
		
		private static var easeCache:Object = {};
		/**
		 * @language en_US
		 * Register a Tween plugin.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 注册一个 Tween 插件。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function registerPlugin(paramName:String, plugin:*):void {
			if(Tween.plugins == null) {
				Tween.plugins = {};
			}
			Tween.plugins[paramName] = plugin;
		}
		
		public static function hasPlugin(paramName:String):Boolean {
			return Tween.plugins[paramName]?true:false;
		}
	}
}