package com.flower.cocos2dx.display
{
	import com.flower.ClassName;
	import com.flower.bufferPool.BufferPool;
	import com.flower.cocos2dx.DebugInfo;
	import com.flower.cocos2dx.EngineLock;
	import com.flower.cocos2dx.display.DisplayObject;
	import com.jc.utils.Matrix;
	
	import cocos2dx.display.CCNode;
	
	/**
	 *容器类，如果是子对象，无需再设置className属性，否则会导致鼠标事件混乱
	 * @author mengjie.li
	 * 
	 */	
	public class DisplayObjectContainer extends DisplayObject
	{
		private var _childs:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		
		public function DisplayObjectContainer(subClass:Boolean=false)
		{
			super(true);
			if(subClass == false && EngineLock.DisplayObjectContainer == true)
			{
				DebugInfo.debug("|创建DisplayObjectContainer| 直接创建请用DisplayObjectContainer.creat()，如果是子类subClass必须传true",DebugInfo.ERROR);
				return;
			}
			if(subClass)
			{
				initBuffer();
			}
			this.className = ClassName.DisplayObjectContainer;
			_show = BufferPool.createCCNode(ClassName.CCNode);
		}
		
		override public function initBuffer():void
		{
			super.initBuffer();
			mutiplyMouseEnabled = true;
			_show = BufferPool.createCCNode(ClassName.CCNode);
		}
		
		/**
		 *回收属性，外部不可调用，BufferPool自动调用
		 * 
		 */		
		override public function cycleBuffer():void
		{
			super.cycleBuffer();
			if(this._parent) this._parent.removeChild(this);
			while(_childs.length)
			{
				this.removeChild(_childs[_childs.length-1]);
			}
			_show.cycle();
			BufferPool.cycyleCCNode(_show,ClassName.CCNode);
			_show = null;
		}
		
		/**
		 *添加子对象 
		 * @param child	显示对象
		 * 
		 */		
		public function addChild(child:DisplayObject):void
		{
			if(child.getParent()) child.getParent().removeChild(child);
			_childs.push(child);
			child.setParent(this);
			child.setParentAlpha(_parentAlpha*_alpha);
		}
		
		/**
		 *添加子对象到某一层 0为最底层 
		 * @param child
		 * @param index
		 * 
		 */		
		/*public function addChildAt(child:*,index:int=0):void
		{
		if(child._parent) child._parent.removeChild(child);
		_childs.splice(index,0,child);
		_container.addChild(child._show,index);
		child.setParent(this);
		}*/
		
		/**
		 *移除子对象 
		 * @param child	显示对象
		 * 
		 */		
		public function removeChild(child:*):void
		{
			for(var i:* in _childs)
			{
				if(_childs[i] == child)
				{
					_childs.splice(i,1);
					child.setParent(null);
					return;
				}
			}
		}
		
		/**
		 *设置子对象的层数 
		 * @param child	子对象
		 * @param index 层数
		 * 
		 */		
		/*public function setChildIndex(child:*,index:uint):void
		{
		var childIndex:uint = getChildIndex(child);
		if(childIndex == index)return;
		_childs.splice(childIndex,1);
		_childs.splice(index,0,child);
		}*/
		
		/**
		 *获取子对象的层数 
		 * @param child
		 * @return
		 * 
		 */		
		public function getChildIndex(child:*):uint
		{
			for(var i:int = 0; i < _childs.length; i++)
			{
				if(_childs[i] == child)
				{
					return i;
				}
			}
			return null;
		}
		
		/**
		 *是否包含某个子对象
		 * @param child
		 * @return 
		 * 
		 */		
		public function contains(child:*):Boolean
		{
			if(child.getParent() == this) return true;
			return false;
		}
		
		public function getContainer():CCNode
		{
			return this._show;
		}
		
		protected function getMouseTarget(matrix:Matrix,mutiply:Boolean):DisplayObject
		{
			if(this.mouseEnabled == false) return null;
			if(mutiply == true && mutiplyMouseEnabled == false) return null;
			matrix.save();
			matrix.translate(-_x,-_y);
			if(_rotation) matrix.rotate(-_rotation);
			if(_scaleX != 1 || _scaleY != 1) matrix.scale(1/_scaleX,1/_scaleY);
			var target:DisplayObject;
			var len:int = _childs.length;
			for(var i:int = len - 1; i >= 0; i--)
			{
				if(_childs[i].mouseEnabled && (mutiply == false || (mutiply == true && _childs[i].mutiplyMouseEnabled  == true)))
				{
					if(_childs[i].className == ClassName.DisplayObjectContainer)
					{
						target = (_childs[i] as DisplayObjectContainer).getMouseTarget(matrix,mutiply);
						if(target != null) break;
					}
					else if(_childs[i].isMouseTarget(matrix,mutiply) == true)
					{
						target = _childs[i] as DisplayObject;
						break;
					}
				}
			}
			matrix.setTo.apply(null,matrix._saves.pop());
			return target;
		}
		
		/**
		 *设置透明度 
		 * @param val 透明度为0~1
		 * 
		 */		
		override public function setAlpha(val:Number):void
		{
			_alpha = val;
			setParentAlpha(_parentAlpha);
		}
		
		/**
		 *从父类传来的透明度，外部对象无需调用，调用会导致错误
		 * @param val
		 * 
		 */		
		override public function setParentAlpha(val:Number):void
		{
			_parentAlpha = val;
			for(var i:int = 0; i < _childs.length; i++)
			{
				this._childs[i].setParentAlpha(_alpha*_parentAlpha);
			}
		}
		
		override public function getWidth():int
		{
			var sx:Number = 0;
			var ex:Number = 0;
			for each(var child:* in _childs)
			{
				if(child.getX() < sx)
				{
					sx = child.getX();
				}
				if(child.getX() + child.getWidth() > ex)
				{
					ex = child.getX() + child.getWidth();
				}
			}
			return ex - sx;
		}
		
		override public function getHeight():int
		{
			var sy:Number = 0;
			var ey:Number = 0;
			for each(var child:* in _childs)
			{
				if(child.getY() < sy)
				{
					sy = child.getY();
				}
				if(child.getY() + child.getWidth() > ey)
				{
					ey = child.getY() + child.getHeight();
				}
			}
			return ey - sy;
		}
		
		/**
		 *设置父对象,外部类无需调用,否则会导致出错,如果需要添加对象请用addChild()
		 * @param val
		 * 
		 */	
		override public function setParent(val:DisplayObjectContainer):void
		{
			super.setParent(val);
			if(val == null)
			{
				BufferPool.cycle(ClassName.DisplayObjectContainer,this,BufferPool.DisplayObjectContainerMax);
			}
		}
		
		/**
		 *回收，如果是子对象则不要再掉这个方法，否则会出错，放入错误的回收列表
		 * 
		 */		
		override public function dispose():void
		{
			if(this._parent) this._parent.removeChild(this);
		}
		
		//////////////////////////////////////////////////////////////static/////////////////////////////////////////////////////////////////////////////////
		public static function create():DisplayObjectContainer
		{
			EngineLock.DisplayObjectContainer = false;
			var dis:DisplayObjectContainer = BufferPool.create(ClassName.DisplayObjectContainer,DisplayObjectContainer);
			EngineLock.DisplayObjectContainer = true;
			return dis;
		}
	}
}