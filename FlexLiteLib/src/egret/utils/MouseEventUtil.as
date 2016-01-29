package egret.utils
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import egret.core.UIComponent;
	
	/**
	 * 
	 * @author dom
	 */
	public class MouseEventUtil
	{
		public static function addDownDragUpListeners(
			target:UIComponent, 
			handleDown:Function, 
			handleDrag:Function, 
			handleUp:Function):void
		{        
			var f:Function = function(e:Event):void 
			{
				var sbr:IEventDispatcher;
				switch(e.type)
				{
					case MouseEvent.MOUSE_DOWN:
						if (e.isDefaultPrevented())
							break;
						handleDown(e);
						sbr = target.systemManager.stage;
						sbr.addEventListener(MouseEvent.MOUSE_MOVE, f, true);
						sbr.addEventListener(MouseEvent.MOUSE_UP, f, true );
						sbr.addEventListener(Event.MOUSE_LEAVE, f, true);                        
						break;
					case MouseEvent.MOUSE_MOVE:
						handleDrag(e);
						break;
					case MouseEvent.MOUSE_UP:
						handleUp(e);
						sbr = target.systemManager.stage; 
						sbr.removeEventListener(MouseEvent.MOUSE_MOVE, f, true);
						sbr.removeEventListener(MouseEvent.MOUSE_UP, f, true);
						sbr.removeEventListener(Event.MOUSE_LEAVE, f, true); 
						break;
					case "removeHandler":
						target.removeEventListener("removeHandler", f);            
						target.removeEventListener(MouseEvent.MOUSE_DOWN, f);
						sbr = target.systemManager.stage;
						sbr.removeEventListener(MouseEvent.MOUSE_MOVE, f, true);
						sbr.removeEventListener(MouseEvent.MOUSE_UP, f, true);
						sbr.removeEventListener(Event.MOUSE_LEAVE, f, true); 
						break;
				}
			}
			target.addEventListener(MouseEvent.MOUSE_DOWN, f);
			target.addEventListener("removeHandler", f);
		}    
	}
}