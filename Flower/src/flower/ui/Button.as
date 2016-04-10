package flower.ui
{
	import flower.Engine;
	import flower.binding.compiler.Compiler;
	import flower.binding.compiler.structs.Stmts;
	import flower.data.DataManager;
	import flower.display.DisplayObject;
	import flower.events.TouchEvent;
	import flower.geom.Matrix;
	import flower.tween.Ease;
	import flower.tween.Tween;
	import flower.utils.Formula;

	public class Button extends Group
	{
		private var _enabled:Boolean = true;
		
		public function Button()
		{
			this.currentState = "up";
			this.addListener(TouchEvent.TOUCH_BEGIN,_onTouch,this);
			this.addListener(TouchEvent.TOUCH_END,_onTouch,this);
			this.addListener(TouchEvent.TOUCH_RELEASE,_onTouch,this);
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
				case TouchEvent.TOUCH_RELEASE:
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
		
		/////////////////////////////////////////Component/////////////////////////////////////////
		//////////////////////bingding event
		override protected function addUIEvents():void {
			super.addUIEvents();
			this.addListener(TouchEvent.TOUCH_END,this.onEXEClick,this);
		}
		
		private var onClickEXE:Function;
		public function set onClick(val:Function):void {
			onClickEXE = val;
		}
		
		public function get onClick():Function {
			return onClickEXE;
		}
		
		private function onEXEClick(e:TouchEvent):void {
			if(onClickEXE && e.target == this) {
				onClickEXE.call(this);
			}
		}
	}
}