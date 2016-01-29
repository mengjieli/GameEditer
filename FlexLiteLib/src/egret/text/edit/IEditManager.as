package egret.text.edit
{
	/**
	 * 编辑管理器
	 * @author xzper
	 */
	public interface IEditManager extends ISelectionManager
	{
		/**
		 * 剪切选中文本
		 */
		function cut():void;
		/**
		 * 粘贴剪切版中的文本
		 */
		function paste():void;
		/**
		 * 清除选中的文本
		 */
		function deleteSelectedText():void;
		/**
		 * 撤销
		 */
		function undo():void;
		/**
		 * 重做
		 */
	 	function redo():void;
		/**
		 * 是否能撤销
		 */
		function canUndo():Boolean;
		/**
		 * 是否能重做
		 */
		function canRedo():Boolean;
		/**
		 * 在光标位置插入一段文本 
		 * @param text
		 */		
		function insertText(text:String):void;
		/**
		 * 从光标位置开始覆盖一段文本 
		 * @param text
		 */		
		function overwriteText(text:String):void;
		/**
		 * 删除光标之后的一个字符
		 */		
		function deleteNextCharacter():void;
		/**
		 * 删除光标之前的一个字符
		 */		
		function deleteNextWord():void;
		/**
		 * 删除当前光标位置下的前一个字符
		 */		
		function deletePreviousCharacter():void;
		/**
		 * 删除当前光标位置下的前一段字符，注意删除跟移动光标时的单词范围并不相同。
		 */		
		function deletePreviousWord():void;
	}
}