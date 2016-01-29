package egret.ui.components
{
	import flash.events.MouseEvent;
	
	import egret.collections.ICollection;
	import egret.components.Button;
	import egret.components.Label;
	import egret.components.Rect;
	import egret.components.Tree;
	import egret.components.ViewStack;
	import egret.components.supportClasses.ListBase;
	import egret.events.UIEvent;
	import egret.layouts.VerticalAlign;
	import egret.managers.Translator;
	import egret.ui.events.ViewStackPageEvent;

	/**
	 * 确认
	 */	
	[Event(name="confirm", type="egret.events.UIEvent")]
	
	/**
	 * 层级堆叠窗口
	 */
	public class ViewStackWindow extends Window
	{
		public function ViewStackWindow()
		{
			super();
			this.width = 600;
			this.height = 480;
			this.minWidth = 600;
			this.minHeight = 480;
		}
		
		protected var _model:Object = {};
		/**
		 * 关联的数据
		 */
		public function get model():Object
		{
			return _model;
		}
		
		public function set model(value:Object):void
		{
			if(value)
				_model = value;
			else
				_model = {};
		}
		
		private var _dataProvider:ICollection;
		
		public function get dataProvider():ICollection
		{
			return _dataProvider;
		}

		public function set dataProvider(value:ICollection):void
		{
			_dataProvider = value;
			if(titleList)
			{
				titleList.dataProvider = _dataProvider;
			}
		}
		
		protected function onCancelClickHandler(event:MouseEvent):void
		{
			this.close();
		}
		
		protected function onConfirmClickHandler(event:MouseEvent):void
		{
			var confirmEvent:UIEvent = new UIEvent(UIEvent.CONFIRM , false , true);
			if(dispatchEvent(confirmEvent))
			{
				this.close();
			}
		}
		
		protected function onTitleListChange(event:UIEvent):void
		{
			if(!titleList.selectedItem || !titleList.selectedItem.page)
			{
				if(titleList.selectedItem)
					pageTitleDisplay.text = labelFunc(titleList.selectedItem);
				else
					pageTitleDisplay.text = "";
				if(pageViewStack.selectedChild)
					pageViewStack.selectedChild.visible = false;
				pageViewStack.selectedIndex = -1;
				return;
			}
			var page:IPage = titleList.selectedItem.page as IPage;
			var index:int = pageViewStack.getElementIndex(page);
			if(index<0)
			{
				addPage(page);
			}
			pageViewStack.selectedChild = page;
			pageTitleDisplay.text = labelFunc(titleList.selectedItem);
		}
		
		private function addPage(page:IPage):void
		{
			var createComplete:Function = function(event:UIEvent):void{
				page.removeEventListener(UIEvent.CREATION_COMPLETE , createComplete);
				onPageCreateComplete(page);
			};
			page.percentWidth = page.percentHeight = 100;
			page.addEventListener(UIEvent.CREATION_COMPLETE , createComplete);
			page.addEventListener(ViewStackPageEvent.VALIDATE , onPageValidate);
			pageViewStack.addElement(page);
		}
		
		/**
		 * 页面创建完成，子类覆盖此方法实现创建完成的页面的初始化
		 */
		protected function onPageCreateComplete(page:IPage):void
		{
		
		}
		
		/**
		 * 页面派发验证事件，子类覆盖此方法实现验证的逻辑处理
		 */
		protected function onPageValidate(event:ViewStackPageEvent):void
		{
			
		}
		
		private function labelFunc(item:Object):String
		{
			if(item.page)
				return item.page.pageName;
			else if(item.label)
				return item.label;
			else
				return "";
		}
		
		public var titleList:ListBase;
		public var pageTitleDisplay:Label;
		public var pageViewStack:ViewStack;
		public var confirmButton:Button;
		public var cancelButton:Button;
		
		override protected function createChildren():void
		{
			super.createChildren();
			titleList = new egret.components.Tree();
			titleList.requireSelection = true;
			titleList.labelFunction = labelFunc;
			titleList.width = 150;
			titleList.percentHeight = 100;
			titleList.dataProvider = _dataProvider;
			titleList.addEventListener(UIEvent.VALUE_COMMIT , onTitleListChange);
			this.addElement(titleList);
			
			pageTitleDisplay = new Label();
			pageTitleDisplay.bold = true;
			pageTitleDisplay.size = 14;
			pageTitleDisplay.verticalAlign = VerticalAlign.MIDDLE;
			pageTitleDisplay.left = 160;
			pageTitleDisplay.right = 0;
			pageTitleDisplay.height = 35;
			this.addElement(pageTitleDisplay);
			
			var rect:Rect = new Rect();
			rect.fillColor = 0x1b2025;
			rect.height =1;
			rect.left = 150;
			rect.right = 0;
			rect.top = 35;
			this.addElement(rect);
			
			pageViewStack = new ViewStack();
			pageViewStack.left = 160;
			pageViewStack.right = 0;
			pageViewStack.top = 40;
			pageViewStack.bottom = 50;
			this.addElement(pageViewStack);
			
			rect = new Rect();
			rect.fillColor = 0x1b2025;
			rect.left = 150;
			rect.width = 1;
			rect.top = 0;
			rect.bottom = 50;
			this.addElement(rect);
			
			rect = new Rect();
			rect.fillColor = 0x1b2025;
			rect.percentWidth = 100;
			rect.height = 1;
			rect.bottom = 50;
			this.addElement(rect);
			
			confirmButton  = new Button();
			confirmButton.width = 80;
			confirmButton.height = 25;
			confirmButton.label = Translator.getText("Alert.Confirm");
			confirmButton.bottom = 10;
			confirmButton.right = 100;
			confirmButton.addEventListener(MouseEvent.CLICK , onConfirmClickHandler);
			this.addElement(confirmButton);
			
			cancelButton = new Button();
			cancelButton.width = 80;
			cancelButton.height = 25;
			cancelButton.label = Translator.getText("Alert.Cancel");
			cancelButton.bottom = 10;
			cancelButton.right = 10;
			cancelButton.addEventListener(MouseEvent.CLICK , onCancelClickHandler);
			this.addElement(cancelButton);
		}
	}
}