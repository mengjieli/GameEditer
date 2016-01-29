package main.menu
{
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;

	public class NativeMenuExtend extends NativeMenu
	{
		public function NativeMenuExtend(sumItems:Array)
		{
			for each(var item:NativeMenuItem in sumItems)
			{
				this.addItem(item);
			}
		}
	}
}