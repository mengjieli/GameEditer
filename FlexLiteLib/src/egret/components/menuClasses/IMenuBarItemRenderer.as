package egret.components.menuClasses
{
	import egret.core.IUIComponent;

	public interface IMenuBarItemRenderer extends IUIComponent
	{
		function get data():Object;
		function set data(value:Object):void;
		
		function get icon():Object;
		function set icon(value:Object):void;
		
		function get label():String;
		function set label(value:String):void;
		
		function get menuDown():Boolean
		function set menuDown(value:Boolean):void
		
		function itemDown():void
		function itemUp():void	
			
	}
}


