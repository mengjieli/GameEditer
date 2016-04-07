package flower.tween.plugins
{
	import flower.geom.Point;
	import flower.tween.IPlugin;
	import flower.tween.Tween;

	public class TweenPath implements IPlugin
	{
		public function TweenPath()
		{
		}
		
		/**
		 * @inheritDoc
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function init(tween:Tween, propertiesTo:Object, propertiesFrom:Object):Vector.<String> {
			this.tween = tween;
			var useAttributes:Vector.<String> = new Vector.<String>();
			useAttributes.push("path");
			var path:Vector.<Point> = propertiesTo["path"];
			var target:* = tween.target;
			var start:Point = Point.create(target.x, target.y);
			path.splice(0, 0, start);
			if (propertiesFrom) {
				if ("x" in propertiesFrom) {
					start.x = +propertiesFrom["x"];
				}
				if ("y" in propertiesFrom) {
					start.y = +propertiesFrom["y"];
				}
			}
			if ("x" in propertiesTo && "y" in propertiesTo) {
				useAttributes.push("x");
				useAttributes.push("y");
				path.push(Point.create(+propertiesTo["x"], +propertiesTo["y"]));
			}
			this.path = path;
			this.pathSum = new Vector.<Number>();
			this.pathSum.push(0);
			for (var i:int = 1, len:int = path.length; i < len; i++) {
				this.pathSum[i] = this.pathSum[i - 1] + Math.sqrt((path[i].x - path[i - 1].x) * (path[i].x - path[i - 1].x) + (path[i].y - path[i - 1].y) * (path[i].y - path[i - 1].y));
			}
			var sum:Number = this.pathSum[len - 1];
			for (i = 1; i < len; i++) {
				this.pathSum[i] = this.pathSum[i] / sum;
			}
			return useAttributes;
		}
		
		private var tween:Tween;
		private var pathSum:Vector.<Number>;
		private var path:Vector.<Point>;
		
		/**
		 * @inheritDoc
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public function update(value:Number):void {
			var path:Vector.<Point> = this.path;
			var target:* = this.tween.target;
			var pathSum:Vector.<Number> = this.pathSum;
			var i:int, len:int = pathSum.length;
			for (i = 1; i < len; i++) {
				if (value > pathSum[i - 1] && value <= pathSum[i]) {
					break;
				}
			}
			if (value <= 0) {
				i = 1;
			}
			else if (value >= 1) {
				i = len - 1;
			}
			value = (value - pathSum[i - 1]) / (pathSum[i] - pathSum[i - 1]);
			target.x = value * (path[i].x - path[i - 1].x) + path[i - 1].x;
			target.y = value * (path[i].y - path[i - 1].y) + path[i - 1].y;
		}
		
		public static function to(target:*, time:Number, path:Vector.<Point>, ease:String = "None"):Tween {
			return Tween.to(target, time, {"path": path}, ease);
		}
		
		public static function vto(target:*, v:Number, path:Vector.<Point>, ease:String = "None"):Tween {
			var sum:Number = 0;
			for(var i:int = 1, len:int = path.length; i < len; i++) {
				sum += Math.sqrt((path[i].x -path[i-1].x)*(path[i].x -path[i-1].x) + (path[i].y -path[i-1].y)*(path[i].y -path[i-1].y));
			}
			var time:Number = sum/v;
			return Tween.to(target, time, {"path": path}, ease);
		}
	}
}