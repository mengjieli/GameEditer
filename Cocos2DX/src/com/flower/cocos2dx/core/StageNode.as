package com.flower.cocos2dx.core
{
	import com.flower.cocos2dx.DebugInfo;
	import com.flower.cocos2dx.core.mouseManager.MouseManager;
	
	import cocos2dx.cc;
	import cocos2dx.display.CCNode;
	import cocos2dx.utils.CCTouch;

	public class StageNode extends CCNode
	{
		public function StageNode()
		{
			cc.registerStandardDelegate(this);
		}
		
		override public function onTouchesBegan(touch:Array):Boolean
		{
			var t:CCTouch;
			for(var i:int = 0; i < touch.length; i++)
			{
				t = touch[i];
				MouseManager.getInstance().onMouseDown(t.getId(),Math.floor(t.getLocation().x),Math.floor(t.getLocation().y));
			}
			return true;
		}
		
		override public function onTouchesMoved(touch:Array):Boolean
		{
			var t:CCTouch;
			for(var i:int = 0; i < touch.length; i++)
			{
				t = touch[i];
				MouseManager.getInstance().onMouseMove(t.getId(),Math.floor(t.getLocation().x),Math.floor(t.getLocation().y));
			}
			return true;
		}
		
		override public function onTouchesEnded(touch:Array):Boolean
		{
			var t:CCTouch;
			for(var i:int = 0; i < touch.length; i++)
			{
				t = touch[i];
				MouseManager.getInstance().onMouseUp(t.getId(),Math.floor(t.getLocation().x),Math.floor(t.getLocation().y));
			}
			return true;
		}
	}
}