package egret.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import egret.components.supportClasses.GroupBase;
	import egret.core.IContainer;
	import egret.core.IVisualElement;
	import egret.core.IVisualElementContainer;
	import egret.core.ns_egret;
	import egret.events.ElementExistenceEvent;
	import egret.layouts.AccordionLayout;
	import egret.layouts.supportClasses.LayoutBase;
	import egret.skins.vector.ToggleButtonSkin;

	use namespace ns_egret;
	
	
	/**
	 * 折叠面板 
	 * @author 雷羽佳
	 * 
	 */	
	public class AccordionGroup extends GroupBase implements IVisualElementContainer
	{
		public function AccordionGroup()
		{
			super();
			super.layout = new AccordionLayout();
		}
		
		/**
		 * 标题栏皮肤,主机组件是ToggleButton
		 */		
		public var accordionButtonSkinClass:Class;
		/**
		 * 标题栏皮肤,主机组件是ToggleButton
		 */		
		public var accordionButtonClass:Class;
		/**
		 * 设置此属性无效
		 */
		override public function set layout(value:LayoutBase):void
		{
			
		}
		
		/**
		 *  createChildren()方法已经执行过的标记
		 */		
		private var createChildrenCalled:Boolean = false;
		
		override protected function createChildren():void
		{
			super.createChildren();
			createChildrenCalled = true;
			if(elementsContentChanged)
			{
				elementsContentChanged = false;
				setElementsContent(_elementsContent);
			}
		}
		
		/**
		 * elementsContent改变标志 
		 */		
		private  var elementsContentChanged:Boolean = false;
		
		private var _elementsContent:Array = [];
		/**
		 * 返回子元素列表
		 */		
		ns_egret function getElementsContent():Array
		{
			return _elementsContent;
		}
		
		/**
		 * 设置容器子对象数组 。数组包含要添加到容器的子项列表，
		 * 之前的已存在于容器中的子项列表被全部移除后添加列表里
		 * 的每一项到容器。设置该属性时会对您输入的数组进行一次
		 * 浅复制操作，所以您之后对该数组的操作不会影响到添加到
		 * 容器的子项列表数量。 
		 * @param value
		 * 
		 */		
		public function set elementsContent(value:Array):void
		{
			if(value==null)
				value = [];
			if(value==_elementsContent)
				return;
			if (createChildrenCalled)
			{
				setElementsContent(value);
			}
			else
			{
				elementsContentChanged = true;
				for (var i:int = _elementsContent.length - 1; i >= 0; i--)
				{
					elementRemoved(_elementsContent[i], i);
				}
				_elementsContent = value;
			}
		}
		
		/**
		 * 设置容器子对象列表
		 */		
		private function setElementsContent(value:Array):void
		{
			var i:int;
			
			for (i = _elementsContent.length - 1; i >= 0; i--)
			{
				elementRemoved(_elementsContent[i], i);
			}
			
			_elementsContent = value.concat();
			
			var n:int = _elementsContent.length;
			for (i = 0; i < n; i++)
			{   
				var elt:IVisualElement = _elementsContent[i];
				
				if(elt.parent is IVisualElementContainer)
					IVisualElementContainer(elt.parent).removeElement(elt);
				
				elementAdded(elt, i);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get numElements():int
		{
			return _elementsContent.length;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getElementAt(index:int):IVisualElement
		{
			checkForRangeError(index);
			return _elementsContent[index];
		}
		
		private function checkForRangeError(index:int, addingElement:Boolean = false):void
		{
			var maxIndex:int = _elementsContent.length - 1;
			
			if (addingElement)
				maxIndex++;
			
			if (index < 0 || index > maxIndex)
				throw new RangeError("索引:\""+index+"\"超出可视元素索引范围");
		}
		
		/**
		 * @inheritDoc
		 */
		public function addElement(element:IVisualElement):IVisualElement
		{
			var index:int = numElements;
			
			if (element.parent == this)
				index = numElements-1;
			
			return addElementAt(element, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addElementAt(element:IVisualElement, index:int):IVisualElement
		{
			if (element == this)
				return element;
			
			checkForRangeError(index, true);
			
			var host:Object = element.owner; 
			if (host == this||element.parent==this)
			{
				setElementIndex(element, index);
				return element;
			}
			else if(host is IContainer)
			{
				IContainer(host).removeElement(element);
			}
			
			_elementsContent.splice(index, 0, element);
			
			if (!elementsContentChanged)
				elementAdded(element, index);
			
			return element;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeElement(element:IVisualElement):IVisualElement
		{
			return removeElementAt(getElementIndex(element));
		}
		/**
		 * @inheritDoc
		 */
		public function removeElementAt(index:int):IVisualElement
		{
			checkForRangeError(index);
			
			var element:IVisualElement = _elementsContent[index];
			
			if (!elementsContentChanged)
				elementRemoved(element, index);
			
			_elementsContent.splice(index, 1);
			
			return element;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeAllElements():void
		{
			for (var i:int = numElements - 1; i >= 0; i--)
			{
				removeElementAt(i);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getElementIndex(element:IVisualElement):int
		{
			return _elementsContent.indexOf(element);
		}
		/**
		 * @inheritDoc
		 */
		public function setElementIndex(element:IVisualElement, index:int):void
		{
			checkForRangeError(index);
			
			var oldIndex:int = getElementIndex(element);
			if (oldIndex==-1||oldIndex == index)
				return;
			
			if (!elementsContentChanged)
				elementRemoved(element, oldIndex, false);
			
			_elementsContent.splice(oldIndex, 1);
			_elementsContent.splice(index, 0, element);
			
			if (!elementsContentChanged)
				elementAdded(element, index, false);
		}
		
		/**
		 * @inheritDoc
		 */
		public function swapElements(element1:IVisualElement, element2:IVisualElement):void
		{
			swapElementsAt(getElementIndex(element1), getElementIndex(element2));
		}
		/**
		 * @inheritDoc
		 */
		public function swapElementsAt(index1:int, index2:int):void
		{
			checkForRangeError(index1);
			checkForRangeError(index2);
			
			if (index1 > index2)
			{
				var temp:int = index2;
				index2 = index1;
				index1 = temp; 
			}
			else if (index1 == index2)
				return;
			
			var element1:IVisualElement = _elementsContent[index1];
			var element2:IVisualElement = _elementsContent[index2];
			if (!elementsContentChanged)
			{
				elementRemoved(element1, index1, false);
				elementRemoved(element2, index2, false);
			}
			
			_elementsContent.splice(index2, 1);
			_elementsContent.splice(index1, 1);
			
			_elementsContent.splice(index1, 0, element2);
			_elementsContent.splice(index2, 0, element1);
			
			if (!elementsContentChanged)
			{
				elementAdded(element2, index1, false);
				elementAdded(element1, index2, false);
			}
		}
		
		/**
		 * 添加一个显示元素到容器
		 */		
		ns_egret function elementAdded(element:IVisualElement, index:int, notifyListeners:Boolean = true):void
		{
			if(element is DisplayObject)
				addToDisplayListAt(DisplayObject(element), index*2);
			
			var button:ToggleButton;
			if(accordionButtonClass)
			{
				button = new accordionButtonClass();
			}else
			{
				button = new ToggleButton();
			}
			button.selected = element.visible;
			button.visible = element.includeInLayout;
			if(accordionButtonSkinClass)
				button.skinName = accordionButtonSkinClass;
			else
				button.skinName = ToggleButtonSkin;
			
			button.label = element["name"];
			if(button.hasOwnProperty("icon") && element["icon"])
			{
				button["icon"] = element["icon"];
			}
			addToDisplayListAt(button,index*2+1);
			button.addEventListener(Event.CHANGE,onButtonChange);
			
			if (notifyListeners)
			{
				if (hasEventListener(ElementExistenceEvent.ELEMENT_ADD))
					dispatchEvent(new ElementExistenceEvent(
						ElementExistenceEvent.ELEMENT_ADD, false, false, element, index));
			}
			
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * 从容器移除一个显示元素
		 */		
		ns_egret function elementRemoved(element:IVisualElement, index:int, notifyListeners:Boolean = true):void
		{
			if (notifyListeners)
			{        
				if (hasEventListener(ElementExistenceEvent.ELEMENT_REMOVE))
					dispatchEvent(new ElementExistenceEvent(
						ElementExistenceEvent.ELEMENT_REMOVE, false, false, element, index));
			}
			
			var button:ToggleButton = super.removeFromDisplayListAt(index*2+1) as ToggleButton;
			button.removeEventListener(Event.CHANGE,onButtonChange);
			
			var childDO:DisplayObject = element as DisplayObject; 
			if (childDO && childDO.parent == this)
			{
				super.removeFromDisplayList(childDO);
			}
			
			invalidateSize();
			invalidateDisplayList();
		}
		
		private static const errorStr:String = "在此组件中不可用，若此组件为容器类，请使用";
		[Deprecated] 
		/**
		 * addChild()在此组件中不可用，若此组件为容器类，请使用addElement()代替
		 */		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			throw(new Error("addChild()"+errorStr+"addElement()代替"));
		}
		[Deprecated] 
		/**
		 * addChildAt()在此组件中不可用，若此组件为容器类，请使用addElementAt()代替
		 */		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			throw(new Error("addChildAt()"+errorStr+"addElementAt()代替"));
		}
		[Deprecated] 
		/**
		 * removeChild()在此组件中不可用，若此组件为容器类，请使用removeElement()代替
		 */		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			throw(new Error("removeChild()"+errorStr+"removeElement()代替"));
		}
		[Deprecated] 
		/**
		 * removeChildAt()在此组件中不可用，若此组件为容器类，请使用removeElementAt()代替
		 */		
		override public function removeChildAt(index:int):DisplayObject
		{
			throw(new Error("removeChildAt()"+errorStr+"removeElementAt()代替"));
		}
		[Deprecated] 
		/**
		 * setChildIndex()在此组件中不可用，若此组件为容器类，请使用setElementIndex()代替
		 */		
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			throw(new Error("setChildIndex()"+errorStr+"setElementIndex()代替"));
		}
		[Deprecated] 
		/**
		 * swapChildren()在此组件中不可用，若此组件为容器类，请使用swapElements()代替
		 */		
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			throw(new Error("swapChildren()"+errorStr+"swapElements()代替"));
		}
		[Deprecated] 
		/**
		 * swapChildrenAt()在此组件中不可用，若此组件为容器类，请使用swapElementsAt()代替
		 */		
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			throw(new Error("swapChildrenAt()"+errorStr+"swapElementsAt()代替"));
		}
		
		
		private function onButtonChange(event:Event):void
		{
			var button:ToggleButton = event.currentTarget as ToggleButton;
			var index:int = (getChildIndex(button)-1)*0.5;
			var element:IVisualElement = getElementAt(index);
			element.visible = button.selected;
			invalidateSize();
			invalidateDisplayList();
		}
	}
}