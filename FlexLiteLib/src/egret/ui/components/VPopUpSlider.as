package egret.ui.components
{
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;

	public class VPopUpSlider extends PopUpSliderBase
	{
		public function VPopUpSlider()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function pointToValue(x:Number, y:Number):Number
		{
			if (!thumb || !track)
				return 0;
			
			var range:Number = maximum - minimum;
			var thumbRange:Number = track.layoutBoundsHeight - thumb.layoutBoundsHeight;
			return minimum + ((thumbRange != 0) ? ((thumbRange - y) / thumbRange) * range : 0); 
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateSkinDisplayList():void
		{
			if (!thumb || !track)
				return;
			
			var thumbHeight:Number = thumb.layoutBoundsHeight
			var thumbRange:Number = track.layoutBoundsHeight - thumbHeight;
			var range:Number = maximum - minimum;
			var thumbPosTrackY:Number = (range > 0) ? thumbRange - (((pendingValue - minimum) / range) * thumbRange) : 0;
			var thumbPos:Point = track.localToGlobal(new Point(0, thumbPosTrackY));
			var thumbPosParentY:Number = thumb.parent.globalToLocal(thumbPos).y;
			
			thumb.setLayoutBoundsPosition(thumb.layoutBoundsX, Math.round(thumbPosParentY));
			if(showTrackHighlight&&trackHighlight&&trackHighlight.parent)
			{
				var trackHighlightY:Number = this.trackHighlight.parent.globalToLocal(thumbPos).y;
				trackHighlight.y = Math.round(trackHighlightY+thumbHeight);
				trackHighlight.height = Math.round(thumbRange-trackHighlightY);
			}
		}
	}
}