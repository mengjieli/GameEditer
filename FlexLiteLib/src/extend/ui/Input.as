package extend.ui
{
	import egret.components.EditableText;

	public class Input extends EditableText
	{
		private var _border:Boolean = false;
		private var _borderColor:uint = 0xffffff;
		private var _backgorund:Boolean = false;
		private var _backgorundColor:uint = 0xdddddd;
		
		public function Input()
		{
			this.maxChars = 100000;
		}
		
		public function set border(val:Boolean):void {
			_border = val;
			this.flushBackground();
		}
		
		public function get border():Boolean {
			return _border;
		}
		
		public function set borderColor(val:uint):void {
			_borderColor = val;
			this.flushBackground();
		}
		
		public function get borderColor():uint {
			return _borderColor;
		}
		
		public function set backgorund(val:Boolean):void {
			_backgorund = val;
			this.flushBackground();
		}
		
		public function get backgorund():Boolean {
			return _backgorund;
		}
		
		public function set backgorundColor(val:uint):void {
			_backgorundColor = val;
			this.flushBackground();
		}
		
		public function get backgorundColor():uint {
			return _backgorundColor;
		}
		
		override public function set width(value:Number):void {
			super.width = value;
			this.flushBackground();
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			this.flushBackground();
		}
		
		private function flushBackground():void {
			this.graphics.clear();
			if(this.backgorund) {
				this.graphics.beginFill(this.backgorundColor,1);
			}
			if(this.border) {
				this.graphics.lineStyle(1,this.borderColor);
			}
			this.graphics.drawRect(0,0,this.width,this.height);
		}
	}
}