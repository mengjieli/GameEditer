package egret.utils.maxRects
{
	/**
	 *盒式布局元素接口 
	 * @author yn
	 * 
	 */	
	public interface IMaxRectangle
	{
		function set x(v:Number):void;
		function get x():Number;
		
		function set y(v:Number):void;
		function get y():Number;
		
		function set width(v:Number):void;
		function get width():Number;
		
		function set height(v:Number):void;
		function get height():Number;
		
		function set data(v:Object):void;
		function get data():Object;
		
		function set isRotated(v:Boolean):void;
		function get isRotated():Boolean;
		
		function cloneOne():IMaxRectangle;
		function newOne():IMaxRectangle;
	}
}