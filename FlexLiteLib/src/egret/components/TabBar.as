package egret.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import egret.collections.ICollection;
	import egret.components.supportClasses.ListBase;
	import egret.core.IVisualElement;
	import egret.core.ns_egret;
	import egret.events.IndexChangeEvent;
	import egret.events.ListEvent;
	import egret.events.RendererExistenceEvent;
	
	use namespace ns_egret;  
	
	[EXML(show="true")]
	
	/**
	 * 选项卡组件
	 * @author dom
	 */	
	public class TabBar extends ListBase
	{
		/**
		 * 构造函数
		 */		
		public function TabBar()
		{
			super();
			tabChildren = false;
			tabEnabled = true;
			requireSelection = true;
		}
		
		/**
		 * requireSelection改变标志
		 */
		private var requireSelectionChanged:Boolean;
		
		/**
		 * @inheritDoc
		 */
		override public function set requireSelection(value:Boolean):void
		{
			if (value == requireSelection)
				return;
			
			super.requireSelection = value;
			requireSelectionChanged = true;
			invalidateProperties();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set dataProvider(value:ICollection):void
		{
			if(dataProvider is ViewStack)
			{
				dataProvider.removeEventListener("IndexChanged",onViewStackIndexChange);
				removeEventListener(IndexChangeEvent.CHANGE,onIndexChanged);
			}
			
			if(value is ViewStack)
			{
				value.addEventListener("IndexChanged",onViewStackIndexChange);
				addEventListener(IndexChangeEvent.CHANGE,onIndexChanged);
			}
			super.dataProvider = value;
		}
		/**
		 * 鼠标点击的选中项改变
		 */		
		private function onIndexChanged(event:IndexChangeEvent):void
		{
			ViewStack(dataProvider).setSelectedIndex(event.newIndex,false);
		}
		
		/**
		 * ViewStack选中项发生改变
		 */		
		private function onViewStackIndexChange(event:Event):void
		{
			setSelectedIndex(ViewStack(dataProvider).selectedIndex, false);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (requireSelectionChanged && dataGroup)
			{
				requireSelectionChanged = false;
				const n:int = dataGroup.numElements;
				for (var i:int = 0; i < n; i++)
				{
					var renderer:TabBarButton = dataGroup.getElementAt(i) as TabBarButton;
					if (renderer)
						renderer.allowDeselection = !requireSelection;
				}
			}
		}  
		
		/**
		 * @inheritDoc
		 */
		override protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
		{
			super.dataGroup_rendererAddHandler(event);
			
			const renderer:IItemRenderer = event.renderer; 
			if (renderer)
			{
				renderer.addEventListener(MouseEvent.MOUSE_DOWN, item_mouseDownHandler);
				//由于ItemRenderer.mouseChildren有可能不为false，在鼠标按下时会出现切换素材的情况，
				//导致target变化而无法抛出原生的click事件,所以此处监听MouseUp来抛出ItemClick事件。
				renderer.addEventListener(MouseEvent.MOUSE_UP, item_mouseUpHandler);
				if (renderer is TabBarButton)
					TabBarButton(renderer).allowDeselection = !requireSelection;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
		{   
			super.dataGroup_rendererRemoveHandler(event);
			
			const renderer:IItemRenderer = event.renderer;
			if (renderer)
			{
				renderer.removeEventListener(MouseEvent.MOUSE_DOWN, item_mouseDownHandler);
				//由于ItemRenderer.mouseChildren有可能不为false，在鼠标按下时会出现切换素材的情况，
				//导致target变化而无法抛出原生的click事件,所以此处监听MouseUp来抛出ItemClick事件。
				renderer.removeEventListener(MouseEvent.MOUSE_UP, item_mouseUpHandler);
			}
		}
		
		private var mouseDownItemRenderer:IItemRenderer;
		/**
		 * 鼠标在项呈示器上按下
		 */
		private function item_mouseDownHandler(event:MouseEvent):void
		{
			var itemRenderer:IItemRenderer = event.currentTarget as IItemRenderer;
			mouseDownItemRenderer = itemRenderer;
			stage.addEventListener(MouseEvent.MOUSE_UP,stage_mouseUpHandler,false,0,true);
			stage.addEventListener(Event.MOUSE_LEAVE,stage_mouseUpHandler,false,0,true);
		}
		/**
		 * 鼠标在项呈示器上弹起，抛出ItemClick事件。
		 */	
		private function item_mouseUpHandler(event:MouseEvent):void
		{
			var itemRenderer:IItemRenderer = event.currentTarget as IItemRenderer;
			if(itemRenderer!=mouseDownItemRenderer)
				return;
			var newIndex:int
			if (itemRenderer)
				newIndex = itemRenderer.itemIndex;
			else
				newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
			
			if (newIndex == selectedIndex)
			{
				if (!requireSelection)
					setSelectedIndex(NO_SELECTION, true);
			}
			else
				setSelectedIndex(newIndex, true);
			dispatchListEvent(event,ListEvent.ITEM_CLICK,itemRenderer);
		}
		/**
		 * 鼠标在舞台上弹起
		 */		
		private function stage_mouseUpHandler(event:Event):void
		{
			if(stage != null)
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP,stage_mouseUpHandler);
				stage.removeEventListener(Event.MOUSE_LEAVE,stage_mouseUpHandler);
			}
			mouseDownItemRenderer = null;
		}
	}
}