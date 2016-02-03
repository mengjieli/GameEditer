package main.panels.contenView
{
	import flash.events.MouseEvent;
	
	import egret.components.Button;
	import egret.core.UIGlobals;

	public class ContentCloseButton extends Button
	{
		public function ContentCloseButton()
		{
		}
		
		public function onMouseEvent(event:MouseEvent):void
		{
			switch (event.type)
			{
				case MouseEvent.ROLL_OVER:
				{
					if (event.buttonDown && !mouseCaptured)
						return;
					hovered = true;
					break;
				}
					
				case MouseEvent.ROLL_OUT:
				{
					hovered = false;
					break;
				}
					
				case MouseEvent.MOUSE_DOWN:
				{
					mouseCaptured = true;
					break;
				}
					
				case MouseEvent.MOUSE_UP:
				{
					if (event.target == this)
					{
						hovered = true;
						
						if (mouseCaptured)
						{
							buttonReleased();
							mouseCaptured = false;
						}
					}
					break;
				}
				case MouseEvent.CLICK:
				{
					if (!enabled)
						event.stopImmediatePropagation();
					else
						clickHandler(MouseEvent(event));
					return;
				}
			}
			if(UIGlobals.useUpdateAfterEvent)
				event.updateAfterEvent();
		}
	}
}