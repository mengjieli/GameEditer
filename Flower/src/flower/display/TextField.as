package flower.display
{
	import flower.geom.Matrix;

	public class TextField extends DisplayObject
	{
		private static var textFieldProperty:Object = System.TextField;
		
		private var _TextField:Object;
		
		public function TextField()
		{
			_TextField = {
				0:12, //size
				1:0,  //color
				2:"", //text
				3:0,  //textWidth
				4:0,  //textHeight
				5:false, //wordWrap
				6:true,	//mutiline
				7:true //autosize
			};
			_show = System.getNativeShow("TextField");
			width = 100;
			height = 100;
			_setSize(_TextField[0]);
			_setColor(_TextField[1]);
			_nativeClass = "TextField";
		}
		
		private function _setSize(val:uint):void {
			_TextField[0] = val;
			var p:Object = textFieldProperty.size;
			if(p.atr) {
				this._show[p.atr] = val;
			}
			else if(p.func) {
				this._show[p.func](val);
			}
			else if(p.exe) {
				p.exe(this._show,val);
			}
			_invalidateNativeText();
		}
		
		private function _setColor(val:uint):void {
			_TextField[1] = val;
			var p:Object = textFieldProperty.color;
			if(p.atr) {
				this._show[p.atr] = val;
			}
			else if(p.func) {
				this._show[p.func](val);
			}
			else if(p.exe) {
				p.exe(this._show,val);
			}
		}
		
		private function _setText(val:String):void {
			_TextField[2] = val;
			_invalidateNativeText();
		}
		
		override protected function _setWidth(val:Number):void {
			_width = +val&~0;
			_invalidateNativeText();
		}
		
		override protected function _setHeight(val:Number):void {
			_height = +val&~0;
			_invalidateNativeText();
		}
		
		private function _setNativeText():void {
			var p:Object = textFieldProperty.resetText;
			p(_show,_TextField[2],_width,_height,_TextField[0],_TextField[5],_TextField[6],_TextField[7]);
			p = textFieldProperty.mesure;
			var size:Object = p(_show);
			_TextField[3] = size.width;
			_TextField[4] = size.height;
			this.$removeFlag(2);
		}
		
		override public function $isMouseTarget(matrix:Matrix,mutiply:Boolean):Boolean
		{
			if(touchEnabled == false || visible == false) return false;
			matrix.save();
			matrix.translate(-_x,-_y);
			if(rotation) matrix.rotate(-radian);
			if(scaleX != 1 || scaleY != 1) matrix.scale(1/scaleX,1/scaleY);
			_touchX = matrix.tx;// + _anchorX*_width;
			_touchY = matrix.ty;// + _anchorY*_height;
			if(_touchX >= 0 && _touchY >= 0 && _touchX < _TextField[3] && _touchY < _TextField[4])
			{
				return true;
			}
			matrix.restore();
			return false;
		}
		
		private function _invalidateNativeText():void {
			this.$addFlag(1);
			if(!this.$getFlag(2)) {
				this.$addFlag(2);
			}
		}
		
		override protected function $getSize():void {
			if(this.$getFlag(2)) {
				_setNativeText();
			}
			this.$removeFlag(1);
		}
		
		override public function $onFrameEnd():void {
			if(this.$getFlag(2)) {
				_setNativeText();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			text = "";
		}
		///////////////////////////////////set & get/////////////////////////////
		public function get size():uint {
			return _TextField[0];
		}
		
		public function set size(val:uint):void {
			_setSize(+val||0);
		}
		
		public function get color():uint {
			return _TextField[1];
		}
		
		public function set color(val:uint):void {
			_setColor(+val||0);
		}
		
		public function get text():String {
			return _TextField[2];
		}
		
		public function set text(val:String):void {
			val = val + "";
			_setText(val);
		}
		
		public function get textWidth():uint {
			return _TextField[3];
		}
		
		public function get textHeight():uint {
			return _TextField[4];
		}
		
		/**
		 * 自动换行
		 */
		public function get wordWrap():Boolean {
			return _TextField[5];
		}
		
		public function set wordWrap(val:Boolean):void {
			val = !!val;
			if(val == _TextField[5]) {
				return;
			}
			_TextField[5] = val;
			_invalidateNativeText();
		}
		
		/**
		 * 是否为多行文本
		 */
		public function get multiline():Boolean {
			return _TextField[6];
		}
		
		public function set multiline(val:Boolean):void {
			val = !!val;
			if(val == _TextField[6]) {
				return;
			}
			_TextField[6] = val;
			_invalidateNativeText();
		}
		
		/**
		 * 宽度是否自动
		 */
		public function get autoSize():Boolean {
			return _TextField[7];
		}
		
		public function set autoSize(val:Boolean):void {
			val = !!val;
			if(val == _TextField[7]) {
				return;
			}
			_TextField[7] = val;
			_invalidateNativeText();
		}
	}
}