package com.flower.cocos2dx.display
{
	import com.flower.cocos2dx.event.MouseEvent;

	public class InputTextField extends DisplayObject
	{
		public function InputTextField()
		{
			var txt = cc.TextFieldTTF.textFieldWithPlaceHolder("点击输入", "Thonburi",20);
			
			txt.setPosition(100,100);
			
			//    绑定接口
			//txt.setDelegate(StageCocos2DX.getInstance()._show);
			//开启输入
			txt.attachWithIME();
			//    关闭输入
			//    txt.detachWithIME();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,onStartInput,this);
		}
		
		private function onStartInput(e:MouseEvent):void
		{
			
		}
	}
}