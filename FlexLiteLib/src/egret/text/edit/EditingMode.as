package egret.text.edit
{
	/**
	 * 文本编辑模式常量
	 * @author dom
	 */	
	public final class EditingMode
	{
		/** 
		 * 只读模式，不能编辑也不能选择。
		 */
		public static const READ_ONLY:String = "readOnly";
		/** 
		 * 可选择也可以编辑文本。
		 */
		public static const READ_WRITE:String = "readWrite";
		/** 
		 * 可以选择文本，但是不能编辑。
		 */
		public static const READ_SELECT:String = "readSelect";			
	}
}