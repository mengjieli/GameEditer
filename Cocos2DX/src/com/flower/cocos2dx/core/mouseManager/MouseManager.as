package com.flower.cocos2dx.core.mouseManager
{
	import com.flower.ClassName;
	import com.flower.bufferPool.BufferPool;
	import com.flower.cocos2dx.core.StageCocos2DX;
	import com.flower.cocos2dx.display.DisplayObject;
	import com.flower.cocos2dx.event.Event;
	import com.flower.cocos2dx.event.MouseEvent;

	public class MouseManager
	{
		private var list:Vector.<MouseInfo>;
		private var stage:StageCocos2DX;
		
		public function MouseManager()
		{
		}
		
		public function init(stg:StageCocos2DX):void
		{
			list = new Vector.<MouseInfo>();
			stage = stg;
		}
		
		public function onMouseDown(id:int,x:int,y:int):void
		{
			var mouse:MouseInfo = BufferPool.create(ClassName.MouseInfo,MouseInfo);
			mouse.id = id;
			mouse.startX = x;
			mouse.startY = y;
			mouse.mutiply = list.length==0?false:true;
			list.push(mouse);
			
			var target:DisplayObject = stage.getMouseTarget2(x,y,mouse.mutiply);
			mouse.target = target;
			target.addEventListener(Event.REMOVE,onMouseTargetRemove,this);
			
			var eventList:Array;
			var event:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN);
			event.stageX = x;
			event.stageY = y;
			if(target)
			{
				event.target = target;
				var dis:DisplayObject = target;
				eventList = [];
				while(dis)
				{
					eventList.push(dis);
					dis = dis.getParent();
				}
			}
			if(eventList)
			{
				while(eventList.length)
				{
					event.currentTarget = eventList.shift();
					event.mouseX = event.currentTarget.getMouseX();
					event.mouseY = event.currentTarget.getMouseY();
					event.currentTarget.dispatchEvent(event);
				}
			}
		}
		
		public function onMouseMove(id:int,x:int,y:int):void
		{
			var mouse:MouseInfo;
			for(var i:int = 0; i < this.list.length; i++)
			{
				if(list[i].id == id)
				{
					mouse = list[i];
					break;
				}
			}
			if(mouse == null) return;
			if(mouse.moveX == x && mouse.moveY == y) return;
			
			stage.getMouseTarget2(x,y,mouse.mutiply);
			
			mouse.moveX = x;
			mouse.moveY = y;
			
			var target:DisplayObject = mouse.target;
			
			var eventList:Array;
			var event:MouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE);
			event.stageX = x;
			event.stageY = y;
			
			if(target)
			{
				event.target = target;
				var dis:DisplayObject = target;
				eventList = [];
				while(dis)
				{
					eventList.push(dis);
					dis = dis.getParent();
				}
			}
			if(eventList)
			{
				while(eventList.length)
				{
					event.currentTarget = eventList.shift();
					event.mouseX = event.currentTarget.getMouseX();
					event.mouseY = event.currentTarget.getMouseY();
					event.currentTarget.dispatchEvent(event);
				}
			}
		}
		
		public function onMouseUp(id:int,x:int,y:int):void
		{
			var mouse:MouseInfo;
			for(var i:int = 0; i < this.list.length; i++)
			{
				if(list[i].id == id)
				{
					mouse = list.splice(i,1)[0];
					break;
				}
			}
			if(mouse == null) return;
			
			var target:DisplayObject = mouse.target;
			
			var eventList:Array;
			var event:MouseEvent = new MouseEvent(MouseEvent.CLICK);
			event.stageX = x;
			event.stageY = y;
			
			if(target)
			{
				event.target = target;
				var dis:DisplayObject = target;
				eventList = [];
				while(dis)
				{
					eventList.push(dis);
					dis = dis.getParent();
				}
			}
			if(eventList)
			{
				while(eventList.length)
				{
					event.currentTarget = eventList.shift();
					event.mouseX = event.currentTarget.getMouseX();
					event.mouseY = event.currentTarget.getMouseY();
					event.currentTarget.dispatchEvent(event);
				}
			}
			
			BufferPool.cycle(ClassName.MouseInfo,mouse);
		}
		
		private function onMouseTargetRemove(e:Event):void
		{
			for(var i:int = 0; i < this.list.length; i++)
			{
				if(list[i].target == e.target)
				{
					list.splice(i,1)[0];
					break;
				}
			}
		}
		
		private static var ist:MouseManager;
		public static function getInstance():MouseManager
		{
			if(!ist)
			{
				ist = new MouseManager();
			}
			return ist;
		}
	}
}