package com.jc.ui.utils
{
	/**
	 *每一帧调用方法管理器
	 * @author MengJie.Li
	 * 
	 */	
	public class EnterFrame
	{
		private static var enterFrames:Array = [];
		private static var waitAdd:Array = [];
		public static var curTime:Number = 0;
		
		/**
		 *添加帧循环调用，每一帧都会调用 
		 * @param call 方法
		 * @param owner 方法拥有对象
		 * 
		 */		
		public static function add(call:Function,owner:*):void
		{
			for(var i:int = 0; i < enterFrames.length; i++)
			{
				if(enterFrames[i].call == call && enterFrames[i].owner == owner)
				{
					return;
				}
			}
			for(i = 0; i < waitAdd.length; i++)
			{
				if(waitAdd[i].call == call && waitAdd[i].owner == owner)
				{
					return;
				}
			}
			waitAdd.push({"call":call,"owner":owner});
		}
		
		/**
		 *删除帧循环调用
		 * @param call 方法
		 * @param owner 方法拥有对象
		 * 
		 */		
		public static function del(call:Function,owner:*):void
		{
			for(var i:int = 0; i < enterFrames.length; i++)
			{
				if(enterFrames[i].call == call && enterFrames[i].owner == owner)
				{
					enterFrames.splice(i,1);
					return;
				}
			}
			for(i = 0; i < waitAdd.length; i++)
			{
				if(waitAdd[i].call == call && waitAdd[i].owner == owner)
				{
					waitAdd.splice(i,1);
					return;
				}
			}
		}
		
		public static var updateFactor:Number = 1;
		/**
		 *驱动，此方法应为引擎驱动 
		 * @param delate
		 * 
		 */		
		public static function update(delate:Number):void
		{
			curTime += delate;
			
			CallLater.run();
			
			DelayCall.update(delate*updateFactor);
			
			if(waitAdd.length)
			{
				enterFrames = enterFrames.concat(waitAdd);
				waitAdd = [];
			}
			
			var copy:Array = enterFrames;
			for(var i:int = 0; i < copy.length; i++)
			{
				copy[i].call.apply(copy[i].owner,[delate*updateFactor]);
			}
		}
	}
}