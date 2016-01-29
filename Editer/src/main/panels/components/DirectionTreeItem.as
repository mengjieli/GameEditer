package main.panels.components
{
	import flash.events.MouseEvent;
	
	import egret.components.Group;
	import egret.components.ITreeItemRenderer;
	import egret.components.Label;
	import egret.components.supportClasses.ItemRenderer;
	import egret.events.TreeEvent;

	public class DirectionTreeItem extends ItemRenderer implements ITreeItemRenderer
	{
		public function DirectionTreeItem()
		{
			this.height = 26;
			this.skinName = DirectionTreeItemSkin;
		}
		
		private var _name:String;
		override public function set label(value:String):void
		{
			nameDisplay.text = value;
		}
		
		/**
		 * [SkinPart]容器
		 */
		public var group:Group;
		/**
		 * [SkinPart]按钮上的文本标签
		 */
		public var floader:RectImage;
		/**
		 * [SkinPart]按钮上的文本标签
		 */
		public var icon:RectImage;
		/**
		 * [SkinPart]名字
		 */
		public var nameDisplay:Label;
		
		
		private var _iconSkinName:Object;
		/**
		 * 图标的皮肤名
		 */
		public function get iconSkinName():Object
		{
			return _iconSkinName;
		}
		public function set iconSkinName(value:Object):void
		{
			_iconSkinName = value;
			floader.source = value;
		}
		
		/**
		 * 缩进深度。0表示顶级节点，1表示第一层子节点，以此类推。
		 */
		public function get depth():int {
			return 0
		}
		public function set depth(value:int):void {
			group.left = value*20;
		}
		
		/**
		 * 是否含有子节点。
		 */
		public function get hasChildren():Boolean {
			return (this.data as DirectionTreeCollectionItem).children.length?true:false;
		}
		
		public function set hasChildren(value:Boolean):void {
			this.floader.visible = value;
		}
		
		/**
		 * 节点是否处于开启状态。
		 */
		public function get opened():Boolean {
			return this.data.isOpen;
		}
		public function set opened(value:Boolean):void {
			floader.source = this._iconSkinName;
		}
		
		private static var lastTime:Number = 0;
		private function onClickIcon(e:MouseEvent):void {
			var now:Number = (new Date()).time;
			if(now - lastTime < 500) return;
			lastTime = now;
			this.dispatchEvent(new TreeEvent(TreeEvent.ITEM_OPENING,false,true,-1,this.data,this));
		}
		
		/**
		 * 子类复写此方法以在data数据源发生改变时跟新显示列表。
		 * 与直接复写data的setter方法不同，它会确保在皮肤已经附加完成后再被调用。
		 */		
		override protected function dataChanged():void
		{
		}
		
		override public function set data(value:Object):void {
			super.data = value;
			if(this.data) {
				var d:DirectionTreeCollectionItem = this.data as DirectionTreeCollectionItem;
				icon.source = d.fileIcon;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance) {
				case floader:
					floader.source = this._iconSkinName;
					floader.addEventListener(MouseEvent.MOUSE_DOWN,onClickIcon);
					break;
				case nameDisplay:
					nameDisplay.text = _name;
					break;
			}
		}
	}
}