package egret.text
{
	import flash.events.IEventDispatcher;
	
	
	/**
	 * 文本容器接口,注意:实现此接口的类必须同时是Sprite的子类。
	 * @author dom
	 */
	public interface ITextContainer extends IEventDispatcher
	{
		/**
		 * 文本容器可视区域宽度
		 */		
		function get width():Number;
		/**
		 * 文本容器可视区域高度
		 */		
		function get height():Number;
		/**
		 * 视域的内容的宽度。
		 * 如果 clipAndEnabledScrolling 为 true， 则视域的 contentWidth 为水平滚动定义限制，
		 * 且视域的实际宽度定义可见的内容量。要在内容中水平滚动， 请在 0 和 contentWidth - width 
		 * 之间更改 horizontalScrollPosition。 
		 */		
		function get contentWidth():Number;
		
		/**
		 * 视域的内容的高度。
		 * 如果 clipAndEnabledScrolling 为 true，则视域的 contentHeight 为垂直滚动定义限制，
		 * 且视域的实际高度定义可见的内容量。要在内容中垂直滚动，请在 0 和 contentHeight - height 
		 * 之间更改 verticalScrollPosition。
		 */		
		function get contentHeight():Number;
		
		/**
		 * 可视区域水平方向起始点
		 */		
		function get horizontalScrollPosition():Number;
		function set horizontalScrollPosition(value:Number):void;
		
		/**
		 * 可视区域竖直方向起始点
		 */		
		function get verticalScrollPosition():Number;
		function set verticalScrollPosition(value:Number):void;
		/**
		 * 显示或隐藏文本的光标。
		 */		
		function get showIBeam():Boolean;
		function set showIBeam(value:Boolean):void;
		/**
		 * 更新文本光标的位置。
		 */		
		function updateIBeamPosition(x:Number,y:Number):void;
		/**
		 * 更新光标的状态和宽度 
		 * @param overwriteMode 是否是覆盖模式
		 */		
		function updateIBeamState(overwriteMode:Boolean):void;
		
		/**
		 * 文本当前显示的行高
		 */		
		function get lineHeight():Number;
	}
}