package egret.debug
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import egret.collections.XMLCollection;
	import egret.components.CheckBox;
	import egret.components.Label;
	import egret.components.RadioButton;
	import egret.components.RadioButtonGroup;
	import egret.components.ToggleButton;
	import egret.components.Tree;
	import egret.components.Window;
	import egret.events.TreeEvent;
	import egret.events.UIEvent;
	import egret.skins.vector.CheckBoxSkin;
	import egret.skins.vector.HScrollBarSkin;
	import egret.skins.vector.ListSkin;
	import egret.skins.vector.RadioButtonSkin;
	import egret.skins.vector.ScrollerSkin;
	import egret.skins.vector.ToggleButtonSkin;
	import egret.skins.vector.TreeItemRendererSkin;
	import egret.skins.vector.VScrollBarSkin;
	import egret.skins.vector.WindowSkin;
	
	
	/**
	 * 运行时显示列表调试工具。
	 * 快捷键：F11开启或关闭调试;F12开启或结束选择;F2复制选中的属性名;F3复制选中属性值;
	 * F6:设置选中节点为浏览树的根
	 * @author dom
	 */
	public class DebugWindow extends Window
	{
		/**
		 * 构造函数
		 */		
		public function DebugWindow()
		{
			super();
			this.skinName = WindowSkin;
			title = "显示列表调试";
			alwaysInFront = true;
			width = 800;
			height = 600;
			modalMask.mouseChildren = false;
			this.addEventListener(Event.CLOSE,onClose);
		}
		
		private function onClose(event:Event):void
		{
			targetStage = null;
		}
		
		override public function open(openWindowActive:Boolean=true):void
		{
			super.open(openWindowActive);
			validateNow();
			var maxX:Number = Capabilities.screenResolutionX;
			var maxY:Number = Capabilities.screenResolutionY;
			nativeWindow.x = maxX - nativeWindow.width - 20;
			nativeWindow.y = maxY - nativeWindow.height - 50;
		}
		
		private var targetLabel:Label = new Label();
		private var rectLabel:Label = new Label();
		public var selectBtn:ToggleButton = new ToggleButton();
		private var selectMode:RadioButtonGroup = new RadioButtonGroup();
		private var infoTree:Tree = new Tree();
		private var foldPropBtn:CheckBox = new CheckBox();
		
		override protected function createChildren():void
		{
			super.createChildren();
			targetLabel.text = "";
			targetLabel.textColor = 0;
			targetLabel.y = 48;
			rectLabel.y = 30;
			rectLabel.textColor = 0;
			addElement(targetLabel);
			addElement(rectLabel);
			selectBtn.label = "重新选取";
			selectBtn.y = 5;
			selectBtn.x = 3;
			selectBtn.selected = true;
			selectBtn.skinName = ToggleButtonSkin;
			selectBtn.addEventListener(Event.CHANGE,onSelectedChange);
			addElement(selectBtn);
			var label:Label = new Label();
			label.text = "选取模式:";
			label.textColor = 0;
			label.y = 8;
			label.x = 75;
			addElement(label);
			var displayRadio:RadioButton = new RadioButton();
			displayRadio.group = selectMode;
			displayRadio.skinName = RadioButtonSkin;
			displayRadio.x = 135;
			displayRadio.y = 5;
			displayRadio.selected = true;
			displayRadio.label = "屏蔽鼠标";
			addElement(displayRadio);
			var mouseRadio:RadioButton = new RadioButton();
			mouseRadio.skinName = RadioButtonSkin;
			mouseRadio.group = selectMode;
			mouseRadio.x = 207;
			mouseRadio.y = 5;
			mouseRadio.label = "响应鼠标";
			addElement(mouseRadio);
			selectMode.addEventListener(Event.CHANGE,onSelectModeChange);
			foldPropBtn.skinName = CheckBoxSkin;
			foldPropBtn.y = 5;
			foldPropBtn.x = 285;
			foldPropBtn.selected = true;
			foldPropBtn.label = "折叠属性";
			foldPropBtn.addEventListener(Event.CHANGE,onFoldChange);
			addElement(foldPropBtn);
			infoTree.skinName = ListSkin;
			infoTree.left = 0;
			infoTree.right = 0;
			infoTree.top = 66;
			infoTree.bottom = 0;
			infoTree.minHeight = 200;
			infoTree.dataProvider = infoDp;
			infoTree.labelFunction = labelFunc;
			infoTree.addEventListener(TreeEvent.ITEM_OPENING,onTreeOpening);
			infoTree.addEventListener(UIEvent.CREATION_COMPLETE,onTreeComp);
			infoTree.doubleClickEnabled = true;
			infoTree.addEventListener(MouseEvent.DOUBLE_CLICK,onTreeDoubleClick);
			addElement(infoTree);
		}
		
		private function onFoldChange(event:Event):void
		{
			if(currentTarget)
			{
				infoDp.source = describe(currentTarget);
				invalidateDisplayList();
			}
		}
		
		/**
		 * 双击一个节点
		 */		
		private function onTreeDoubleClick(event:MouseEvent):void
		{
			var item:XML = infoTree.selectedItem;
			if(!item||item.children().length()==0)
				return;
			var target:DisplayObject = getTargetByItem(item) as DisplayObject;
			if(target)
			{
				currentTarget = target;
				infoDp.source = describe(currentTarget);
				invalidateDisplayList();
			}
		}
		/**
		 * 选择模式发生改变
		 */		
		private function onSelectModeChange(event:Event):void
		{
			if(selectMode.selectedValue=="鼠标事件")
			{
				_targetStage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				_targetStage.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
				_targetStage.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
				modalMask.mouseEnabled = false;
			}
			else
			{
				_targetStage.removeEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
				_targetStage.removeEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
				_targetStage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				modalMask.mouseEnabled = true;
			}
			selectBtn.selected = true;
			onSelectedChange();
		}
		/**
		 * 树列表创建完成
		 */		
		private function onTreeComp(event:UIEvent):void
		{
			infoTree.removeEventListener(UIEvent.CREATION_COMPLETE,onTreeComp);
			infoTree.dataGroup.itemRendererSkinName = TreeItemRendererSkin;
			(infoTree.skin as ListSkin).scroller.skinName = ScrollerSkin;
			(infoTree.skin as ListSkin).scroller.verticalScrollBar.skinName = VScrollBarSkin;
			(infoTree.skin as ListSkin).scroller.horizontalScrollBar.skinName = HScrollBarSkin;
		}
		/**
		 * 即将打开树的一个节点,生成子节点内容。
		 */		
		private function onTreeOpening(event:TreeEvent):void
		{
			if(!event.opening)
				return;
			var item:XML = event.item as XML;
			if(item.children().length()==1&&
				item.children()[0].localName()=="child")
			{
				var target:Object = getTargetByItem(item);
				if(target)
				{
					item.setChildren(describe(target).children());
				}
			}
		}
		/**
		 * 根据xml节点获取对应的对象引用
		 */		
		private function getTargetByItem(item:XML):*
		{
			var keys:Array = [String(item.@key)];
			var parent:XML = item.parent();
			while(parent&&parent.parent())
			{
				if(parent.localName()!="others")
					keys.push(String(parent.@key));
				parent = parent.parent();
			}
			var target:Object = currentTarget;
			try
			{
				while(keys.length>0)
				{
					var key:String = keys.pop();
					if(key.substr(0,8)=="children")
					{
						var index:int = int(key.substring(9,key.length-1));
						target = DisplayObjectContainer(target).getChildAt(index);
					}
					else
					{
						if(key.charAt(0)=="["&&key.charAt(key.length-1)=="]")
						{
							index = int(key.substring(9,key.length-1));
							target = target[index];
						}
						else
						{
							target = target[key];
						}
					}
				}
			}
			catch(e:Error)
			{
				return null;
			}
			return target;
		}
		/**
		 * 树列表项显示文本格式化函数
		 */		
		private function labelFunc(item:Object):String
		{
			if(item.hasOwnProperty("@value"))
				return item.@key+" : "+item.@value;
			return item.@key;
		}

		private function onSelectedChange(event:Event=null):void
		{
			if(selectBtn.selected)
			{
				currentTarget = null;
				mouseEnabled = false;
				infoDp.source = null;
				invalidateDisplayList();
			}
		}
		
		/**
		 * 设置选中节点为浏览树的根
		 */		
		public function setSelectedItemAsRoot():void
		{
			if(!selectBtn.selected)
			{
				changeCurrentTarget();
			}
		}
		/**
		 * 开启或结束选择
		 */		
		public function startOrEndSelection():void
		{
			if(selectBtn.selected)
			{
				selectBtn.selected = false;
				mouseEnabled = true;
				infoDp.source = describe(currentTarget);
			}
			else
			{
				selectBtn.selected = true;
				onSelectedChange();
				mouseMoved = true;
				invalidateProperties();
			}
		}
		/**
		 * 复制选中节点的属性名到剪贴板
		 */		
		public function copyKeyToClipboard():void
		{
			var item:XML = infoTree.selectedItem as XML;
			if(item)
			{
				System.setClipboard(String(item.@key));
			}
		}
		/**
		 * 复制选中节点的属性值到剪贴板
		 */		
		public function copyValueToClipboard():void
		{
			var item:XML = infoTree.selectedItem as XML;
			if(item)
			{
				System.setClipboard(String(item.@value));
			}
		}
		/**
		 * 设置当前选中节点为根节点
		 */		
		private function changeCurrentTarget():void
		{
			var item:XML = infoTree.selectedItem;
			var target:DisplayObject;
			while(item)
			{
				if(item.children().length()>0)
				{
					target = getTargetByItem(item) as DisplayObject;
					if(target)
					{
						currentTarget = target;
						infoDp.source = describe(currentTarget);
						invalidateDisplayList();
						break;
					}
				}
				item = item.parent();
			}
		}
		
		private var _targetStage:Stage;
		/**
		 * 当前要调试的舞台引用
		 */	
		public function get targetStage():Stage
		{
			return _targetStage;
		}
		
		public function set targetStage(value:Stage):void
		{
			if(_targetStage==value)
				return;
			if(_targetStage)
			{
				_targetStage.removeChild(modalMask);
				currentTarget = null;
				infoDp.source = null;
				selectBtn.selected = true;
				mouseEnabled = false;
				_targetStage.removeEventListener(Event.ADDED,onAdded);
				_targetStage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				_targetStage.removeEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
				_targetStage.removeEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
				_targetStage.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			}
			_targetStage = value;
			if(_targetStage)
			{
				var list:Array = _targetStage.getObjectsUnderPoint(new Point(_targetStage.mouseX,_targetStage.mouseY));
				if(list.length>0)
				{
					currentTarget = list[list.length-1];
				}
				invalidateDisplayList();
				_targetStage.addChild(modalMask);
				_targetStage.addEventListener(Event.ADDED,onAdded);
				if(selectMode.selectedValue=="鼠标事件")
				{
					_targetStage.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
					_targetStage.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
				}
				else
				{
					_targetStage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				}
				_targetStage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			}
		}
		
		/**
		 * stage子项发生改变
		 */		
		private function onAdded(event:Event):void
		{
			if(_targetStage.getChildIndex(modalMask)!=_targetStage.numChildren-1)
				_targetStage.addChild(modalMask);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(mouseMoved&&_targetStage)
			{
				mouseMoved = false;
				var target:DisplayObject;
				if(_targetStage.numChildren>1)
				{
					for(var i:int=_targetStage.numChildren-2;i>=0;i--)
					{
						var dp:DisplayObject = _targetStage.getChildAt(i);
						if(!dp.hitTestPoint(_targetStage.mouseX,_targetStage.mouseY,true))
							continue;
						target = dp;
						if(dp is DisplayObjectContainer)
						{
							var list:Array = DisplayObjectContainer(dp).getObjectsUnderPoint(new Point(_targetStage.mouseX,_targetStage.mouseY));
							if(list.length>0)
							{
								target = list[list.length-1];
							}
						}
						if(target)
							break;
					}
					
					
					
				}
				
				if(currentTarget != target)
				{
					currentTarget = target;
					invalidateDisplayList();
				}
			}
		}
		
		private var modalMask:Sprite = new Sprite();
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			if(!_targetStage)
			{
				return;
			}
			var g:Graphics = modalMask.graphics;
			g.clear();
			g.beginFill(0,0);
			g.drawRect(0,0,_targetStage.stageWidth,_targetStage.stageHeight);
			g.endFill();
			g.beginFill(0,0.2);
			g.drawRect(0,0,_targetStage.stageWidth,_targetStage.stageHeight);
			if(currentTarget)
			{
				var pos:Point = currentTarget.localToGlobal(new Point());
				var className:String = getQualifiedClassName(currentTarget);
				targetLabel.text = "对象:";
				if(className.indexOf("::")!=-1)
					targetLabel.text += className.split("::")[1];
				else
					targetLabel.text += className;
				targetLabel.text += "#"+currentTarget.name+" : ["+className+"]";;
				rectLabel.text = "区域:["+pos.x+","+pos.y+","+currentTarget.width+","+currentTarget.height+"]";
				g.drawRect(pos.x,pos.y,currentTarget.width,currentTarget.height);
				g.endFill();
				g.beginFill(0x009aff,0);
				g.lineStyle(1,0xff0000);
				g.drawRect(pos.x,pos.y,currentTarget.width,currentTarget.height);
			}
			else
			{
				targetLabel.text = "对象:";
				rectLabel.text = "区域:";
			}
			g.endFill();
		}
		/**
		 * 当前鼠标下的对象
		 */		
		private var currentTarget:DisplayObject;
		
		/**
		 * 鼠标移动过的标志
		 */		
		private var mouseMoved:Boolean = false;
		/**
		 * 鼠标移动
		 */		
		private function onMouseMove(event:MouseEvent):void
		{
			if(mouseMoved||!selectBtn.selected)
				return;
			mouseMoved = true;
			invalidateProperties();
		}	
		
		/**
		 * 鼠标经过
		 */		
		private function onMouseOver(event:MouseEvent):void
		{
			if(!selectBtn.selected||contains(event.target as DisplayObject))
				return;
			currentTarget = event.target as DisplayObject;
			
			invalidateDisplayList();
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			if(!selectBtn.selected||contains(event.target as DisplayObject))
				return;
			currentTarget = null;
			invalidateDisplayList();
		}
		
		private var infoDp:XMLCollection = new XMLCollection();
		
		private function onMouseDown(event:MouseEvent):void
		{
			if(!selectBtn.selected)
				return;
			if(currentTarget)
			{
				selectBtn.selected = false;
				mouseEnabled = true;
				infoDp.source = describe(currentTarget);
			}
		}
		private function describe(target:Object):XML
		{
			var xml:XML = <root/>;
			var items:Array = [];
			try
			{
				var type:String = getQualifiedClassName(target);
			}
			catch(e:Error){}
			if(type=="Array")
			{
				var length:int = (target as Array).length;
				for(var i:int=0;i<length;i++)
				{
					var childValue:* = target[i];
					item = <item></item>;
					item.@key = "["+i+"]";
					try
					{
						type = getQualifiedClassName(childValue);
						if(childValue===null||childValue===undefined||
							basicTypes.indexOf(type)!=-1)
							item.@value = childValue;
						else
						{
							item.@value = "["+type+"]";
							item.appendChild(<child/>);
						}
					}
					catch(e:Error){}
					xml.appendChild(item);
				}
				return xml;
			}
			else if(type=="Object")
			{
				var keyList:Array = [];
				for(var key:String in target)
				{
					if(keyList.indexOf(key)!=-1)
						continue;
					keyList.push(key);
					item = <item/>;
					item.@key = key;
					try
					{
						type = getQualifiedClassName(target[key]);
						if(target[key]===null||target[key]===undefined||
							basicTypes.indexOf(type)!=-1)
							item.@value = target[key];
						else
						{
							item.@value = "["+type+"]";
							item.appendChild(<child/>);
						}
					}
					catch(e:Error){}
					items.push(item);
				}
				items.sortOn("@key");
				while(items.length>0)
				{
					xml.appendChild(items.shift());
				}
				return xml;
			}
			var info:XML = describeType(target);
			var others:Array = [];
			var children:Array = [];
			var parent:XML;
			var childXMLList:XMLList = info.variable+info.accessor;
			for each(var node:XML in childXMLList)
			{
				if(node.@access=="writeonly")
					continue;
				var item:XML = <item/>;
				key = node.@name.toString();
				if(key=="stage")
					continue;
				item.@key = key;
				if(foldPropBtn.selected&&layoutProps.indexOf(key)==-1)
					others.push(item);
				else if(key=="parent")
					parent = item;
				else
					items.push(item);
				try
				{
					type = getQualifiedClassName(target[key]);
				}
				catch(e:Error){}
				try
				{
					if(target[key]===null||target[key]===undefined||
						basicTypes.indexOf(type)!=-1)
						item.@value = target[key];
					else
					{
						item.@value = "["+type+"]";
						item.appendChild(<child/>);
					}
				}
				catch(e:Error){}
			}
			if(target is DisplayObjectContainer)
			{
				var dc:DisplayObjectContainer = DisplayObjectContainer(target);
				var numChildren:int = dc.numChildren;
				for(i=0;i<numChildren;i++)
				{
					var child:DisplayObject = dc.getChildAt(i);
					item = <item><child/></item>;
					item.@key = "children["+i+"]";
					try
					{
						item.@value = "["+getQualifiedClassName(child)+"]";
					}
					catch(e:Error){}
					children.push(item);
				}
			}
			if(children.length>0)
			{
				while(children.length>0)
				{
					xml.appendChild(children.shift());
				}
			}
			if(parent)
			{
				xml.appendChild(parent);
			}
			items.sortOn("@key");
			others.sortOn("@key");
			if(items.length==0)
			{
				items = others;
				others = [];
			}
			else if(!(target is DisplayObject))
			{
				items = items.concat(others);
				others = [];
			}
			if(others.length>0)
			{
				var other:XML = <others key="其他属性"/>;
				while(others.length>0)
				{
					other.appendChild(others.shift());
				}
				xml.appendChild(other);
			}
			while(items.length>0)
			{
				xml.appendChild(items.shift());
			}
			
			return xml;
		}
		
		private var layoutProps:Vector.<String> = 
			new <String>["x","y","width","height","measuredWidth","measuredHeight",
			"layoutBoundsWidth","layoutBoundsHeight","preferredWidth","preferredHeight",
			"left","right","top","bottom","percentWidth","percentHeight","verticalCenter",
			"horizontalCenter","explicitWidth","explicitHeight","includeInLayout","preferredX","preferredY",
			"layoutBoundsX","layoutBoundsY","maxWidth","minWidth","skin","skinName","source","content",
			"maxHeight","minHeight","visible","alpha","parent"];
		/**
		 * 基本数据类型列表
		 */		
		private var basicTypes:Vector.<String> = 
			new <String>["Number","int","String","Boolean","uint"];
	}
}