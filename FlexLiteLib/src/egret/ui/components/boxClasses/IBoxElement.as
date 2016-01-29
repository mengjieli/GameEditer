package egret.ui.components.boxClasses
{
	import flash.events.IEventDispatcher;
	
	/**
	 * 盒子元素
	 * @author dom
	 */
	public interface IBoxElement extends IEventDispatcher
	{
		/**
		 * 标识的唯一ID 
		 */		
		function get elementId():int;
		function set elementId(value:int):void
		
		/**
		 * x坐标
		 */		
		function get x():Number;
		function set x(value:Number):void;
		/**
		 * y坐标
		 */		
		function get y():Number;
		function set y(value:Number):void;
		/**
		 * 宽度
		 */
		function get width():Number;
		function set width(value:Number):void;
		/**
		 * 高度
		 */
		function get height():Number;
		function set height(value:Number):void;
		/**
		 * 显式设置的宽度
		 */		
		function get explicitWidth():Number;
		/**
		 * 显式设置的高度
		 */
		function get explicitHeight():Number;
		/**
		 * 默认宽度
		 */
		function get defaultWidth():Number;
		function set defaultWidth(value:Number):void;
		/**
		 * 默认高度
		 */
		function get defaultHeight():Number;
		function set defaultHeight(value:Number):void;
		/**
		 * 设置元素的布局尺寸，此方法不影响显式尺寸属性。
		 */
		function setLayoutSize(width:Number,height:Number):void;
		/**
		 * 父级盒式布局容器
		 */		
		function get parentBox():IBoxElementContainer;
		/**
		 * 父级盒式布局容器改变
		 */		
		function parentBoxChanged(box:IBoxElementContainer,checkOldParent:Boolean=true):void;
		/**
		 * 所属的盒式容器
		 */		
		function get ownerBox():IBoxElement;
		function set ownerBox(value:IBoxElement):void;
		/**
		 * 是否作为父级的第一个元素
		 */		
		function get isFirstElement():Boolean;
		function set isFirstElement(value:Boolean):void;
		/**
		 * 是否处于最小化状态
		 */		
		function get minimized():Boolean;
		function set minimized(value:Boolean):void;
		/**
		 * 是否可见
		 */		
		function get visible():Boolean;
			
	}
}