package egret.ui.core.FTEText.core
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	
	import egret.ui.core.FTEText.info.TextDataInfo;
	import egret.ui.core.FTEText.info.TextLineInfo;
	import egret.utils.Recycler;

	/**
	 * 文本编辑器基类 
	 * @author featherJ
	 * 
	 */	
	public class FTETextBase extends Sprite
	{
		
		/**数据行列表*/
		protected var textLineDatas:Vector.<TextDataInfo> = new Vector.<TextDataInfo>();
		/**显示行列表*/
		protected var textLineViews:Vector.<TextLineInfo> = new Vector.<TextLineInfo>();
		/**
		 * textLine对象缓存表
		 */		
		private static var textLineRecycler:Recycler;
		private static var staticTextBlock:TextBlock;
		private static var staticTextElement:TextElement;

	

		private static var staticRecreateTextLine:Function;
		
		public function FTETextBase()
		{
			
		}
		/**
		 * 初始化类静态属性
		 */		
		private static function initClass():void
		{
			staticTextBlock = new TextBlock();
			staticTextElement = new TextElement();
			textLineRecycler = new Recycler();
			if ("recreateTextLine" in staticTextBlock)
				staticRecreateTextLine = staticTextBlock["recreateTextLine"];
		}
		//调用初始化静态属性
		initClass();
		/**
		 * 对staticTextBlock.recreateTextLine()方法的引用。
		 * 它是player10.1新添加的接口，能够重用TextLine而不用创建新的。
		 * 若当前版本低于10.1，此方法无效。
		 * @param recycleLine 需要回收的文本行
		 * @param previousLine 指定在其后开始断开的上一个断行。在对第一行换行时可以是 null。
		 * @param $width 以像素为单位指定所需的行宽度。实际宽度可能更小。
		 * @param lineOffset 一个可选参数，以像素为单位指定行的起点和 Tab 停靠位起点之间的距离。当行未对齐但其 Tab 停靠位需要对齐时可以使用此参数。此参数的默认值为 0.0。
		 * @param fitSomething 一个可选参数，表示 Flash Player 至少使一个字符适合文本行，不管指定的宽度如何（即使宽度为零或负值，在这种情况下，将导致引发异常）。
		 * 
		 */		
		public function recreateTextLine(recycleLine:TextLine,previousLine:TextLine=null, $width:Number=1000000, lineOffset:Number=0.0, fitSomething:Boolean=false):TextLine
		{
			return staticRecreateTextLine(recycleLine,previousLine,$width,lineOffset,fitSomething);
		}
		/**
		 * 释放TextLines
		 */		
		protected function releaseTextLines($textLines:* = null):void
		{
			var textLine:TextLine;
			var parent:DisplayObjectContainer
			if($textLines is Array || $textLines is Vector.<TextLine>)
			{
				while($textLines.length>0)
				{
					textLine = $textLines.pop();
					parent = textLine.parent as DisplayObjectContainer;
					if (parent)
						DisplayObjectContainer(textLine.parent).removeChild(textLine);
					if (textLine)
					{
						if (textLine.validity != TextLineValidity.INVALID && 
							textLine.validity != TextLineValidity.STATIC)
						{
							textLine.validity = TextLineValidity.INVALID;
						}
						textLine.userData = null;	
						textLineRecycler.push(textLine);
					}
				}
				return;
			}else if($textLines is TextLine)
			{
				textLine = $textLines;
				parent = textLine.parent as DisplayObjectContainer;
				if (parent)
					DisplayObjectContainer(textLine.parent).removeChild(textLine);
				if (textLine)
				{
					if (textLine.validity != TextLineValidity.INVALID && 
						textLine.validity != TextLineValidity.STATIC)
					{
						textLine.validity = TextLineValidity.INVALID;
					}
					textLine.userData = null;	
					textLineRecycler.push(textLine);
				}
				return;
			}
			
			if(!$textLines)
				while(textLineViews.length>0)
				{
					var textLineInfo:TextLineInfo = textLineViews.pop();
					textLine = textLineInfo.content;
					parent = textLine.parent as DisplayObjectContainer;
					if (parent)
						DisplayObjectContainer(textLine.parent).removeChild(textLine);
					if (textLine)
					{
						if (textLine.validity != TextLineValidity.INVALID && 
							textLine.validity != TextLineValidity.STATIC)
						{
							textLine.validity = TextLineValidity.INVALID;
						}
						textLine.userData = null;	
						textLineRecycler.push(textLine);
					}
				}
		}
		
		protected function get textElement():TextElement
		{
			return staticTextElement;
		}
		
		protected function get textBlock():TextBlock
		{
			return staticTextBlock;
		}
		
		protected function getRecycleLine():TextLine
		{
			return textLineRecycler.get();
		}
		
		/**
		 * 将字符串按照"\r"或"\n"或"\r\n"分割成多个子字符串 
		 * @param str
		 * @return 
		 * 
		 */		
		protected function sliceText(str:String):Vector.<String>
		{
			var strArr:Vector.<String> = new Vector.<String>();
			var lineTags:int = 0;
			for(var i:int = 0;i<str.length;i++)
			{
				var currentStr:String;
				if(i == str.length-1)
				{
					currentStr = str.slice(lineTags,i+1);
					strArr.push(currentStr)
				}else if(i<str.length-1 && str.charAt(i) == "\r" && str.charAt(i+1) == "\n")
				{
					currentStr = str.slice(lineTags,i+2);
					lineTags = i+2;
					i++;
					strArr.push(currentStr);
				}else if(str.charAt(i) == "\r" || str.charAt(i) == "\n")
				{
					currentStr = str.slice(lineTags,i+1);
					lineTags = i+1;
					strArr.push(currentStr);
				}
			}
			if(strArr.length == 0)
				strArr.push("");
			return strArr;
		}
	}
}