package com.jc.ui.utils
{
	/**
	 *下一帧调用方法管理器 
	 * @author MengJie.Li
	 * 
	 */	
	public class CallLater
	{
		private static var calls:Array = [];
		
		/**
		 *添加下一帧调用方法
		 * @param call 方法
		 * @param owner 方法拥有者对象
		 * @param args 参数
		 * 
		 */		
		public static function add(call:Function,owner:*,...args):void
		{
			for(var i:int = 0; i < calls.length; i++)
			{
				if(calls[i].call == call && calls[i].owner == owner)
				{
					calls[i].args = args.length==0?null:args;
				}
			}
			calls.push({"call":call,"owner":owner,"args":args.length==0?null:args});
		}
		
		/**
		 *驱动，外部不可用，为EnterFrame专用 
		 * 
		 */		
		public static function run():void
		{
			var copy:Array = calls;
			calls = [];
			for(var i:int = 0; i < copy.length; i++)
			{
				copy[i].call.apply(copy[i].owner,copy[i].args);
			}
		}
	}
}