package main.panels.components
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import egret.components.Button;
	import egret.components.Group;

	/**
	 *横向分割容器
	 * </p>由左右两个显示项组成，以左项宽度为基准，右项填满剩余空间
	 * @author Grayness
	 */
	public class ClipItemPanelH extends Group
	{
		public function ClipItemPanelH()
		{
		}
		private var cliperW:Number=5;//分割条宽度
		private var leftItem:*;
		private var rightItem:ClipItem;
		private var cliper:Button=new Button();
		/**
		 * 添加显示项
		 */		
		public function addClipItem(leftItem:*,rightItem:ClipItem):void
		{
			this.leftItem=leftItem;
			this.addElement(leftItem);
			this.addElement(cliper);
			cliper.addEventListener(MouseEvent.MOUSE_DOWN,cliperMouseEvent);
			this.rightItem=rightItem;
			this.addElement(rightItem);
		}
		/**
		 *重置容器 
		 */		
		public function reSet():void
		{
			this.leftItem=this.rightItem=null;
			this.removeAllElements();
		}
		protected override function measure():void
		{
			measuredMinWidth=measuredMinHeight=0;
		}
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			drawBackGround();
			leftItem.width=width;
			rightItem.width=width;
			cliper.width=width;
			
			cliper.height=cliperW;
			leftItem.y=0;
			cliper.y=leftItem.height;
			rightItem.y=cliper.y+cliper.height;
			rightItem.height=height-leftItem.height-cliper.height;
		}
		private var oldw:Number;
		private var oldx:Number;
		private function cliperMouseEvent(e:MouseEvent):void
		{
			switch(e.type)
			{
				case MouseEvent.MOUSE_DOWN:
					oldw=leftItem.height;
					oldx=cliper.y;
					stage.addEventListener(MouseEvent.MOUSE_MOVE,cliperMouseEvent);
					stage.addEventListener(MouseEvent.MOUSE_UP,cliperMouseEvent);
					break;
				case MouseEvent.MOUSE_MOVE:
					var vx:Number=this.globalToLocal(new Point(0,e.stageY)).y-oldx;
					leftItem.height=oldw+vx;
					if(leftItem.height<10)
						leftItem.height=10;
					if(leftItem.height>height-10)
						leftItem.height=height-10;
					this.invalidateDisplayList();
					break;
				case MouseEvent.MOUSE_UP:
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,cliperMouseEvent);
					stage.removeEventListener(MouseEvent.MOUSE_UP,cliperMouseEvent);
					break;
			}
		}
		private function drawBackGround():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1,0x222222);
			this.graphics.drawRect(0,0,width,height);
		}
	}
}

