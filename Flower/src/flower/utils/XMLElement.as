package flower.utils
{
	import flower.debug.DebugInfo;

	/**
	 *xml对象 
	 * @author MengJie.Li
	 * 
	 */	
	public class XMLElement extends XMLAttribute
	{
		public var namesapces:Vector.<XMLNameSpace>;
		public var attributes:Vector.<XMLAttribute>;
		/**xml子列表*/
		public var list:Vector.<XMLElement>;
		
		public function XMLElement()
		{
			namesapces = new Vector.<XMLNameSpace>();
			attributes = new Vector.<XMLAttribute>();
			list = new Vector.<XMLElement>();
		}
		
		public function getNameSapce(name:String):XMLNameSpace {
			for(var i:int = 0; i < namesapces.length; i++) {
				if(namesapces[i].name == name) {
					return namesapces[i];
				}
			}
			return null;
		}
		
		public function getElementByAttribute(atrName:String,value:String):XMLElement
		{
			for(var i:int = 0; i < list.length; i++)
			{
				for(var a:int = 0; a < list[i].attributes.length; a++)
				{
					if(list[i].attributes[a].name == atrName && list[i].attributes[a].value == value)
					{
						return list[i];
					}
				}
			}
			return null;
		}
		
		/**
		 *解析xml对象，传入xml字符串 
		 * @param content String xml内容
		 * 
		 */		
		public function parse(content:String):void
		{
			var delStart:int = -1;
			for(var i:int = 0; i < content.length; i++)
			{
				if(content.charAt(i) == "\r" || content.charAt(i) == "\n")
				{
					content = content.slice(0,i) + content.slice(i+1,content.length);
					i--;
				}
				if(delStart == -1 && (content.slice(i,i+2) == "<!" || content.slice(i,i+2) == "<?"))
				{
					delStart = i;
				}
				if(delStart != -1 && content.charAt(i) == ">")
				{
					content = content.slice(0,delStart) + content.slice(i+1,content.length);
					i = i - (i - delStart + 1);
					delStart = -1;
				}
			}
			readInfo(content);
		}
		
		private function readInfo(content:String,startIndex:int=0):int
		{
			/**<data>
					<me/>
					<me2 val="21/>
					<!11111嗯哪aaaaa/>
					<item a="1" b="123"/>
					<item c="2" d="556">
						我了个擦
					</item>
				</data>
			 */
			var leftSign:int = -1;
			var len:int = content.length;
			var c:String;
			var j:int;
			//第一步，寻找name
			for(var i:int = startIndex; i < len; i++)
			{
				c = content.charAt(i);
				if(c == "<")
				{
					//找名字的开始
					for(j = i + 1; j < len; j++)
					{
						c = content.charAt(j);
						if(c != " " && c != "\t")
						{
							i = j;
							break;
						}
					}
					//找名字的结尾
					for(j = i + 1; j < len; j++)
					{
						c = content.charAt(j);
						if(c == " " || c == "\t" || c == "/" || c == ">")
						{
							this.name = content.slice(i,j);
							i = j;
							break;
						}
					}
					break;
				}
			}
			
			//第二步，找属性
			var end:Boolean = false;
			var attribute:XMLAttribute;
			var nameSpace:XMLNameSpace;
			for(; i < len; i++)
			{
				c = content.charAt(i);
				if(c == "/")
				{
					end = true;
				}
				else if(c == ">")
				{
					i++;
					break;
				}
				else if(c == " " || c == "\t")
				{
					
				}
				else
				{
					//先寻找=号左边的名称
					for(j = i + 1; j < len; j++)
					{
						c = content.charAt(j);
						if(c == "=" || c == " " || c == "\t")
						{
							var atrName:String = content.slice(i,j);
							if(atrName.split(":").length == 2) {
								nameSpace = new XMLNameSpace();
								this.namesapces.push(nameSpace);
								nameSpace.name = atrName.split(":")[1];
							} else {
								attribute = new XMLAttribute();
								this.attributes.push(attribute);
								attribute.name = atrName;
							}
							break;
						}
					}
					
					//寻找=号右边的字符
					//寻找开始 " 符号
					j++;
					var startSign:String;
					for(; j < len; j++)
					{
						c = content.charAt(j);
						if(c == "\"" || c == "'")
						{
							i = j + 1;
							startSign = c;
							break;
						}
					}
					
					//寻找=号右边的字符
					//寻找结束 " 符号
					j++
					for(; j < len; j++)
					{
						c = content.charAt(j);
						if(c == startSign && content.charAt(j-1) != "\\")
						{
							if(attribute) {
								attribute.value = content.slice(i,j);
								attribute = null;
							} else {
								nameSpace.value = content.slice(i,j);
								nameSpace = null;
							}
							i = j;
							break;
						}
					}
				}
			}
			
			if(end == true) return i;
			
			//第二步，解析内容，和定位结尾
			//寻找下一个<
			var contentStart:int;
			for(; i < len; i++)
			{
				c = content.charAt(i);
				if(c != " " && c != "\t")
				{
					contentStart = i;
					i--;
					break;
				}
			}
			for(; i < len; i++)
			{
				c = content.charAt(i);
				if(c == "<")
				{
					//略去前面的" "和"\t"
					for(j = i + 1; j < len; j++)
					{
						c = content.charAt(j);
						if(c != " " && c != "\t")
						{
							break;
						}
					}
					//寻找第一个字符，如果是/则表示找到了结尾，否则继续寻找结尾
					if(c == "/")
					{
						for(j = i + 1; j < len; j++)
						{
							c = content.charAt(j);
							if(c == " " || c == "\t" || c == ">")
							{
								var endName:String = content.slice(i+2,j);
								if(endName != name)
								{
									DebugInfo.debug("开始标签和结尾标签不一致，开始标签：" + name + " ，结尾标签：" + endName,DebugInfo.ERROR);
								}
								break;
							}
						}
						if(this.list.length == 0) //寻找中间的字符串内容
						{
							i--;
							for(; i >= 0; i--)
							{
								c = content.charAt(i);
								if(c != " " && c != "\t")
								{
									break;
								}
							}
							value = content.slice(contentStart,i+1);
						}
						//寻找>结束符
						for(; j < len; j++)
						{
							c = content.charAt(j);
							if(c == ">")
							{
								i = j+1;
								break;
							}
						}
						end = true;
						break;
					}
					else
					{
						var element:XMLElement = new XMLElement();
						this.list.push(element);
						i = element.readInfo(content,i) - 1;
					}
				}
			}
			return i;
		}
		
		public static function parse(content:String):XMLElement {
			var xml:XMLElement = new XMLElement();
			xml.parse(content);
			return xml;
		}
	}
}