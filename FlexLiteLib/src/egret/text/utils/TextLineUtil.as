package egret.text.utils
{
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	/**
	 * 
	 * @author dom
	 */
	public class TextLineUtil
	{
		/**
		 * 计算TextLine的文本宽度。此方法能获得真实的文本宽度，包括文本末端结尾的空格字符。TextLine.width或TextLine.textWidth都不包含结尾空格字符的宽度。
		 */		
		public static function getTextWidth(textLine:TextLine):Number
		{
			if(textLine.atomCount==0)
				return 0;
			var atomIndex:int = textLine.atomCount-1;
			var bounds:Rectangle = textLine.getAtomBounds(atomIndex);
			return bounds.right;
		}
	}
}