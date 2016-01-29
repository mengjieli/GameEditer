package egret.ui.components.boxClasses
{
	import flash.events.EventDispatcher;

	/**
	 * 盒式布局元素
	 * @author dom
	 */
	public class BoxElement extends EventDispatcher implements IBoxElementContainer
	{
		/**
		 * 构造函数
		 * @param vertical 是否为垂直方向布局,默认水平布局。
		 */		
		public function BoxElement(vertical:Boolean=false)
		{
			this._isVertical = vertical;
			_separator = new Separator();
			_separator.target = this;
		}
		
		public var _separator:Separator;
		
		/**
		 * 分隔符
		 */
		public function get separator():Separator
		{
			return _separator;
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
		
		private var _isVertical:Boolean = false;
		/**
		 * 是否为垂直方向布局
		 */
		public function get isVertical():Boolean
		{
			return _isVertical;
		}
		public function set isVertical(value:Boolean):void
		{
			_isVertical = value;
		}
		
		private var _percentSize:Number = 0.5;
		/**
		 * 第一个元素尺寸占父级容器的百分比,取值范围0~1。默认值0.5
		 */
		public function get percentSize():Number
		{
			return _percentSize;
		}
		public function set percentSize(value:Number):void
		{
			if(value>1)
				value = 1;
			if(value<0)
				value = 0;
			_percentSize = value;
		}
		
		
		private var _firstElement:IBoxElement;
		/**
		 * 第一个子元素
		 */
		public function get firstElement():IBoxElement
		{
			return _firstElement;
		}
		public function set firstElement(value:IBoxElement):void
		{
			if(_firstElement==value)
				return;
			if(_firstElement)
				_firstElement.parentBoxChanged(null,false);
			_firstElement = value;
			if(_firstElement)
			{
				_firstElement.parentBoxChanged(this);
				_firstElement.isFirstElement = true;
			}
		}
		
		private var _secondElement:IBoxElement;
		/**
		 * 第二个子元素
		 */
		public function get secondElement():IBoxElement
		{
			return _secondElement;
		}
		public function set secondElement(value:IBoxElement):void
		{
			if(_secondElement==value)
				return;
			if(_secondElement)
				_secondElement.parentBoxChanged(null,false);
			_secondElement = value;
			if(_secondElement)
			{
				_secondElement.parentBoxChanged(this);
				_secondElement.isFirstElement = false;
			}
		}
		
		private var _parentBox:IBoxElementContainer;
		/**
		 * 父级盒式布局元素
		 */
		public function get parentBox():IBoxElementContainer
		{
			return _parentBox;
		}
		
		/**
		 * 父级盒式布局容器改变
		 */		
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
		
		private var _x:Number = 0;
		/**
		 * x坐标
		 */
		public function get x():Number
		{
			return _x;
		}
		public function set x(value:Number):void
		{
			_x = value;
		}
		
		private var _y:Number = 0;
		/**
		 * y坐标
		 */
		public function get y():Number
		{
			return _y;
		}
		public function set y(value:Number):void
		{
			_y = value;
		}
		
		
		private var _explicitWidth:Number = NaN;
		/**
		 * 显式指定的宽度
		 */
		public function get explicitWidth():Number
		{
			return _explicitWidth;
		}
		
		private var _width:Number = 0;
		/**
		 * 宽度
		 */
		public function get width():Number
		{
			return _width;
		}
		public function set width(value:Number):void
		{
			if(_width==value)
				return;
			_width = value;
			_explicitWidth = value;
		}
		
		private var _explicitHeight:Number = NaN;
		/**
		 * 显式指定的高度
		 */
		public function get explicitHeight():Number
		{
			return _explicitHeight;
		}
		
		private var _height:Number = 0;
		/**
		 * 高度
		 */
		public function get height():Number
		{
			return _height;
		}
		public function set height(value:Number):void
		{
			if(_height==value)
				return;
			_height = value;
			_explicitHeight = value;
		}
		
		private var _defaultWidth:Number = 265;
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
		
		
		/**
		 * 设置元素的布局尺寸，此方法不影响显式尺寸属性。
		 */		
		public function setLayoutSize(width:Number,height:Number):void
		{
			_width = width;
			_height = height;
		}
		
		
		public function get minimized():Boolean
		{
			return firstElement&&firstElement.minimized&&
				secondElement&&secondElement.minimized;
		}
		
		public function set minimized(value:Boolean):void
		{
		}
		
		public function get visible():Boolean
		{
			return (firstElement&&firstElement.visible)||
				(secondElement&&secondElement.visible);
		}
	}
}