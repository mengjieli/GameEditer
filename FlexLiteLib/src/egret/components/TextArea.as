package egret.components
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import egret.components.supportClasses.SkinnableTextBase;
	import egret.core.ns_egret;
	
	use namespace ns_egret;
	
	[DefaultProperty(name="text",array="false")]
	
	[EXML(show="true")]
	
	/**
	 * 可设置外观的多行文本输入控件
	 * @author dom
	 */	
	public class TextArea extends SkinnableTextBase
	{
		/**
		 * 构造函数
		 */		
		public function TextArea()
		{
			super();
		}
		
		/**
		 * 控件的默认宽度（使用字号：size为单位测量）。 若同时设置了maxChars属性，将会根据两者测量结果的最小值作为测量宽度。
		 */		
		public function get widthInChars():Number
		{
			return getWidthInChars();
		}
		
		public function set widthInChars(value:Number):void
		{
			setWidthInChars(value);
		}
		
		/**
		 * 控件的默认高度（以行为单位测量）。 
		 */
		public function get heightInLines():Number
		{
			return getHeightInLines();
		}
		
		/**
		 *  @private
		 */
		public function set heightInLines(value:Number):void
		{
			setHeightInLines(value);
		}
		
		/**
		 * 滚动到指定索引区域
		 * @param beginIndex 开始的索引(包括)
		 * @param endIndex 结束的索引(不包括)
		 */		
		public function scrollToRange(beginIndex:int=0,endIndex:int=int.MAX_VALUE):void
		{
			if(textDisplay)
			{
				textDisplay.scrollToRange(beginIndex,endIndex);
			}
		}
		
		/**
		 * 水平滚动条策略改变标志
		 */		
		private var horizontalScrollPolicyChanged:Boolean = false;
		
		private var _horizontalScrollPolicy:String;

		/**
		 * 水平滚动条显示策略，参见ScrollPolicy类定义的常量。
		 */		
		public function get horizontalScrollPolicy():String
		{
			return _horizontalScrollPolicy;
		}

		public function set horizontalScrollPolicy(value:String):void
		{
			if(_horizontalScrollPolicy==value)
				return;
			_horizontalScrollPolicy = value;
			horizontalScrollPolicyChanged = true;
			invalidateProperties();
		}

		/**
		 * 垂直滚动条策略改变标志 
		 */		
		private var verticalScrollPolicyChanged:Boolean = false;
		
		private var _verticalScrollPolicy:String;
		/**
		 * 垂直滚动条显示策略，参见ScrollPolicy类定义的常量。
		 */
		public function get verticalScrollPolicy():String
		{
			return _verticalScrollPolicy;
		}

		public function set verticalScrollPolicy(value:String):void
		{
			if(_verticalScrollPolicy==value)
				return;
			_verticalScrollPolicy = value;
			verticalScrollPolicyChanged = true;
			invalidateProperties();
		}

		
		/**
		 * [SkinPart]实体滚动条组件
		 */
		public var scroller:Scroller;
		
		/**
		 * @inheritDoc
		 */
		override public function set text(value:String):void
		{
			super.text = value;
			dispatchEvent(new Event("textChanged"));        
		}

		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (horizontalScrollPolicyChanged)
			{
				if (scroller)
					scroller.horizontalScrollPolicy = horizontalScrollPolicy;
				horizontalScrollPolicyChanged = false;
			}
			
			if (verticalScrollPolicyChanged)
			{
				if (scroller)
					scroller.verticalScrollPolicy = verticalScrollPolicy;
				verticalScrollPolicyChanged = false;
			}
		}

		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == textDisplay)
			{
				textDisplay.multiline = true;
			}
			else if (instance == scroller)
			{
				if (scroller.horizontalScrollBar)
					scroller.horizontalScrollBar.snapInterval = 0;
				if (scroller.verticalScrollBar)
					scroller.verticalScrollBar.snapInterval = 0;
			}
		}
		
	}
	
}
