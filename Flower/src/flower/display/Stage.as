package flower.display
{
	import flower.events.Event;
	import flower.events.TouchEvent;
	import flower.geom.Matrix;

	public class Stage extends Sprite
	{
		public static var stages:Array = [];
		
		public function Stage()
		{
			_stage = this;
			stages.push(this);
		}
		
		/////////////////////////////////鼠标事件/////////////////////////////////////
		public function getMouseTarget(touchX:int,touchY:int,mutiply:Boolean):DisplayObject {
			var matrix:Matrix = Matrix.$matrix;
			matrix.identity();
			matrix.tx = touchX;
			matrix.ty = touchY;
			var target:DisplayObject = this._getMouseTarget(matrix,mutiply)||this;
			return target;
		}
		
		private var touchList:Array = [];
		public function onMouseDown(id:int,x:int,y:int):void
		{
			var mouse:Object = {
				id:0,
				mutiply:false,
				startX:0,
				startY:0,
				moveX:0,
				moveY:0,
				target:null
			};
			mouse.id = id;
			mouse.startX = x;
			mouse.startY = y;
			mouse.mutiply = touchList.length==0?false:true;
			touchList.push(mouse);
			
			var target:DisplayObject = this.getMouseTarget(x,y,mouse.mutiply);
			mouse.target = target;
			target.addListener(Event.REMOVED,onMouseTargetRemove,this);
			
			if(target)
			{
				var event:TouchEvent = new TouchEvent(TouchEvent.TOUCH_BEGIN);
				event.stageX = x;
				event.stageY = y;
				event.$target = target;
				event.touchX = Math.floor(target.touchX);
				event.touchY = Math.floor(target.touchY);
				target.dispatch(event);
			}
			
		}
		
		public function onMouseMove(id:int,x:int,y:int):void
		{
			var mouse:Object;
			for(var i:int = 0; i < this.touchList.length; i++)
			{
				if(touchList[i].id == id)
				{
					mouse = touchList[i];
					break;
				}
			}
			if(mouse == null) return;
			if(mouse.moveX == x && mouse.moveY == y) return;
			var target:DisplayObject = this.getMouseTarget(x,y,mouse.mutiply);
			mouse.moveX = x;
			mouse.moveY = y;
			if(target != mouse.target) {
				return;
			}
			if(target)
			{
				var event:TouchEvent = new TouchEvent(TouchEvent.TOUCH_MOVE);
				event.stageX = x;
				event.stageY = y;
				event.$target = target;
				event.touchX = Math.floor(target.touchX);
				event.touchY = Math.floor(target.touchY);
				target.dispatch(event);
			}
		}
		
		public function onMouseUp(id:int,x:int,y:int):void
		{
			var mouse:Object;
			for(var i:int = 0; i < this.touchList.length; i++)
			{
				if(touchList[i].id == id)
				{
					mouse = touchList.splice(i,1)[0];
					break;
				}
			}
			if(mouse == null) return;
			var target:DisplayObject = this.getMouseTarget(x,y,mouse.mutiply);
			var event:TouchEvent;
			if(target == mouse.target)
			{
				event = new TouchEvent(TouchEvent.TOUCH_END);
				event.stageX = x;
				event.stageY = y;
				event.$target = target;
				event.touchX = Math.floor(target.touchX);
				event.touchY = Math.floor(target.touchY);
				target.dispatch(event);
			} else {
				target = mouse.target;
				event = new TouchEvent(TouchEvent.TOUCH_RELEASE);
				event.stageX = x;
				event.stageY = y;
				event.$target = target;
				event.touchX = Math.floor(target.touchX);
				event.touchY = Math.floor(target.touchY);
				target.dispatch(event);
			}
		}
		
		private function onMouseTargetRemove(e:Event):void
		{
			for(var i:int = 0; i < this.touchList.length; i++)
			{
				if(touchList[i].target == e.target)
				{
					touchList.splice(i,1)[0];
					break;
				}
			}
		}
		////////////////////////////////End 鼠标事件/////////////////////////////////
		
		public function get stageWidth():int {
			return System.width;
		}
		
		public function get stageHeight():int {
			return System.height;
		}
	}
}