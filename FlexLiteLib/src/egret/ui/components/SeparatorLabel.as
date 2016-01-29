package egret.ui.components
{
	import flash.display.Graphics;
	
	import egret.components.Group;
	import egret.components.Label;
	
	/**
	 * 虚线分隔文本
	 * @author dom
	 */
	public class SeparatorLabel extends Group
	{
		public function SeparatorLabel()
		{
			super();
			mouseEnabledWhereTransparent = false;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			if(!label.parent)
			{
				addElement(label);
				label.horizontalCenter = 0;
				label.verticalCenter = 0;
				label.textColor = 0xe1e1e1;
			}
		}
		
		private var label:Label = new Label();
		/**
		 * 要显示的文本
		 */		
		public function get text():String
		{
			return label.text;
		}
		
		public function set text(value:String):void
		{
			label.text = value;
		}
		
		private var _lineColor:uint = 0x808080;
		
		public function get lineColor():uint
		{
			return _lineColor;
		}
		
		public function set lineColor(value:uint):void
		{
			if(_lineColor==value)
				return;
			_lineColor = value;
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(_lineColor);
			var y:int = unscaledHeight*0.5;
			var minX:int = label.x-4;
			var maxX:int = label.x+label.width;
			if(label.text=="")
			{
				minX = maxX;
			}
			for(var x:int=3;x<unscaledWidth;x+=4)
			{
				if(x>=minX&&x<=maxX)
					continue;
				g.drawRect(x,y,1,1);
			}
			g.endFill();
		}
	}
}