package flower.geom
{
	public class Rectangle
	{
		
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		
		public function Rectangle(x:Number=0,y:Number=0,width:Number=0,height:Number=0)
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public function get right():Number {
			return this.x + this.width;
		}
		
		public function set right(value:Number) {
			this.width = value - this.x;
		}
		
		public function get bottom():Number {
			return this.y + this.height;
		}
		
		public function set bottom(value:Number) {
			this.height = value - this.y;
		}
		
		public function get left():Number {
			return this.x;
		}
		
		public function set left(value:Number) {
			this.width += this.x - value;
			this.x = value;
		}
		
		public function get top():Number {
			return this.y;
		}
		
		public function set top(value:Number) {
			this.height += this.y - value;
			this.y = value;
		}
		
		public function copyFrom(sourceRect:Rectangle):Rectangle {
			this.x = sourceRect.x;
			this.y = sourceRect.y;
			this.width = sourceRect.width;
			this.height = sourceRect.height;
			return this;
		}
		
		public function setTo(x:Number, y:Number, width:Number, height:Number):Rectangle {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			return this;
		}
		
		/**
		 * 确定由此 Rectangle 对象定义的矩形区域内是否包含指定的点。
		 * @param x 检测点的x轴
		 * @param y 检测点的y轴
		 * @returns 如果检测点位于矩形内，返回true，否则，返回false
		 */
		public function contains(x:Number, y:Number):Boolean {
			return this.x <= x &&
				this.x + this.width >= x &&
				this.y <= y &&
				this.y + this.height >= y;
		}
		
		public function intersection(toIntersect: Rectangle): Rectangle {
			return this.clone().$intersectInPlace(toIntersect);
		}
		
		protected function $intersectInPlace(clipRect: Rectangle): Rectangle {
			var x0 = this.x;
			var y0 = this.y;
			var x1 = clipRect.x;
			var y1 = clipRect.y;
			var l = Math.max(x0, x1);
			var r = Math.min(x0 + this.width, x1 + clipRect.width);
			if (l <= r) {
				var t = Math.max(y0, y1);
				var b = Math.min(y0 + this.height, y1 + clipRect.height);
				if (t <= b) {
					this.setTo(l, t, r - l, b - t);
					return this;
				}
			}
			this.setEmpty();
			return this;
		}
		
		/**
		 * 确定在 toIntersect 参数中指定的对象是否与此 Rectangle 对象相交。此方法检查指定的 Rectangle
		 * 对象的 x、y、width 和 height 属性，以查看它是否与此 Rectangle 对象相交。
		 * @param toIntersect 要与此 Rectangle 对象比较的 Rectangle 对象。
		 * @returns 如果两个矩形相交，返回true，否则返回false
		 */
		public function intersects(toIntersect:Rectangle):Boolean {
			return Math.max(this.x, toIntersect.x) <= Math.min(this.right, toIntersect.right)
				&& Math.max(this.y, toIntersect.y) <= Math.min(this.bottom, toIntersect.bottom);
		}
		
		public function isEmpty():Boolean {
			return this.width <= 0 || this.height <= 0;
		}
		
		/**
		 * 将 Rectangle 对象的所有属性设置为 0。
		 */
		public function setEmpty():void {
			this.x = 0;
			this.y = 0;
			this.width = 0;
			this.height = 0;
		}
		
		public function clone():Rectangle {
			return new Rectangle(this.x, this.y, this.width, this.height);
		}
		
		private function _getBaseWidth(angle:Number):Number {
			var u = Math.abs(Math.cos(angle));
			var v = Math.abs(Math.sin(angle));
			return u * this.width + v * this.height;
		}
		
		/**
		 * @private
		 */
		private function _getBaseHeight(angle:Number):Number {
			var u = Math.abs(Math.cos(angle));
			var v = Math.abs(Math.sin(angle));
			return v * this.width + u * this.height;
		}
		
		private static var rectanglePool:Vector.<Rectangle> = new Vector.<Rectangle>();
		public static function release(rect:Rectangle):void {
			if (!rect) {
				return;
			}
			rectanglePool.push(rect);
		}
		
		/**
		 * 从对象池中取出或创建一个新的Rectangle对象。
		 */
		public static function create():Rectangle {
			var rect:Rectangle = rectanglePool.pop();
			if (!rect) {
				rect = new Rectangle();
			}
			return rect;
		}
	}
}