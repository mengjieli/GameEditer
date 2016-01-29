package egret.layouts
{
	import egret.components.ToggleButton;
	import egret.components.supportClasses.GroupBase;
	import egret.core.IVisualElement;

	/**
	 * 可折叠框的布局 
	 * @author 雷羽佳
	 * 
	 */	
	public class AccordionLayout extends ScrollBasicLayout
	{
		public function AccordionLayout()
		{
			super();
		}
		
		override public function measure():void
		{
			super.measure();
			var target:GroupBase = this.target;
			var length:int = target.numElements;
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;
			for(var i:int=0;i<length;i++)
			{
				var element:IVisualElement = target.getElementAt(i);
				if(!element||!element.includeInLayout)
				{
					continue;
				}
				var button:ToggleButton = target.getChildAt(i*2+1) as ToggleButton;
				maxWidth = Math.max(maxWidth,button.preferredWidth);
				maxHeight += button.preferredHeight;
				if(button.selected)
				{
					maxWidth = Math.max(maxWidth,element.preferredWidth);
					maxHeight += element.preferredHeight;
				}
			}
			target.measuredWidth = maxWidth;
			target.measuredHeight = maxHeight;
		}
		
		override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var target:GroupBase = this.target;
			var length:int = target.numElements;
			var yPos:Number = 0;
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;
			for(var i:int=0;i<length;i++)
			{
				var element:IVisualElement = target.getElementAt(i);
				if(!element||!element.includeInLayout)
				{
					continue;
				}
				var button:ToggleButton = target.getChildAt(i*2+1) as ToggleButton;
				maxWidth = Math.max(maxWidth,button.preferredWidth,button.getMinBoundsWidth());
				if(button.selected)
				{
					maxWidth = Math.max(maxWidth,element.preferredWidth,element.getMinBoundsWidth());
				}
			}
			var layoutWidth:Number = Math.max(unscaledWidth,maxWidth);
			for(i=0;i<length;i++)
			{
				element = target.getElementAt(i);
				if(!element||!element.includeInLayout)
				{
					continue;
				}
				button = target.getChildAt(i*2+1) as ToggleButton;
				button.visible = element.includeInLayout;
				button.setLayoutBoundsSize(Math.min(layoutWidth,button.getMaxBoundsWidth()),NaN);
				button.setLayoutBoundsPosition(0,yPos);
				yPos += button.layoutBoundsHeight;
				maxHeight += button.layoutBoundsHeight;
				if(button.selected)
				{
					element.setLayoutBoundsSize(Math.min(layoutWidth,element.getMaxBoundsWidth()),NaN);
					element.setLayoutBoundsPosition(0,yPos);
					yPos += element.layoutBoundsHeight;
					maxHeight += element.layoutBoundsHeight;
				}
			}
			target.setContentSize(Math.ceil(maxWidth), Math.ceil(maxHeight));
		}
		
	}
}