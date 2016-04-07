package flower.tween.plugins
{
	import flower.tween.Tween;
	import flower.tween.IPlugin;

	public class TweenCenter implements IPlugin
	{
		public function TweenCenter()
		{
		}
		
		/**
		 * @inheritDoc
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function init(tween:Tween, propertiesTo:Object, propertiesFrom:Object):Vector.<String> {
			this.tween = tween;
			var target:* = tween.target;
			this.centerX = target.width / 2;
			this.centerY = target.height / 2;
			var useAttributes:Vector.<String> = new Vector.<String>();
			useAttributes.push("center");
			if ("scaleX" in propertiesTo) {
				this.scaleXTo = +propertiesTo["scaleX"];
				useAttributes.push("scaleX");
				if (propertiesFrom && "scaleX" in propertiesFrom) {
					this.scaleXFrom = +propertiesFrom["scaleX"];
				} else {
					this.scaleXFrom = target["scaleX"];
				}
			}
			if ("scaleY" in propertiesTo) {
				this.scaleYTo = +propertiesTo["scaleY"];
				useAttributes.push("scaleY");
				if (propertiesFrom && "scaleY" in propertiesFrom) {
					this.scaleYFrom = +propertiesFrom["scaleY"];
				} else {
					this.scaleYFrom = target["scaleY"];
				}
			}
			if ("rotation" in propertiesTo) {
				this.rotationTo = +propertiesTo["rotation"];
				useAttributes.push("rotation");
				if (propertiesFrom && "rotation" in propertiesFrom) {
					this.rotationFrom = +propertiesFrom["rotation"];
				} else {
					this.rotationFrom = target["rotation"];
				}
				this.centerLength = Math.sqrt(target.width*target.width + target.height*target.height)*.5;
			}
			this.lastMoveX = this.lastMoveY = 0;
			return useAttributes;
		}
		
		private var tween:Tween;
		private var scaleXFrom:Number;
		private var scaleYFrom:Number;
		private var scaleXTo:Number;
		private var scaleYTo:Number;
		private var rotationFrom:Number;
		private var rotationTo:Number;
		private var centerX:Number;
		private var centerY:Number;
		private var centerLength:Number;
		private var lastMoveX:Number;
		private var lastMoveY:Number;
		
		/**
		 * @inheritDoc
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function update(value:Number):void {
			var target:* = this.tween.target;
			var moveX:Number = 0;
			var moveY:Number = 0;
			value = 0.25;
			if (this.scaleXTo) {
				target.scaleX = this.scaleXFrom + (this.scaleXTo - this.scaleXFrom) * value;
				target.x = this.centerX - target.width / 2;
			}
			if (this.scaleYTo) {
				target.scaleY = this.scaleYFrom + (this.scaleYTo - this.scaleYFrom) * value;
				target.y = this.centerY - target.height / 2;
			}
			if (this.rotationTo) {
				target.rotation = this.rotationFrom + (this.rotationTo - this.rotationFrom) * value;
				moveX += this.centerX - this.centerLength*Math.cos((target.rotation + 45)*Math.PI/180);
				moveY += this.centerY - this.centerLength*Math.sin((target.rotation + 45)*Math.PI/180);
				target.x += moveX - this.lastMoveX;
				target.y += moveY - this.lastMoveY;
			}
			this.lastMoveX = moveX;
			this.lastMoveY = moveY;
		}
		
		public static function scaleTo(target:*, time:Number, scaleTo:Number, scaleFrom:* = null, ease:String = "None"):Tween {
			return Tween.to(target, time, {
				"center": true,
				"scaleX": scaleTo,
				"scaleY": scaleTo
			}, ease, scaleFrom == null ? null : {"scaleX": scaleFrom, "scaleY": scaleFrom});
		}
		
		public static function rotationTo(target:*, time:Number, rotationTo:Number, rotationFrom:* = null, ease:String = "None"):Tween {
			return Tween.to(target, time, {
				"center": true,
				"rotation": rotationTo
			}, ease, rotationFrom == null ? null : {"rotation": rotationFrom});
		}
	}
}