package egret.ui.behaivors
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import egret.collections.ICollection;
	import egret.collections.ITreeCollection;
	import egret.collections.ObjectCollection;
	import egret.components.DataGroup;
	import egret.components.IItemRenderer;
	import egret.components.Tree;
	import egret.components.supportClasses.ItemRenderer;
	import egret.components.supportClasses.TreeItemRenderer;
	import egret.core.ns_egret;
	import egret.events.RendererExistenceEvent;
	import egret.managers.CursorManager;
	import egret.managers.DragManager;
	import egret.ui.core.Cursors;
	
	use namespace ns_egret;
	/**
	 * 树的拖拽行为 
	 * @author 雷羽佳
	 * 
	 */	
	public class TreeDragBehavior
	{
		public var onDragInComplete:Function;
		public var onDragMoveComplete:Function;
		private var _stage:Stage;
		private var _tree:Tree
		private var _dragable:Boolean = false;
		private var shapeSelect:Shape;
		private var shapeSelectRoot:Shape;
		/**
		 * 得到接收拖拽的目标项，如果为空则默认为当前鼠标所指向的项。  accpetFunctionHandler(obj:Object):Object 
		 */		
		public var accpetFunction:Function;
		/**
		 * 目标项是否可以拖拽，形式如canDragFunction(dragItems:Array):Boolean
		 */			
		public var canDragFunction:Function;
		/**
		 * 是否可以释放拖拽进入。(dropTarget:Object,dragItems:Array):Boolean 
		 */		
		public var canDropInFunction:Function;
		/**
		 * 是否可以释放拖拽移动。 (dropTarget:Object,dragItems:Array):Boolean 
		 * 或(dropTarget:Object,dragItems:Array,pos:String):Boolean,pos的值为top,in,bottom
		 */		
		public var canDropMoveFunction:Function;
		
		public var onDragStart:Function;
		private var _orderable:Boolean = false;
		private var _dataGroup:DataGroup
		
		private static const rootSelectOffsetY:int = 20;
		public function TreeDragBehavior()
		{
			
		}
		/**
		 * 初始化一棵树 
		 * @param tree
		 * 
		 */		
		public function init(tree:Tree):void
		{
			_tree = tree;
			shapeSelect = new Shape();
			shapeSelect.visible = false;
			shapeSelectRoot = new Shape();
			shapeSelectRoot.visible = false;
			_tree.addToDisplayList(shapeSelectRoot);
			_tree.addToDisplayList(shapeSelect);
		}
		
		/**
		 * 设置数据容器 
		 * @param dataGroup
		 * 
		 */		
		public function setDataGrid(dataGroup:DataGroup):void
		{
			_dataGroup = dataGroup;
			dataGroup.addToDisplayList(shapeSelect);
			dataGroup.addEventListener(
				RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
			dataGroup.addEventListener(
				RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
			_dataGroup.addEventListener(MouseEvent.ROLL_OVER,dataGroupRollOverHandler);
			_dataGroup.addEventListener(MouseEvent.ROLL_OUT,dataGroupRollOutHandler);
		}
		private var isDataGroupMouseIn:Boolean = false;
		protected function dataGroupRollOverHandler(event:MouseEvent):void
		{
			isDataGroupMouseIn = true;
			updateRootSelect();
		}
		
		protected function dataGroupRollOutHandler(event:MouseEvent):void
		{
			isDataGroupMouseIn = false;
			updateRootSelect();
		}
		
		/**
		 * 是否可以拖拽 
		 */		
		public function get dragable():Boolean
		{
			return _dragable;
		}
		
		public function set dragable(value:Boolean):void
		{
			_dragable = value;
			if(_dragable)
			{
				if(_tree.stage)
				{
					_stage = _tree.stage;
					_tree.stage.addEventListener(MouseEvent.MOUSE_MOVE,treeStageMouseMoveHandler);
				}else
				{
					_tree.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
				}
			}
			else
			{
				_tree.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
				if(_stage)
				{
					_stage.removeEventListener(MouseEvent.MOUSE_MOVE,treeStageMouseMoveHandler);
				}
			}
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			_tree.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			_tree.stage.addEventListener(MouseEvent.MOUSE_MOVE,treeStageMouseMoveHandler);
			_stage = _tree.stage;
		}
		
		
		protected function treeStageMouseMoveHandler(event:MouseEvent):void
		{
			if( (_tree.mouseX < 0)|| 
				(_tree.mouseX > _tree.width) || 
				(_tree.mouseY < -rootSelectOffsetY )|| 
				(_tree.mouseY > _tree.height + rootSelectOffsetY))
			{
				isTreeMouseIn = false;
				shapeSelect.graphics.clear();
				shapeSelect.visible = false;
				shapeSelectRoot.graphics.clear();
				shapeSelectRoot.visible = false;
			}else
			{
				isTreeMouseIn = true;
			}
			updateRootSelect();
		}
		
		private var isTreeMouseIn:Boolean = false;
		
		private function updateRootSelect():void
		{
			shapeSelectRoot.visible = false;
			shapeSelectRoot.graphics.clear();
			
			if(dragItems && _isDraging)
			{
				if(!isTreeMouseIn)
				{
					if(!DragManager.isDragging)
					{
						if(CursorManager.cursor != Cursors.DESKTOP_DISABLE)
						{
							CursorManager.setCursor(Cursors.DESKTOP_DISABLE,1);
						}
					}
				}
			}
			
			if(isTreeMouseIn == true && isDataGroupMouseIn == false)
			{
				moveToOrder = false;
				if(dragItems && _isDraging)
				{
					canDropIn = true;
					parentFolder = ObjectCollection(_tree.dataProvider).source;
					if(canDropInFunction != null)
					{
						if(!canDropInFunction(parentFolder,dragItems))
						{
							canDropIn = false;
						}
					}
					
					if(canDropIn)
					{
						if(!DragManager.isDragging)
						{
							if(CursorManager.cursor != Cursors.DESKTOP_DRAG)
							{
								CursorManager.setCursor(Cursors.DESKTOP_DRAG,1);
							}
						}
						if(DragManager.isDragging)
						{
							DragManager.acceptDragDrop(_tree);
						}
						shapeSelect.graphics.clear();
						shapeSelect.visible = false;
						shapeSelectRoot.visible = true;
						shapeSelectRoot.graphics.beginFill(0x396895);
						shapeSelectRoot.graphics.drawRect(0,0,_tree.width,_tree.height);
						shapeSelectRoot.graphics.drawRect(2,2,_tree.width-4,_tree.height-4);
						shapeSelectRoot.graphics.endFill();
					}else
					{
						if(!DragManager.isDragging)
						{
							if(CursorManager.cursor != Cursors.DESKTOP_DISABLE)
							{
								CursorManager.setCursor(Cursors.DESKTOP_DISABLE,1);
							}
						}
					}
				}
			}
		}
		
		/**
		 * 是否支持拖拽改变顺序 
		 */
		public function get orderable():Boolean
		{
			return _orderable;
		}
		public function set orderable(value:Boolean):void
		{
			_orderable = value;
		}
		
		protected function treeMouseDownHandler(event:MouseEvent):void
		{
			if(!dragable) return;
			_tree.addEventListener(MouseEvent.MOUSE_MOVE,startDragHandler);
			if(_tree.stage)
			{
				_tree.stage.addEventListener(MouseEvent.MOUSE_UP,treeMouseUpHandler);
			}
		}
		
		protected function treeMouseUpHandler(event:MouseEvent):void
		{
			event.currentTarget.removeEventListener(MouseEvent.MOUSE_UP,treeMouseUpHandler);
			_tree.removeEventListener(MouseEvent.MOUSE_MOVE,startDragHandler);
			_tree.removeEventListener(Event.ENTER_FRAME,adjustVPosHandler);
		}
		
		private var dragItems:Array;
		private var _isDraging:Boolean = false;
		private var _dragStage:Stage;
		private var parentFolder:Object;
		
		protected function startDragHandler(event:MouseEvent):void
		{
			_tree.removeEventListener(MouseEvent.MOUSE_MOVE,startDragHandler);
			if(_tree.selectedItems.length > 0 && _tree.stage != null)
			{
				_dragStage = _tree.stage;
				_dragStage.addEventListener(MouseEvent.MOUSE_UP,dragMouseUpHandler);
				var arr:Array = [];
				for(var i:int = 0;i<_tree.selectedItems.length;i++)
				{
					arr.push(_tree.selectedItems[i]);
				}
				arr = sortSelectedItems(arr);
				dragItems = arr;
				if(canDragFunction != null)
				{
					if(!canDragFunction(dragItems)) 
					{
						dragItems = null;
						if(!DragManager.isDragging)
						{
							if(CursorManager.cursor != Cursors.DESKTOP_DISABLE)
							{
								CursorManager.setCursor(Cursors.DESKTOP_DISABLE,1);
							}
						}
						return;
					}
				}
				if(onDragStart!=null)
				{
					onDragStart(dragItems)
				}
				_isDraging = true;
			}
			
			if(dragItems != null && _isDraging)
			{
				_startMouseY = _tree.mouseY;
				_tree.addEventListener(Event.ENTER_FRAME,adjustVPosHandler);
			}
		}	
		/**
		 * 排序选择项
		 * @param items
		 * @return 
		 */		
		private function sortSelectedItems(items:Array):Array
		{
			var newItems:Array = [];
			function sort(collection:ICollection):void
			{
				if(!collection) return;
				for(var i:int = 0;i<collection.length;i++)
				{
					var obj:Object = collection.getItemAt(i);
					if(items.indexOf(obj) != -1)
					{
						newItems.push(obj);
					}
				}
			}
			sort(_tree.dataProvider);
			return newItems;
		}
		
		private var _startMouseY:Number = 0
		protected function adjustVPosHandler(event:Event):void
		{
			var v:Number;
			if(_tree.mouseY > _startMouseY && _tree.mouseY<_tree.height+rootSelectOffsetY &&
				_tree.mouseX>0 && _tree.mouseX<_tree.width) //向下移动
			{
				v = Math.pow((1-(_tree.height-_tree.mouseY)/(_tree.height-_startMouseY)),4);
				if(v > 1) v = 1;
				v = Math.round(v);
				_tree.dataGroup.verticalScrollPosition += v*15;
				_tree.dataGroup.validateNow();
				_tree.validateNow();
				
			}else if(_tree.mouseY < _startMouseY  && _tree.mouseY > -rootSelectOffsetY &&  
				_tree.mouseX>0 && _tree.mouseX<_tree.width) //向上移动
			{
				v = Math.pow((1-(_tree.mouseY)/(_startMouseY)),4);
				if(v > 1) v = 1;
				v = Math.round(v);
				_tree.dataGroup.verticalScrollPosition -= v*15;
				_tree.dataGroup.validateNow();
				_tree.validateNow();
			}
		}
		
		private var targetRenderer:ItemRenderer;
		private var moveToOrder:Boolean = false;
		private var moveTop:Boolean = false;
		private var currentData:Object;
		private var canDropIn:Boolean = true;
		private var canDropMove:Boolean = true;
		protected function itemDragMouseOverHandler(event:MouseEvent = null):void
		{
			shapeSelect.graphics.clear();
			shapeSelect.visible = false;
			moveToOrder = false;
			if(dragItems != null && _isDraging)
			{
				if(!DragManager.isDragging)
				{
					if(CursorManager.cursor != Cursors.DESKTOP_DISABLE)
					{
						CursorManager.setCursor(Cursors.DESKTOP_DISABLE,1);
					}
				}
				if(event != null)
					targetRenderer = event.currentTarget as ItemRenderer;
				
				if(!targetRenderer) return;
				if(accpetFunction!=null)
				{
					parentFolder = accpetFunction(targetRenderer.data);
				}else
				{
					parentFolder = targetRenderer.data;
				}
				
				if(parentFolder != null)
				{
					canDropIn = true;
					if(canDropInFunction != null)
					{
						if(!canDropInFunction(parentFolder,dragItems))
						{
							canDropIn = false;
							if(!DragManager.isDragging)
								if(CursorManager.cursor != Cursors.DESKTOP_DISABLE)
								{
									CursorManager.setCursor(Cursors.DESKTOP_DISABLE,1);
								}
						}
					}
					if(canDropIn)
						canDropIn = !checkIsChildren(dragItems,parentFolder);
					canDropMove = true
					if(canDropMoveFunction != null)
					{
						if(canDropMoveFunction.length == 2)
						{
							if(!canDropMoveFunction(targetRenderer.data,dragItems))
							{
								canDropMove = false;
							}
						}else if(canDropMoveFunction.length == 3)
						{
							var pos:String = "in";
							if(parentFolder == targetRenderer.data && _orderable)
							{
								if(DisplayObject(targetRenderer).mouseY < DisplayObject(targetRenderer).height/3 && canDropMove)
								{
									pos = "top"
								}else if(DisplayObject(targetRenderer).mouseY > (DisplayObject(targetRenderer).height/3)*2 && canDropMove)
								{
									pos = "bottom";	
								}
							}
							if(!canDropMoveFunction(targetRenderer.data,dragItems,pos))
							{
								canDropMove = false;
							}
						}
					}
					if(canDropMove)
						canDropMove = !checkIsChildren(dragItems,parentFolder)
					var itemRender:IItemRenderer;
					//如果接受者本身就是文件夹，那选中这个文件夹
					if(parentFolder == targetRenderer.data && !_orderable && canDropIn)
					{
						
						itemRender = getItemByData(parentFolder);
						if(itemRender != null && itemRender is DisplayObject)
						{
							drawDropIn(itemRender);
							DragManager.acceptDragDrop(_tree);
							if(!DragManager.isDragging)
							{
								if(CursorManager.cursor != Cursors.DESKTOP_DRAG)
								{
									CursorManager.setCursor(Cursors.DESKTOP_DRAG,1);
								}
							}
							moveToOrder = false;
						}
					}else if(parentFolder == targetRenderer.data && _orderable)
					{
						
						itemRender = getItemByData(parentFolder);
						if(itemRender != null && itemRender is DisplayObject)
						{
							if(DisplayObject(targetRenderer).mouseY < DisplayObject(targetRenderer).height/3 && canDropMove)
							{
								drawDropMove(itemRender,true);
								moveToOrder = true;
								moveTop = true;
								DragManager.acceptDragDrop(_tree);
								if(!DragManager.isDragging)
								{
									if(CursorManager.cursor != Cursors.DESKTOP_DRAG)
									{
										CursorManager.setCursor(Cursors.DESKTOP_DRAG,1);
									}
								}
								currentData = targetRenderer.data;
							}else if(DisplayObject(targetRenderer).mouseY > (DisplayObject(targetRenderer).height/3)*2 && canDropMove)
							{
								drawDropMove(itemRender,false);
								moveToOrder = true;
								moveTop = false;
								DragManager.acceptDragDrop(_tree);
								if(!DragManager.isDragging)
								{
									if(CursorManager.cursor != Cursors.DESKTOP_DRAG)
									{
										CursorManager.setCursor(Cursors.DESKTOP_DRAG,1);
									}
								}
								currentData = targetRenderer.data;
							}else if(canDropIn)
							{
								drawDropIn(itemRender);
								moveToOrder = false;
								DragManager.acceptDragDrop(_tree);
								if(!DragManager.isDragging)
								{
									if(CursorManager.cursor != Cursors.DESKTOP_DRAG)
									{
										CursorManager.setCursor(Cursors.DESKTOP_DRAG,1);
									}
								}
							}
						}
					}else if(parentFolder != targetRenderer.data && !_orderable && canDropIn)
					{
						itemRender = getItemByData(parentFolder);
						if(itemRender != null && itemRender is DisplayObject)
						{
							drawDropIn(itemRender);
							moveToOrder = false;
							DragManager.acceptDragDrop(_tree);
							if(!DragManager.isDragging)
							{
								if(CursorManager.cursor != Cursors.DESKTOP_DRAG)
								{
									CursorManager.setCursor(Cursors.DESKTOP_DRAG,1);
								}
							}
						}
					}else if(parentFolder != targetRenderer.data && _orderable && canDropMove) //如果接受者不是文件夹，就显示一条线
					{
						if(DisplayObject(targetRenderer).mouseY > DisplayObject(targetRenderer).height/2)
						{
							moveTop = false;
							drawDropMove(itemRender,false);
						}else
						{
							moveTop = true;
							drawDropMove(itemRender,true);
						}
						DragManager.acceptDragDrop(_tree);
						moveToOrder = true;
						currentData = targetRenderer.data;
					}
				}
			}
		}
		
		/**
		 * 得到指定项的高度，把子项也算进去了 
		 * @param itemRenderer
		 * @return 
		 * 
		 */		
		private function getRenderHeightInSameLevel(itemRenderer:IItemRenderer):Number
		{
			var dataArr:Array = [];
			var treeCollection:ITreeCollection = _tree.dataProvider as ITreeCollection;
			
			function getChild(data:Object):void
			{
				if(data.children && treeCollection.isItemOpen(data))
				{
					for(var i:int = 0;i<data.children.length;i++)
					{
						getChild(data.children[i]);
					}
				}
				dataArr.push(data);
			}
			getChild(itemRenderer.data);
			var itemRenderers:Array = [];
			for(var i:int = 0;i<dataArr.length;i++)
			{
				var item:IItemRenderer = getItemRenderByData(dataArr[i]);
				if(item)
				{
					itemRenderers.push(item);
				}
			}
			var h:Number = 0;
			for(i = 0;i<itemRenderers.length;i++)
			{
				h += DisplayObject(itemRenderers[i]).height;
			}
			return h;
		}
		
		private function getItemRenderByData(data:Object):IItemRenderer
		{
			for(var i:int = 0;i<itemRenderList.length;i++)
			{
				if(itemRenderList[i].data == data)
				{
					return itemRenderList[i];
				}
			}
			return null;
		}
		
		protected function itemDragMouseOutHandler(event:MouseEvent):void
		{
			//			parentFolder = null;
			//			targetRenderer = null;
			//			shapeSelect.graphics.clear();
			//			shapeSelect.visible = false;
		}
		
		
		protected function dragMouseUpHandler(event:MouseEvent):void
		{
			_dragStage.removeEventListener(MouseEvent.MOUSE_UP,dragMouseUpHandler);
			if(!DragManager.isDragging)
			{
				CursorManager.removeCursor(Cursors.DESKTOP_DISABLE);
				CursorManager.removeCursor(Cursors.DESKTOP_DRAG);
			}
			_dragStage = null;
			shapeSelect.graphics.clear();
			shapeSelect.visible = false;
			shapeSelectRoot.graphics.clear();
			shapeSelectRoot.visible = false;
			if(dragItems != null && _isDraging == true && isTreeMouseIn && parentFolder != null)
			{
				if(!parentFolder.children)
				{
					var arr:Array = [];
					parentFolder.children = arr;
				}
				if(dragItems)
				{
					if(moveToOrder == true && canDropMove == true)
					{
						if(onDragMoveComplete != null && currentData.parent)
						{
							onDragMoveComplete(currentData,dragItems,moveTop);
						}
					}else if(canDropIn == true)
					{
						var sameObj:Boolean = checkSameObj(parentFolder,dragItems);
						if(!sameObj)
						{
							if(onDragInComplete != null)
							{
								onDragInComplete(parentFolder,dragItems);
							}
						}
					}
				}
			}
			_isDraging = false;
			parentFolder = null;
			dragItems = null;
		}
		
		/**
		 * 完成拖拽 
		 * @param $parentFolder
		 * @param $dragItems
		 * 
		 */		
		public function doDrag($parentFolder:Object,$dragItems:Array):void
		{
			for(var i:int = 0;i<$dragItems.length;i++)
			{
				deleteFrom($dragItems[i].parent.children,$dragItems[i]);
				$parentFolder.children.push($dragItems[i]);
				$dragItems[i].parent =$parentFolder; 
			}
			ObjectCollection(_tree.dataProvider).refresh();
			_tree.validateNow();
		}
		/**
		 * 完成移动 
		 * @param $parentFolder
		 * @param $dragItems
		 * 
		 */		
		public function doMove($currentData:Object,$dragItems:Array,isTop:Boolean):void
		{
			if(!$currentData.parent) return;
			var parent:Object = $currentData.parent;
			var index:int = parent.children.indexOf($currentData);
			var numAbove:int = 0;
			for(var i:int = 0;i<$dragItems.length;i++)
			{
				if($dragItems[i].parent == parent && parent.children.indexOf($dragItems[i]) <= index)
				{
					if((parent.children.indexOf($dragItems[i]) == index && !isTop) || parent.children.indexOf($dragItems[i]) != index)
						numAbove++;
				}
			}
			index -= numAbove;
			for(i = 0;i<$dragItems.length;i++)
			{
				deleteFrom($dragItems[i].parent.children,$dragItems[i]);
			}
			if(isTop == true)
			{
				index--;
			}
			
			var selectes:Vector.<Object> = new Vector.<Object>();
			while($dragItems.length>0)
			{
				var current:Object = $dragItems.pop();
				selectes.push(current);
				parent.children.push(current);
				for(i = parent.children.length-1;i > index+1;i--)
				{
					parent.children[i] = parent.children[i-1];
				}
				parent.children[index+1] =  current;
				current.parent = parent;
			}
			ObjectCollection(_tree.dataProvider).refresh();
			_tree.validateNow();
			_tree.selectedItems = selectes;
		}
		
		/**
		 * 检查相同项 
		 * @param source
		 * @param target
		 * @return 
		 * 
		 */		
		private function checkSameObj(source:Object,target:Array):Boolean
		{
			var isSame:Boolean = false;
			for(var i:int = 0;i<target.length;i++)
			{
				if(source == target[i])
				{
					isSame = true;
					break;
				}
			}
			return isSame
		}
		
		
		private function deleteFrom(arr:Array,target:Object):void
		{
			for(var i:int = 0;i<arr.length;i++)
			{
				if(arr[i] == target)
				{
					for(var j:int = i;j<arr.length-1;j++)
					{
						arr[j] = arr[j+1];
					}
					arr.pop();
					break;
				}
			}
		}
		
		
		private var itemRenderList:Vector.<IItemRenderer> = new Vector.<IItemRenderer>();
		protected function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
		{
			if(event.renderer is ItemRenderer)
			{
				event.renderer.removeEventListener(MouseEvent.MOUSE_DOWN,treeMouseDownHandler);
				event.renderer.removeEventListener(MouseEvent.ROLL_OUT,itemDragMouseOutHandler);
				event.renderer.removeEventListener(MouseEvent.MOUSE_MOVE,itemDragMouseOverHandler);
				for(var i:int = 0;i<itemRenderList.length;i++)
				{
					if(itemRenderList[i] == ItemRenderer(event.renderer))
					{
						for(var j:int = i;j<itemRenderList.length-1;j++)
						{
							itemRenderList[j] = itemRenderList[j+1];
						}
						itemRenderList.pop();
						break;
					}
				}
			}
		}
		
		protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
		{
			if(event.renderer is ItemRenderer)
			{
				event.renderer.addEventListener(MouseEvent.MOUSE_DOWN,treeMouseDownHandler);
				event.renderer.addEventListener(MouseEvent.ROLL_OUT,itemDragMouseOutHandler);
				event.renderer.addEventListener(MouseEvent.MOUSE_MOVE,itemDragMouseOverHandler);
				itemRenderList.push(ItemRenderer(event.renderer));
			}
		}
		
		/**
		 * 通过内容得到渲染项 
		 * @param data
		 * @return 
		 * 
		 */		
		private function getItemByData(data:Object):IItemRenderer
		{
			var target:IItemRenderer;
			for(var i:int = 0;i<itemRenderList.length;i++)
			{
				if(itemRenderList[i].data == data)
				{
					target = itemRenderList[i];
					break;
				}
			}
			return target;
		}
		
		/**
		 * 判断是否是子类 
		 * @param parent
		 * @param children
		 * @return 
		 * 
		 */		
		private function checkIsChildren(parents:Array,child:Object):Boolean
		{
			//递归函数
			var checkNode:Function = function($parent:Object,$child:Object):Boolean
			{
				var tmpResult:Boolean = false;
				if($parent.children)
				{
					for(var i:int = 0;i<$parent.children.length;i++)
					{
						if($parent.children[i] == $child)
						{
							tmpResult = true
						}else if($parent.children[i].children)
						{
							tmpResult = checkNode($parent.children[i],$child);
						}
					}
				}
				return tmpResult;
			};
			
			var result:Boolean = false;
			for(var i:int = 0;i<parents.length;i++)
			{
				if(checkNode(parents[i],child))
				{
					result = true;
					break;
				}
			}
			return result;
		}
		
		private function drawDropIn(renderer:IItemRenderer):void
		{
			shapeSelect.graphics.beginFill(0x396895);
			shapeSelect.graphics.drawRect(0,0,_tree.width,DisplayObject(renderer).height);
			shapeSelect.graphics.drawRect(2,2,_tree.width-4,DisplayObject(renderer).height-4);
			shapeSelect.graphics.endFill();
			shapeSelect.visible = true;
			var pos:Point = DisplayObject(renderer).localToGlobal(new Point(0,0));
			pos = shapeSelect.parent.globalToLocal(pos);
			shapeSelect.x = pos.x;
			shapeSelect.y = pos.y;
			_dataGroup.addToDisplayList(shapeSelect);
		}
		
		private function drawDropMove(renderer:IItemRenderer,isTop:Boolean = false):void
		{
			if(renderer is TreeItemRenderer)
			{
				var depth:Point = TreeItemRenderer(renderer).disclosureButton.localToGlobal(new Point(TreeItemRenderer(renderer).disclosureButton.width,0));
				depth = shapeSelect.parent.globalToLocal(depth);
				shapeSelect.graphics.beginFill(0x396895);
				shapeSelect.graphics.drawRect(depth.x,0,_tree.width-depth.x,2);
				shapeSelect.graphics.endFill();
				shapeSelect.visible = true;
				var pos:Point = DisplayObject(renderer).localToGlobal(new Point(0,0));
				pos = shapeSelect.parent.globalToLocal(pos);
				shapeSelect.x = pos.x;
				if(isTop)
					shapeSelect.y = pos.y-1;
				else
					shapeSelect.y = pos.y-1+getRenderHeightInSameLevel(renderer);
				
				_dataGroup.addToDisplayList(shapeSelect);
			}
		}
	}
}