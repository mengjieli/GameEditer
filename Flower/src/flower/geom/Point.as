package flower.geom
{
	public class Point
	{
		public var x:Number;
		public var y:Number;
		
		public function Point(x:Number=0,y:Number=0)
		{
			this.x = x;
			this.y = y;
		}
		
		public function setTo(x:Number=0,y:Number=0):Point
		{
			this.x = x;
			this.y = y;
			return this;
		}
		
		public function get length():Number{
			return Math.sqrt(this.x*this.x+this.y*this.y);
		}
		
		public static function distance(p1:Point, p2:Point):Number {
			return Math.sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
		}
		
		public static var $TempPoint:Point = new Point();
		
		private static var pointPool:Vector.<Point> = new Vector.<Point>();
		
		public static function release(point:Point):void {
			if(!point){
				return;
			}
			pointPool.push(point);
		}
		
		public static function create(x:Number,y:Number):Point {
			var point:Point = pointPool.pop();
			if (!point) {
				point = new Point(x,y);
			} else {
				point.x = x;
				point.y = y;
			}
			return point;
		}
	}
}