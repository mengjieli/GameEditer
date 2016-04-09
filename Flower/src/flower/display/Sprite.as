package flower.display
{
	import flower.geom.Matrix;
	import flower.utils.CallLater;

	public class Sprite extends DisplayObject implements DisplayObjectContainer
	{
		protected var _childs:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		private static var displayObjectContainerProperty:Object = System.DisplayObjectContainer;
		
		public function Sprite()
		{
			super();
			_show = System.getNativeShow("DisplayObjectContainer");
			_nativeClass = "DisplayObjectContainer";
		}
		
		/**
		 *添加子对象 
		 * @param child	显示对象
		 * 
		 */		
		public function addChild(child:DisplayObject):void
		{
			if(child.parent) child.parent.removeChild(child);
			_childs.push(child);
			child.$parentAlpha = $parentAlpha*alpha;
			child.$setParent(this);
			child.$onAddToStage(this.stage,this._nestLevel+1);
			if(System.IDE == "cocos2dx") {
				CallLater.add(this._resetChildIndex,this);
			}
		}
		
		public function getChildAt(index:int):DisplayObject {
			index = +index&~0;
			return _childs[index];
		}
		
		/**
		 *添加子对象到某一层 0为最底层 
		 * @param child
		 * @param index
		 * 
		 */		
		public function addChildAt(child:DisplayObject,index:int=0):void
		{
			if(child.parent == this) {
				this.setChildIndex(child,index);
			} else {
				if(child.parent) child.parent.removeChild(child);
				_childs.splice(index,0,child);
				child.$parentAlpha = $parentAlpha*alpha;
				child.$setParent(this);
				child.$onAddToStage(this.stage,this._nestLevel+1);
				if(System.IDE == "cocos2dx") {
					CallLater.add(this._resetChildIndex,this);
				}
			}
		}
		
		/**
		 *移除子对象 
		 * @param child	显示对象
		 * 
		 */		
		public function removeChild(child:DisplayObject):void
		{
			for(var i:int = 0; i < _childs.length; i++)
			{
				if(_childs[i] == child)
				{
					_childs.splice(i,1);
					child.$parentAlpha = 1;
					child.$setParent(null);
					child.$onRemoveFromStage();
					if(System.IDE == "cocos2dx") {
						CallLater.add(this._resetChildIndex,this);
					}
					return;
				}
			}
		}
		
		public function removeChildAt(index:int):void {
			var child:DisplayObject = _childs.splice(index,1)[0];
			child.$parentAlpha = 1;
			child.$setParent(null);
			child.$onRemoveFromStage();
			if(System.IDE == "cocos2dx") {
				CallLater.add(this._resetChildIndex,this);
			}
		}
		
		/**
		 *设置子对象的层数 
		 * @param child	子对象
		 * @param index 层数
		 * 
		 */		
		public function setChildIndex(child:DisplayObject,index:uint):void
		{
			var childIndex:uint = getChildIndex(child);
			if(childIndex == index) {
				return;
			}
			_childs.splice(childIndex,1);
			_childs.splice(index,0,child);
			var p:Object = displayObjectContainerProperty.setChildIndex;
			if(System.IDE == "cocos2dx") {
				CallLater.add(this._resetChildIndex,this);
			} else {
				this._show[p.func](child.$nativeShow,index);
			}
		}
		
		private function _resetChildIndex():void {
			if(System.IDE == "cocos2dx") {
				for(var i:int = 0; i < _childs.length; i++) {
					_childs[i].$nativeShow["setLocalZOrder"](i);
				}
			}
		}
		
		/**
		 *获取子对象的层数 
		 * @param child
		 * @return
		 * 
		 */		
		public function getChildIndex(child:DisplayObject):uint
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
		public function contains(child:DisplayObject):Boolean
		{
			if(child.parent == this) return true;
			return false;
		}
		
		override protected function _alphaChange():void {
			for(var i:int = 0; i < this._childs.length; i++) {
				this._childs[i].$parentAlpha = $parentAlpha*alpha;
			}
		}
		
		override public function $onFrameEnd():void {
			for(var i:int = 0,len:int = this._childs.length; i < len; i++) {
				this._childs[i].$onFrameEnd();
			}
		}
		
		/**
		 *回收，如果是子对象则不要再掉这个方法，否则会出错，放入错误的回收列表
		 * 
		 */		
		override public function dispose():void
		{
			while(this._childs.length) {
				this._childs[0].dispose();
			}
			if(this.parent) {
				this.parent.removeChild(this);
			}
		}
		
		protected function _getMouseTarget(matrix:Matrix,mutiply:Boolean):DisplayObject
		{
			if(this._touchEnabled == false || this._visible == false) return null;
			if(mutiply == true && _mutiplyTouchEnabled == false) return null;
			matrix.save();
			matrix.translate(-x,-y);
			if(rotation) matrix.rotate(-radian);
			if(scaleX != 1 || scaleY != 1) {
				matrix.scale(1/scaleX,1/scaleY);
			}
			_touchX = matrix.tx;
			_touchY = matrix.ty;
			var target:DisplayObject;
			var len:uint = _childs.length;
			for(var i:int = len - 1; i >= 0; i--)
			{
				if(_childs[i].touchEnabled && (mutiply == false || (mutiply == true && _childs[i].mutiplyTouchEnabled  == true)))
				{
					if(_childs[i] is Sprite)
					{
						target = (_childs[i] as Sprite)._getMouseTarget(matrix,mutiply);
						if(target != null) break;
					}
					else if(_childs[i].$isMouseTarget(matrix,mutiply) == true)
					{
						target = _childs[i] as DisplayObject;
						break;
					}
				}
			}
			matrix.restore();
			return target;
		}
		
		//////////////////////////////////////set & get////////////////////////////////////
		public function get numChildren():uint {
			return _childs.length;
		}
		
		/**
		 * 获取测量宽
		 */
		public function get mesureWidth():int {
			var sx:Number = 0;
			var ex:Number = 0;
			for each(var child:* in _childs)
			{
				if(child.x < sx)
				{
					sx = child.x;
				}
				if(child.x + child.width > ex)
				{
					ex = child.x + child.width;
				}
			}
			return Math.floor(ex - sx);
		}
		
		/**
		 * 获取测量高
		 */
		public function get mesureHeight():int {
			var sy:Number = 0;
			var ey:Number = 0;
			for each(var child:* in _childs)
			{
				if(child.y < sy)
				{
					sy = child.y;
				}
				if(child.y + child.width > ey)
				{
					ey = child.y + child.height;
				}
			}
			return Math.floor(ey - sy);
		}
		
		public static var _EVENT_ADD_TO_STAGE_LIST:Array = [];
		public static var _EVENT_REMOVE_FROM_STAGE_LIST:Array = [];
	}
}