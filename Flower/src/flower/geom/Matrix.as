package flower.geom
{
	public class Matrix
	{
		public var a:Number;
		public var b:Number;
		public var c:Number;
		public var d:Number;
		public var tx:Number;
		public var ty:Number; 
		
		public function Matrix(a:Number = 1, b:Number = 0, c:Number = 0, d:Number = 1, tx:Number = 0, ty:Number = 0) {
			this.a = a;
			this.b = b;
			this.c = c;
			this.d = d;
			this.tx = tx;
			this.ty = ty;
		}
		
		public function clone():Matrix {
			return new Matrix(a,b,c,d,tx,ty);
		}
		
		/**
		 * 将某个矩阵与当前矩阵连接，从而将这两个矩阵的几何效果有效地结合在一起。在数学术语中，将两个矩阵连接起来与使用矩阵乘法将它们结合起来是相同的。
		 * @param other 要连接到源矩阵的矩阵。
		 */
		public function concat(other:Matrix):void {
			var a:Number =  this.a * other.a;
			var b:Number =  0.0;
			var c:Number =  0.0;
			var d:Number =  this.d * other.d;
			var tx:Number = this.tx * other.a + other.tx;
			var ty:Number = this.ty * other.d + other.ty;
			
			if (this.b !== 0.0 || this.c !== 0.0 || other.b !== 0.0 || other.c !== 0.0) {
				a  += this.b * other.c;
				d  += this.c * other.b;
				b  += this.a * other.b + this.b * other.d;
				c  += this.c * other.a + this.d * other.c;
				tx += this.ty * other.c;
				ty += this.tx * other.b;
			}
			this.a = a;
			this.b = b;
			this.c = c;
			this.d = d;
			this.tx = tx;
			this.ty = ty;
		}
		
		/**
		 * 将源 Matrix 对象中的所有矩阵数据复制到调用方 Matrix 对象中。
		 * @param other 要拷贝的目标矩阵
		 */
		public function copyFrom(other:Matrix):Matrix {
			this.a = other.a;
			this.b = other.b;
			this.c = other.c;
			this.d = other.d;
			this.tx = other.tx;
			this.ty = other.ty;
			return this;
		}
		
		/**
		 * 为每个矩阵属性设置一个值，该值将导致矩阵无转换。通过应用恒等矩阵转换的对象将与原始对象完全相同。
		 * 调用 identity() 方法后，生成的矩阵具有以下属性：a=1、b=0、c=0、d=1、tx=0 和 ty=0。
		 */
		public function identity():void {
			this.a = this.d = 1;
			this.b = this.c = this.tx = this.ty = 0;
		}
		
		/**
		 * 执行原始矩阵的逆转换。
		 * 您可以将一个逆矩阵应用于对象来撤消在应用原始矩阵时执行的转换。
		 */
		public function invert():void {
			this._invertInto(this);
		}
		
		private function _invertInto(target:Matrix):void {
			var a:Number = this.a;
			var b:Number  = this.b;
			var c:Number  = this.c;
			var d:Number = this.d;
			var tx:Number = this.tx;
			var ty:Number = this.ty;
			if (b === 0 && c === 0) {
				target.b = target.c = 0;
				if(a===0||d===0){
					target.a = target.d = target.tx = target.ty = 0;
				}
				else{
					a = target.a = 1 / a;
					d = target.d = 1 / d;
					target.tx = -a * tx;
					target.ty = -d * ty;
				}
				
				return;
			}
			var determinant:Number = a * d - b * c;
			if (determinant === 0) {
				target.identity();
				return;
			}
			determinant = 1 / determinant;
			var k:Number = target.a =  d * determinant;
			b = target.b = -b * determinant;
			c = target.c = -c * determinant;
			d = target.d =  a * determinant;
			target.tx = -(k * tx + c * ty);
			target.ty = -(b * tx + d * ty);
		}
		
		/**
		 * 对 Matrix 对象应用旋转转换。
		 * rotate() 方法将更改 Matrix 对象的 a、b、c 和 d 属性。
		 * @param angle 以弧度为单位的旋转角度。
		 */
		public function rotate(angle:Number):void {
			angle = +angle;
			if (angle !== 0) {
				var u:Number = cos(angle);
				var v:Number = sin(angle);
				var ta:Number = this.a;
				var tb:Number = this.b;
				var tc:Number = this.c;
				var td:Number = this.d;
				var ttx:Number = this.tx;
				var tty:Number = this.ty;
				this.a = ta  * u - tb  * v;
				this.b = ta  * v + tb  * u;
				this.c = tc  * u - td  * v;
				this.d = tc  * v + td  * u;
				this.tx = ttx * u - tty * v;
				this.ty = ttx * v + tty * u;
			}
		}
		
		/**
		 * 对矩阵应用缩放转换。x 轴乘以 sx，y 轴乘以 sy。
		 * scale() 方法将更改 Matrix 对象的 a 和 d 属性。
		 * @param sx 用于沿 x 轴缩放对象的乘数。
		 * @param sy 用于沿 y 轴缩放对象的乘数。
		 */
		public function scale(sx:Number, sy:Number):void {
			if (sx !== 1) {
				this.a *= sx;
				this.c *= sx;
				this.tx *= sx;
			}
			if (sy !== 1) {
				this.b *= sy;
				this.d *= sy;
				this.ty *= sy;
			}
		}
		
		/**
		 * 将 Matrix 的成员设置为指定值
		 * @param a 缩放或旋转图像时影响像素沿 x 轴定位的值。
		 * @param b 旋转或倾斜图像时影响像素沿 y 轴定位的值。
		 * @param c 旋转或倾斜图像时影响像素沿 x 轴定位的值。
		 * @param d 缩放或旋转图像时影响像素沿 y 轴定位的值。
		 * @param tx 沿 x 轴平移每个点的距离。
		 * @param ty 沿 y 轴平移每个点的距离。
		 */
		public function setTo(a:Number, b:Number, c:Number, d:Number, tx:Number, ty:Number):Matrix {
			this.a = a;
			this.b = b;
			this.c = c;
			this.d = d;
			this.tx = tx;
			this.ty = ty;
			return this;
		}

		/**
		 * 返回将 Matrix 对象表示的几何转换应用于指定点所产生的结果。
		 * @param pointX 想要获得其矩阵转换结果的点的x坐标。
		 * @param pointY 想要获得其矩阵转换结果的点的y坐标。
		 * @param resultPoint 框架建议尽可能减少创建对象次数来优化性能，可以从外部传入一个复用的Point对象来存储结果，若不传入将创建一个新的Point对象返回。
		 * @returns 由应用矩阵转换所产生的点。
		 */
		public function transformPoint(pointX:Number, pointY:Number, resultPoint:Point=null):Point {
			var x:Number = this.a * pointX + this.c * pointY + this.tx;
			var y:Number = this.b * pointX + this.d * pointY + this.ty;
			if (resultPoint) {
				resultPoint.setTo(x, y);
				return resultPoint;
			}
			return new Point(x, y);
		}
		
		/**
		 * 沿 x 和 y 轴平移矩阵，由 dx 和 dy 参数指定。
		 * @param dx 沿 x 轴向右移动的量（以像素为单位）。
		 * @param dy 沿 y 轴向下移动的量（以像素为单位）。
		 */
		public function translate(dx:Number, dy:Number):void {
			this.tx += dx;
			this.ty += dy;
		}
		
		/**
		 * 是否与另一个矩阵数据相等
		 * @param other 要比较的另一个矩阵对象。
		 * @returns 是否相等，ture表示相等。
		 */
		public function equals(other:Matrix):Boolean {
			return this.a === other.a && this.b === other.b &&
				this.c === other.c && this.d === other.d &&
				this.tx === other.tx && this.ty === other.ty;
		}
		
		/**
		 * @private
		 */
		private function _transformBounds(bounds:Rectangle):void {
			var a  = this.a;
			var b  = this.b;
			var c  = this.c;
			var d  = this.d;
			var tx = this.tx;
			var ty = this.ty;
			
			var x = bounds.x;
			var y = bounds.y;
			var xMax = x + bounds.width;
			var yMax = y + bounds.height;
			
			var x0 = a * x + c * y + tx;
			var y0 = b * x + d * y + ty;
			var x1 = a * xMax + c * y + tx;
			var y1 = b * xMax + d * y + ty;
			var x2 = a * xMax + c * yMax + tx;
			var y2 = b * xMax + d * yMax + ty;
			var x3 = a * x + c * yMax + tx;
			var y3 = b * x + d * yMax + ty;
			
			var tmp = 0;
			
			if (x0 > x1) {
				tmp = x0;
				x0 = x1;
				x1 = tmp;
			}
			if (x2 > x3) {
				tmp = x2;
				x2 = x3;
				x3 = tmp;
			}
			
			bounds.x = Math.floor(x0 < x2 ? x0 : x2);
			bounds.width = Math.ceil((x1 > x3 ? x1 : x3) - bounds.x);
			
			if (y0 > y1) {
				tmp = y0;
				y0 = y1;
				y1 = tmp;
			}
			if (y2 > y3) {
				tmp = y2;
				y2 = y3;
				y3 = tmp;
			}
			
			bounds.y = Math.floor(y0 < y2 ? y0 : y2);
			bounds.height = Math.ceil((y1 > y3 ? y1 : y3) - bounds.y);
		}
		
		private function getDeterminant() {
			return this.a * this.d - this.b * this.c;
		}
		
		private function _getScaleX():Number {
			var m = this;
			if (m.a === 1 && m.b === 0) {
				return 1;
			}
			var result = Math.sqrt(m.a * m.a + m.b * m.b);
			return this.getDeterminant() < 0 ? -result : result;
		}
		
		/**
		 * @private
		 */
		private function _getScaleY():Number {
			var m = this;
			if (m.c === 0 && m.d === 1) {
				return 1;
			}
			var result = Math.sqrt(m.c * m.c + m.d * m.d);
			return this.getDeterminant() < 0 ? -result : result;
		}
		
		/**
		 * @private
		 */
		private function _getSkewX():Number {
			return Math.atan2(this.d, this.c) - (PI / 2);
		}
		
		/**
		 * @private
		 */
		private function _getSkewY():Number {
			return Math.atan2(this.b, this.a);
		}
		
		/**
		 * @private
		 */
		private function _updateScaleAndRotation(scaleX:Number, scaleY:Number, skewX:Number, skewY:Number) {
			if ((skewX === 0 || skewX === TwoPI) && (skewY === 0 || skewY === TwoPI)) {
				this.a = scaleX;
				this.b = this.c = 0;
				this.d = scaleY;
				return;
			}
			
			var u = cos(skewX);
			var v = sin(skewX);
			if (skewX === skewY) {
				this.a = u * scaleX;
				this.b = v * scaleX;
			} else {
				this.a = cos(skewY) * scaleX;
				this.b = sin(skewY) * scaleX;
			}
			this.c = -v * scaleY;
			this.d = u * scaleY;
		}
		
		/**
		 * @private
		 * target = other * this
		 */
		private function _preMultiplyInto(other:Matrix, target:Matrix):void {
			var a =  other.a * this.a;
			var b =  0.0;
			var c =  0.0;
			var d =  other.d * this.d;
			var tx = other.tx * this.a + this.tx;
			var ty = other.ty * this.d + this.ty;
			
			if (other.b !== 0.0 || other.c !== 0.0 || this.b !== 0.0 || this.c !== 0.0) {
				a  += other.b * this.c;
				d  += other.c * this.b;
				b  += other.a * this.b + other.b * this.d;
				c  += other.c * this.a + other.d * this.c;
				tx += other.ty * this.c;
				ty += other.tx * this.b;
			}
			
			target.a = a;
			target.b = b;
			target.c = c;
			target.d = d;
			target.tx = tx;
			target.ty = ty;
		}
		
		private static var PI:Number = Math.PI;
		private static var HalfPI:Number = PI / 2;
		private static var PacPI:Number = PI + HalfPI;
		private static var TwoPI:Number = PI * 2;
		
		/**
		 * @private
		 */
		private static function cos(angle:Number):Number {
			switch (angle) {
				case HalfPI:
				case -PacPI:
					return 0;
				case PI:
				case -PI:
					return -1;
				case PacPI:
				case -HalfPI:
					return 0;
				default:
					return Math.cos(angle);
			}
		}
		
		/**
		 * @private
		 */
		private static function sin(angle:Number):Number {
			switch (angle) {
				case HalfPI:
				case -PacPI:
					return 1;
				case PI:
				case -PI:
					return 0;
				case PacPI:
				case -HalfPI:
					return -1;
				default:
					return Math.sin(angle);
			}
		}
		
		private static var matrixPool:Vector.<Matrix> = new Vector.<Matrix>();
		
		/**
		 * 释放一个Matrix实例到对象池
		 */
		public static function release(matrix:Matrix):void {
			if(!matrix){
				return;
			}
			matrixPool.push(matrix);
		}
		
		/**
		 * 从对象池中取出或创建一个新的Matrix对象。
		 */
		public static function create():Matrix {
			var matrix:Matrix = matrixPool.pop();
			if (!matrix) {
				matrix = new Matrix();
			}
			return matrix;
		}
	}
}