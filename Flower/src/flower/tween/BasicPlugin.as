package flower.tween
{
	import flower.utils.ObjectDo;
	
	public class BasicPlugin implements IPlugin
	{
		public function BasicPlugin()
		{
		}
		
		/**
		 * @inheritDoc
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function init(tween:Tween, propertiesTo:Object, propertiesFrom:Object):Vector.<String> {
			this.tween = tween;
			this._attributes = propertiesTo;
			this.keys = ObjectDo.keys(propertiesTo);
			var target:* = tween.target;
			var startAttributes:Object = {};
			var keys:Vector.<String> = this.keys;
			var length:int = keys.length;
			for (var i:int = 0; i < length; i++) {
				var key:String = keys[i];
				if (propertiesFrom && key in propertiesFrom) {
					startAttributes[key] = propertiesFrom[key];
				}
				else {
					startAttributes[key] = target[key];
				}
			}
			this.startAttributes = startAttributes;
			return null;
		}
			
			/**
			 * @private
			 */
		protected var tween:Tween;
		
		/**
		 * @private
		 */
		protected var keys:Vector.<String>;
		
		/**
		 * @private
		 */
		protected var startAttributes:Object;
		
		/**
		 * @private
		 */
		protected var _attributes:Object;
		
		/**
		 * @inheritDoc
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function update(value:Number):void {
			var target:* = this.tween.target;
			var keys:Vector.<String> = this.keys;
			var length:int = keys.length;
			var startAttributes:Object = this.startAttributes;
			for (var i:int = 0; i < length; i++) {
				var key:String = keys[i];
				target[key] = (this._attributes[key] - startAttributes[key]) * value + startAttributes[key];
			}
		}
	}
}