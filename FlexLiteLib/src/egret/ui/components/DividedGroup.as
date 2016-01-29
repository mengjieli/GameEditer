package egret.ui.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import egret.components.Group;
	import egret.components.SkinnableContainer;
	import egret.core.IVisualElement;
	import egret.core.ns_egret;
	import egret.managers.CursorManager;
	import egret.ui.core.Cursors;
	
	use namespace ns_egret
	
	/**
	 * 带分割线的容器
	 * @author xzper
	 */
	public class DividedGroup extends SkinnableContainer
	{
		public function DividedGroup()
		{
			super();
		}
		
		/**
		 * [SkinParts] 分割线
		 */
		public var dividerLine:Class;
		
		/**
		 * [SkinParts] 分割线的容器
		 */
		public var dividerGroup:Group;
		
		protected var dividers:Array = [];
		
		protected function get cursorName():String
		{
			return "";
		}
		
		private function createDivider(firstChild:IVisualElement, secondChild:IVisualElement):void
		{
			var divider:IVisualElement = new dividerLine();
			divider.addEventListener(MouseEvent.MOUSE_OVER , onDividerMouseOver);
			divider.addEventListener(MouseEvent.MOUSE_OUT , onDividerMouseOut);
			divider.addEventListener(MouseEvent.MOUSE_DOWN , onDividerMouseDown);
			dividers.push({"line":divider, "prev":firstChild, "next":secondChild});
			this.dividerGroup.addElement(divider);
		}
		
		private function recycleDivider(index:int):void
		{
			if(index>=dividers.length||index<0)
				return
			var divider:IVisualElement = dividers[index]["line"];
			divider.removeEventListener(MouseEvent.MOUSE_OVER , onDividerMouseOver);
			divider.removeEventListener(MouseEvent.MOUSE_OUT , onDividerMouseOut);
			divider.removeEventListener(MouseEvent.MOUSE_DOWN , onDividerMouseDown);
			dividers.splice(index, 1);
			this.dividerGroup.removeElement(divider);
		}
		
		private function getDividerIndex(divider:Object):int
		{
			for (var i:int = 0; i < dividers.length; i++) 
			{
				if(dividers[i].line == divider)
					return i;
			}
			return -1;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth , unscaledHeight);
			if(!contentGroup)
				return;
			var prevElement:IVisualElement;
			var numLayoutElement:int = 0;
			for (var i:int = 0; i < numElements; i++)
			{
				var element:IVisualElement = this.getElementAt(i);
				if(element.includeInLayout)
				{
					numLayoutElement++;
					if(prevElement)
					{
						var dividerIndex:int = numLayoutElement/2 - 1;
						if(dividerIndex<dividers.length)
						{
							dividers[dividerIndex]["prev"] = prevElement;
							dividers[dividerIndex]["next"] = element;
						}
						else
						{
							createDivider(prevElement, element);
						}
						contentGroup.validateNow();
						layoutDivider(dividers[dividerIndex]["line"], prevElement, element);
						prevElement = null;
					}
					else
					{
						prevElement = element;
						continue;
					}
				}
			}
			
			var numDivider:int = Math.floor(numLayoutElement/2);
			while(dividers.length>numDivider)
			{
				recycleDivider(dividers.length-1);
			}
		}
		
		/**
		 * 更新分割线的位置，子类重写此方法
		 */
		protected function layoutDivider(divider:IVisualElement, prev:IVisualElement, next:IVisualElement):void
		{
		}
		
		private function onDividerMouseOver(e:MouseEvent):void
		{
			CursorManager.setCursor(cursorName);
		}
		
		private function onDividerMouseOut(e:MouseEvent):void
		{
			CursorManager.setCursor(Cursors.AUTO);
		}
		
		private function onDividerMouseDown(e:MouseEvent):void
		{
			CursorManager.setCursor(cursorName);
			startDividerDrag(e);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onDividerMouseUp, true);
		}
		
		private function onDividerMouseUp(e:MouseEvent):void
		{
			CursorManager.setCursor(Cursors.AUTO);
			stopDividerDrag(e);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onDividerMouseUp, true);
		}
		
		protected var activeDivider:Object;
		/**
		 * 拖拽时代理UI
		 */
		protected var dragUI:IVisualElement;
		
		protected function startDividerDrag(e:MouseEvent):void
		{
			var index:int = getDividerIndex(e.currentTarget);
			activeDivider = dividers[index];
			
			dragUI = new dividerLine();
			dragUI.alpha = 0.8;
			dragUI.x = e.currentTarget.x;
			dragUI.y = e.currentTarget.y;
			this.dividerGroup.addElement(dragUI);
			
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, dragMove, true);
		}
		
		protected function stopDividerDrag(e:MouseEvent):void
		{
			applyDrag(e);
			activeDivider = null;
			this.dividerGroup.removeElement(dragUI);
			dragUI = null;
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragMove, true);
		}
		
		/**
		 * 应用拖拽结果
		 */
		protected function applyDrag(e:MouseEvent):void
		{
			
		}
		
		/**
		 * 拖拽移动时
		 */
		protected function dragMove(e:MouseEvent):void
		{
			
		}
	}
}