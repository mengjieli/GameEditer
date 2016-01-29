package egret.utils
{
	
	/**
	 * 从ts文件读取类名列表的工具类
	 * @author dom
	 */
	public class ClassReader
	{
		/**
		 * 获取TS文件里包含的类名,接口名,全局变量，或全局函数列表
		 */		
		public static function readClassNameFromTS(tsText:String):Array
		{
			var list:Array = [];
			if(tsText)
			{
				tsText = tsText.split("\r\n").join("\n").split("\r").join("\n");
				analyzeModule(tsText,list);
			}
			return list;
		}
		
		/**
		 * 分析一个ts文件
		 */
		private static function analyzeModule(text:String,list:Array,moduleName:String=""):void
		{
			var block:String = "";
			while (text.length > 0) 
			{
				var index:int = CodeUtil.getFirstVariableIndex("module",text);
				if (index == -1) 
				{
					readClassFromBlock(text,list,moduleName);
					break;
				} 
				else 
				{
					readClassFromBlock(text.substring(0, index+6),list,moduleName);
					text = text.substring(index+6);
					var ns:String = CodeUtil.getFirstWord(text);
					ns = CodeUtil.trimVariable(ns);
					index = CodeUtil.getBracketEndIndex(text);
					if (index == -1) 
					{
						break;
					}
					block = text.substring(0, index);
					text = text.substring(index + 1);
					index = block.indexOf("{");
					block = block.substring(index+1);
					if(moduleName)
					{
						ns = moduleName+"."+ns;
					}
					analyzeModule(block,list,ns);
				}
			}
		}
		
		/**
		 * 从代码块中分析引用关系，代码块为一个Module，或类外的一段全局函数定义
		 */
		private static function readClassFromBlock(text:String,list:Array,ns:String):void
		{
			var newText:String = "";
			while(text.length>0)
			{
				var index:int = text.indexOf("{");
				if(index==-1)
				{
					newText += text;
					break;
				}
				newText += text.substring(0,index);
				text = text.substring(index);
				index = CodeUtil.getBracketEndIndex(text);
				if(index==-1)
				{
					newText += text;
					break;
				}
				text = text.substring(index+1);
			}
			text = newText;
			while (text.length > 0) 
			{
				index = getFirstKeyWordIndex("class", text,ns);
				var interfaceIndex:int = getFirstKeyWordIndex("interface", text,ns);
				var enumIndex:int = getFirstKeyWordIndex("enum",text,ns);
				var functionIndex:int = getFirstKeyWordIndex("function", text,ns);
				var varIndex:int = getFirstKeyWordIndex("var", text,ns);
				index = Math.min(interfaceIndex,index,enumIndex,functionIndex,varIndex);
				if (index == int.MAX_VALUE) 
				{
					break;
				}
				
				var isVar:Boolean = (index==varIndex);
				var keyLength:int = 5;
				switch (index)
				{
					case varIndex:
						keyLength = 3;
						break;
					case interfaceIndex:
						keyLength = 9;
						break;
					case functionIndex:
						keyLength = 8;
						break;
					case enumIndex:
						keyLength = 4;
						break;
				}
				
				text = text.substring(index + keyLength);
				var word:String = CodeUtil.getFirstVariable(text);
				if (word) {
					var className:String;
					if (ns) 
					{
						className = ns + "." + word;
					} 
					else 
					{
						className = word;
					}
					if (list.indexOf(className) == -1) 
					{
						list.push(className);
					}
					text = CodeUtil.removeFirstVariable(text);
				}
				if(isVar)
				{
					index = text.indexOf("\n");
					if(index==-1)
					{
						index = text.length;
					}
					text = text.substring(index);
				}
				else
				{
					index = CodeUtil.getBracketEndIndex(text);
					text = text.substring(index + 1);
				}
			}
		}
		
		/**
		 * 读取第一个关键字的索引
		 */
		private static function getFirstKeyWordIndex(key:String,text:String,ns:String):int
		{
			var preText:String = "";
			var index:int = int.MAX_VALUE;
			while(text.length>0)
			{
				index = CodeUtil.getFirstVariableIndex(key, text);
				if(index==-1)
				{
					index = int.MAX_VALUE;
				}
				else if(ns)
				{
					if(CodeUtil.getLastWord(text.substring(0,index))!="export")
					{
						preText = text.substring(0,index+key.length);
						text = text.substring(index+key.length);
						index = int.MAX_VALUE;
						continue;
					}
				}
				break;
			}
			if(index!=int.MAX_VALUE)
				index += preText.length;
			return index;
		}
	}
}