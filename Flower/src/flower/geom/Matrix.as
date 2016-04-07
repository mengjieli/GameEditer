package flower.geom
{
	public class Matrix
	{
		public static var sin:Number;
		public static var cos:Number;
		
		public var a:Number = 1;
		public var b:Number = 0;
		public var c:Number = 0;
		public var d:Number = 1;
		public var tx:Number = 0;
		public var ty:Number = 0;
		
		public var _storeList:Array = [];
		
		public function Matrix()
		{
		}
		
		public function identity():void
		{
			a = 1;
			b = 0;
			c = 0;
			d = 1;
			tx = 0;
			ty = 0;
		}
		
		public function setTo(aa:Number,bb:Number,cc:Number,dd:Number,txx:Number,tyy:Number):void
		{
			a = aa;
			b = bb;
			c = cc;
			d = dd;
			tx = txx;
			ty = tyy;
		}
		
		/**
		 *位移 
		 * @param x 移动x
		 * @param y 移动y
		 * 
		 */		
		public function translate(x:Number,y:Number):void
		{
			tx += x;
			ty += y;
		}
		
		/**
		 *旋转 
		 * @param rot 弧度
		 * 
		 */		
		public function rotate(angle:Number):void
		{
			sin = Math.sin(angle);
			cos = Math.cos(angle);
			setTo(a*cos - c*sin,
				a*sin + c*cos,
				b*cos - d*sin,
				b*sin + d*cos,
				tx*cos - ty*sin,
				tx*sin + ty*cos);
		}
		
		/**
		 *缩放 
		 * @param sx x缩放比例
		 * @param sy y缩放比例
		 * 
		 */		
		public function scale(sx:Number,sy:Number):void
		{
			a = sx;
			d = sy;
			tx *= a;
			ty *= d;
		}
		
		public function prependMatrix(prep:Matrix):void
		{
			setTo(a * prep.a + c * prep.b,
				b * prep.a + d * prep.b,
				a * prep.c + c * prep.d,
				b * prep.c + d * prep.d,
				tx + a * prep.tx + c * prep.ty,
				ty + b * prep.tx + d * prep.ty);
		}
		
		public function prependTranslation(tx:Number, ty:Number):void
		{
			this.tx += a * tx + c * ty;
			this.ty += b * tx + d * ty;
		}
		
		public function prependScale(sx:Number, sy:Number):void
		{
			setTo(a * sx, b * sx, 
				c * sy, d * sy,
				tx, ty);
		}
		
		public function prependRotation(angle:Number):void
		{
			var sin:Number = Math.sin(angle);
			var cos:Number = Math.cos(angle);
			
			setTo(a * cos + c * sin,  b * cos + d * sin,
				c * cos - a * sin,  d * cos - b * sin,
				tx, ty);
		}
		
		public function prependSkew(skewX:Number, skewY:Number):void
		{
			var sinX:Number = Math.sin(skewX);
			var cosX:Number = Math.cos(skewX);
			var sinY:Number = Math.sin(skewY);
			var cosY:Number = Math.cos(skewY);
			
			setTo(a * cosY + c * sinY,
				b * cosY + d * sinY,
				c * cosX - a * sinX,
				d * cosX - b * sinX,
				tx, ty);
		}
		
		//是否变形
		public function get deformation():Boolean
		{
			if(a != 1 || b != 0 || c != 0 || d != 1) return true;
			return false;
		}
		
		public function save():void {
			var matrix:Matrix = Matrix.create();
			matrix.a = a;
			matrix.b = b;
			matrix.c = c;
			matrix.d = d;
			matrix.tx = tx;
			matrix.ty = ty;
			_storeList.push(matrix);
		}
		
		public function restore():void {
			var matrix:Matrix = _storeList.pop();
			this.setTo(matrix.a,matrix.b,matrix.c,matrix.d,matrix.tx,matrix.ty);
			Matrix.release(matrix);
		}
		
		
		public static var $matrix:Matrix = new Matrix();
		
		private static var matrixPool:Vector.<Matrix> = new Vector.<Matrix>();
		
		/**
		 * 释放一个Matrix实例到对象池
		 */
		public static function release(matrix:Matrix):void {
			if(!matrix){
				return;
			}
			matrix._storeList.length = 0;
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