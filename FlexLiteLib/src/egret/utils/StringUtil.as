package egret.utils
{
	import flash.utils.getTimer;

	/**
	 * 字符串工具类
	 * @author dom
	 */	
	public class StringUtil
	{
		/**
		 * 去掉字符串两端所有连续的不可见字符。
		 * 注意：若目标字符串为null或不含有任何可见字符,将输出空字符串""。
		 * @param str 要格式化的字符串
		 */		
		public static  function trim(str:String):String
		{
			return trimLeft(trimRight(str));
		}
		/**
		 * 去除字符串左边所有连续的不可见字符。
		 * @param str 要格式化的字符串
		 */		
		public static function trimLeft(str:String):String
		{
			if(!str)
				return "";
			var char:String = str.charAt(0);
			while(str.length>0&&
				(char==" "||char=="\t"||char=="\n"||char=="\r"||char=="\f"))
			{
				str = str.substr(1);
				char = str.charAt(0);
			}
			return str;
		}
		/**
		 * 去除字符串右边所有连续的不可见字符。
		 * @param str 要格式化的字符串
		 */
		public static function trimRight(str:String):String
		{
			if(!str)
				return "";
			var char:String = str.charAt(str.length-1);
			while(str.length>0&&
				(char==" "||char=="\t"||char=="\n"||char=="\r"||char=="\f"))
			{
				str = str.substr(0,str.length-1);
				char = str.charAt(str.length-1);
			}
			return str;
		}
		
		/**
		 * 替换指定的字符串里所有的p为rep
		 */		
		public static function replaceStr(targetStr:String,p:String,rep:String):String
		{
			if(!targetStr)
				return "";
			var arr:Array = targetStr.split(p);
			return arr.join(rep);
		}
		/**
		 * 将颜色数字代码转换为字符串。
		 */		
		public static function toColorString(color:uint):String
		{
			var str:String = color.toString(16).toUpperCase();
			var num:int = 6-str.length;
			for(var i:int=0;i<num;i++)
			{
				str = "0"+str;
			}
			return "0x"+str;
		}
		/**
		 * 格式化文件长度为带单位的字符串
		 * @param length 文件长度,单位:字节。
		 * @param fractionDigits 要近似保留的小数位数,若为-1，则输出完整的大小。
		 */		
		public static function toSizeString(length:Number,fractionDigits:int=-1):String
		{
			var sizeStr:String = "";
			if(fractionDigits==-1)
			{
				if(length>1073741824)
				{
					sizeStr += int(length/1073741824).toString()+"GB";
					length = length%1073741824;
				}
				if(length>1048576)
				{
					if(sizeStr)
						sizeStr += ",";
					sizeStr += int(length/1048576).toString()+"MB";
					length = length%1048576;
				}
				if(length>1204)
				{
					if(sizeStr)
						sizeStr += ",";
					sizeStr += int(length/1204).toString()+"KB";
					length = length%1204;
				}
				if(length>0)
				{
					if(sizeStr)
						sizeStr += ",";
					sizeStr += length.toString()+"B";
				}
			}
			else
			{
				if(length>1073741824)
				{
					sizeStr = Number(length/1073741824).toFixed(fractionDigits)+"GB";
				}
				else if(length>1048576)
				{
					sizeStr = Number(length/1048576).toFixed(fractionDigits)+"MB";
				}
				else if(length>1204)
				{
					sizeStr = Number(length/1204).toFixed(fractionDigits)+"KB";
				}
				else
				{
					sizeStr = length.toString()+"B";
				}
			}
			return sizeStr;
		}
		
		private static var htmlEntities:Array = [["&","&amp;"],["<","&lt;"],[">","&gt;"],["\"","&quot;"],["'","&apos;"]];
		/**
		 * 转换为HTML实体字符
		 */		
		public static function escapeHTMLEntity(str:String,excludeApos:Boolean=true):String
		{
			if(!str)
				return "";
			var list:Array = htmlEntities;
			for each(var arr:Array in list)
			{
				var key:String = arr[0];
				if(excludeApos&&key=="'")
				{
					continue;
				}
				var value:String = arr[1];
				str = str.split(key).join(value);
			}
			return str;
		}
		/**
		 * 转换HTML实体字符为普通字符
		 */		
		public static function unescapeHTMLEntity(str:String):String
		{
			if(!str)
				return "";
			var list:Array = htmlEntities;
			for each(var arr:Array in list)
			{
				var key:String = arr[0];
				var value:String = arr[1];
				str = str.split(value).join(key);
			}
			return str;
		}
		
		/**
		 * 检查指定的索引是否在字符串中
		 * @param text 全文
		 * @param index 指定索引
		 * 
		 */		
		public static function checkInString(text:String,index:int):Boolean
		{
			var newStr:String = "";
			for(var i:int = index-1;i>=0;i--)
			{
				if(text.charAt(i) == "\r" || text.charAt(i) == "\n")
					break;
				else
				{
					newStr = text.charAt(i)+newStr;
				}
			}
			var flag1:Boolean = false;
			var flag2:Boolean = false;
			for(i = 0;i<newStr.length;i++)
			{
				if(newStr.charAt(i) == "\"" && (i == 0 || newStr.charAt(i-1) != "\\"))
				{
					if(!flag1 && !flag2)
					{
						flag1 = true;
					}else if(flag1)
					{
						flag1 = false;
					}
				}
				if(newStr.charAt(i) == "\'" && (i == 0 || newStr.charAt(i-1) != "\\"))
				{
					if(!flag1 && !flag2)
					{
						flag2 = true;
					}else if(flag2)
					{
						flag2 = false;
					}
				}
			}
			return flag1 || flag2;
		}
		
		/**
		 * 通过行和列得到索引位置 
		 * @param text
		 * @param line
		 * @param column
		 * @return 
		 * 
		 */		
		public static function getPosByLine(text:String,lineIndex:int,columnIndex:int):int
		{
			var lineList:Vector.<String> = new Vector.<String>();
			var lineBreaks:Vector.<String> = new Vector.<String>();
			var index:int = 0;
			var t:Number = getTimer();
			var rnLines:Array = text.split("\r\n");
			for each(var rnLine:String in rnLines)
			{
				var rLines:Array = rnLine.split("\r");
				for each(var rLine:String in rLines)
				{
					var nLines:Array = rLine.split("\n");
					for each(var line:String in nLines)
					{
						lineList.push(line);
						lineBreaks.push("\n");
					}
					lineBreaks[lineBreaks.length-1] = "\r";
				}
				lineBreaks[lineBreaks.length-1] = "\r\n";
			}
			
			if(lineBreaks.length>0)
				lineBreaks[lineBreaks.length-1] = "";
			
			var result:int = -1;
			var l:int = 0;
			for(var i:int = 0;i<lineList.length;i++)
			{
				if(lineIndex == i)
				{
					result = l+columnIndex;
					break;
				}
				l+=lineList[i].length;
				if(i<lineBreaks.length)
				{
					l+= lineBreaks[i].length;
				}
			}
			return result;
		}
		
//		/**
//		 * 通过行和列得到索引位置 
//		 * @param text
//		 * @param line
//		 * @param column
//		 * @return 
//		 * 
//		 */		
//		public static function getPosByLine(text:String,line:int,column:int):int
//		{
//			var currentLineIndex:int = 0;
//			var pos:int = 0;
//			var found:Boolean = false;
//			while(true)
//			{
//				if(line == currentLineIndex)
//				{
//					found = true;
//					if(column != -1) //查找首个非空字符
//					{
//						pos += column;
//					}else
//					{
//						for(var i:int = pos;i<text.length;i++)
//						{
//							if(text.charAt(i) != " " && text.charAt(i) != "\t" && text.charAt(i) != "\r" && text.charAt(i) != "\n")
//							{
//								pos = i;
//								break;
//							}
//						}
//					}
//					break;
//				}else
//				{
//					var lineEnd1:int = text.indexOf("\r\n",pos);
//					var lineEnd2:int = text.indexOf("\r",pos);
//					var lineEnd3:int = text.indexOf("\n",pos);
//					lineEnd1 = lineEnd1 == -1 ? int.MAX_VALUE : lineEnd1;
//					lineEnd2 = lineEnd2 == -1 ? int.MAX_VALUE : lineEnd2;
//					lineEnd3 = lineEnd3 == -1 ? int.MAX_VALUE : lineEnd3;
//					
//					var minLineEnd:int = Math.min(lineEnd1,lineEnd2,lineEnd3);
//					if(minLineEnd == int.MAX_VALUE)
//					{
//						break;
//					}else
//					{
//						if(minLineEnd == lineEnd1)
//						{
//							minLineEnd += 2;
//						}else
//						{
//							minLineEnd += 1;
//						}
//					}
//					pos = minLineEnd;
//					currentLineIndex++;
//				}
//			}
//			if(found)
//				return pos;
//			return -1;
//		}
		
		/**
		 * 通过索引位置得到行和列 
		 * @param text
		 * @param position
		 * @return 
		 * 
		 */		
		public static function getLineByPos(text:String,position:int):Object
		{
			var lineList:Vector.<String> = new Vector.<String>();
			var lineBreaks:Vector.<String> = new Vector.<String>();
			var index:int = 0;
			var t:Number = getTimer();
			var rnLines:Array = text.split("\r\n");
			for each(var rnLine:String in rnLines)
			{
				var rLines:Array = rnLine.split("\r");
				for each(var rLine:String in rLines)
				{
					var nLines:Array = rLine.split("\n");
					for each(var line:String in nLines)
					{
						lineList.push(line);
						lineBreaks.push("\n");
					}
					lineBreaks[lineBreaks.length-1] = "\r";
				}
				lineBreaks[lineBreaks.length-1] = "\r\n";
			}
			
			if(lineBreaks.length>0)
				lineBreaks[lineBreaks.length-1] = "";
			var result:Object = {"line":-1,"column":-1};
			var l:int = 0;
			var positionCache:int = 0;
			for(var i:int = 0;i<lineList.length;i++)
			{
				l+=lineList[i].length;
				if(i<lineBreaks.length)
				{
					l+= lineBreaks[i].length;
				}
				if(position<=l && position>=positionCache)
				{
					result["line"] = i;
					result["column"] = position-positionCache;
					break;
				}
				positionCache = l;
			}
			return result;
		}
		
		
//		/**
//		 * 通过索引位置得到行和列 
//		 * @param text
//		 * @param position
//		 * @return 
//		 * 
//		 */		
//		public static function getLineByPos(text:String,position:int):Object
//		{
//			var t:int = getTimer();
//			var pos:int = 0;
//			var previousPos:int = 0;
//			var line:int = 0;
//			var column:int = 0;
//			var found:Boolean = false;
//			while(true)
//			{
//				var lineEnd1:int = text.indexOf("\r\n",pos);
//				var lineEnd2:int = text.indexOf("\r",pos);
//				var lineEnd3:int = text.indexOf("\n",pos);
//				lineEnd1 = lineEnd1 == -1 ? int.MAX_VALUE : lineEnd1;
//				lineEnd2 = lineEnd2 == -1 ? int.MAX_VALUE : lineEnd2;
//				lineEnd3 = lineEnd3 == -1 ? int.MAX_VALUE : lineEnd3;
//				
//				var minLineEnd:int = Math.min(lineEnd1,lineEnd2,lineEnd3);
//				if(minLineEnd == int.MAX_VALUE)
//				{
//					break;
//				}else
//				{
//					if(minLineEnd == lineEnd1)
//					{
//						minLineEnd += 2;
//					}else
//					{
//						minLineEnd += 1;
//					}
//				}
//				pos = minLineEnd;
//				if(position>=previousPos && position < pos)
//				{
//					column = position-previousPos;
//					found = true;
//					break;
//				}
//				previousPos = pos;
//				line++;
//			}
//			if(found)
//				return {"line":line,"column":column};
//			return {"line":-1,"column":-1};
//		}
		
	}
}