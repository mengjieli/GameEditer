package egret.ui.components
{
	import flash.events.MouseEvent;
	
	import egret.components.ITreeItemRenderer;
	import egret.components.Tree;
	import egret.components.supportClasses.TreeItemRenderer;
	import egret.events.TreeEvent;
	import egret.ui.behaivors.TreeDragBehavior;
	import egret.ui.events.TreeDragEvent;

	/**
	 * 拖拽开始
	 */	
	[Event(name="itemsDragStart", type="egret.ui.events.TreeDragEvent")]
	/**
	 * 拖拽进入完成
	 */	
	[Event(name="itemsDargInComplete", type="egret.ui.events.TreeDragEvent")]
	/**
	 * 拖拽移动完成
	 */	
	[Event(name="itemsDargMoveComplete", type="egret.ui.events.TreeDragEvent")]
	/**
	 * 增加了拖拽的支持 
	 * @author 雷羽佳
	 * 
	 */	
	public class Tree extends egret.components.Tree
	{
		private var treeDragBehavior:TreeDragBehavior;
		public function Tree()
		{
			super();
			this.doubleClickEnabled = true;
			this.doubleClickExpand = true;
			treeDragBehavior = new TreeDragBehavior();
			treeDragBehavior.init(this);
			treeDragBehavior.onDragInComplete = function(drop:Object,dragItems:Array):void
			{
				var evt:TreeDragEvent = new TreeDragEvent(TreeDragEvent.ITEMS_DRAG_IN_COMPLETE);
				evt.dragItems = dragItems;
				evt.dropItem = drop;
				if(dispatchEvent(evt))
				{
					treeDragBehavior.doDrag(drop,dragItems);
				}
			};
			treeDragBehavior.onDragMoveComplete = function(drop:Object,dragItems:Array,isTop:Boolean):void
			{
				var evt:TreeDragEvent = new TreeDragEvent(TreeDragEvent.ITEMS_DRAG_MOVE_COMPLETE);
				evt.dragItems = dragItems;
				evt.dropItem = drop;
				evt.moveToTop = isTop;
				if(dispatchEvent(evt))
				{
					treeDragBehavior.doMove(drop,dragItems,isTop);
				}
			}
			
			treeDragBehavior.onDragStart = function(dragItems:Array):void
			{
				var evt:TreeDragEvent = new TreeDragEvent(TreeDragEvent.ITEMS_DRAG_START);
				evt.dragItems = dragItems;
				dispatchEvent(evt);
			}
		}

		public function get orderable():Boolean
		{
			return treeDragBehavior.orderable;
		}

		public function set orderable(value:Boolean):void
		{
			treeDragBehavior.orderable = value;
		}

		public function get dragable():Boolean
		{
			return treeDragBehavior.dragable;
		}

		public function set dragable(value:Boolean):void
		{
			treeDragBehavior.dragable = value;
		}

		/**
		 * 是否可以释放拖拽移动。<code>(dropTarget:Object,dragItems:Array):Boolean </code><br/> 
		 * 或 <code>(dropTarget:Object,dragItems:Array,pos:String):Boolean</code> ,pos的值为top,in,bottom
		 */		
		public function get canDropMoveFunction():Function
		{
			return treeDragBehavior.canDropMoveFunction;
		}
		
		public function set canDropMoveFunction(value:Function):void
		{
			treeDragBehavior.canDropMoveFunction = value;
		}
		
		/**
		 * 是否可以释放拖拽进入。(dropTarget:Object,dragItems:Array):Boolean 
		 */		
		public function get canDropInFunction():Function
		{
			return treeDragBehavior.canDropInFunction;
		}
		
		public function set canDropInFunction(value:Function):void
		{
			treeDragBehavior.canDropInFunction = value;
		}
		/**
		 * 得到接收拖拽的目标项，如果为空则默认为当前鼠标所指向的项。  accpetFunctionHandler(obj:Object):Object 
		 */		
		public function get accpetFunction():Function
		{
			return treeDragBehavior.accpetFunction;
		}
		
		public function set accpetFunction(value:Function):void
		{
			treeDragBehavior.accpetFunction = value;
		}
		
		/**
		 * 目标项是否可以拖拽，形式如canDragFunction(dragItems:Array):Boolean
		 */		
		public function get canDragFunction():Function
		{
			return treeDragBehavior.canDragFunction;
		}
		
		public function set canDragFunction(value:Function):void
		{
			treeDragBehavior.canDragFunction = value;
		}
		
		private var _doubleClickExpand:Boolean;
		/**
		 * 是否在双击时自动展开或者关闭节点，此属性只有在doubleClickEnabled为true才有效
		 */
		public function get doubleClickExpand():Boolean
		{
			return _doubleClickExpand;
		}
		
		public function set doubleClickExpand(value:Boolean):void
		{
			_doubleClickExpand = value;
			if(value)
				this.addEventListener(MouseEvent.DOUBLE_CLICK , doubleClickHandler);
			else
				this.removeEventListener(MouseEvent.DOUBLE_CLICK , doubleClickHandler);
		}
		
		private function doubleClickHandler(event:MouseEvent):void
		{
			var target:Object = event.target;
			var renderer:ITreeItemRenderer;
			while(target&&target!=this)
			{
				if(target is ITreeItemRenderer)
				{
					renderer = target as ITreeItemRenderer;
					break;
				}
				target = target.parent;
			}

			if(renderer && renderer.hasChildren)
			{
				if(renderer is TreeItemRenderer)
				{
					target = event.target;
					while(target&&target!=renderer)
					{
						if(TreeItemRenderer(renderer).disclosureButton == target)
							return;
						target = target.parent;
					}
				}
				var evt:TreeEvent = new TreeEvent(TreeEvent.ITEM_OPENING,
					false,true,renderer.itemIndex,renderer.data,renderer);
				evt.opening = !renderer.opened;
				renderer.dispatchEvent(evt);
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance == dataGroup)
			{
				treeDragBehavior.setDataGrid(dataGroup);
			}
		}

	}
}