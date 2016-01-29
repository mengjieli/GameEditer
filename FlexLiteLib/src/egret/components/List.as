package egret.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import egret.components.supportClasses.ItemRenderer;
	import egret.components.supportClasses.ListBase;
	import egret.core.IVisualElement;
	import egret.core.NavigationUnit;
	import egret.core.ns_egret;
	import egret.events.IndexChangeEvent;
	import egret.events.ListEvent;
	import egret.events.RendererExistenceEvent;
	import egret.events.UIEvent;

	use namespace ns_egret;
	
	[EXML(show="true")]
	
	/**
	 * 列表组件
	 * @author dom
	 */
	public class List extends ListBase
	{
		private var _selectedByKeyboard:Boolean = true;
		public function List()
		{
			super();
			useVirtualLayout = true;
			selectedByKeyboard = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			if(!itemRenderer)
				itemRenderer = ItemRenderer;
			super.createChildren();
		}
		
		/**
		 * 是否使用虚拟布局,默认true
		 */		
		override public function get useVirtualLayout():Boolean
		{
			return super.useVirtualLayout;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set useVirtualLayout(value:Boolean):void
		{
			super.useVirtualLayout = value;
		}
		
		
		private var _allowMultipleSelection:Boolean = false;
		/**
		 * 是否允许同时选中多项
		 */
		public function get allowMultipleSelection():Boolean
		{
			return _allowMultipleSelection;
		}

		public function set allowMultipleSelection(value:Boolean):void
		{
			_allowMultipleSelection = value;
		}

		private var _selectedIndices:Vector.<int> = new Vector.<int>();
		
		private var _proposedSelectedIndices:Vector.<int>; 
		/**
		 * 当前选中的一个或多个项目的索引列表
		 */		
		public function get selectedIndices():Vector.<int>
		{
			if(_proposedSelectedIndices)
				return _proposedSelectedIndices;
			return _selectedIndices;
		}

		public function set selectedIndices(value:Vector.<int>):void
		{
			setSelectedIndices(value, false);
		}
		/**
		 * @inheritDoc
		 */
		override public function get selectedIndex():int
		{
			if(_proposedSelectedIndices)
			{
				if(_proposedSelectedIndices.length>0)
					return _proposedSelectedIndices[0];
				return -1;
			}
			return super.selectedIndex;
		}
		
		/**
		 * 当前选中的一个或多个项目的数据源列表
		 */		
		public function get selectedItems():Vector.<Object>
		{
			var result:Vector.<Object> = new Vector.<Object>();
			var list:Vector.<int> = selectedIndices;
			if (list)
			{
				var count:int = list.length;
				
				for (var i:int = 0; i < count; i++)
					result[i] = dataProvider.getItemAt(list[i]);  
			}
			
			return result;
		}
		
		public function set selectedItems(value:Vector.<Object>):void
		{
			var indices:Vector.<int> = new Vector.<int>();
			
			if (value)
			{
				var count:int = value.length;
				
				for (var i:int = 0; i < count; i++)
				{
					var index:int = dataProvider.getItemIndex(value[i]);
					if (index != -1)
					{ 
						indices.splice(0, 0, index);   
					}
					if (index == -1)
					{
						indices = new Vector.<int>();
						break;  
					}
				}
			}
			setSelectedIndices(indices,false);
		}
		/**
		 * 设置多个选中项
		 */
		ns_egret function setSelectedIndices(value:Vector.<int>, dispatchChangeEvent:Boolean = false):void
		{
			if (dispatchChangeEvent)
				dispatchChangeAfterSelection = (dispatchChangeAfterSelection || dispatchChangeEvent);
			
			if (value)
				_proposedSelectedIndices = value;
			else
				_proposedSelectedIndices = new Vector.<int>();
			invalidateProperties();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (_proposedSelectedIndices)
			{
				commitSelection();
			}
		}
		/**
		 * @inheritDoc
		 */
		override protected function commitSelection(dispatchChangedEvents:Boolean = true):Boolean
		{
			var oldSelectedIndex:Number = _selectedIndex;
			if(_proposedSelectedIndices)
			{
				_proposedSelectedIndices = _proposedSelectedIndices.filter(isValidIndex);
				
				if (!allowMultipleSelection && _proposedSelectedIndices.length>0)
				{
					var temp:Vector.<int> = new Vector.<int>(); 
					temp.push(_proposedSelectedIndices[0]); 
					_proposedSelectedIndices = temp;  
				}
				if (_proposedSelectedIndices.length>0)
				{
					_proposedSelectedIndex = _proposedSelectedIndices[0];
				}
				else
				{
					_proposedSelectedIndex = -1;
				}
			}
			
			var retVal:Boolean = super.commitSelection(false); 
			
			if (!retVal)
			{
				_proposedSelectedIndices = null;
				return false; 
			}
			
			if (selectedIndex > NO_SELECTION)
			{
				if (_proposedSelectedIndices)
				{
					if(_proposedSelectedIndices.indexOf(selectedIndex) == -1)
						_proposedSelectedIndices.push(selectedIndex);
				}
				else
				{
					_proposedSelectedIndices = new <int>[selectedIndex];
				}
			}
			
			if(_proposedSelectedIndices)
			{
				if(_proposedSelectedIndices.indexOf(oldSelectedIndex)!=-1)
					itemSelected(oldSelectedIndex,true);
				commitMultipleSelection(); 
			}
			
			if (dispatchChangedEvents && retVal)
			{
				var e:IndexChangeEvent; 
				
				if (dispatchChangeAfterSelection)
				{
					e = new IndexChangeEvent(IndexChangeEvent.CHANGE);
					e.oldIndex = oldSelectedIndex;
					e.newIndex = _selectedIndex;
					dispatchEvent(e);
					dispatchChangeAfterSelection = false;
				}
				
				dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
			}
			
			return retVal; 
		}
		/**
		 * 是否是有效的索引
		 */		
		private function isValidIndex(item:int, index:int, v:Vector.<int>):Boolean
		{
			return dataProvider && (item >= 0) && (item < dataProvider.length); 
		}
		
		/**
		 * 提交多项选中项属性
		 */			
		protected function commitMultipleSelection():void
		{
			var removedItems:Vector.<int> = new Vector.<int>();
			var addedItems:Vector.<int> = new Vector.<int>();
			var i:int;
			var count:int;
			
			if (_selectedIndices.length>0&& _proposedSelectedIndices.length>0)
			{
				count = _proposedSelectedIndices.length;
				for (i = 0; i < count; i++)
				{
					if (_selectedIndices.indexOf(_proposedSelectedIndices[i]) == -1)
						addedItems.push(_proposedSelectedIndices[i]);
				}
				count = _selectedIndices.length; 
				for (i = 0; i < count; i++)
				{
					if (_proposedSelectedIndices.indexOf(_selectedIndices[i]) == -1)
						removedItems.push(_selectedIndices[i]);
				}
			}
			else if (_selectedIndices.length>0)
			{
				removedItems = _selectedIndices;
			}
			else if (_proposedSelectedIndices.length>0)
			{
				addedItems = _proposedSelectedIndices;
			}
			
			_selectedIndices = _proposedSelectedIndices;
			
			if (removedItems.length > 0)
			{
				count = removedItems.length;
				for (i = 0; i < count; i++)
				{
					itemSelected(removedItems[i], false);
				}
			}
			
			if (addedItems.length>0)
			{
				count = addedItems.length;
				for (i = 0; i < count; i++)
				{
					itemSelected(addedItems[i], true);
				}
			}
			
			_proposedSelectedIndices = null;
		}
		
		/**
		 * @inheritDoc
		 */
		override ns_egret function isItemIndexSelected(index:int):Boolean
		{
			if (_allowMultipleSelection)
				return _selectedIndices.indexOf(index) != -1;
			
			return super.isItemIndexSelected(index);
		}
		/**
		 * @inheritDoc
		 */
		override protected function dataProviderRefreshed():void
		{
			if(_allowMultipleSelection)
				return;
			super.dataProviderRefreshed();
		}
		/**
		 * @inheritDoc
		 */
		override protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
		{
			super.dataGroup_rendererAddHandler(event);
			
			var renderer:DisplayObject = event.renderer as DisplayObject;
			if (renderer == null)
				return;
			
			renderer.addEventListener(MouseEvent.MOUSE_DOWN, item_mouseDownHandler);
			//由于ItemRenderer.mouseChildren有可能不为false，在鼠标按下时会出现切换素材的情况，
			//导致target变化而无法抛出原生的click事件,所以此处监听MouseUp来抛出ItemClick事件。
			renderer.addEventListener(MouseEvent.MOUSE_UP, item_mouseUpHandler);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
		{
			super.dataGroup_rendererRemoveHandler(event);
			
			var renderer:DisplayObject = event.renderer as DisplayObject;
			if (renderer == null)
				return;
			
			renderer.removeEventListener(MouseEvent.MOUSE_DOWN, item_mouseDownHandler);
			renderer.removeEventListener(MouseEvent.MOUSE_UP, item_mouseUpHandler);
		}
		/**
		 * @inheritDoc
		 */
		override protected function itemAdded(index:int):void
		{
			adjustSelection(index, true); 
		}
		/**
		 * @inheritDoc
		 */
		override protected function itemRemoved(index:int):void
		{
			adjustSelection(index, false);        
		}
		/**
		 * @inheritDoc
		 */
		override protected function adjustSelection(index:int, add:Boolean=false):void
		{
			var i:int; 
			var curr:Number; 
			var newInterval:Vector.<int> = new Vector.<int>(); 
			var e:IndexChangeEvent; 
			
			if (selectedIndex == NO_SELECTION || doingWholesaleChanges)
			{
				if (dataProvider && dataProvider.length == 1 && requireSelection)
				{
					newInterval.push(0);
					_selectedIndices = newInterval;   
					_selectedIndex = 0; 
					itemSelected(_selectedIndex, true);
					dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
				}
				return; 
			}
			
			if ((!selectedIndices && selectedIndex > NO_SELECTION) ||
				(selectedIndex > NO_SELECTION && selectedIndices.indexOf(selectedIndex) == -1))
			{
				commitSelection(); 
			}
			
			if (add)
			{
				for (i = 0; i < selectedIndices.length; i++)
				{
					curr = selectedIndices[i];
					
					if (curr >= index)
						newInterval.push(curr + 1); 
					else 
						newInterval.push(curr); 
				}
			}
			else
			{
				if ((!selectedIndices||selectedIndices.length==0) 
					&& selectedIndices.length == 1 
					&& index == selectedIndex && requireSelection)
				{
					if (dataProvider.length == 0)
					{
						newInterval = new Vector.<int>(); 
					}
					else
					{
						_proposedSelectedIndex = 0; 
						invalidateProperties();
						
						if (index == 0)
							return;
						
						newInterval.push(0);  
					}
				}
				else
				{    
					for (i = 0; i < selectedIndices.length; i++)
					{
						curr = selectedIndices[i]; 
						if (curr > index)
							newInterval.push(curr - 1); 
						else if (curr < index) 
							newInterval.push(curr);
					}
				}
			}
			
			var oldIndices:Vector.<int> = selectedIndices;  
			_selectedIndices = newInterval;
			_selectedIndex = getFirstItemValue(newInterval);
			if (_selectedIndices != oldIndices)
			{
				selectedIndexAdjusted = true; 
				invalidateProperties(); 
			}
		}
		
		private function getFirstItemValue(v:Vector.<int>):int
		{
			if (v && v.length > 0)
				return v[0]; 
			else 
				return -1; 
		}
		
		/**
		 * 是否捕获ItemRenderer以便在MouseUp时抛出ItemClick事件
		 */		
		ns_egret var captureItemRenderer:Boolean = true;
		
		private var mouseDownItemRenderer:IItemRenderer;
		/**
		 * 鼠标在项呈示器上按下
		 */		
		protected function item_mouseDownHandler(event:MouseEvent):void
		{
			var itemRenderer:IItemRenderer = event.currentTarget as IItemRenderer;
			mouseDownItemRenderer = itemRenderer;
			itemRenderer.addEventListener(MouseEvent.MOUSE_MOVE,item_mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP,stage_mouseUpHandler,false,0,true);
			stage.addEventListener(Event.MOUSE_LEAVE,stage_mouseUpHandler,false,0,true);
			
		}
		
		protected function item_mouseMoveHandler(event:MouseEvent):void
		{
			event.currentTarget.removeEventListener(MouseEvent.MOUSE_MOVE,item_mouseMoveHandler);
			var itemRenderer:IItemRenderer = event.currentTarget as IItemRenderer;
			var isInSelected:Boolean = false;
			for(var i:int = 0;i<selectedItems.length;i++)
			{
				if(itemRenderer.data == selectedItems[i])
				{
					isInSelected = true;
					break;
				}
			}
			if(isInSelected) return;
			if(itemRenderer!=mouseDownItemRenderer)
				return;
			var newIndex:int
			if (itemRenderer)
				newIndex = itemRenderer.itemIndex;
			else
				newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
			
			if(_allowMultipleSelection)
			{
				setSelectedIndices(calculateSelectedIndices(newIndex, event.shiftKey, event.ctrlKey), true);
			}else
			{
				setSelectedIndex(newIndex, true);
			}
			validateNow();
		}		
		
		/**
		 * 鼠标在项呈示器上弹起，抛出ItemClick事件。
		 */	
		protected function item_mouseUpHandler(event:MouseEvent):void
		{
			event.currentTarget.removeEventListener(MouseEvent.MOUSE_MOVE,item_mouseMoveHandler);
			
			var itemRenderer:IItemRenderer = event.currentTarget as IItemRenderer;
			
			if(itemRenderer!=mouseDownItemRenderer)
				return;
			
			var newIndex:int
			if (itemRenderer)
				newIndex = itemRenderer.itemIndex;
			else
				newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
			
			if(_allowMultipleSelection)
			{
				setSelectedIndices(calculateSelectedIndices(newIndex, event.shiftKey, event.ctrlKey), true);
			}else
			{
				setSelectedIndex(newIndex, true);
			}
			dispatchListEvent(event,ListEvent.ITEM_CLICK,itemRenderer);
		}
		
		/**
		 * 计算当前的选中项列表
		 */		
		private function calculateSelectedIndices(index:int, shiftKey:Boolean, ctrlKey:Boolean):Vector.<int>
		{
			var i:int; 
			var interval:Vector.<int> = new Vector.<int>();  
			if (!shiftKey)
			{
				if(ctrlKey)
				{
					if (_selectedIndices.length>0)
					{
						if (_selectedIndices.length == 1 && (_selectedIndices[0] == index))
						{
							if (!requireSelection)
								return interval; 
							
							interval.splice(0, 0, _selectedIndices[0]); 
							return interval; 
						}
						else
						{
							var found:Boolean = false; 
							for (i = 0; i < _selectedIndices.length; i++)
							{
								if (_selectedIndices[i] == index)
									found = true; 
								else if (_selectedIndices[i] != index)
									interval.splice(0, 0, _selectedIndices[i]);
							}
							if (!found)
							{
								interval.splice(0, 0, index);   
							}
							return interval; 
						} 
					}
					else
					{ 
						interval.splice(0, 0, index); 
						return interval; 
					}
				}
				else 
				{ 
					interval.splice(0, 0, index); 
					return interval; 
				}
			}
			else 
			{
				var start:int = _selectedIndices.length>0 ? _selectedIndices[_selectedIndices.length - 1] : 0; 
				var end:int = index; 
				if (start < end)
				{
					for (i = start; i <= end; i++)
					{
						interval.splice(0, 0, i); 
					}
				}
				else 
				{
					for (i = start; i >= end; i--)
					{
						interval.splice(0, 0, i); 
					}
				}
				return interval; 
			}
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
		
		/**
		 * 能否使用键盘来控制选中项
		 */
		public function get selectedByKeyboard():Boolean
		{
			return _selectedByKeyboard;
		}
		
		public function set selectedByKeyboard(value:Boolean):void
		{
			_selectedByKeyboard = value;
			if(_selectedByKeyboard)
				this.addEventListener(KeyboardEvent.KEY_DOWN,adjustSelectionAndCaretUponNavigation);
			else
				this.removeEventListener(KeyboardEvent.KEY_DOWN,adjustSelectionAndCaretUponNavigation);
		}
		
		/**
		 * 通过键盘导航键调整选中项
		 */
		protected function adjustSelectionAndCaretUponNavigation(event:KeyboardEvent):void
		{
			var navigationUnit:uint = event.keyCode;
			
			if (!NavigationUnit.isNavigationUnit(event.keyCode))
				return; 
			
			var proposedNewIndex:int = layout.getNavigationDestinationIndex(selectedIndex, navigationUnit);
			if (proposedNewIndex == -1)
				return;
			
			event.preventDefault();
			
			if (allowMultipleSelection && event.shiftKey && selectedIndices)
			{
				var startIndex:int = 0;
				if (selectedIndices && selectedIndices.length > 0)
					startIndex = selectedIndices[selectedIndices.length - 1]; 
				
				var newInterval:Vector.<int> = new Vector.<int>();
				var i:int; 
				if (startIndex <= proposedNewIndex)
				{
					for (i = startIndex; i <= proposedNewIndex; i++)
					{
						newInterval.splice(0, 0, i); 
					}
				}
				else 
				{
					for (i = startIndex; i >= proposedNewIndex; i--)
					{
						newInterval.splice(0, 0, i); 
					}
				}
				setSelectedIndices(newInterval, true);  
				ensureIndexIsVisible(proposedNewIndex); 
			}
			else
			{
				setSelectedIndex(proposedNewIndex, true);
				ensureIndexIsVisible(proposedNewIndex);
			}
			
			if(stage && !stage.focus)
				setFocus();
		}
		
		/**
		 * 滚动数据项以使其可见的简便处理方法
		 */
		public function ensureIndexIsVisible(index:int):void
		{
			if (!layout)
				return;
			
			var spDelta:Point = dataGroup.layout.getScrollPositionDeltaToElement(index);
			if (spDelta)
			{
				dataGroup.horizontalScrollPosition += spDelta.x;
				dataGroup.verticalScrollPosition += spDelta.y;
				dataGroup.validateNow();
			}
		}
	}
}