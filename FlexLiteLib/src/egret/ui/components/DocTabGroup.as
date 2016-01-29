package egret.ui.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import egret.collections.ArrayCollection;
	import egret.components.IItemRenderer;
	import egret.core.IVisualElement;
	import egret.events.IndexChangeEvent;
	import egret.events.UIEvent;
	import egret.ui.components.boxClasses.DocDropDownList;
	import egret.ui.events.CloseTabEvent;
	import egret.ui.events.DocumentEvent;
	import egret.ui.events.TabGroupEvent;
	import egret.ui.skins.DocTabGroupSkin;

	/**
	 * 文档选项卡，对应的数据是一个IDocumentData对象
	 */
	public class DocTabGroup extends TabGroup
	{
		public function DocTabGroup()
		{
			super();
			this.skinName = DocTabGroupSkin;
			this.panelRendererFunction = documentRenderer;
			this.addEventListener(TabGroupEvent.CLOSING_PANEL , onClosingPanel);
			this.addEventListener(TabGroupEvent.CLOSE_PANEL , onClosedPanel);
		}
		
		override protected function onFocusIn(event:FocusEvent):void
		{
			super.onFocusIn(event);
			
			var docEvent:DocumentEvent = new DocumentEvent(DocumentEvent.DOC_FOCUS_IN,true);
			this.dispatchEvent(docEvent);
		}

		/**
		 * 文档要显示的Panel对象
		 */
		private function documentRenderer(data:Object):Class
		{
			if(data.clazz)
				return data.clazz;
			else
				return null;
		}
		
		/**
		 * 添加一个文档
		 */
		public function addDocument(document:IDocumentData):void
		{
			dataProvider.addItem(document);
		}
		
		/**
		 * 移除一个文档
		 * @param document 要移除的对象
		 * @param dispatch 随后是否派发事件
		 */
		public function removeDocument(document:IDocumentData , dispatch:Boolean = true,direct:Boolean = false):void
		{
			var index:int = this.getDocumentIndex(document);
			if(index>-1)
			{
				if(dispatch)
					onClosePanel(index,direct);
				else
					dataProvider.removeItemAt(index);
			}
		}
		
		/**
		 * 选中的文档数据
		 */
		public function get selectedDocument():IDocumentData
		{
			if(selectedIndex>-1)
				return dataProvider.getItemAt(selectedIndex) as  IDocumentData;
			else
				return null;
		}

		public function set selectedDocument(value:IDocumentData):void
		{
			var index:int = dataProvider.getItemIndex(value);
			selectedIndex = index;
		}
		
		/**
		 * 获取指定位置的文档
		 */
		public function getDocumentAt(index:int):IDocumentData
		{
			return dataProvider.getItemAt(index) as IDocumentData;
		}
		
		/**
		 * 获取文档的位置
		 */
		public function getDocumentIndex(value:IDocumentData):int
		{
			return dataProvider.getItemIndex(value);
		}
		
		private var dataProviderChanged:Boolean;
		override public function set dataProvider(value:ArrayCollection):void
		{
			super.dataProvider = value;
			dataProviderChanged = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(dataProviderChanged)
			{
				dataProviderChanged = false;
				while(cacheDataArray.length>0)
				{
					removeDocumentPropery(cacheDataArray.shift());
				}
				for (var i:int = 0; i < dataProvider.length; i++) 
				{
					addDocumentPropery(dataProvider.getItemAt(i) as IDocumentData);
				}
			}
		}
		
		/**
		 * 添加一项
		 */		
		override protected function itemAdded(item:Object,index:int):void
		{
			addDocumentPropery(item as IDocumentData);
			super.itemAdded(item , index);
		}
		
		/**
		 * 移除一项
		 */
		override protected function itemRemoved(item:Object, index:int):void
		{
			removeDocumentPropery(item as IDocumentData);
			super.itemRemoved(item , index);
		}
		
		/**
		 * 添加文档数据属性
		 */
		private function addDocumentPropery(item:IDocumentData):void
		{
			item.owner = this;
			var cacheIndex:int = cacheDataArray.indexOf(item);
			if(cacheIndex>=0)
				cacheDataArray.splice(cacheIndex , 1);
			cacheDataArray.unshift(item);
			invalidateDisplayList();
		}
		
		/**
		 * 移除文档数据属性
		 */
		private function removeDocumentPropery(item:IDocumentData):void
		{
			item.owner = null;
			var cacheIndex:int = cacheDataArray.indexOf(item);
			if(cacheIndex>=0)
				cacheDataArray.splice(cacheIndex , 1);
			if(cacheDataArray.length > 0)
			{
				selectedIndex = -1;
				selectedDocument = cacheDataArray[0] as IDocumentData;
			}
			invalidateDisplayList();
		}
		
		private var lastDocument:IDocumentData;
		override protected function commitSelection(newIndex:int , dispatch:Boolean = true):void
		{
			super.commitSelection(newIndex);
			var _selectedDocument:IDocumentData = selectedDocument;
			if(_selectedDocument)
			{
				var cacheIndex:int = cacheDataArray.indexOf(_selectedDocument);
				if(cacheIndex>=0)
					cacheDataArray.splice(cacheIndex , 1);
				cacheDataArray.unshift(_selectedDocument);
			}
			if(_selectedDocument != lastDocument)
			{
				var documentEvent:DocumentEvent = new DocumentEvent(DocumentEvent.SELECTED_DOC_CHANGE , true);
				documentEvent.oldData = lastDocument;
				documentEvent.newData = _selectedDocument;
				this.dispatchEvent(documentEvent);
			}
			
			
			lastDocument = _selectedDocument;
		}
		
		/**
		 * [SkinPart] 显示标签个数的下拉框
		 */
		public var tabDropDown:DocDropDownList;
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName , instance);
			if(instance == titleTabBar)
			{
				titleTabBar.useVirtualLayout = false;
				titleTabBar.addEventListener(CloseTabEvent.CLOSE,onTabClose);
				titleTabBar.addEventListener(CloseTabEvent.CLOSE_ALL,onTabCloseAll);
				titleTabBar.addEventListener(CloseTabEvent.CLOSE_OTHER,onTabCloseOther);
			}
			else if(instance == tabDropDown)
			{
				tabDropDown.addEventListener(UIEvent.OPEN , dropDownOpen);
				tabDropDown.addEventListener(IndexChangeEvent.CHANGING , onSelectDropDown);
			}
		}
		
		/**
		 * 关闭标签
		 */		
		private function onTabClose(event:Event):void
		{
			event.stopImmediatePropagation();
			var index:int = (event.target as IItemRenderer).itemIndex;
			onClosePanel(index);
		}
		
		/**
		 * 关闭其他 
		 */		
		protected function onTabCloseOther(event:Event):void
		{
			event.stopImmediatePropagation();
			var index:int = (event.target as IItemRenderer).itemIndex;
			var tabPanelList:Array = [];
			for(var i:int = this.numElements - 1;i>=0;i--)
			{
				if(index != i)
					onClosePanel(i);
			}
		}
		
		/**
		 * 关闭全部 
		 */		
		protected function onTabCloseAll(event:Event):void
		{
			event.stopImmediatePropagation();
			var index:int = (event.target as IItemRenderer).itemIndex;
			var tabPanelList:Array = [];
			for(var i:int = this.numElements - 1;i>=0;i--)
			{
				onClosePanel(i);
			}
		}
		
		/**
		 * 正在关闭面板
		 */
		protected function onClosingPanel(event:TabGroupEvent):void
		{
			var documentData:IDocumentData = event.relateObject as IDocumentData;
			if(!documentData.dispatchEvent(event.clone()))
			{
				event.preventDefault();
			}
		}
		
		/**
		 * 面板关闭了
		 */
		protected function onClosedPanel(event:TabGroupEvent):void
		{
			var documentData:IDocumentData = event.relateObject as IDocumentData;
			documentData.dispatchEvent(event.clone());
		}
		
		/**
		 * 选中了下拉框中的项
		 */
		protected function onSelectDropDown(event:IndexChangeEvent):void
		{
			event.preventDefault();
			var item:Object = tabDropDown.dataProvider.getItemAt(event.newIndex);
			var index:int = dataProvider.getItemIndex(item);
			selectedIndex = index;
		}
		
		/**
		 * 下拉框打开
		 */
		protected function dropDownOpen(event:UIEvent):void
		{
			var arr:Array = [];
			for (var i:int = _maxTabElement; i < cacheDataArray.length; i++) 
			{
				var panelIndex:int = dataProvider.getItemIndex(cacheDataArray[i]);
				arr.push(dataProvider.getItemAt(panelIndex));
			}
			arr.sortOn("label");
			tabDropDown.dataProvider = new ArrayCollection(arr);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth , unscaledHeight);
			updateTitleBarElement();
		}
		
		/**
		 * 显示的最大标签数
		 */
		private var _maxTabElement:int = 0;
		
		/**
		 * 缓存面板的数组， 越在数组前面表示越是最近打开的。
		 */
		private var cacheDataArray:Array = [];
		
		/**
		 * 刷新TitleBar上显示的元素
		 */
		private function updateTitleBarElement():void
		{
			_maxTabElement = 0;
			menuButton.owner.validateNow();
			var elementNum:int = titleTabBar.dataGroup.numElements;
			var totalX:Number = 0;
			var maxElementIndex:int = -1;
			
			for (var i:int = 0; i < cacheDataArray.length ; i++) 
			{
				var elementIndex:int = dataProvider.getItemIndex(cacheDataArray[i]);
				var element:IVisualElement = titleTabBar.dataGroup.getElementAt(elementIndex);
				if(!element)
					continue;
				
				totalX+= element.layoutBoundsWidth-1;
				
				var maxX:Number = menuButton.layoutBoundsX - tabDropDown.layoutBoundsWidth-5;
				if(i == elementNum-1)
				{
					maxX = maxX+tabDropDown.layoutBoundsWidth;
				}
				if(totalX > maxX)
				{
					element.visible = false;
					element.includeInLayout = false;
				}
				else
				{
					_maxTabElement++;
					element.visible = true;
					element.includeInLayout = true;
					maxElementIndex = Math.max(maxElementIndex , elementIndex);
				}
			}
			titleTabBar.validateNow();
			if(elementNum <= _maxTabElement || maxElementIndex < 0)
			{
				tabDropDown.visible = false;
			}
			else
			{
				var lastElement:IVisualElement = titleTabBar.dataGroup.getElementAt(maxElementIndex);
				tabDropDown.visible = true;
				tabDropDown.label = String(elementNum - _maxTabElement);
				tabDropDown.x = lastElement.layoutBoundsX + lastElement.layoutBoundsWidth +5;
			}
		}
	}
}