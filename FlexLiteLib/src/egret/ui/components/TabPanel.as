package egret.ui.components
{
	import egret.components.Group;
	import egret.components.Rect;
	import egret.components.SkinnableContainer;
	import egret.events.UIEvent;
	import egret.ui.skins.TabPanelSkin;
	
	public class TabPanel extends SkinnableContainer implements ITabPanel
	{
		public function TabPanel()
		{
			super();
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.focusEnabled = true;
			this.skinName = TabPanelSkin;
		}
		
		/**
		 *[SkinPart] 
		 */		
		public var titleGroup:Group;
		
		public var gapLine:Rect;
		
		private var _show:Boolean = false;
		/**
		 * 当前是否显示
		 */
		public function get show():Boolean
		{
			return _show;
		}
		public function set show(value:Boolean):void
		{
			if(value==_show)
				return;
			_show = value;
			var event:UIEvent = new UIEvent(UIEvent.SHOW_CHANGE);
			dispatchEvent(event);
			showChanged();
		}
		
		/**
		 * 数据改变，子类复写此方法以在data数据源发生改变时跟新相关属性。
		 */
		protected function dataChanged():void
		{
		}
		
		/**
		 * show的状态发生改变,子类复写此方法在面板被隐藏时停用函数监听。
		 */
		protected function showChanged():void
		{
		}
		
		private var _itemIndex:int = -1;
		public function get itemIndex():int
		{
			return _itemIndex;
		}
		
		public function set itemIndex(value:int):void
		{
			_itemIndex = value;
		}
		
		private var _icon:Object;
		/**
		 * 图标
		 */
		public function get icon():Object
		{
			return _icon;
		}

		public function set icon(value:Object):void
		{
			_icon = value;
			_data["icon"] = value;
			updateOwner();
		}
		
		private var _title:String;
		public function get title():String
		{
			if(!_title && _data["label"])
			{
				return _data["label"];
			}
			return _title;
		}
		
		public function set title(value:String):void
		{
			if(_title == value)
				return;
			_title = value;
			_data["label"] = value;
			updateOwner();
		}
		
		protected var _data:Object = {};
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			_data = value;
			dataChanged();
		}
		
		/**
		 * 更新数据与视图
		 */
		public function updateOwner():void
		{
			if(owner && owner is TabGroup)
				TabGroup(owner).dataProvider.itemUpdated(data);
		}
		
	}
}