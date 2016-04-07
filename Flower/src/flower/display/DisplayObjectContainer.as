package flower.display
{
	import flower.events.Event;

	public interface DisplayObjectContainer
	{
		function addChild(child:DisplayObject):void;
		function getChildAt(index:int):DisplayObject;
		function addChildAt(child:DisplayObject,index:int=0):void;
		function removeChild(child:DisplayObject):void;
		function removeChildAt(index:int):void;
		function setChildIndex(child:DisplayObject,index:uint):void;
		function getChildIndex(child:DisplayObject):uint;
		function contains(child:DisplayObject):Boolean;
		function get $nativeShow():*;
		function get x():Number;
		function set x(val:Number):void;
		function get y():Number;
		function set y(val:Number):void;
		function get width():int;
		function set width(val:int):void;
		function get height():int;
		function set height(val:int):void;
		function get scaleX():Number;
		function set scaleX(val:Number):void;
		function get scaleY():Number;
		function set scaleY(val:Number):void;
		function get rotation():Number;
		function set rotation(val:Number):void;
		function get mesureWidth():int;
		function get mesureHeight():int
		function once(type:String,listener:Function,thisObject:*):void;
		function addListener(type:String,listener:Function,thisObject:*):void;
		function removeListener(type:String,listener:Function,thisObject:*):void;
		function removeAllListener():void;
		function hasListener(type:String):Boolean;
		function dispatch(event:Event):void;
		function dispatchWidth(type:String,data:*=null):void;
		function dispose():void;
		function $getFlag(pos:int):Boolean;
	}
}