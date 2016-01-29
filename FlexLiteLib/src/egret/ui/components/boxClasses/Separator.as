package egret.ui.components.boxClasses
{
	import flash.display.Graphics;
	
	import egret.core.UIComponent;
	
	
	/**
	 * 分隔符
	 * @author dom
	 */
	public class Separator extends UIComponent
	{
		/**
		 * 构造函数
		 */		
		public function Separator()
		{
			super();
			mouseChildren = false;
		}
		
		/**
		 * 目标布局元素
		 */		
		public var target:BoxElement;
		
		
		override protected function updateDisplayList(w:Number,h:Number):void
		{
			super.updateDisplayList(w,h);
			if(isNaN(w))
				w = 0;
			if(isNaN(h))
				h = 0;
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(0,0x1b2025,0,true,"normal","square");
			if(w>h)
			{
				g.moveTo(0,1);
				g.lineTo(w,1);
			}
			else
			{
				g.moveTo(1,0);
				g.lineTo(1,h-1);
			}
			g.endFill();
			g.lineStyle();
			g.beginFill(0x009aff,0);
			g.drawRect(0,0,w,h);
			g.endFill();
		}
	}
}