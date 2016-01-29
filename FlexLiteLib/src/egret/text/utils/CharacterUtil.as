package egret.text.utils
{
	public final class CharacterUtil
	{
		public static function isHighSurrogate(charCode:int):Boolean
		{
			return (charCode >= 0xD800 && charCode <= 0xDBFF);
		}
		
		public static function isLowSurrogate (charCode:int):Boolean
		{
			return (charCode >= 0xDC00 && charCode <= 0xDFFF);
		}
		/**
		 * 检查指定的字符是否为大写字母
		 */		
		public static function isUpperCaseLetter(charCode:int):Boolean
		{
			return (charCode>=65 && charCode <= 90);
		}
		/**
		 * 检查指定的字符是否为小写字母
		 */		
		public static function isLowerCaseLetter(charCode:int):Boolean
		{
			return (charCode>=97 && charCode<122);
		}
		
		private static var whiteSpaceObject:Object = createWhiteSpaceObject();
		
		private static function createWhiteSpaceObject():Object
		{
			var rslt:Object = new Object();
			rslt[0x0020] =  true;  //SPACE
			rslt[0x1680] =  true;  //OGHAM SPACE MARK
			rslt[0x180E] =  true;  //MONGOLIAN VOWEL SEPARATOR
			rslt[0x2000] =  true;  //EN QUAD
			rslt[0x2001] =  true;  //EM QUAD
			rslt[0x2002] =  true;  //EN SPACE
			rslt[0x2003] =  true;  //EM SPACE
			rslt[0x2004] =  true;  //THREE-PER-EM SPACE
			rslt[0x2005] =  true;  //FOUR-PER-EM SPACE
			rslt[0x2006] =  true;  //SIZE-PER-EM SPACE
			rslt[0x2007] =  true;  //FIGURE SPACE
			rslt[0x2008] =  true;  //PUNCTUATION SPACE
			rslt[0x2009] =  true;  //THIN SPACE
			rslt[0x200A] =  true;  //HAIR SPACE
			rslt[0x202F] =  true;  //NARROW NO-BREAK SPACE
			rslt[0x205F] =  true;  //MEDIUM MATHEMATICAL SPACE
			rslt[0x3000] =  true;  //IDEOGRAPHIC SPACE
			rslt[0x2028] =  true;  //LINE SEPARATOR
			rslt[0x2029] =  true;
			rslt[0x0009] =  true; //CHARACTER TABULATION
			rslt[0x000A] =  true; //LINE FEED
			rslt[0x000B] =  true; //LINE TABULATION
			rslt[0x000C] =  true; //FORM FEED
			rslt[0x000D] =  true; //CARRIAGE RETURN
			rslt[0x0085] =  true; //NEXT LINE
			rslt[0x00A0] =  true; //NO-BREAK SPACE	
			return rslt;
		}
		/**
		 * 检查指定的字符是否为空白字符
		 */		
		public static function isWhitespace(charCode:int):Boolean
		{			
			return whiteSpaceObject[charCode];
		}
	}
}
