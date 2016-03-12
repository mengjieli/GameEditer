package com.flower.cocos2dx.display
{
	import com.flower.ClassName;
	import com.flower.bufferPool.BufferPool;
	import com.flower.cocos2dx.DebugInfo;
	import com.flower.cocos2dx.event.Event;
	import com.flower.cocos2dx.event.EventDispatcher;
	import com.jc.utils.Matrix;
	
	import cocos2dx.display.CCNode;

	/**
	 * 显示基类，提供显示对象需要的基本属性
	 * @author mengjie.li
	 * 2013/12/19
	 */
	
	public class DisplayObject extends EventDispatcher
	{
		private static var sid:Number = 0;
		
		protected var _id:Number;
		protected var _visible:Boolean;
		protected var _parentAlpha:Number;    //父类透明度
		protected var _alpha:Number;				//透明度
		protected var _x:Number;
		protected var _y:Number;
		protected var _width:int;
		protected var _height:int;
		protected var _scaleX:Number;
		protected var _scaleY:Number;
		protected var _anchorX:Number;
		protected var _anchorY:Number;
		protected var _rotation:Number;				//弧度
		protected var _parent:DisplayObjectContainer;
		public var mouseEnabled:Boolean;		//是否检测鼠标事件 默认检测
		public var mutiplyMouseEnabled:Boolean; //是否容许多点触摸
		
		/**偏移量，由于plist打包自动去白边引起的，对应plist中的sourceColorRect中x,y的值*/
		protected var _moveX:int;
		protected var _moveY:int;
		
		//鼠标事件
		protected var _mouseX:int;
		protected var _mouseY:int;
		
		//COCOS2DX
		protected var _show:CCNode;
		
		/**
		 *创建DisplayObject对象
		 * 单纯的DisplayObject是无意义的 
		 * @param subClass 是否为子类的对象，如果为false则创建不成功
		 * 
		 */		
		public function DisplayObject(subClass:Boolean=false)
		{
			super();
			if(subClass == 0)
			{
				DebugInfo.debug("|创建DisplayObject| 无意义的对象，如果是子对象必须设置subClass为true",DebugInfo.ERROR);
				return;
			}
		}
		
		/**
		 *从BufferPool中创建时初始化的内容，也是对象本身的初始化的内容
		 * 
		 */		
		public function initBuffer():void
		{
			_id = sid;
			sid++;
			_visible = true;
			_alpha = 1;
			_parentAlpha = 1;
			_x = 0;
			_y = 0;
			_width = 0;
			_height = 0;
			_scaleX = 1;
			_scaleY = 1;
			_anchorX = 0.5;
			_anchorY = 0.5;
			_rotation = 0;
			mouseEnabled = true;
			mutiplyMouseEnabled = false;
			_moveX = 0;
			_moveY = 0;
			_mouseX = 0;
			_mouseY = 0;
			_show = null;
			_parent = null;
		}
		
		public function isMouseTarget(matrix:Matrix,mutiply:Boolean):Boolean
		{
			if(mouseEnabled == false || _visible == false) return false;
			matrix.save();
			matrix.translate(-_x,-_y);
			if(_rotation) matrix.rotate(-_rotation);
			if(_scaleX != 1 || _scaleY != 1) matrix.scale(1/_scaleX,1/_scaleY);
			_mouseX = matrix.tx - _moveX + _anchorX*_width;
			_mouseY = matrix.ty - _moveY + _anchorY*_height;
			if(_mouseX >= 0 && _mouseY >= 0 && _mouseX < _width && _mouseY < _height)
			{
				return true;
			}
			matrix.setTo.apply(null,matrix._saves.pop());
			return false;
		}
		
		public function getId():Number 
		{
			return _id;
		}
		
		public function getShow():CCNode
		{
			return _show;
		}
		
		public function setVisible(val:Boolean):void 
		{
			_visible = val;
		}
		public function getVisible():Boolean 
		{
			return _visible;
		}
		
		/**
		 *从父类传来的透明度，外部对象无需调用，调用会导致错误
		 * @param val
		 * 
		 */		
		public function setParentAlpha(val:Number):void
		{
			_parentAlpha = val;
		}
		
		/**
		 *设置透明度 
		 * @param val 透明度为0~1
		 * 
		 */	
		public function setAlpha(val:Number):void 
		{
			_alpha = val;
		}
		public function getAlpha():Number 
		{
			return _alpha;
		}
		
		public function setPosition(x:Number,y:Number):void
		{
			if(_x == x && _y == y) return;
			_x = x;
			_y = y;
			this._show.setPosition(_x,_y);
		}
		
		public function setX(val:Number):void 
		{
			if(_x == val) return;
			_x = val;
			this._show.setPosition(_x,_y);
		}
		public function getX():Number 
		{
			return _x;
		}
		
		public function setY(val:Number):void 
		{
			if(_y == val) return;
			_y = val;
			this._show.setPosition(_x,_y);
		}
		public function getY():Number 
		{
			return _y;
		}
		
		public function getWidth():int 
		{
			return _width;
		}
		public function getHeight():int 
		{
			return _height;
		}
		
		public function setScaleX(val:Number):void 
		{
			if(_scaleX == val) return;
			_scaleX = val;
			if(_show) _show.setScaleX(val);
		}
		public function getScaleX():Number 
		{
			return _scaleX;
		}
		
		public function setScaleY(val:Number):void 
		{
			if(_scaleY == val) return;
			_scaleY = val;
			if(_show) _show.setScaleY(val);
		}
		public function getScaleY():Number 
		{
			return _scaleY;
		}
		
		public function setRotation(val:Number):void 
		{
			if(_rotation == val) return;
			_rotation = -val*Math.PI/180;
			if(_show) _show.setRotation(val);
		}
		public function getRotation():Number 
		{
			return -_rotation*180/Math.PI;
		}
		
		public function setAnchorPoint(x:Number,y:Number):void
		{
			if(_anchorX == x && _anchorY == y) return;
			_anchorX = x;
			_anchorY = y;
			this._show.setAnchorPoint(_anchorX,_anchorY);
		}
		
		public function setAnchorX(val:Number):void
		{
			if(_anchorX == val) return;
			_anchorX = val;
			this._show.setAnchorPoint(_anchorX,_anchorY);
		}
		public function getAnchorX():Number 
		{
			return _anchorX;
		}
		
		public function setAnchorY(val:Number):void
		{
			if(_anchorY == val) return;
			_anchorY = val;
			this._show.setAnchorPoint(_anchorX,_anchorY);
		}
		public function getAnchorY():Number 
		{
			return _anchorY;
		}
		
		public function getMouseX():int 
		{
			return _mouseX;
		}
		public function getMouseY():int 
		{
			return _mouseY;
		}
		
		/**
		 *设置父对象,外部类无需调用,否则会导致出错,如果需要添加对象请用addChild()
		 * @param val
		 * 
		 */	
		public function setParent(val:DisplayObjectContainer):void 
		{
			_parent  = val;
			if(_parent == null)
			{
				this._show.removeFromParent();
				this.dispatchEvent(new Event(Event.ADD));
			}
			else
			{
				_parent.getContainer().addChild(this._show);
				this.dispatchEvent(new Event(Event.REMOVE));
			}
		}
		public function getParent():DisplayObjectContainer
		{
			return _parent;
		}
	}
}