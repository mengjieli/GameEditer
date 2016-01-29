package egret.ui.components
{
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import egret.components.ComboBox;
	import egret.components.TextInput;
	import egret.components.UIAsset;
	import egret.core.UIComponent;
	import egret.events.DragEvent;
	import egret.managers.DragManager;
	import egret.ui.core.DragFormat;
	import egret.utils.callLater;
	
	/**
	 * 单行文本输入控件
	 * @author dom
	 */
	public class TextInput extends egret.components.TextInput
	{
		public function TextInput()
		{
			super();
			addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			
			
		}
		
		private var _canDrop:Boolean = false;
		/**
		 * 拖入完成的回调， onDropComplete(target:TextInput,data:Object):void
		 */		
		public var onDropComplete:Function;
		/**
		 * 拖入的时候， 用来判定是否可以拖入的，onDropEnter(target:TextInput,data:Object):Boolean
		 */		
		public var onDropEnter:Function;
		public var bgUnselect:UIAsset;
		public var bgSelect:UIAsset;
		
		/**
		 * 是否可以拖入文本 
		 * @return 
		 * 
		 */		
		public function get canDrop():Boolean
		{
			return _canDrop;
		}

		public function set canDrop(value:Boolean):void
		{
			_canDrop = value;
			if(_canDrop)
			{
				addEventListener(DragEvent.DRAG_ENTER,onDragEnter);
				addEventListener(DragEvent.DRAG_DROP,onDragDrop);
			}else
			{
				removeEventListener(DragEvent.DRAG_ENTER,onDragEnter);
				removeEventListener(DragEvent.DRAG_DROP,onDragDrop);
			}
		}
		
		private function onDragEnter(event:DragEvent):void
		{
			if(event.dragSource.hasFormat(DragFormat.DRAG_STRING))
			{
				if(onDropEnter != null)
				{
					var data:Object = event.dragSource.dataForFormat(DragFormat.DRAG_STRING);
					if(onDropEnter(this,data))
					{
						DragManager.acceptDragDrop(this);
						setFocus();
					}
				}else
				{
					DragManager.acceptDragDrop(this);
					setFocus();
				}
			}
		}
		
		
		private function onDragDrop(event:DragEvent):void
		{
			var data:Object = event.dragSource.dataForFormat(DragFormat.DRAG_STRING);
			if(onDropComplete!=null)
			{
				onDropComplete(this,data);
			}else
			{
				this.text = String(data);
				stage.focus = stage;
			}
		}

		/**
		 * 焦点移入
		 */		
		protected function focusInHandler(event:FocusEvent):void
		{
			if (event.target == this)
			{
				setFocus();
			}
			addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			if(bgUnselect)
				bgUnselect.visible = false;
			if(bgSelect)
				bgSelect.visible = true;
			
			callLater(textDisplay.selectAll);
			invalidateSkinState();
		}
		
		private function keyDownHandler(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.ENTER && stage)
			{
				var currentParent:DisplayObject = this;
				while(currentParent)
				{
					currentParent = currentParent.parent;
					if(currentParent && currentParent is UIComponent && UIComponent(currentParent).focusEnabled == true && !(currentParent is egret.components.ComboBox))
					{
						UIComponent(currentParent).setFocus();
						break;
					}
				}
			}
		}
		
		
		
		/**
		 * 焦点移出
		 */		
		protected function focusOutHandler(event:FocusEvent):void
		{
			removeEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			if(bgUnselect)
				bgUnselect.visible = true;
			if(bgSelect)
				bgSelect.visible = false;
			invalidateSkinState();
		}
	}
}