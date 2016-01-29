package egret.utils
{
	
	/**
	 * 命令行参数解析工具类
	 * @author dom
	 */
	public class Argments
	{
		
		/**
		 * 将数组转换成参数字符串
		 * @param args 要转换的参数
		 * @param addQuotes 是否自动添加双引号
		 * @return 转换后的字符串
		 */
		public static function stringify(args:Array , addQuotes:Boolean = true):String
		{
			if(args && args.length>0)
			{
				var result:String = "";

				for (var i:int = 0; i < args.length; i++) 
				{
					if(i>0)
						result+=" ";
					if(addQuotes && String(args[i]).indexOf(" ")>=0)
						result += "\""+String(args[i])+"\"";
					else
						result += String(args[i]);
				}
				return result;
			}
			else
			{
				return "";
			}
		}
		
		public static function parse(cmd:String):Array
		{
			var args:Array = [];
			if(!cmd)
				return args;
			var betweenQuote:Boolean = false;
			var arg:String = "";
			while(cmd)
			{
				var char:String = cmd.charAt(0);
				cmd = cmd.substring(1);
				if(char==" "||char=="\t")
				{
					if(arg)
					{
						args.push(arg);
						arg = "";
					}
				}
				else if(char=="\""||char=="'")
				{
					var index:int = cmd.indexOf(char);
					if(index==-1)
					{
						break;
					}
					arg += char+cmd.substring(0,index+1);
					cmd = cmd.substring(index+1);
				}
				else
				{
					arg += char;
				}
			}
			if(arg)
			{
				args.push(arg);
			}
			return args;
		}
	}
}