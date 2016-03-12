package com.flower.cocos2dx.event
{
	import com.flower.ClassName;
	import com.flower.cocos2dx.ClassBase;

	/**
	 *消息类 
	 * @author MengJie.Li
	 * @time 2014/10/22
	 */	
	public class EventDispatcher extends ClassBase
	{
		/**消息存储对象*/
		private var changeBacks:Object;
		
		public function EventDispatcher()
		{
			super();
			this.className = ClassName.EventDispatcher;
			this.changeBacks = {};
		}
		
		/**
		 *注册消息 
		 * @param valueName 消息名
		 * @param back 回调函数
		 * @param owner 回调对象
		 * 
		 */		
		public function addEventListener(valueName:String,back:Function,owner:*):void
		{
			if(!this.changeBacks[valueName])
			{
				this.changeBacks[valueName] = [];
			}
			this.changeBacks[valueName].push({back:back,owner:owner});
		}
		
		/**
		 *抛出消息 
		 * @param valueName 消息名
		 * @param args 消息参数
		 * 
		 */		
		public function dispatchEvent(event:Event):void
		{
			event.target = this;
			var list:Array = this.changeBacks[event.type];
			if(list)
			{
				var copy:Array = [];
				for(var i:int = 0; i < list.length; i++)
				{
					copy[i] = list[i];
				}
				for(i = 0; i < copy.length; i++)
				{
					copy[i].back.apply(copy[i].owner,[event]);
				}
			}
		}
		
		/**
		 *根据消息名和回调函数注销消息 
		 * @param valueName 消息名
		 * @param back 回调函数
		 * 
		 */		
		public function removeEventListener(valueName:String,back:Function):void
		{
			if(!this.changeBacks[valueName])
			{
				return;
			}
			for(var i:int = 0; i < this.changeBacks[valueName].length; i++)
			{
				if(this.changeBacks[valueName][i].back == back)
				{
					this.changeBacks[valueName][i] = null;
					this.changeBacks[valueName].splice(i,1);
					break;
				}
			}
		}
		
		/**
		 *根据消息回调对象移除所有相关消息监听
		 * @param owner 消息回调对象
		 * 
		 */		
		public function removeEventsByOwner(owner:*):void
		{
			for(var o:* in this.changeBacks)
			{
				for(var i:int = 0; i < this.changeBacks[o].length; i++)
				{
					if(this.changeBacks[o][i].owner == owner)
					{
						this.changeBacks[o].splice(i,1);
						i--;
					}
				}
			}
		}
		
		public function cycleBuffer():void
		{
			for(var o:* in this.changeBacks)
			{
				delete this.changeBacks[o];
			}
		}
		
		/**
		 *清除内存对象 
		 * 
		 */	
		public function dispose():void
		{
			for(var o:* in this.changeBacks)
			{
				delete this.changeBacks[o];
			}
		}
	}
}