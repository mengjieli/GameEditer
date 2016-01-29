package egret.ui.proxy
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * 某一个基本鼠标响应控件的舞台代理，专管事件相关。
	 * 直接引用并添加事件即可，代理内部会等到舞台被赋值之后将之前添加的事件进行添加的。 
	 * @author 雷羽佳 2013.10.20 3:52 
	 * 
	 */	
	public class StageProxy implements IEventDispatcher
	{
		private var isDisposed:Boolean = false;
		private var _stage:Stage;
		private var _target:DisplayObject;
		
		
		private var $eventDict:Dictionary;	

		private var _enable:Boolean = true;

		
		public function StageProxy(target:DisplayObject)
		{
			_target = target;
			_target.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		public function get enable():Boolean
		{
			return _enable;
		}
		
		public function set enable(value:Boolean):void
		{
			_enable = value;
		}
		
		private function get _eventDict():Dictionary
		{
			if($eventDict == null)
			{
				$eventDict = new Dictionary();
			}
			return $eventDict;
		}
		
		protected function addedToStageHandler(event:Event):void
		{
//			_target.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			//如果还没被添加到舞台就被销毁了,销毁之后才添加到的舞台,则不进行赋值
			if(isDisposed)
			{
				return;
			}
			
			var key:String
			if(_stage != null)
			{
				for(key in _eventDict)
				{
					_stage.removeEventListener(key,callEventHandler);
				}
			}
			
			_stage = _target.stage;
			for(key in _eventDict)
			{
				_stage.addEventListener(key,callEventHandler);
			}
		
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if(isDisposed)
			{
				return;
			}
			
			//这种情况就是,显示对象早已被添加到了显示列表.但是后期才对显示对象的舞台代理进行操作
			if(_stage == null && _target.stage != null)
			{
				_stage = _target.stage;
//				_target.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			}
			
			if(_stage != null)
			{
				if(_eventDict[type] == null)
				{
					_stage.addEventListener(type,callEventHandler);
				}
			}
			
			if(_eventDict[type] == null)
			{
				_eventDict[type] = listener;
			}else if(_eventDict[type] is Function)
			{
				if(_eventDict[type] != listener)
				{
					var tmpArr:Array = [_eventDict[type]];
					_eventDict[type] = tmpArr;
					tmpArr = _eventDict[type];
					tmpArr.push(listener);
				}
			}else if(_eventDict[type] is Array)
			{
				var isHave:Boolean = false;
				var handlerArr:Array = _eventDict[type];
				for(var i:int = 0;i<handlerArr.length;i++)
				{
					if(handlerArr[i] == listener)
					{
						isHave = true;
						break;
					}
				}
				if(!isHave)
				{
					handlerArr.push(listener);
				}
			}
		}
		
		
		private function callEventHandler(event:Event):void
		{
			if(isDisposed == true) return;
			if(_enable == true)
			{
				if(_eventDict[event.type] == null)
				{
					_stage.removeEventListener(event.type,callEventHandler);
					//ErrorManager.instance.throwException("事件行为出现莫名异常");
				}else if(_eventDict[event.type] is Function)
				{
					var func:Function = _eventDict[event.type];
					func(event);
				}else if(_eventDict[event.type] is Array)
				{
					var arr:Array = _eventDict[event.type];
					for(var i:int = 0;i<arr.length;i++)
					{
						arr[i](event);
					}
				}
			}
		}
		
		
		/**
		 * 移除一个事件,listener为空的时候，会将此type的时间全部移除
		 * @param type
		 * @param listener
		 * 
		 */		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			var tmpArr:Array;
			if(listener == null)
			{
				if(_eventDict[type] == null)
				{
					
				}else if(_eventDict[type] is Function)
				{
					_eventDict[type] = null;
					delete _eventDict[type];
				}else if(_eventDict[type] is Array)
				{
					tmpArr = _eventDict[type];
					while(tmpArr.length>0)
					{
						tmpArr.pop();
					}
					delete _eventDict[type];
				}	
				if(_stage != null)
					_stage.removeEventListener(type,callEventHandler);
			}else
			{
				if(_eventDict[type] == null)
				{
					
				}else if(_eventDict[type] is Function)
				{
					if(_eventDict[type] == listener)
					{
						_eventDict[type] = null;
						delete _eventDict[type];
						if(_stage != null)
							_stage.removeEventListener(type,callEventHandler);
					}
				}else if(_eventDict[type] is Array)
				{
					tmpArr = _eventDict[type];
					for(var i:int = 0;i<tmpArr.length;i++)
					{
						if(tmpArr[i] == listener)
						{
							for(var j:int = i;j<tmpArr.length-1;j++)
							{
								tmpArr[j] = tmpArr[j+1];
							}
							tmpArr.pop();
							break;
						}
					}
					if(tmpArr.length == 0)
					{
						_eventDict[type] = null;
						delete _eventDict[type];
						if(_stage != null)
							_stage.removeEventListener(type,callEventHandler);
					}
				}
			}
		}
		
		/**
		 * 返回一个回调数组,此数组为克隆数组
		 * @param event
		 * @return 
		 * 
		 */		
		public function getEventHandlers(event:String):Array
		{
			var arr:Array = [];
			if(_eventDict[event] == null)
			{
				
			}else if(_eventDict[event] is Function)
			{
				arr.push(_eventDict[event]);
			}else if(_eventDict[event] is Array)
			{
				var tmpArr:Array = _eventDict[event];
				for(var i:int = 0;i<tmpArr.length;i++)
				{
					arr.push(tmpArr[i]);
				}
			}
			return arr;
		}
		
		public function dispose():void
		{
			isDisposed = true;			
			var keyList:Array = [];
			for(var eventType:String in _eventDict)
			{
				if(_stage != null)
					_stage.removeEventListener(eventType,callEventHandler);
				
				if(_eventDict[eventType] is Function)
				{
					_eventDict[eventType] = null;
				}else if(_eventDict[eventType] is Array)
				{
					var arr:Array = _eventDict[eventType];
					while(arr.length>0)
					{
						arr.pop();
					}
				}
				keyList.push(eventType);
			}
			for(var i:int = 0;i<keyList.length;i++)
			{
				delete _eventDict[keyList[i]];
			}		
			_stage = null;
			
		}
		
	
		
		public function dispatchEvent(event:Event):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
		
	}
}