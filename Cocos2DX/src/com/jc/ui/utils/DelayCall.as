package com.jc.ui.utils
{
	/**
	 *延迟调用函数管理器 
	 * @author MengJie.Li
	 * 
	 */	
	public class DelayCall
	{
		private static var calls:Array = [];
		
		/**
		 *添加延迟调用方法
		 * @param delay 延迟时间，单位秒
		 * @param call 回调方法
		 * @param owner 方法拥有者
		 * @param args 方法参数
		 * 
		 */		
		public static function addCall(delay:Number,call:Function,owner:*,...args):void
		{
			calls.push({"delay":delay,"call":call,"owner":owner,"args":args.length==0?null:args});
		}
		
		/**
		 *移除延迟调用方法 
		 * @param call 方法
		 * @param owner 方法拥有者
		 * 
		 */		
		public static function removeCall(call:Function,owner:*):void
		{
			for(var i:int = 0; i < calls.length; i++)
			{
				if(calls[i].call == call && calls[i].owner == owner)
				{
					calls.splice(i,1);
					i--;
				}
			}
		}
		
		/**
		 *更新驱动，外部不可调用，为EnterFrame专用 
		 * @param delate
		 * 
		 */		
		public static function update(delate:Number):void
		{
			for(var i:* in calls)
			{
				calls[i].delay -= delate;
				if(calls[i].delay <= 0)
				{
					calls[i].call.apply(calls[i].owner,calls[i].args);
					calls.splice(i,1);
					i--;
				}
			}
		}
	}
}