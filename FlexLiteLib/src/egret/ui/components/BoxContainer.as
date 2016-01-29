package egret.ui.components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import egret.components.IItemRenderer;
	import egret.components.TabBarButton;
	import egret.core.IVisualElement;
	import egret.core.IVisualElementContainer;
	import egret.core.UIComponent;
	import egret.core.UIGlobals;
	import egret.core.ns_egret;
	import egret.managers.CursorManager;
	import egret.ui.components.boxClasses.BoxElement;
	import egret.ui.components.boxClasses.IBoxElement;
	import egret.ui.components.boxClasses.IBoxElementContainer;
	import egret.ui.components.boxClasses.Separator;
	import egret.ui.core.AddPosition;
	import egret.ui.core.Cursors;
	import egret.ui.events.BoxContainerEvent;
	import egret.ui.utils.BoxElementIdUtil;
	import egret.utils.callLater;
	
	use namespace ns_egret;
	
	/**
	 * 拖拽操作完成。包括拖拽面板，拖拽组，拖拽调整尺寸。没有参数。
	 */
	[Event(name="boxDragComplete", type="egret.ui.events.BoxContainerEvent")]
	/**
	 * 将一个TabPanel拖出TabGroup从而形成一个新的TabGroup。
	 * 此事件之后也会同时引发DRAG_GROUP_MOVED事件。<br/>
	 * 相关参数：fromPanel; fromPanelIndex; toGroup;
	 */
	[Event(name="dragPanelOut", type="egret.ui.events.BoxContainerEvent")]
	/**
	 * 拖拽移动一个TabGroup的位置。 <br/>
	 * 相关参数：fromGroup; toGroup; toGroupPosititon;
	 */
	[Event(name="dragGroupMoved", type="egret.ui.events.BoxContainerEvent")]
	/**
	 * 拖拽移动一个TabPanel的位置。  <br/>
	 * 相关参数：fromPanel; fromPanelIndex; fromGroup; toPanel; toPanelIndex; toGroup;
	 *  <br/> toPanel和fromPanel是同一个。
	 */
	[Event(name="dragPanelMoved", type="egret.ui.events.BoxContainerEvent")]
	/**
	 * 拖拽一个TabGroup到另一个TabGroup，使之与目标Group合并。<br/>
	 * 相关参数：fromGroup; toGroup;
	 */
	[Event(name="dragGroupIn", type="egret.ui.events.BoxContainerEvent")]
	
	/**
	 * 
	 * @author dom
	 */
	public class BoxContainer extends UIComponent implements IBoxElement
	{
		/**
		 * 构造函数
		 */		
		public function BoxContainer(isDoc:Boolean=false)
		{
			super();
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			_isDoc = isDoc;
		}
		
		private var _elementId:int = -1;
		public function get elementId():int
		{
			return _elementId;
		}
		
		public function set elementId(value:int):void
		{
			_elementId = value;
		}
		
		
		private var _isDoc:Boolean = false;
		
		
		
		/**
		 * 作为文档区域的标志
		 */
		public function get isDoc():Boolean
		{
			return _isDoc;
		}
		public function set isDoc(value:Boolean):void
		{
			_isDoc = value;
		}
		/**
		 * 鼠标按下事件
		 */		
		private function onMouseDown(event:MouseEvent):void
		{
			var target:DisplayObject = event.target as DisplayObject;
			if(_documentBox&&_documentBox.contains(target))
				return;
			if(target is Separator)
			{
				startResizePanel(target as Separator);
			}
			else
			{
				var tabGroup:TabGroup;
				var tabButton:IItemRenderer;
				while(target&&target!=this)
				{
					if(target is IItemRenderer)
					{
						tabButton = target as IItemRenderer;
					}
					if(target is TabGroup)
					{
						tabGroup = target as TabGroup;
						break;
					}
					target = target.parent;
				}
				if(tabGroup)
				{
					target = event.target as DisplayObject;
					if(tabGroup.titleTabBar&&tabGroup.titleTabBar.contains(target))
					{
						if(tabButton)
						{
							startDragPanel(tabGroup , tabButton.itemIndex);
						}
					}
					else if(tabGroup.moveArea)
					{
						if(tabGroup.moveArea==target || 
							((tabGroup.moveArea is DisplayObjectContainer) &&
							DisplayObjectContainer(tabGroup.moveArea).contains(target)))
						{
							startDragPanel(tabGroup);
						}
					}
					
				}
			}
		}
		
		/**
		 * 拖拽关联的TabGroup
		 */
		private var dragingTabGroup:TabGroup;
		/**
		 * 拖拽的TabPanel索引，如果为-1则表示拖拽TabGroup
		 */
		private var dragingIndex:int = -1;

		private var oldMouseChildren:Boolean;
		private var dragShape:Shape = new Shape();
		private var startPoint:Point;;
		
		/**
		 * 开始拖拽
		 */
		private function startDragPanel(target:TabGroup , index:int = -1):void
		{
			if(_documentBox)
			{
				oldMouseChildren = _documentBox.mouseChildren;
				_documentBox.mouseChildren = false;
			}
			dragingTabGroup = target;
			dragingIndex = index;
			var point:Point = localToGlobal(new Point());
			dragShape.x = point.x;
			dragShape.y = point.y;
			stage.addChild(dragShape);
			startPoint = new Point(stage.mouseX,stage.mouseY);
			var sm:DisplayObject = systemManager as DisplayObject;
			sm.addEventListener(MouseEvent.MOUSE_MOVE,onDragMouseMove);
			sm.stage.addEventListener(MouseEvent.MOUSE_UP,onDragMouseUp);
			sm.addEventListener(Event.MOUSE_LEAVE,onDragMouseUp);
			sm.addEventListener(MouseEvent.RIGHT_MOUSE_UP,onDragMouseUp);
		}
		/**
		 * 拖拽窗口完成
		 */		
		private function onDragMouseUp(event:Event):void
		{
			var sm:DisplayObject = systemManager as DisplayObject;
			sm.removeEventListener(MouseEvent.MOUSE_MOVE,onDragMouseMove);
			sm.stage.removeEventListener(MouseEvent.MOUSE_UP,onDragMouseUp);
			sm.removeEventListener(Event.MOUSE_LEAVE,onDragMouseUp);
			sm.removeEventListener(MouseEvent.RIGHT_MOUSE_UP,onDragMouseUp);
			if(_documentBox)
			{
				_documentBox.mouseChildren = oldMouseChildren;
			}
			var oldParentGroup:TabGroup;
			if(dragingIndex > -1)
			{
				oldParentGroup = dragingTabGroup;
				if(relativeBox==oldParentGroup||oldParentGroup.numElements>1)
				{
					oldParentGroup = null;
				}
			}
			if(insertPosition)
			{
				var tabGroup:TabGroup = dragingTabGroup;
				if(dragingIndex > -1)
				{
					var className:String = getQualifiedClassName(dragingTabGroup);
					var clazz:Class = getDefinitionByName(className) as Class;
					tabGroup = new clazz();
					var panel:ITabPanel = dragingTabGroup.getElementAt(dragingIndex)
					tabGroup.addElement(panel);
					var boxContainerEvent:BoxContainerEvent = new BoxContainerEvent(BoxContainerEvent.DRAG_PANEL_OUT);
					boxContainerEvent.fromPanel = panel;
					boxContainerEvent.fromPanelIndex = dragingIndex;
					boxContainerEvent.toGroup = tabGroup;
					dispatchEvent(boxContainerEvent);
				}
				tabGroup.width = NaN;
				tabGroup.height = NaN;
				relativeBox.width = NaN;
				relativeBox.height = NaN;
				addElementAt(tabGroup,relativeBox,insertPosition);
				boxContainerEvent = new BoxContainerEvent(BoxContainerEvent.DRAG_GROUP_MOVED);
				boxContainerEvent.fromGroup = tabGroup;
				boxContainerEvent.toGroup = relativeBox;
				boxContainerEvent.toGroupPosititon = insertPosition;
				dispatchEvent(boxContainerEvent);
				boxContainerEvent = new BoxContainerEvent(BoxContainerEvent.BOX_DRAG_COMPLETE);
				dispatchEvent(boxContainerEvent);
			}
			else if(dropIndex>=0)
			{
				if(dragingIndex > -1)
				{
					panel = dragingTabGroup.getElementAt(dragingIndex);
					TabGroup(relativeBox).addElementAt(panel  , dropIndex);
					TabGroup(relativeBox).selectedIndex = dropIndex;
					boxContainerEvent = new BoxContainerEvent(BoxContainerEvent.DRAG_PANEL_MOVED);
					boxContainerEvent.fromPanel = panel;
					boxContainerEvent.fromPanelIndex = dragingIndex;
					boxContainerEvent.fromGroup = dragingTabGroup;
					boxContainerEvent.toPanel = panel;
					boxContainerEvent.toPanelIndex = dropIndex;
					boxContainerEvent.toGroup = relativeBox;
					dispatchEvent(boxContainerEvent);
					boxContainerEvent = new BoxContainerEvent(BoxContainerEvent.BOX_DRAG_COMPLETE);
					dispatchEvent(boxContainerEvent);
					
				}
				else if(dragingTabGroup != relativeBox)
				{
					while(dragingTabGroup.numElements>0)
					{
						TabGroup(relativeBox).addElement(dragingTabGroup.removeElementAt(0));
					}
					boxContainerEvent = new BoxContainerEvent(BoxContainerEvent.DRAG_GROUP_IN);
					boxContainerEvent.fromGroup = dragingTabGroup;
					boxContainerEvent.toGroup = relativeBox;
					dispatchEvent(boxContainerEvent);
					boxContainerEvent = new BoxContainerEvent(BoxContainerEvent.BOX_DRAG_COMPLETE);
					dispatchEvent(boxContainerEvent);
					oldParentGroup = dragingTabGroup;
				}
			}
			else
			{
				oldParentGroup = null;
			}
			if(oldParentGroup)
			{
				removeElement(oldParentGroup);
			}
			dragingTabGroup = null;
			dragingIndex = -1;
			relativeBox = null;
			lastRect = null;
			insertPosition = "";
			dropIndex = -1;
			dragShape.graphics.clear();
			stage.removeChild(dragShape);
		}
		
		private var dragMoved:Boolean = false;
		private function onDragMouseMove(event:MouseEvent):void
		{
			if(dragMoved)
				return;
			if(startPoint)
			{
				if(startPoint.subtract(new Point(event.stageX,event.stageY)).length>2)
					startPoint = null;
				else
					return;
			}
			dragMoved = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(dragMoved)
			{
				dragMoved = false;
				redrawDragShape();
			}
		}
		
		private static const EDGE_SIZE:Number = 21;
		private var lastRect:Rectangle;
		private var relativeBox:IBoxElement;
		private var insertPosition:String = "";
		private var dropIndex:int = -1;
		
		public var reorderOnly:Boolean = false;
		private function redrawDragShape():void
		{
			insertPosition = "";
			dropIndex = -1;
			var g:Graphics = dragShape.graphics;
			g.clear();
			var lenght:int = numChildren;
			var child:DisplayObject;
			var rect:Rectangle;
			var curX:Number = mouseX;
			var curY:Number = mouseY;
			if(curX>=0&&curX<=width&&curY>=-2&&curY<=height)
			{
				for(var i:int=0;i<lenght;i++)
				{
					child = getChildAt(i);
					if(child is Separator)
					{
						continue;
					}
					if(child.x<=curX&&child.x+child.width>=curX&&
						child.y-2<=curY&&child.y+child.height>=curY)
					{
						rect = new Rectangle(child.x,child.y,child.width,child.height);
						break;
					}
				}
				if(!rect)
					return;
				var innerRect:Rectangle = rect.clone();
				relativeBox = child as IBoxElement;
				if(child is TabGroup)
				{
					var tabRect:Rectangle;
					var tabGroup:TabGroup = child as TabGroup;
					if(dragingIndex > -1)
					{
						tabRect = getTabRectUnderMouse(tabGroup);
					}
					if(tabRect)
					{
						rect = tabRect;
					}
					else if(dragingTabGroup && !reorderOnly)
					{
						innerRect.inflate(-EDGE_SIZE,-EDGE_SIZE);
						if((tabGroup.numElements>1&&dragingIndex > -1
							||tabGroup != dragingTabGroup)
							&&!innerRect.contains(curX,curY))
						{
							adjustRect(rect,innerRect,curX,curY,0.5);
						}
						else if(tabGroup != dragingTabGroup)
						{
							dropIndex = tabGroup.numElements;
						}
					}
				}
				else
				{
					innerRect.inflate(-rect.width*0.5,-rect.height*0.5);
					adjustRect(rect,innerRect,curX,curY,0.25);
				}
				if(!rect)
					return;
			}
			else
			{
				relativeBox = _rootBox;
				rect = new Rectangle(0,0,width,height);
				var fraction:Number = 0.5;
				if(_documentBox)
					fraction = 0.25;
				if(numChildren>1)
					adjustRect(rect,rect.clone(),curX,curY,fraction);
			}
			lastRect = rect;
			g.lineStyle(2,0x396895);
			g.drawRect(rect.x,rect.y,rect.width,rect.height);
			g.endFill();
		}
		
		private function adjustRect(rect:Rectangle,innerRect:Rectangle,curX:Number,curY:Number,fraction:Number):void
		{
			if(curX<innerRect.x&&curY>curX-rect.x+rect.y&&curY<-curX+rect.x+rect.bottom)
			{
				insertPosition = AddPosition.LEFT;
				rect.width *= fraction;
			}
			else if(curX>innerRect.right&&curY>-curX+rect.right+rect.y&&curY<curX+rect.bottom-rect.right)
			{
				insertPosition = AddPosition.RIGHT;
				rect.x += rect.width*(1-fraction);
				rect.width *= fraction;
			}
			else if(curY<innerRect.y&&curY<curX-rect.x+rect.y&&curY<-curX+rect.right+rect.y)
			{
				insertPosition = AddPosition.TOP;
				rect.height *= fraction;
			}
			else
			{
				insertPosition = AddPosition.BOTTOM;
				rect.y += rect.height*(1-fraction);
				rect.height *= fraction;
			}
		}
		
		private function getTabRectUnderMouse(tabGroup:TabGroup):Rectangle
		{
			var rect:Rectangle;
			var list:Array = stage.getObjectsUnderPoint(new Point(stage.mouseX,stage.mouseY));
			var target:DisplayObject = list[list.length-1];
			var button:TabBarButton;
			var pos:Point;
			target = list[list.length-1];
			if(tabGroup.titleTabBar&&tabGroup.titleTabBar.contains(target))
			{
				while(target&&target!=tabGroup)
				{
					if(target is IItemRenderer)
					{
						dropIndex = IItemRenderer(target).itemIndex;
					}
					target = target.parent;
				}
				button = tabGroup.titleTabBar.dataGroup.getElementAt(dropIndex) as TabBarButton;
				pos = button.localToGlobal(new Point);
				pos = globalToLocal(pos);
				rect = new Rectangle(pos.x,pos.y,button.width,button.height);
			}
			else if(tabGroup.moveArea && !reorderOnly)
			{
				if(tabGroup.moveArea==target||
					tabGroup.moveArea is DisplayObjectContainer&&
					DisplayObjectContainer(tabGroup.moveArea).contains(target))
				{
					dropIndex = tabGroup.numElements-1;
					button = tabGroup.titleTabBar.dataGroup.getElementAt(dropIndex) as TabBarButton;
					if(button)
					{
						pos = button.localToGlobal(new Point);
						pos = globalToLocal(pos);
						rect = new Rectangle(pos.x,pos.y,button.width,button.height);
						if(tabGroup != dragingTabGroup)
						{
							dropIndex++;
							rect.x += button.width;
							rect.width = 30;
						}
					}
				}
			}
			return rect;
		}
		private var _ownerBox:IBoxElement;
		/**
		 * 所属的盒式容器
		 */
		public function get ownerBox():IBoxElement
		{
			return _ownerBox;
		}
		public function set ownerBox(value:IBoxElement):void
		{
			_ownerBox = value;
		}
		
		private var _isFirstElement:Boolean = true;
		/**
		 * 是否作为父级的第一个元素
		 */
		public function get isFirstElement():Boolean
		{
			return _isFirstElement;
		}
		
		public function set isFirstElement(value:Boolean):void
		{
			_isFirstElement = value;
		}
		public function setLayoutSize(width:Number, height:Number):void
		{
			super.setLayoutBoundsSize(width,height);
		}
		
		private var _defaultWidth:Number = 250;
		/**
		 * 默认宽度
		 */
		public function get defaultWidth():Number
		{
			return _defaultWidth;
		}
		public function set defaultWidth(value:Number):void
		{
			_defaultWidth = value;
		}
		
		private var _defaultHeight:Number = 250;
		/**
		 * 默认高度
		 */
		public function get defaultHeight():Number
		{
			return _defaultHeight;
		}
		public function set defaultHeight(value:Number):void
		{
			_defaultHeight = value;
		}
		
		private var _parentBox:IBoxElementContainer;
		
		public function get parentBox():IBoxElementContainer
		{
			return _parentBox;
		}
		
		private var _minimized:Boolean = false;
		/**
		 * 是否处于最小化状态
		 */
		public function get minimized():Boolean
		{
			return _minimized;
		}
		public function set minimized(value:Boolean):void
		{
			if(_minimized==value)
				return;
			_minimized = value;
			var oldVisible:Boolean = super.visible;
			if(value)
				super.visible = false;
			else
				super.visible = explicitVisible;
			if(visible!=oldVisible)
			{
				dispatchEvent(new Event("visibleChanged"));
			}
		}
		
		private var explicitVisible:Boolean = true;
		
		override public function set visible(value:Boolean):void
		{
			explicitVisible = value;
			if(super.visible == value)
				return;
			super.visible = value;
			dispatchEvent(new Event("visibleChanged"));
		}
		
		public function parentBoxChanged(box:IBoxElementContainer,checkOldParent:Boolean=true):void
		{
			if(checkOldParent&&_parentBox)
			{
				if(isFirstElement)
					_parentBox.firstElement = null;
				else
					_parentBox.secondElement = null;
			}
			_parentBox = box;
		}
		/**
		 * 在根节点旁添加一个盒式元素
		 * @param box 要添加的盒式元素
		 * @param position 插入位置，只能从容器的四个边缘插入元素。请使用AddPosition定义的常量。
		 */		
		public function addElement(box:IBoxElement,position:String="right"):IBoxElement
		{
			if(!box||box==_rootBox)
				return box;
			if(box.ownerBox)
				BoxContainer(box.ownerBox).removeElement(box);
			if(_rootBox)
			{
				addElementAt(box,_rootBox,position);
			}
			else
			{
				_rootBox = box;
				addBoxElement(box);
			}
			invalidateDisplayList();
			return box;
		}
		/**
		 * 添加盒式元素到指定位置
		 * @param box 要添加的盒式元素
		 * @param relativeBox 要与之共享盒子的元素。
		 * @param position 插入的位置,只能从容器的四个边缘插入元素。请使用AddPosition定义的常量。
		 */		
		public function addElementAt(box:IBoxElement,relativeBox:IBoxElement,position:String="right"):IBoxElement
		{
			if(!box||box==relativeBox)
				return box;
			if(box.parentBox == relativeBox)
			{
				relativeBox = box.isFirstElement?IBoxElementContainer(relativeBox).secondElement:
					IBoxElementContainer(relativeBox).firstElement;
			}
			if(BoxContainer(box.ownerBox))
				BoxContainer(box.ownerBox).removeElement(box);
			var newBox:BoxElement;
			var isFirst:Boolean = relativeBox.isFirstElement;
			var parentBox:BoxElement = relativeBox.parentBox as BoxElement;
			if(!parentBox&&relativeBox!=_rootBox)
				return box;
			switch(position)
			{
				case AddPosition.TOP:
					newBox = new BoxElement(true);
					newBox.elementId = BoxElementIdUtil.newId();
					newBox.firstElement = box;
					newBox.secondElement = relativeBox;
					break;
				case AddPosition.BOTTOM:
					newBox = new BoxElement(true);
					newBox.elementId = BoxElementIdUtil.newId();
					newBox.firstElement = relativeBox;
					newBox.secondElement = box;
					break;
				case AddPosition.LEFT:
					newBox = new BoxElement();
					newBox.elementId = BoxElementIdUtil.newId();
					newBox.firstElement = box;
					newBox.secondElement = relativeBox;
					break;
				default:
					newBox = new BoxElement();
					newBox.elementId = BoxElementIdUtil.newId();
					newBox.firstElement = relativeBox;
					newBox.secondElement = box;
					break;
			}
			if(relativeBox==_rootBox)
				_rootBox = newBox;
			else if(isFirst)
				parentBox.firstElement = newBox;
			else
				parentBox.secondElement = newBox;
			addBoxElement(box);
			newBox.ownerBox = this;
			initSeparator(newBox.separator);
			invalidateDisplayList();
			return box;
		}
		
		/**
		 * 移除一个盒式元素
		 */		
		public function removeElement(box:IBoxElement):IBoxElement
		{
			if(!box)
				return box;
			if(box==_rootBox)
			{
				_rootBox = null;
			}
			else if(!box.parentBox)
			{
				return box;
			}
			else
			{
				var parentBox:BoxElement = box.parentBox as BoxElement;
				var remainBox:IBoxElement;
				if(box.isFirstElement)
					remainBox = parentBox.secondElement;
				else
					remainBox = parentBox.firstElement;
				if(parentBox==_rootBox)
				{
					_rootBox = remainBox;
				}
				else
				{
					if(parentBox.isFirstElement)
						BoxElement(parentBox.parentBox).firstElement = remainBox;
					else
						BoxElement(parentBox.parentBox).secondElement = remainBox;
				}
				parentBox.ownerBox = null;
				destorySeparator(parentBox.separator);
			}
			removeBoxElement(box);
			invalidateDisplayList();
			if(box is TabGroup)
			{
//				TabGroup(box).removeEventListener(UIEvent.VALUE_COMMIT,onSelectedPanelChange);
			}
			return box;
		}
		
		
		/**
		 * 添加元素到显示列表
		 */		
		private function addBoxElement(box:IBoxElement):void
		{
			if(box)
			{
				if(box is IEventDispatcher)
					IEventDispatcher(box).addEventListener("visibleChanged",onVisibleChanged);
				box.ownerBox = this;
			}
			if(box is DisplayObject)
			{
				if(DisplayObject(box).parent&&DisplayObject(box).parent is IVisualElementContainer)
				{
					IVisualElementContainer(DisplayObject(box).parent).removeElement(box as IVisualElement);
				}
				addToDisplayList(DisplayObject(box));
			}
			else if(box is BoxElement)
			{
				addBoxElement(BoxElement(box).firstElement);
				addBoxElement(BoxElement(box).secondElement);
				initSeparator(BoxElement(box).separator);
			}
			if(box is TabGroup)
			{
				TabGroup(box).validateNow();
			}
		}
		/**
		 * 子项visible属性发生改变
		 */
		private function onVisibleChanged(event:Event):void
		{
			invalidateDisplayList();
		}
		/**
		 * 初始化分隔符
		 */		
		private function initSeparator(separator:DisplayObject):void
		{
			addToDisplayList(separator);
			separator.addEventListener(MouseEvent.ROLL_OVER,onSepRollOver);
			separator.addEventListener(MouseEvent.ROLL_OUT,onSepRollOut);
		}
		/**
		 * 从显示列表移除元素
		 */		
		private function removeBoxElement(box:IBoxElement):void
		{
			if(box)
			{
				if(box is IEventDispatcher)
					IEventDispatcher(box).removeEventListener("visibleChanged",onVisibleChanged);
				box.ownerBox = null;
			}
			if(box is DisplayObject)
			{
				if(DisplayObject(box).parent==this)
					removeFromDisplayList(DisplayObject(box));
			}
			else if(box is BoxElement)
			{
				removeBoxElement(BoxElement(box).firstElement);
				removeBoxElement(BoxElement(box).secondElement);
				destorySeparator(BoxElement(box).separator);
			}
		}
		/**
		 * 销毁分隔符
		 */		
		private function destorySeparator(separator:DisplayObject):void
		{
			removeFromDisplayList(separator);
			separator.removeEventListener(MouseEvent.ROLL_OVER,onSepRollOver);
			separator.removeEventListener(MouseEvent.ROLL_OUT,onSepRollOut);
		}
		
		private var offsetX:Number = 0;
		private var offsetY:Number = 0;
		private var firstHasDoc:Boolean; 
		private var secondHasDoc:Boolean;
		private var isVertical:Boolean;
		private var curBox:BoxElement;
		/**
		 * 鼠标按下
		 */		
		private function startResizePanel(separator:Separator):void
		{
			curBox = separator.target;
			firstHasDoc = hasDocument(separator.target.firstElement);
			secondHasDoc = hasDocument(separator.target.secondElement);
			isVertical = separator.target.isVertical;
			offsetX = separator.x - stage.mouseX;
			offsetY = separator.y - stage.mouseY;
			var sm:DisplayObject = systemManager as DisplayObject;
			sm.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			sm.stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			sm.addEventListener(Event.MOUSE_LEAVE,onMouseUp);
			sm.addEventListener(MouseEvent.RIGHT_MOUSE_UP,onMouseUp);
			mouseChildren = false;
		}
		
		private function onMouseUp(event:Event):void
		{
			callLater(function():void{
				CursorManager.setCursor(Cursors.AUTO);
			});
			curBox = null;
			mouseChildren = true;
			var sm:DisplayObject = systemManager as DisplayObject;
			sm.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			sm.stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			sm.removeEventListener(Event.MOUSE_LEAVE,onMouseUp);
			sm.removeEventListener(MouseEvent.RIGHT_MOUSE_UP,onMouseUp);
			this.dispatchEvent(new BoxContainerEvent(BoxContainerEvent.BOX_DRAG_COMPLETE));
		}
		/**
		 * 调整盒子元素大小
		 */		
		private function onMouseMove(event:MouseEvent):void
		{
			if(!curBox.firstElement||!curBox.secondElement)
				return;
			var offset:Number = 0;
			var first:IBoxElement = curBox.firstElement;
			var second:IBoxElement = curBox.secondElement;
			var firstHasDoc:Boolean = hasDocument(first);
			var secondHasDoc:Boolean = hasDocument(second);
			var firstH:Number;
			var firstW:Number;
			var secondH:Number;
			var secondW:Number;
			if(isVertical)
			{
				offset = Math.round(offsetY + event.stageY - curBox.separator.y);
				firstH = Math.min(first.height + offset,curBox.height-_gap-MIN_SIZE);
				firstH = Math.max(MIN_SIZE,firstH);
				if(secondHasDoc)
					first.defaultHeight = firstH;
				if(isNaN(first.explicitHeight))
					first.setLayoutSize(first.width,firstH);
				else
					setExplicitHeight(first,firstH);
				secondH = Math.max(MIN_SIZE,curBox.height-firstH-_gap);
				if(firstHasDoc)
					second.defaultHeight = secondH;
				if(isNaN(second.explicitHeight))
					second.setLayoutSize(second.width,secondH);
				else
					setExplicitHeight(second,secondH);
				curBox.percentSize = firstH/curBox.height;
			}
			else
			{
				offset = Math.round(offsetX + event.stageX - curBox.separator.x);
				firstW = Math.min(first.width+offset,curBox.width-_gap-MIN_SIZE);
				firstW = Math.max(MIN_SIZE,firstW);
				if(secondHasDoc)
					first.defaultWidth = firstW;
				if(isNaN(first.explicitWidth))
					first.setLayoutSize(firstW,first.height);
				else
					setExplicitWidth(first,firstW);
				secondW = Math.max(MIN_SIZE,curBox.width-firstW-_gap);
				if(firstHasDoc)
					second.defaultWidth = secondW;
				if(isNaN(second.explicitWidth))
					second.setLayoutSize(secondW,second.height);
				else
					setExplicitWidth(second,secondW);
				curBox.percentSize = firstW/curBox.width;
			}
			updateChildElement(curBox);
			UIGlobals.layoutManager.validateNow();
			event.updateAfterEvent();
		}
		
		private function setExplicitWidth(box:IBoxElement,w:Number):void
		{
			var tab:TabGroup = box as TabGroup;
			if(tab&&isNaN(tab.$explicitWidth))
			{
				tab.selectedPanel.width = w;
				tab.setLayoutSize(w,tab.height);
			}
			else
			{
				box.width = w;
			}
		}
		private function setExplicitHeight(box:IBoxElement,h:Number):void
		{
			var tab:TabGroup = box as TabGroup;
			if(tab&&isNaN(tab.$explicitHeight))
			{
				tab.selectedPanel.height = h;
				tab.setLayoutSize(tab.width,h);
			}
			else
			{
				box.height = h;
			}
		}
		/**
		 * 鼠标经过
		 */		
		private function onSepRollOver(event:MouseEvent):void
		{
			if(event.buttonDown)
				return;
			var target:BoxElement = event.target.target;
			CursorManager.setCursor(target.isVertical?Cursors.DESKTOP_RESIZE_NS:Cursors.DESKTOP_RESIZE_EW);
		}
		/**
		 * 鼠标移出
		 */		
		private function onSepRollOut(event:MouseEvent):void
		{
			if(event.buttonDown)
				return;
			CursorManager.setCursor(Cursors.AUTO);
		}
		
		
		private var _documentBox:BoxContainer;
		/**
		 * 文档区域显示对象
		 */
		public function get documentBox():BoxContainer
		{
			return _documentBox;
		}
		public function set documentBox(value:BoxContainer):void
		{
			if(_documentBox==value)
				return;
			if(_documentBox)
			{
				removeElement(_documentBox);
			}
			_documentBox = value;
			addElement(_documentBox);
			invalidateDisplayList();
		}
		
		
		private var _rootBox:IBoxElement;
		/**
		 * 容器根元素
		 */
		public function get rootBox():IBoxElement
		{
			return _rootBox;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(_rootBox)
			{
				_rootBox.setLayoutSize(unscaledWidth,unscaledHeight);
				_rootBox.x = 0;
				_rootBox.y = 0;
				updateChildElement(_rootBox);
			}
		}
		
		/**
		 * 缩放时的最小尺寸
		 */		
		public static const MIN_SIZE:Number = 21;
		
		private var _gap:Number = -1;
		/**
		 * 布局元素之间的间距
		 */
		public function get gap():Number
		{
			return _gap;
		}
		
		public function set gap(value:Number):void
		{
			if(_gap==value)
				return;
			_gap = value;
			invalidateDisplayList();
		}
		
		/**
		 * 更新子项的尺寸和位置
		 */		
		ns_egret function updateChildElement(child:IBoxElement):void
		{
			var box:BoxElement = child as BoxElement;
			if(!box||!box.firstElement||!box.secondElement)
				return;
			if(!box.firstElement.visible||!box.secondElement.visible)
				box.separator.visible = false;
			else
				box.separator.visible = true;
			box.firstElement.x = box.secondElement.x = box.x;
			box.firstElement.y = box.secondElement.y = box.y;
			
			var firstResizable:Boolean = hasDocument(box.firstElement);
			var secondResizable:Boolean = hasDocument(box.secondElement);
			var firstH:Number = 0;
			var firstW:Number = 0;
			var secondH:Number = 0;
			var secondW:Number = 0;
			var separator:DisplayObject = box.separator;
			var firstMinSize:Number;
			var secondMinSize:Number;
			if(!box.firstElement.visible&&box.secondElement.visible)
			{
				secondH = box.height;
				secondW = box.width;
			}
			if(box.firstElement.visible&&!box.secondElement.visible)
			{
				firstH = box.height;
				firstW = box.width;
			}
			else if(box.secondElement.visible&&box.firstElement.visible)
			{
				if(box.isVertical)
				{
					if(!firstResizable&&!secondResizable)
					{
						firstResizable = isNaN(box.firstElement.explicitHeight);
						secondResizable = isNaN(box.secondElement.explicitHeight);
						if(firstResizable&&secondResizable)
							firstResizable = secondResizable = false;
					}
					firstMinSize = (box.firstElement is BoxElement)&&
						BoxElement(box.firstElement).isVertical?2*MIN_SIZE:MIN_SIZE;
					secondMinSize = (box.secondElement is BoxElement)&&
						BoxElement(box.secondElement).isVertical?2*MIN_SIZE:MIN_SIZE;
					var isBoxElement:Boolean = box.firstElement is BoxElement;
					firstW = secondW = box.width;
					separator.x = box.x;
					separator.width = box.width;
					separator.height = 3;
					if(firstResizable)
					{
						secondH = Math.ceil(box.secondElement.explicitHeight);
						if(isNaN(secondH))
						{
							secondH = Math.ceil(box.secondElement.defaultHeight);
						}
						firstH = Math.max(firstMinSize,box.height - secondH-_gap);
						secondH = Math.max(secondMinSize,box.height - firstH-_gap);
					}
					else if(secondResizable)
					{
						firstH = Math.ceil(box.firstElement.explicitHeight);
						if(isNaN(firstH))
						{
							firstH = Math.ceil(box.firstElement.defaultHeight);
						}
						secondH = Math.max(secondMinSize,box.height - firstH-_gap);
						firstH = Math.max(firstMinSize,box.height - secondH-_gap);
					}
					else
					{
						if(!isNaN(box.firstElement.explicitHeight))
						{
							firstH = Math.max(MIN_SIZE,box.firstElement.explicitHeight);
						}else
						{
							firstH = Math.ceil(box.height*box.percentSize);
						}
						secondH = box.height-firstH-_gap;
					}
					box.secondElement.y += firstH+_gap;
					separator.y = box.secondElement.y-1;
				}
				else
				{
					if(!firstResizable&&!secondResizable)
					{
						firstResizable = isNaN(box.firstElement.explicitWidth);
						secondResizable = isNaN(box.secondElement.explicitWidth);
						if(firstResizable&&secondResizable)
							firstResizable = secondResizable = false;
					}
					firstMinSize = (box.firstElement is BoxElement)&&
						!BoxElement(box.firstElement).isVertical?2*MIN_SIZE:MIN_SIZE;
					secondMinSize = (box.secondElement is BoxElement)&&
						!BoxElement(box.secondElement).isVertical?2*MIN_SIZE:MIN_SIZE;
					firstH = secondH = box.height;
					separator.y = box.y;
					separator.height = box.height;
					separator.width = 3; 
					if(firstResizable)
					{
						secondW = Math.ceil(box.secondElement.explicitWidth);
						if(isNaN(secondW))
						{
							secondW = Math.ceil(box.secondElement.defaultWidth);
						}
						firstW = Math.max(firstMinSize,box.width - secondW-_gap);
						secondW = Math.max(secondMinSize,box.width - firstW-_gap);
					}
					else if(secondResizable)
					{
						firstW = Math.ceil(box.firstElement.explicitWidth);
						if(isNaN(firstW))
						{
							firstW = Math.ceil(box.firstElement.defaultWidth);
						}
						secondW = Math.max(secondMinSize,box.width - firstW-_gap);
						firstW = Math.max(firstMinSize,box.width - secondW-_gap);
					}
					else
					{
						if(!isNaN(box.firstElement.explicitWidth))
						{
							firstW = Math.max(MIN_SIZE,box.firstElement.explicitWidth);
						}else
						{
							firstW = Math.ceil(box.width*box.percentSize);
						}
						secondW = box.width-firstW-_gap;
					}
					box.secondElement.x += firstW+_gap;
					separator.x = box.secondElement.x-1;
				}
			}
			box.firstElement.setLayoutSize(firstW,firstH);
			box.secondElement.setLayoutSize(secondW,secondH);
			updateChildElement(box.firstElement);
			updateChildElement(box.secondElement);
		}
		/**
		 * 检查指定的元素是否包含或等于documentBox
		 */		
		private function hasDocument(box:IBoxElement):Boolean
		{
			var doc:IBoxElement = documentBox;
			while(doc)
			{
				if(box==doc)
					return true;
				doc = doc.parentBox;
			}
			return false;
		}
	}
}