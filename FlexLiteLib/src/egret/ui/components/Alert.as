package egret.ui.components
{
	import flash.display.NativeWindow;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import egret.components.Button;
	import egret.core.IDisplayText;
	import egret.core.IWindow;
	import egret.core.ns_egret;
	import egret.events.CloseEvent;
	import egret.managers.Translator;
	import egret.ui.skins.macWindowSkin.MacAlertSkin;
	import egret.ui.skins.winWindowSkin.WinAlertSkin;
	import egret.utils.SystemInfo;

	use namespace ns_egret;
	/**
	 * 弹出对话框 
	 * @author 雷羽佳
	 * 
	 */	
	public class Alert extends Window
	{
		public function Alert()
		{
			type="utility";
			if(SystemInfo.isMacOS)
			{
				this.skinName = MacAlertSkin;
			}
			else
			{
				this.skinName = WinAlertSkin;
			}
		}
		
		
		override protected function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode==13)
			{
				onCloseButtonClick();
			}
			else if(event.keyCode==Keyboard.ESCAPE)
			{
				close();
				if(closeHandler!=null)
				{
					var closeEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
					closeEvent.detail = Alert.CLOSE_BUTTON;
					closeHandler(closeEvent);
				}
			}
		}
		
		
		/**
		 * 当对话框关闭时，closeEvent.detail的值若等于此属性,表示被点击的按钮为firstButton。
		 */		
		public static const FIRST_BUTTON:int = 1;
		/**
		 * 当对话框关闭时，closeEvent.detail的值若等于此属性,表示被点击的按钮为secondButton。
		 */		
		public static const SECOND_BUTTON:int = 2;
		/**
		 * 当对话框关闭时，closeEvent.detail的值若等于此属性,表示被点击的按钮为thirdButton。
		 */		
		public static const THIRD_BUTTON:int = 3;
		/**
		 * 当对话框关闭时，closeEvent.detail的值若等于此属性,表示被点击的按钮为closeButton。
		 */		
		public static const CLOSE_BUTTON:int = 4;
		
		/**
		 * 弹出Alert控件的静态方法。在Alert控件中选择一个按钮，将关闭该控件。
		 * @param text 要显示的文本内容字符串。
		 * @param title 对话框标题
		 * @param parent 父级窗口
		 * @param closeHandler 按下Alert控件上的任意按钮时的回调函数。示例:closeHandler(event:CloseEvent);
		 * event的detail属性包含 Alert.FIRST_BUTTON、Alert.SECOND_BUTTON和Alert.CLOSE_BUTTON。
		 * @param firstButtonLabel 第一个按钮上显示的文本。
		 * @param secondButtonLabel 第二个按钮上显示的文本，若为null，则不显示第二个按钮。
		 * @param thirdButtonLabel 第三个按钮上显示的文本，若为null，则不显示第三个按钮。
		 * @param modal 是否启用模态。即禁用弹出层以下的鼠标事件。默认true。
		 * @return 弹出的对话框实例的引用
		 */		
		public static function show(text:String="",title:String="",parent:IWindow=null,closeHandler:Function=null,
									firstButtonLabel:String="Alert.Confirm",secondButtonLabel:String="",
									thirdButtonLabel:String="",modal:Boolean=true,width:Number=NaN):Alert
		{
			var alert:Alert = new Alert();
			alert.contentText = text;
			alert.title = title;
			firstButtonLabel = Translator.getText(firstButtonLabel);
			alert._firstButtonLabel = firstButtonLabel;
			alert._secondButtonLabel = secondButtonLabel;
			alert._thirdButtonLabel = thirdButtonLabel;
			
			alert.closeHandler = closeHandler;
			alert.modal = modal;
			alert.parentWindow = parent;
			if(!isNaN(width))
				alert.width = width;
			alert.open();
			return alert;
		}
		
		override public function open(openWindowActive:Boolean = true):void
		{
			super.open(openWindowActive);
			var win:NativeWindow = parentWindow ? parentWindow.nativeWindow : Application.topApp.nativeWindow;
			var bounds:Rectangle = win.bounds;
			nativeWindow.x = Math.round(bounds.x + bounds.width*0.5-nativeWindow.width*0.5);
			nativeWindow.y = Math.round(bounds.y+bounds.height*0.5-nativeWindow.height*0.5);
			if(nativeWindow.x<0)
				nativeWindow.x = 0;
			if(nativeWindow.y<0)
				nativeWindow.y = 0;
		}
		
		private var _parentWindow:IWindow;
		/**
		 * 父窗口，一旦设置无法更改
		 */
		public function get parentWindow():IWindow
		{
			return _parentWindow;
		}

		public function set parentWindow(value:IWindow):void
		{
			_parentWindow = value;
		}

		
		private var _firstButtonLabel:String = "";
		/**
		 * 第一个按钮上显示的文本
		 */
		public function get firstButtonLabel():String
		{
			return _firstButtonLabel;
		}
		public function set firstButtonLabel(value:String):void
		{
			if(_firstButtonLabel==value)
				return;
			_firstButtonLabel = value;
			if(firstButton)
				firstButton.label = value;
		}
		
		private var _secondButtonLabel:String = "";
		/**
		 * 第二个按钮上显示的文本
		 */
		public function get secondButtonLabel():String
		{
			return _secondButtonLabel;
		}
		public function set secondButtonLabel(value:String):void
		{
			if(_secondButtonLabel==value)
				return;
			_secondButtonLabel = value;
			if(secondButton)
			{
				if(value==null||value=="")
					secondButton.includeInLayout = secondButton.visible
						= (_secondButtonLabel!=""&&_secondButtonLabel!=null);
			}
		}
		private var _thirdButtonLabel:String = "";
		/**
		 * 第三个按钮上显示的文本
		 */
		public function get thirdButtonLabel():String
		{
			return _thirdButtonLabel;
		}
		public function set thirdButtonLabel(value:String):void
		{
			if(_thirdButtonLabel==value)
				return;
			_thirdButtonLabel = value;
			if(thirdButton)
			{
				if(value==null||value=="")
					thirdButton.includeInLayout = thirdButton.visible
						= (_thirdButtonLabel!=""&&_thirdButtonLabel!=null);
			}
		}
		
		private var _contentText:String = "";
		/**
		 * 文本内容
		 */
		public function get contentText():String
		{
			return _contentText;
		}
		public function set contentText(value:String):void
		{
			if(_contentText==value)
				return;
			_contentText = value;
			if(contentDisplay)
				contentDisplay.text = value;
		}
		
		private var _closeHandler:Function;

		/**
		 * 对话框关闭回调函数
		 */
		public function get closeHandler():Function
		{
			return _closeHandler;
		}

		/**
		 * @private
		 */
		public function set closeHandler(value:Function):void
		{
			_closeHandler = value;
		}

		
		/**
		 * @inheritDoc
		 */
		override protected function onCloseButtonClick(event:MouseEvent=null):void
		{
//			super.onCloseButtonClick(event);
			var closeEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE,false,true);
			if(closeHandler!=null)
			{
				
				if(event)
				{
					switch(event.currentTarget)
					{
						case firstButton:
							closeEvent.detail = Alert.FIRST_BUTTON;
							break;
						case secondButton:
							closeEvent.detail = Alert.SECOND_BUTTON;
							break;
						case thirdButton:
							closeEvent.detail = Alert.THIRD_BUTTON;
							break;
						case closeButton:
							closeEvent.detail = Alert.CLOSE_BUTTON;
					}
				}
				else
				{
					if(firstButton&&firstButton.visible)
						closeEvent.detail = Alert.FIRST_BUTTON;
					else if(secondButton&&secondButton.visible)
						closeEvent.detail = Alert.SECOND_BUTTON;
					else if(thirdButton&&thirdButton.visible)
						closeEvent.detail = Alert.THIRD_BUTTON;
					else
						closeEvent.detail = Alert.CLOSE_BUTTON;
					
				}
				closeHandler(closeEvent);
			}
			if(!closeEvent.isDefaultPrevented())
			{
				close();
			}
		}
		
		/**
		 * [SkinPart]文本内容显示对象
		 */		
		public var contentDisplay:IDisplayText;
		/**
		 * [SkinPart]第一个按钮，通常是"是"。
		 */		
		public var firstButton:Button;
		/**
		 * [SkinPart]第二个按钮，通常是"否"。
		 */		
		public var secondButton:Button;
		/**
		 * [SkinPart]第三个按钮，通常是"取消"。 
		 */		
		public var thirdButton:Button;
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance==contentDisplay)
			{
				contentDisplay.text = _contentText;
			}
			else if(instance==firstButton)
			{
				firstButton.label = _firstButtonLabel;
				firstButton.addEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
			else if(instance==secondButton)
			{
				secondButton.label = _secondButtonLabel;
				secondButton.includeInLayout = secondButton.visible
					= (_secondButtonLabel!=""&&_secondButtonLabel!=null);
				secondButton.addEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
			else if(instance==thirdButton)
			{
				thirdButton.label = _thirdButtonLabel;
				thirdButton.includeInLayout = thirdButton.visible
					= (_thirdButtonLabel!=""&&_thirdButtonLabel!=null);
				thirdButton.addEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
		}
		
		/**
		 * @inheritDoc
		 */		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName,instance);
			if(instance==firstButton)
			{
				firstButton.removeEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
			else if(instance==secondButton)
			{
				secondButton.removeEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
			else if(instance==thirdButton)
			{
				thirdButton.removeEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
		}
	}
}