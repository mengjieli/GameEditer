package main.menu
{
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	
	public class NativeMenuItemExtend extends NativeMenuItem
	{
		public function NativeMenuItemExtend(label:String="",data:Object=null,isSeparator:Boolean=false,subMenu:NativeMenu=null,click:Function=null,clickParams:Array=null)
		{
			super(label, isSeparator);
			this.data=data;
			if(subMenu)
				this.submenu=subMenu;
			if(click!=null)
				this.addEventListener(Event.SELECT,function(e:Event):void {
					click.apply(null,clickParams);
				});
		}
	}
}