package egret.ui.events
{
	import flash.events.Event;
	
	import egret.components.ITreeItemRenderer;

	public class TreeEditorEvent extends Event
	{
		/**
		 * 编辑完的时候放出该事件，但不会进行真正的赋值操作，真正的赋值需要使用者自己完成。
		 */	
		public static const TREE_ITEM_EDITOR_END:String = "treeItemEditorEnd";
		public static const TREE_ITEM_EDITOR_START:String = "treeItemEditorStart";
		public function TreeEditorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=true,
										itemIndex:int = -1,item:Object = null,itemRenderer:ITreeItemRenderer = null)
		{
			super(type, bubbles, cancelable);
			this.item = item;
			this.itemRenderer = itemRenderer;
			this.itemIndex = itemIndex;
		}
		/**
		 * 触发鼠标事件的项呈示器数据源项。
		 */
		public var item:Object;
		/**
		 * 触发鼠标事件的项呈示器。 
		 */		
		public var itemRenderer:ITreeItemRenderer;
		/**
		 * 触发鼠标事件的项索引
		 */		
		public var itemIndex:int;
		/**
		 * 编辑的文字 
		 */		
		public var itemText:String = ""
	}
}