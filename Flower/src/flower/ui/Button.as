package flower.ui
{
	import flower.display.DisplayObject;
	import flower.events.TouchEvent;
	import flower.geom.Matrix;

	public class Button extends Group
	{
		private var _enabled:Boolean = true;
		
		public function Button()
		{
			this.currentState = "up";
			this.addListener(TouchEvent.TOUCH_BEGIN,_onTouch,this);
			this.addListener(TouchEvent.TOUCH_END,_onTouch,this);
		}
		
		override protected function _getMouseTarget(matrix:Matrix,mutiply:Boolean):DisplayObject
		{
			var target:DisplayObject = super._getMouseTarget(matrix,mutiply);
			if(target) {
				target = this;
			}
			return target;
		}
		
		private function _onTouch(e:TouchEvent):void {
			if(!_enabled) {
				return;
			}
			switch(e.type) {
				case TouchEvent.TOUCH_BEGIN:
					this.currentState = "down";
					break;
				case TouchEvent.TOUCH_END:
					this.currentState = "up";
					break;
			}
		}
		
		
		///////////////////////////////////set & get/////////////////////////////
		public function set enabled(val:Boolean):void {
			if(_enabled == val) {
				return;
			}
			_enabled = val;
			if(_enabled) {
				this.currentState = "up";
			} else {
				this.currentState = "disabled";
			}
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
	}
}