package flower.utils
{
	public class ObjectDo
	{
		public static function toString(obj:*,maxDepth:int=4,before:String="",depth:int=0):String {
			before = before||"";
			depth = depth||0;
			maxDepth = maxDepth||4;
			var str:String =  "";
			if(obj is Array) {
				if(depth > maxDepth) {
					return "...";
				}
				str = "[\n";
				for(var i = 0; i < obj.length; i++) {
					str += before + "\t" + ObjectDo.toString(obj[i],maxDepth,before + "\t",depth+1) + (i<obj.length-1?",\n":"\n");
				}
				str += before + "]";
			}
			else if(obj is Object) {
				if(depth > maxDepth) {
					return "...";
				}
				str  = "{\n";
				for(var key in obj) {
					str += before + "\t" + key + "\t: " + ObjectDo.toString(obj[key],maxDepth,before + "\t",depth+1);
					str += ",\n";
				}
				if(str.slice(str.length - 2,str.length) == ",\n") {
					str = str.slice(0,str.length-2) + "\n";
				}
				str += before + "}";
			} else {
				str +=  obj;
			}
			return str
		}
	}
}