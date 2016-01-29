package egret.text.edit
{
	/**
	 * 文本选择管理器接口
	 * @author dom
	 */	
	public interface ISelectionManager
	{		
		/**
		 * 选择部分开头的文本位置，是自文本流起始位置的偏移。
		 * 绝对起点与选择部分的活动点或锚点相同，具体取决于哪一个在文本流中更靠前。
		 */	
		function get absoluteStart() : int;
		/**
		 * 选择部分末尾的文本位置，是自文本流起始位置的偏移。
		 * 绝对终点与选择部分的活动点或锚点相同，具体取决于哪一个在文本流中更靠后。
		 */	
		function get absoluteEnd() : int;

		/**
		 * 选择某一范围的文本。如果任一参数值为负值，则会删除任何已经选择的部分。
		 * @param anchorPosition 新选择部分的锚点，是 TextFlow 中的绝对位置
		 * @param activePosition 新选择部分的活动终点，是 TextFlow 中的绝对位置
		 * @return 选中范围是否发生改变
		 */	
		function selectRange(anchorPosition:int, activePosition:int) : Boolean
		
		/**
		 * 全选文本
		 */
		function selectAll() : void;
		
		/**
		 * 复制选中文本
		 */
		function copy() : void;
		
		/** 
		 * 选择部分的锚点。
		 * 锚点是选择部分的固定终点。当扩展选择部分时，锚点不会随之改变。锚点可以位于当前选择的起始或结束位置。
		 */				
		function get anchorPosition() : int;

		/** 
		 * 选择部分的活动点。
		 * 活动点是选择部分的不定终点。活动点随选择的修改而改变。活动点可以位于当前选择的起始或结束位置。
		 */									
		function get activePosition() : int;
		/**
		 * 设置文本容器获得焦点
		 */	
		function setFocus():void;
		/**
		 * 此方法由文本编辑器内部方法，外部请勿调用。通常在TextOperation的子类中使用，以避免影响操作合并标志。
		 */		
		function internalSelectRange(anchorPosition:int, activePosition:int):Boolean;
		/**
		 * 获取当前的选中状态数据
		 */		
		function getSelectionState():SelectionState;
		/**
		 * 滚动到指定区域
		 */		
		function scrollToRange(anchorPosition:int,activePosition:int):void;
		/**
		 * 文本编辑模式
		 * @see egret.text.edit.EditingMode 
		 */	
		 function get editingMode():String;	
		 function set editingMode(value:String):void;
		 /**
		  * 获取选中的文本。如果没有选中则返回空字符串
		  */
		 function getSelectionText():String;
	}
}
