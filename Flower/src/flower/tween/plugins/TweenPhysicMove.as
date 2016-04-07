package flower.tween.plugins
{
	import flower.tween.IPlugin;
	import flower.tween.Tween;

	public class TweenPhysicMove implements IPlugin
	{
		public function TweenPhysicMove()
		{
			if(!Tween.hasPlugin("physicMove")) {
				Tween.registerPlugin("physicMove", TweenPhysicMove);
			}
		}
		
		/**
		 * @inheritDoc
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function init(tween:Tween, propertiesTo:Object, propertiesFrom:Object):Vector.<String> {
			this.tween = tween;
			var useAttributes:Vector.<String> = new Vector.<String>();
			useAttributes.push("physicMove");
			var target:* = tween.target;
			var startX:Number = target.x;
			var startY:Number = target.y;
			if (propertiesFrom) {
				if ("x" in propertiesFrom) {
					startX = +propertiesFrom["x"];
				}
				if ("y" in propertiesFrom) {
					startY = +propertiesFrom["y"];
				}
			}
			this.startX = startX;
			this.startY = startY;
			var endX:Number = startX;
			var endY:Number = startY;
			if ("x" in propertiesTo) {
				endX = +propertiesTo["x"];
				useAttributes.push("x");
			}
			if ("y" in propertiesTo) {
				endY = +propertiesTo["y"];
				useAttributes.push("y");
			}
			var vx:Number = 0;
			var vy:Number = 0;
			var t:Number = tween.time;
			if ("vx" in propertiesTo) {
				vx = +propertiesTo["vx"];
				useAttributes.push("vx");
				if (!("x" in propertiesTo)) {
					endX = startX + t * vx;
				}
			}
			if ("vy" in propertiesTo) {
				vy = +propertiesTo["vy"];
				useAttributes.push("vy");
				if (!("y" in propertiesTo)) {
					endY = startY + t * vy;
				}
			}
			this.vx = vx;
			this.vy = vy;
			this.ax = (endX - startX - vx * t) * 2 / (t * t);
			this.ay = (endY - startY - vy * t) * 2 / (t * t);
			this.time = t;
			return useAttributes;
		}
		
		private var tween:Tween;
		private var startX:Number;
		private var vx:Number;
		private var ax:Number;
		private var startY:Number;
		private var vy:Number;
		private var ay:Number;
		private var time:Number;
		
		/**
		 * @inheritDoc
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function update(value:Number):void {
			var target:* = this.tween.target;
			var t:Number = this.time * value;
			target.x = this.startX + this.vx * t + .5 * this.ax * t * t;
			target.y = this.startY + this.vy * t + .5 * this.ay * t * t;
		}
		
		public static function freeFallTo(target:*, time:Number, groundY:Number):Tween {
			return Tween.to(target, time, {"y": groundY, "physicMove": true});
		}
		
		public static function freeFallToWithG(target:*, g:Number, groundY:Number):Tween {
			return Tween.to(target, Math.sqrt(2 * (groundY - target.y) / g), {"y": groundY, "physicMove": true});
		}
		
		public static function fallTo(target:*, time:Number, groundY:Number, vX:* = null, vY:* = null):Tween {
			return Tween.to(target, time, {"y": groundY, "physicMove": true, "vx": vX, "vy": vY});
		}
		
		public static function fallToWithG(target:*, g:Number, groundY:Number, vX:* = null, vY:* = null):Tween {
			vX = +vX;
			vY = +vY;
			return Tween.to(target, Math.sqrt(2 * (groundY - target.y) / g + (vY * vY / (g * g))) - vY / g, {
				"y": groundY,
				"physicMove": true,
				"vx": vX,
				"vy": vY
			});
		}
		
		public static function to(target:*, time:Number, xTo:Number, yTo:Number, vX:Number = 0, vY:Number = 0):Tween {
			return Tween.to(target, time, {"x": xTo, "y": yTo, "vx": vX, "vy": vY, "physicMove": true});
		}
	}
}