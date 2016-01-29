package egret.ui.components
{
	import flash.events.MouseEvent;
	
	import egret.components.IItemRenderer;
	import egret.components.SkinnableComponent;
	import egret.components.TabBar;
	import egret.core.IVisualElement;
	import egret.core.ns_egret;
	import egret.events.RendererExistenceEvent;

	use namespace ns_egret;  
	
	/**
	 * 图标选项卡组件 
	 * @author 雷羽佳
	 * 
	 */	
	public class IconTabBar extends TabBar
	{
		public function IconTabBar()
		{
			super();
			
		}
		
		public var firstButtonSkin:Class;
		public var middleButtonSkin:Class;
		public var lastButtonSkin:Class;
		
		override public function updateRenderer(renderer:IItemRenderer, itemIndex:int, data:Object):IItemRenderer
		{
			if(itemIndex == 0 && firstButtonSkin)
			{
				(renderer as SkinnableComponent).skinName = firstButtonSkin;
			}else if(itemIndex == dataProvider.length-1 && lastButtonSkin)
			{
				(renderer as SkinnableComponent).skinName = lastButtonSkin;
			}else if(middleButtonSkin)
			{
				(renderer as SkinnableComponent).skinName = middleButtonSkin;
			}
			return super.updateRenderer(renderer,itemIndex,data);
		}
		
		override protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
		{
			super.dataGroup_rendererAddHandler(event);
			
			const renderer:IItemRenderer = event.renderer;
			if (renderer)
				renderer.removeEventListener(MouseEvent.MOUSE_DOWN, item_mouseDownHandler);
		}
		
		private function item_mouseDownHandler(event:MouseEvent):void
		{
			var newIndex:int;
			if (event.currentTarget is IItemRenderer)
				newIndex = IItemRenderer(event.currentTarget).itemIndex;
			else
				newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
			
			var oldSelectedIndex:int = selectedIndex;
			if (newIndex == selectedIndex)
			{
				if (!requireSelection)
					setSelectedIndex(NO_SELECTION, true);
			}
			else
				setSelectedIndex(newIndex, true);
		}
	}
}