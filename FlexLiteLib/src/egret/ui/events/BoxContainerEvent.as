package egret.ui.events
{
	import flash.events.Event;
	
	import egret.ui.components.ITabPanel;
	import egret.ui.components.boxClasses.IBoxElement;

	/**
	 * 盒子布局容器事件
	 * @author 雷羽佳
	 * 
	 */	
	public class BoxContainerEvent extends Event
	{
		/**
		 * 拖拽操作完成。包括拖拽面板，拖拽组，拖拽调整尺寸。没有参数。
		 */		
		public static const BOX_DRAG_COMPLETE:String = "boxDragComplete";
		/**
		 * 将一个TabPanel拖出TabGroup从而形成一个新的TabGroup。
		 * 此事件之后也会同时引发DRAG_GROUP_MOVED事件。<br/>
		 * 相关参数：fromPanel; fromPanelIndex; toGroup;
		 */		
		public static const DRAG_PANEL_OUT:String = "dragPanelOut";
		/**
		 * 拖拽移动一个TabGroup的位置。 <br/>
		 * 相关参数：fromGroup; toGroup; toGroupPosititon;
		 */		
		public static const DRAG_GROUP_MOVED:String = "dragGroupMoved";
		/**
		 * 拖拽移动一个TabPanel的位置。  <br/>
		 * 相关参数：fromPanel; fromPanelIndex; fromGroup; toPanel; toPanelIndex; toGroup;
		 *  <br/> toPanel和fromPanel是同一个。
		 */		
		public static const DRAG_PANEL_MOVED:String = "dragPanelMoved";
		/**
		 * 拖拽一个TabGroup到另一个TabGroup，使之与目标Group合并。<br/>
		 * 相关参数：fromGroup; toGroup;
		 */		
		public static const DRAG_GROUP_IN:String = "dragGroupIn";
		
		/**
		 * 添加了一个盒子 
		 */		
		public static const BOX_ADDED:String = "boxAdded";
		
		public function BoxContainerEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * 起始面板 
		 */
		public var fromPanel:ITabPanel = null;
		/**
		 * 起始面板索引
		 */
		public var fromPanelIndex:int = -1
		/**
		 * 目标面板 
		 */
		public var toPanel:ITabPanel = null;
		/**
		 * 目标面板索引
		 */
		public var toPanelIndex:int = -1;
		
		/**
		 * 起始组 
		 */		
		public var fromGroup:IBoxElement = null;
		/**
		 * 目标组 
		 */		
		public var toGroup:IBoxElement = null;
		/**
		 * 相对于目标组的位置 
		 */		
		public var toGroupPosititon:String = "";
	}
}