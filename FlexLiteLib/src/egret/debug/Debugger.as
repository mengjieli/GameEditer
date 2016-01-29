package egret.debug
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import egret.core.UIGlobals;
	import egret.core.ns_egret;
	
	use namespace ns_egret;
	
	
	/**
	 * 
	 * @author dom
	 */
	public class Debugger
	{
		public static function initialize():void
		{
			instance = new Debugger();
		}
		
		private static var instance:Debugger;
		/**
		 * 构造函数
		 */		
		public function Debugger()
		{
			UIGlobals.addStageCallBack = onAddStage;
			UIGlobals.removeStageCallBack = onRemoveStage;
			for each(var stage:Stage in UIGlobals.stages)
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
				stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			}
		}
		
		/**
		 * 添加舞台的回调
		 */		
		private function onAddStage(stage:Stage):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			if(debugWindow&&stage.nativeWindow==debugWindow.nativeWindow)
				return;
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		}
		/**
		 * 移除舞台的回调
		 */		
		private function onRemoveStage(stage:Stage):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			if(debugWindow&&stage.nativeWindow==debugWindow.nativeWindow)
				return;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		}
		/**
		 * 在舞台上按下鼠标
		 */		
		private function onMouseDown(event:MouseEvent):void
		{
			if(!debugWindow||debugWindow.closed)
				return;
			var target:Stage = event.currentTarget as Stage;
			if(!debugWindow.selectBtn.selected)
			{
				debugWindow.startOrEndSelection();
			}
			debugWindow.targetStage = target;
		}
		
		private var debugWindow:DebugWindow;
		
		/**
		 * 键盘事件
		 */		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode==Keyboard.F11 && event.ctrlKey)
			{
				if(!debugWindow || debugWindow.closed)
				{
					debugWindow = new DebugWindow();
					debugWindow.open();
					debugWindow.targetStage = event.currentTarget as Stage;
				}
				else
				{
					debugWindow.close();
				}
			}
			
			if(!debugWindow||debugWindow.closed)
				return;
			if(event.keyCode==Keyboard.ESCAPE)
			{
				debugWindow.close();
			}
			else if(event.keyCode==Keyboard.F2)
			{
				debugWindow.copyKeyToClipboard();
			}
			else if(event.keyCode==Keyboard.F3)
			{
				debugWindow.copyValueToClipboard();
			}
			else if(event.keyCode==Keyboard.F12)
			{
				debugWindow.startOrEndSelection();
			}
			else if(event.keyCode==Keyboard.F6)
			{
				debugWindow.setSelectedItemAsRoot();
			}
		}
	}
}