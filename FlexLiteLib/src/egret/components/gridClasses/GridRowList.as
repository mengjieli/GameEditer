package egret.components.gridClasses
{
	
	import egret.collections.ArrayCollection;
	
	[ExcludeClass]
	
	/**
	 *  链表，一个GridRowNode代表表格中的一行的行高
	 */	
	public class GridRowList
	{
		private var _head:GridRowNode;
		private var _tail:GridRowNode;
		private var _length:Number = 0;
		
		private var recentNode:GridRowNode;
		public function GridRowList():void
		{
			super();
		}
		/**
		 * 列表中的首节点 
		 * @return 
		 * 
		 */		
		public function get first():GridRowNode
		{
			return _head;
		}
		/**
		 * 列表中的最后一个节点 
		 * @return 
		 * 
		 */		
		public function get last():GridRowNode
		{
			return _tail;
		}
		/**
		 * 尾节点
		 * @return 
		 * 
		 */		
		public function get tail():GridRowNode
		{
			return _tail;
		}
		/**
		 * 头结点 
		 * @return 
		 * 
		 */		
		public function get head():GridRowNode
		{
			return _head;
		}
		/**
		 * 列表的长度 
		 * @return 
		 * 
		 */		
		public function get length():Number
		{
			return _length;
		}
		private var _numColumns:uint = 0;
		
		/**
		 * 每一行里列的数量 
		 * @return 
		 * 
		 */		
		public function get numColumns():uint
		{
			return _numColumns;
		}
		public function set numColumns(value:uint):void
		{
			if (_numColumns == value)
				return;
			
			_numColumns = value;
			
			var cur:GridRowNode = _head;
			while (cur)
			{
				cur.numColumns = value;
				cur = cur.next;
			}
		}
		
		/**
		 * 在指定的行位置插入一个新的节点，如果指定位置已经存在节点，那就直接把它返回回来。
		 * 
		 * @param index 要插入新节点的位置
		 * @return 新插入的节点或者已存在的节点
		 * 
		 */		
		public function insert(index:int):GridRowNode
		{
			
			if (_head == null)
			{
				_head = new GridRowNode(numColumns, index);
				_tail = _head;
				_length++;
				return _head;
			}
			var cur:GridRowNode = findNearestLTE(index);
			if (cur && cur.rowIndex == index)
				return cur;
			
			var newNode:GridRowNode = new GridRowNode(numColumns, index);
			if (!cur)
				insertBefore(_head, newNode);
			else 
				insertAfter(cur, newNode);
			
			recentNode = newNode;
			
			return newNode;
		}
		
		/**
		 * 在指定的节点之后插入一个新的节点，并返回这个节点。 
		 * @param node
		 * @param newNode
		 * 
		 */		
		public function insertAfter(node:GridRowNode, newNode:GridRowNode):void
		{
			newNode.prev = node;
			newNode.next = node.next;
			if (node.next == null)
				_tail = newNode;
			else
				node.next.prev = newNode;
			node.next = newNode;
			
			_length++;
		}
		
		/**
		 * 在指定节点之前插入一个新的节点，并返回这个新节点 
		 * @param node
		 * @param newNode
		 * 
		 */		
		public function insertBefore(node:GridRowNode, newNode:GridRowNode):void
		{
			newNode.prev = node.prev;
			newNode.next = node;
			if (node.prev == null)
				_head = newNode;
			else
				node.prev.next = newNode;
			node.prev = newNode;
			
			_length++;
		}
		/**
		 * 通过索引，得到节点 
		 * @param index
		 * @return 
		 * 
		 */		
		public function find(index:int):GridRowNode
		{
			
			if (!_head)
				return null;
			
			var indexToRecent:int;
			var temp:int;
			var lastToIndex:int = _tail.rowIndex - index;
			var result:GridRowNode = null;
			
			if (recentNode)
			{
				if (recentNode.rowIndex == index)
					return recentNode;
				
				indexToRecent = recentNode.rowIndex - index;
				temp = Math.abs(indexToRecent);
			}
			if (lastToIndex < 0)
			{
				return null;
			}
			else if (recentNode && temp < lastToIndex && temp < index)
			{
				if (indexToRecent > 0)
					result = findBefore(index, recentNode);
				else
					result = findAfter(index, recentNode);
			}
			else if (lastToIndex < index)
			{
				result = findBefore(index, _tail);
			}
			else
			{
				result = findAfter(index, _head);
			}
			
			if (result)
				recentNode = result;
			
			return result;
		}
		/**
		 * 得到指定节点之后的节点 
		 * @param index
		 * @param node
		 * @return 
		 * 
		 */		
		private function findAfter(index:int, node:GridRowNode):GridRowNode
		{
			var cur:GridRowNode = node;
			var result:GridRowNode = null;
			while (cur && cur.rowIndex <= index)
			{
				if (cur.rowIndex == index)
				{
					result = cur;
					break;
				}
				cur = cur.next;
			}
			return result;
		}
		/**
		 * 得到指定节点之前的一个节点
		 * @param index
		 * @param node
		 * @return 
		 * 
		 */		
		private function findBefore(index:int, node:GridRowNode):GridRowNode
		{
			var cur:GridRowNode = node;
			var result:GridRowNode = null;
			while (cur && cur.rowIndex >= index)
			{
				if (cur.rowIndex == index)
				{
					result = cur;
					break;
				}
				cur = cur.prev;
			}
			return result;
		}
		
		/**
		 * 找到与指定的索引最近的一个节点。如果指定的节点已存在，就直接返回。
		 * @param index
		 * @return 
		 * 
		 */		
		public function findNearestLTE(index:int):GridRowNode
		{
			
			if (!_head || index < 0)
				return null;
			
			var indexToRecent:int;
			var temp:int;
			var lastToIndex:int;
			var result:GridRowNode = null;
			
			if (recentNode)
			{
				if (recentNode.rowIndex == index)
					return recentNode;
				
				indexToRecent = recentNode.rowIndex - index;
				temp = Math.abs(indexToRecent);
			}
			
			lastToIndex = _tail.rowIndex - index;
			
			if (index < _head.rowIndex)
			{
				result = null;
			}
				
			else if (lastToIndex < 0)
			{
				result = _tail;
			}
			else if (recentNode && temp < lastToIndex && temp < index)
			{
				if (indexToRecent > 0)
					result = findNearestLTEBefore(index, recentNode);
				else
					result = findNearestLTEAfter(index, recentNode);
			}
			else if (lastToIndex < index)
			{
				result = findNearestLTEBefore(index, _tail);
			}
			else
			{
				result = findNearestLTEAfter(index, _head);
			}
			
			recentNode = result;
			
			return result;
		}
		/**
		 * 得到在指定的索引之后最近的一个节点。 
		 * @param index
		 * @param node
		 * @return 
		 * 
		 */		
		private function findNearestLTEAfter(index:int, node:GridRowNode):GridRowNode
		{
			var cur:GridRowNode = node;
			while (cur && cur.rowIndex < index)
			{
				if (cur.next == null)
					break;
				else if (cur.next.rowIndex > index)
					break;
				
				cur = cur.next;
			}
			return cur;
		}
		/**
		 * 得到在指定的索引之前最近的一个节点。 
		 * @param index
		 * @param node
		 * @return 
		 * 
		 */		
		private function findNearestLTEBefore(index:int, node:GridRowNode):GridRowNode
		{
			var cur:GridRowNode = node;
			while (cur && cur.rowIndex > index)
			{
				cur = cur.prev;
			}
			return cur;
		}
		
		/**
		 * 在列表的最后插入一个指定的节点 
		 * @param node
		 * 
		 */		
		public function push(node:GridRowNode):void
		{
			if (_tail)
			{
				node.prev = _tail;
				node.next = null;
				_tail.next = node;
				_tail = node;
				_length++;
			}
			else
			{
				node.prev = null;
				node.next = null;
				_head = node;
				_tail = node;
				_length = 1;
			}
		}
		/**
		 * 移除指定位置的节点 
		 * @param index
		 * @return 
		 * 
		 */		
		public function remove(index:int):GridRowNode
		{
			var node:GridRowNode = find(index);
			if (node)
				removeNode(node);
			return node;
		}
		/**
		 * 移除一个节点 
		 * @param node
		 * 
		 */		
		public function removeNode(node:GridRowNode):void
		{
			if (node.prev == null)
				_head = node.next;
			else
				node.prev.next = node.next;
			
			if (node.next == null)
				_tail = node.prev;
			else
				node.next.prev = node.prev;
			
			node.next = null;
			node.prev = null;
			
			if (node == recentNode)
				recentNode = null;
			
			_length--;
		}
		/**
		 * 移除全部 
		 * 
		 */		
		public function removeAll():void
		{
			this._head = null;
			this._tail = null;
			this._length = 0;
			this.recentNode = null;
		}
		/**
		 * 插入一列 
		 * @param startColumn
		 * @param count
		 * 
		 */		
		public function insertColumns(startColumn:int, count:int):void
		{
			_numColumns += count;
			
			var node:GridRowNode = first;
			while (node)
			{   
				node.insertColumns(startColumn, count);
				node = node.next;
			}
		}
		/**
		 * 移除一列 
		 * @param startColumn
		 * @param count
		 * 
		 */		
		public function removeColumns(startColumn:int, count:int):void
		{
			_numColumns -= count;
			
			var node:GridRowNode = first;
			while (node)
			{
				node.removeColumns(startColumn, count);
				node = node.next;
			}
		}
		/**
		 * 把指定列从fromCol移动到toCol
		 * @param fromCol
		 * @param toCol
		 * @param count
		 * 
		 */		
		public function moveColumns(fromCol:int, toCol:int, count:int):void
		{
			var node:GridRowNode = first;
			while (node)
			{
				node.moveColumns(fromCol, toCol, count);
				node = node.next;
			}
		}
		/**
		 * 从 startColumn开始清除count这么多的列
		 * @param startColumn
		 * @param count
		 * 
		 */		
		public function clearColumns(startColumn:int, count:int):void
		{
			var node:GridRowNode = first;
			while (node)
			{
				node.clearColumns(startColumn, count);
				node = node.next;
			}
		}
		public function toString():String
		{
			var s:String = "[ ";
			var node:GridRowNode = this.first;
			
			while (node)
			{
				s += "(" + node.rowIndex + "," + node.maxCellHeight + ") -> ";
				node = node.next;
			}
			s += "]";
			
			return s;
		}
		public function toArray():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection();
			var node:GridRowNode = this.first;
			var index:int = 0;
			
			while (node)
			{
				arr.addItem(node);
				node = node.next;
			}
			return arr;
		}
	}
}