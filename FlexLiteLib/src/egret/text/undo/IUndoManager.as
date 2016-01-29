package egret.text.undo
{   
	/**
	 * 撤销管理器接口
	 * @author dom
	 */    
    public interface IUndoManager 
    {   
		/**
		 * 清空所有撤销和重做的历史记录
		 */       
        function clearAll():void;
        
		/**
		 * 可以撤销或重做的最大的次数。
		 */       
        function get undoAndRedoItemLimit():int;
        function set undoAndRedoItemLimit(value:int):void;

		/**
		 * 当前是否可以执行撤销
		 */        
        function canUndo():Boolean;
        
		/**
		 * 返回下一个可撤销的操作对象，但不移除它。
		 */        
        function peekUndo():IOperation;
        
		/**
		 * 返回下一个可撤销的操作对象，并且移除它。
		 */       
        function popUndo():IOperation;

		/**
		 * 添加一个操作对象到撤销列表
		 * @param operation 要添加的操作对象
		 */		
        function pushUndo(operation:IOperation):void;
        
		/**
		 * 清理重做列表
		 */        
        function clearRedo():void;

		/**
		 * 当前是否可以执行重做
		 */        
        function canRedo():Boolean;

		/**
		 * 返回下一个可重做的操作对象，但不删除它。
		 */        
        function peekRedo():IOperation;
        
		/**
		 * 返回下一个可重做的操作对象，并且删除它。
		 */        
        function popRedo():IOperation;

		/**
		 * 添加一个操作对象到重做列表
		 * @param operation 要添加的操作对象
		 */		
        function pushRedo(operation:IOperation):void;

		/**
		 * 执行一次撤销
		 */        
        function undo():void;
        
		/**
		 * 执行一次重做
		 */        
        function redo():void;                       
    }
}
