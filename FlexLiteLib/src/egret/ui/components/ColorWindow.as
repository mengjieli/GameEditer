package egret.ui.components
{
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowType;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	
	import egret.components.Button;
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.UIAsset;
	import egret.core.UIComponent;
	import egret.events.UIEvent;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;
	import egret.layouts.VerticalLayout;
	import egret.managers.CursorManager;
	import egret.managers.Translator;
	import egret.ui.core.Cursors;
	import egret.ui.skins.ButtonSkin;
	import egret.ui.skins.HueSliderSkin;
	import egret.ui.skins.macWindowSkin.MacColorWindowSkin;
	import egret.ui.skins.winWindowSkin.WinColorWindowSkin;
	import egret.utils.SharedObjectTool;
	import egret.utils.SystemInfo;

	/**
	 * 当通过用户交互发生更改后分派。使用代码更改文本时不会引发此事件。 
	 */	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * 颜色选择器
	 * @author 雷羽佳
	 * 
	 */	
	public class ColorWindow extends Window
	{
		public function ColorWindow()
		{
			super();
			
			if(SystemInfo.isMacOS)
			{
				this.skinName = MacColorWindowSkin;
			}else
			{
				this.skinName = WinColorWindowSkin;
			}
			
			
			type = NativeWindowType.UTILITY;
			title = Translator.getText("ColorWindow.Title");
			width = 407;
			height = 388;
			minimizable = false;
			resizable = false;
			maximizable = false;
			appID = NativeApplication.nativeApplication.applicationID;
			this.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN,stageKeyDownHandler);
		}
		
		protected function stageKeyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode==Keyboard.ENTER)
			{
				onConfirmClick();
			}
		}
		
		private var _liveChange:Boolean = false;
		/**
		 * 如果为 true，则将在用户交互，而不是在点击确定时，提交颜色值。
		 */
		public function get liveChange():Boolean
		{
			return _liveChange;
		}
		
		public function set liveChange(value:Boolean):void
		{
			_liveChange = value;
		}

		private var _currentColor:uint = 0x009Aff;
		/**
		 * 当前选中的颜色
		 */
		public function get currentColor():uint
		{
			return _currentColor;
		}
		
		public function set currentColor(value:uint):void
		{
			if(_currentColor==value)
				return;
			_currentColor = value;
			if(currentColorArea)
				drawCurrentColor(_currentColor);
			if(rgbTextInput)
				setRGBValue(_currentColor);
			if(saturationCircle)
				setSaturationCirclePos(_currentColor);
			if(hueSlider)
				setHueSlider(_currentColor);
		}
		
		private var _lastColor:uint = 0x009aff;
		/**
		 * 上一次选中的颜色
		 */
		public function get lastColor():uint
		{
			return _lastColor;
		}
		
		public function set lastColor(value:uint):void
		{
			if(_lastColor==value)
				return;
			_lastColor = value;
			if(lastColorArea)
				drawLastColor(_lastColor);
		}
		
		private var _defaultColor:uint = 0x009aff;
		/**
		 * 默认的颜色
		 */
		public function get defaultColor():uint
		{
			return _defaultColor;
		}
		public function set defaultColor(value:uint):void
		{
			_defaultColor = value;
		}
		
		
		public var ICON_CIRCLE_WHITE:Class;
		public var ICON_CIRCLE_BLACK:Class;
		
		
		private var saturationCircle:UIAsset;
		
		private var saturationAreaData:BitmapData;
		/**
		 * 色相区域。
		 */		
		private var hueLine:UIAsset;
		
		private var hueSlider:HueSlider;
		
		private var hueLineData:Array = [];
		
		private var saturationUI:UIComponent;
		/**
		 * 饱和度区域。
		 */
		private var saturationGroup:Group;
		
		private var currentColorArea:UIComponent;
		private var lastColorArea:UIComponent;
		
		private var rTextInput:TextInput;
		private var gTextInput:TextInput;
		private var bTextInput:TextInput;
		private var rgbTextInput:TextInput;
		
		private var focusUi:FocusUIComponent;
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance == ICON_CIRCLE_WHITE)
			{
				saturationCircle.source = ICON_CIRCLE_WHITE;
			}else if(instance == ICON_CIRCLE_BLACK)
			{
				if(saturationCircle.y<121)
					saturationCircle.source = ICON_CIRCLE_BLACK;
				else
					saturationCircle.source = ICON_CIRCLE_WHITE;
			}
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			var label:Label = new Label();
			label.text = Translator.getText("ColorWindow.SelectColor");
			label.x = 7;
			label.y = 7;
			label.textColor = 0xe1e1e1;
			addElement(label);
			
			
			hueLine = new UIAsset();
			hueLine.x = 279;
			hueLine.y = 27;
			hueLine.source = drawHueLine();
			addElement(hueLine);

			label = new Label();
			label.text = Translator.getText("ColorWindow.NewColor");
			label.right = 26;
			label.y = 7;
			label.textColor = 0xe1e1e1;
			addElement(label);
			
			label = new Label();
			label.text = Translator.getText("ColorWindow.CurrentColor");
			label.right = 26;
			label.y = 90;
			label.textColor = 0xe1e1e1;
			addElement(label);
			
			focusUi = new FocusUIComponent();
			focusUi.percentHeight = focusUi.percentWidth = 100;
			addElement(focusUi);
			
			saturationGroup = new Group();
			saturationGroup.mouseChildren = false;
			saturationGroup.clipAndEnableScrolling = true;
			saturationGroup.x = 7;
			saturationGroup.y = 27;
			saturationUI = new UIComponent();
			saturationUI.width = saturationUI.height = 256;
			saturationGroup.width = saturationGroup.height = 256;
			saturationGroup.addElement(saturationUI);
			var whiteMask:UIComponent = new UIComponent();
			whiteMask.width = whiteMask.height = 256;
			drawMask(whiteMask,0xFFFFFF);
			saturationGroup.addElement(whiteMask);
			var blackMask:UIComponent = new UIComponent();
			blackMask.width = blackMask.height = 256;
			drawMask(blackMask,0x000000,-90);
			saturationGroup.addElement(blackMask);
			addElement(saturationGroup);
			saturationGroup.validateNow();
			
			hueSlider = new HueSlider();
			hueSlider.skinName = HueSliderSkin;
			hueSlider.x = 270;
			hueSlider.y = 27;
			hueSlider.maximum = 256*6-1;
			hueSlider.addEventListener(Event.CHANGE,onHueSliderChange);
			hueSlider.minimum = 0;
			addElement(hueSlider);
			
			var hGroup:Group = new Group();
			var h:HorizontalLayout = new HorizontalLayout();
			h.gap = 16;
			hGroup.layout = h;
			hGroup.right = 16;
			hGroup.bottom = 16;
			addElement(hGroup);
			
			var defaultButton:Button = new Button();
			defaultButton.skinName = ButtonSkin;
			defaultButton.label = Translator.getText("ColorWindow.UseDefault");
			defaultButton.addEventListener(MouseEvent.CLICK,onDefaultClick);
			hGroup.addElement(defaultButton);
			var confirmButton:Button = new Button();
			confirmButton.skinName = ButtonSkin;
			confirmButton.width = 60;
			confirmButton.label = Translator.getText("Alert.Confirm");
			confirmButton.addEventListener(MouseEvent.CLICK,onConfirmClick);
			hGroup.addElement(confirmButton);
			var cancelButton:Button = new Button();
			cancelButton.skinName = ButtonSkin;
			cancelButton.width = 60;
			cancelButton.label = Translator.getText("Alert.Cancel");
			cancelButton.addEventListener(MouseEvent.CLICK,onCloseButtonClick);
			hGroup.addElement(cancelButton);
			
			var vGroup:Group = new Group();
			var v:VerticalLayout = new VerticalLayout();
			v.gap = 5;
			vGroup.right = 7;
			vGroup.layout = v;
			vGroup.y = 132;
			addElement(vGroup);
			
			hGroup = new Group();
			h = new HorizontalLayout();
			h.gap = 5;
			h.verticalAlign = VerticalAlign.MIDDLE;
			hGroup.layout = h;
			label = new Label();
			label.textColor = 0xe1e1e1;
			label.text = "R:";
			hGroup.addElement(label);
			rTextInput = new TextInput();
			rTextInput.addEventListener(Event.CHANGE,onTextChange);
			rTextInput.addEventListener(FocusEvent.FOCUS_OUT,onTextInputFocusOut);
			rTextInput.maxChars = 3;
			rTextInput.restrict = "0-9";
			rTextInput.width = 38;
			hGroup.addElement(rTextInput);
			vGroup.addElement(hGroup);
			
			hGroup = new Group();
			h = new HorizontalLayout();
			h.gap = 5;
			h.verticalAlign = VerticalAlign.MIDDLE;
			hGroup.layout = h;
			label = new Label();
			label.textColor = 0xe1e1e1;
			label.text = "G:";
			hGroup.addElement(label);
			gTextInput = new TextInput();
			gTextInput.addEventListener(Event.CHANGE,onTextChange);
			gTextInput.addEventListener(FocusEvent.FOCUS_OUT,onTextInputFocusOut);
			gTextInput.maxChars = 3;
			gTextInput.restrict = "0-9";
			gTextInput.width = 38;
			hGroup.addElement(gTextInput);
			vGroup.addElement(hGroup);
			
			hGroup = new Group();
			h = new HorizontalLayout();
			h.gap = 5;
			h.verticalAlign = VerticalAlign.MIDDLE;
			hGroup.layout = h;
			label = new Label();
			label.textColor = 0xe1e1e1;
			label.text = "B:";
			hGroup.addElement(label);
			bTextInput = new TextInput();
			bTextInput.addEventListener(Event.CHANGE,onTextChange);
			bTextInput.addEventListener(FocusEvent.FOCUS_OUT,onTextInputFocusOut);
			bTextInput.maxChars = 3;
			bTextInput.restrict = "0-9";
			bTextInput.width = 38;
			hGroup.addElement(bTextInput);
			vGroup.addElement(hGroup);
			
			hGroup = new Group();
			h = new HorizontalLayout();
			h.gap = 5;
			h.verticalAlign = VerticalAlign.MIDDLE;
			hGroup.layout = h;
			label = new Label();
			label.textColor = 0xe1e1e1;
			label.text = "#";
			hGroup.addElement(label);
			rgbTextInput = new TextInput();
			rgbTextInput.addEventListener(Event.CHANGE,onRGBTextChange);
			rgbTextInput.addEventListener(FocusEvent.FOCUS_OUT,onRGBTextInputFocusOut);
			rgbTextInput.maxChars = 6;
			rgbTextInput.restrict = "0-9a-fA-F";
			rgbTextInput.width  = 50;
			hGroup.addElement(rgbTextInput);
			hGroup.y = 231;
			hGroup.right = 7;
			addElement(hGroup);
			
			vGroup = new Group();
			v = new VerticalLayout();
			v.gap = 0;
			vGroup.layout = v;
			vGroup.right = 7;
			vGroup.y = 27;
			addElement(vGroup);
			
			currentColorArea = new UIComponent();
			currentColorArea.width = 62;
			currentColorArea.height = 28;
			vGroup.addElement(currentColorArea);
			
			lastColorArea = new UIComponent();
			lastColorArea.width = 62;
			lastColorArea.height = 28;
			lastColorArea.addEventListener(MouseEvent.CLICK,onLastColorClick);
			vGroup.addElement(lastColorArea);
			
			saturationGroup.addEventListener(MouseEvent.MOUSE_DOWN,onSaturationMouseDown);
			saturationGroup.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			saturationGroup.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			
			saturationCircle = new UIAsset();
			if(ICON_CIRCLE_WHITE != null)
			saturationCircle.source = ICON_CIRCLE_WHITE;
			saturationGroup.addElement(saturationCircle);
			
			drawCurrentColor(_currentColor);
			setRGBValue(_currentColor);
			drawLastColor(_lastColor);
			setHueSlider(_currentColor);
			setSaturationCirclePos(_currentColor);
		}
		
		protected function onRGBTextInputFocusOut(event:FocusEvent):void
		{
			var textInput:TextInput = event.currentTarget as TextInput;
			var rgb:String = textInput.text.toUpperCase();
			while(rgb.length<6)
			{
				rgb = "0"+rgb;
			}
			textInput.text = rgb;
		}
		
		protected function onTextInputFocusOut(event:FocusEvent):void
		{
			var textInput:TextInput = event.currentTarget as TextInput;
			var value:uint = uint(textInput.text);
			if(value>255)
				value = 255;
			textInput.text = value.toString();
		}
		
		private var rgbTextInputing:Boolean = false;
		
		protected function onRGBTextChange(event:Event):void
		{
			rgbTextInputing = true;
			var color:uint = uint("0x"+rgbTextInput.text);
			currentColor = color;
			rgbTextInputing = false;
			doLivingChange();
		}
		
		private var textInputing:Boolean = false;
		
		protected function onTextChange(event:Event):void
		{
			textInputing = true;
			var r:uint = uint(rTextInput.text);
			var g:uint = uint(gTextInput.text);
			var b:uint = uint(bTextInput.text);
			currentColor = getColor(Math.min(255,r),Math.min(255,g),Math.min(255,b));
			textInputing = false;
			doLivingChange();
		}
		/**
		 * 鼠标在上次使用的颜色上点击
		 */		
		protected function onLastColorClick(event:MouseEvent):void
		{
			focusUi.setFocus();
			currentColor = _lastColor;
			doLivingChange();
		}
		private var hoverd:Boolean = false;
		/**
		 * 鼠标移出饱和度区域
		 */		
		private function onRollOut(event:MouseEvent):void
		{
			hoverd = false;
			if(event.buttonDown)
				return;
			CursorManager.removeCursor(Cursors.DESKTOP_CIRCLE);
		}
		/**
		 * 鼠标经过饱和度区域
		 */		
		private function onRollOver(event:MouseEvent):void
		{
			hoverd = true;
			if(event.buttonDown)
				return;
			CursorManager.setCursor(Cursors.DESKTOP_CIRCLE,1);
		}
		
		private var currentHueIndex:int;
		
		private function setHueSlider(color:uint):void
		{
			currentHueIndex = getHue(color);
			hueSlider.value = currentHueIndex;
			var currentHue:uint = hueLineData[currentHueIndex];
			drawSaturation(currentHue);
		}
		
		private function setSaturationCirclePos(color:uint):void
		{
			saturationCircle.x = getSaturation(_currentColor)-7;
			saturationCircle.y = 255-getLightness(_currentColor)-7;
			if(saturationCircle.y<121 && ICON_CIRCLE_BLACK != null)
				saturationCircle.source = ICON_CIRCLE_BLACK;
			else if(ICON_CIRCLE_WHITE != null)
				saturationCircle.source = ICON_CIRCLE_WHITE;
		}
		
		private function onSaturationMouseDown(event:MouseEvent):void
		{
			focusUi.setFocus();
			onMouseMove(event);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			this.stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseUp(event:Event):void
		{
			if(!hoverd)
			{
				CursorManager.removeCursor(Cursors.DESKTOP_CIRCLE);
			}
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			var x:int = Math.max(0,Math.min(255,saturationGroup.mouseX));
			var y:int = Math.max(0,Math.min(255,saturationGroup.mouseY));
			saturationCircle.x = x-7;
			saturationCircle.y = y-7;
			if(saturationCircle.y<121 && ICON_CIRCLE_BLACK != null)
				saturationCircle.source = ICON_CIRCLE_BLACK;
			else if(ICON_CIRCLE_WHITE != null)
				saturationCircle.source = ICON_CIRCLE_WHITE;
			
			var h:int = currentHueIndex*360/(256*6);
			_currentColor = Hsv2Rgb(h,x/255,(255-y)/255);
			if(currentColorArea)
				drawCurrentColor(_currentColor);
			if(rgbTextInput)
				setRGBValue(_currentColor);
			event.updateAfterEvent();
			doLivingChange();
		}
		/**
		 * 色相改变
		 */		
		private function onHueSliderChange(event:Event):void
		{
			currentHueIndex = hueSlider.value;
			var currentHue:uint = hueLineData[currentHueIndex];
			drawSaturation(currentHue);
			var x:int = saturationCircle.x+7;
			var y:int = saturationCircle.y+7;
			var h:int = currentHueIndex*360/(256*6);
			_currentColor = Hsv2Rgb(h,x/255,(255-y)/255);
			if(currentColorArea)
				drawCurrentColor(_currentColor);
			if(rgbTextInput)
				setRGBValue(_currentColor);
			doLivingChange();
		}
		
		override protected function onCloseButtonClick(event:MouseEvent=null):void
		{
			currentColor = _lastColor;
			this.dispatchEvent(new Event(Event.CANCEL));
			super.onCloseButtonClick();
		}
		
		private function onDefaultClick(event:MouseEvent):void
		{
			currentColor = _defaultColor;
			this.dispatchEvent(new Event(Event.CHANGE));
			this.dispatchEvent(new Event(Event.CLEAR));
			this.close();
		}
		
		private function onConfirmClick(event:MouseEvent=null):void
		{
			this.dispatchEvent(new UIEvent(UIEvent.CONFIRM));
			this.close();
		}
		
		/**
		 * 进行实时改变，如果livingChange为true则派发事件
		 */
		private function doLivingChange():void
		{
			if(liveChange)
				this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 应用程序ID
		 */		
		private var appID:String = "Wing";
		
		override public function close():void
		{
			var window:NativeWindow = nativeWindow;
			SharedObjectTool.write(appID,"colorWindowX",window.x);
			SharedObjectTool.write(appID,"colorWindowY",window.y);
			super.close();
		}
		
		override public function open(openWindowActive:Boolean = true):void
		{
			super.open(openWindowActive);
			var window:NativeWindow = nativeWindow;
			var windowX:Number = SharedObjectTool.read(appID,"colorWindowX");
			var windowY:Number = SharedObjectTool.read(appID,"colorWindowY");
			if(isNaN(windowX)||isNaN(windowY))
			{
				window.x = Math.max(0,(Capabilities.screenResolutionX-this.width)*0.5);
				window.y = Math.max(0,(Capabilities.screenResolutionY-this.height)*0.5-15);
			}
			else
			{
				window.x = windowX;
				window.y = windowY;
			}
		}
		/**
		 * 设置RGB分量
		 */
		private function setRGBValue(color:uint):void
		{
			if(!textInputing)
			{
				var r:int = color>>16;
				var g:int = color>>8&0xFF;
				var b:int = color&0xFF;
				rTextInput.text = r.toString();
				gTextInput.text = g.toString();
				bTextInput.text = b.toString();
			}
			if(!rgbTextInputing)
			{
				var rgb:String = color.toString(16).toUpperCase();
				while(rgb.length<6)
				{
					rgb = "0"+rgb;
				}
				rgbTextInput.text = rgb;
			}
		}
		/**
		 * 绘制当前的颜色
		 */		
		private function drawCurrentColor(color:uint):void
		{
			var g:Graphics = currentColorArea.graphics;
			g.clear();
			g.beginFill(color);
			g.drawRect(0,0,currentColorArea.width,currentColorArea.height);
			g.endFill();
		}
		
		private function drawLastColor(color:uint):void
		{
			var g:Graphics = lastColorArea.graphics;
			g.clear();
			g.beginFill(color);
			g.drawRect(0,0,lastColorArea.width,lastColorArea.height);
			g.endFill();
		}
		/**
		 * 绘制饱和度遮罩层
		 */		
		private function drawMask(mask:UIComponent,color:uint,rotation:Number=0):void
		{
			var g:Graphics = mask.graphics;
			g.clear();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(mask.width,mask.height,Math.PI*rotation/180);
			g.beginGradientFill(GradientType.LINEAR,[color,color],[1,0],[0,255],matrix)
			g.drawRect(0,0,mask.width,mask.height);
			g.endFill();
		}
		
		private function drawHueLine():BitmapData
		{
			var ui:UIComponent = new UIComponent();
			var graphics:Graphics = ui.graphics;
			graphics.clear();
			var r:int;
			var g:int;
			var b:int;
			var color:uint;
			var line:int = 0;
			var w:int = 19;
			r = 255;
			g = 0;
			for(b=0;b<256;b++)
			{
				color = getColor(r,g,b); 
				hueLineData[256*6-line-1] = color;
				if(line%6==0)
				{
					graphics.beginFill(color);
					graphics.drawRect(0,line/6,w,1);
				}
				line++;
			}
			
			g = 0;
			b = 255;
			for(r=255;r>=0;r--)
			{
				color = getColor(r,g,b); 
				hueLineData[256*6-line-1] = color;
				if(line%6==0)
				{
					graphics.beginFill(color);
					graphics.drawRect(0,line/6,w,1);
				}
				line++;
			}
			
			r = 0;
			b = 255;
			for(g=0;g<256;g++)
			{
				color = getColor(r,g,b); 
				hueLineData[256*6-line-1] = color;
				if(line%6==0)
				{
					graphics.beginFill(color);
					graphics.drawRect(0,line/6,w,1);
				}
				line++;
			}
			
			r = 0;
			g = 255;
			for(b=255;b>=0;b--)
			{
				color = getColor(r,g,b); 
				hueLineData[256*6-line-1] = color;
				if(line%6==0)
				{
					graphics.beginFill(color);
					graphics.drawRect(0,line/6,w,1);
				}
				line++;
			}
			
			g = 255;
			b = 0;
			for(r=0;r<256;r++)
			{
				color = getColor(r,g,b); 
				hueLineData[256*6-line-1] = color;
				if(line%6==0)
				{
					graphics.beginFill(color);
					graphics.drawRect(0,line/6,w,1);
				}
				line++;
			}
			
			r = 255;
			b = 0;
			for(g=255;g>=0;g--)
			{
				color = getColor(r,g,b); 
				hueLineData[256*6-line-1] = color;
				if(line%6==0)
				{
					graphics.beginFill(color);
					graphics.drawRect(0,line/6,w,1);
				}
				line++;
			}
			graphics.endFill();
			
			var bd:BitmapData = new BitmapData(w,256,true,0);
			bd.draw(ui);
			return bd;
		}
		
		/**
		 * 根据rgb分量获取颜色值
		 */		
		private function getColor(r:uint,g:uint,b:uint):uint
		{
			return (r<<16)+(g<<8)+b;
		}
		
		/**
		 * 根据颜色值获取色相环度数,0~255*6。
		 */		
		private function getHue(color:uint):uint
		{
			var r:int = color>>16;
			var g:int = color>>8&0xFF;
			var b:int = color&0xFF;
			var max:int = Math.max(r,g,b);
			var min:int = Math.min(r,g,b);
			if(max==min)
				return 0;
			if(max==r&&g>=b)
				return 256*(g-b)/(max-min);
			if(max==r&&g<b)
				return 256*(g-b)/(max-min)+(256*6);
			if(max==g)
				return 256*(b-r)/(max-min)+512;
			return 256*(r-g)/(max-min)+(256*4);
		}
		/**
		 * 获取饱和度的值，0~255。
		 */		
		private function getSaturation(color:uint):uint
		{
			var r:int = color>>16;
			var g:int = color>>8&0xFF;
			var b:int = color&0xFF;
			var max:uint = Math.max(r,g,b);
			var min:uint = Math.min(r,g,b);
			if(max==0)
				return 0;
			return (1-min/max)*255;
		}
		/**
		 * 获取亮度的值0~255。
		 */		
		private function getLightness(color:uint):uint
		{
			var r:int = color>>16;
			var g:int = color>>8&0xFF;
			var b:int = color&0xFF;
			return Math.max(r,g,b);
		}
		/**
		 * HSV转换为RGB
		 */		
		private function Hsv2Rgb(h:uint,s:Number,v:Number):uint
		{
			if(s==0)
				return getColor(v*255,v*255,v*255);
			var remain:int = int(h/60)%6;
			var f:Number = (h/60)-remain;
			var p:int = v * (1-s)*255;
			var q:int = v * (1-f*s)*255;
			var t:int = v*(1-(1-f)*s)*255;
			v = int(v*255);
			var color:uint;
			switch(remain)
			{
				case 0:
					color = getColor(v,t,p);
					break;
				case 1:
					color = getColor(q,v,p);
					break;
				case 2:
					color = getColor(p,v,t);
					break;
				case 3:
					color = getColor(p,q,v);
					break;
				case 4:
					color = getColor(t,p,v);
					break;
				case 5:
					color = getColor(v,p,q);
					break;
			}
			return color;
		}
		
		/**
		 * 绘制饱和度区域
		 */		
		private function drawSaturation(color:uint):void
		{
			var g:Graphics = saturationUI.graphics;
			g.clear();
			g.beginFill(color);
			g.drawRect(0,0,256,256);
			g.endFill();
			
			saturationAreaData = new BitmapData(256,256,true,0);
			saturationAreaData.draw(saturationGroup);
		}
		
	}
}