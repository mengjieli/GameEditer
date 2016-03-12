package com.flower.cocos2dx.display
{
	import com.flower.ClassName;
	import com.flower.bufferPool.BufferPool;
	import com.flower.cocos2dx.DebugInfo;
	import com.flower.cocos2dx.EngineLock;
	
	import cocos2dx.cc;
	import cocos2dx.display.CCLabelTTF;
	import cocos2dx.utils.CCSize;

	public class TextField extends DisplayObject
	{
		public function TextField()
		{
			super(true);
			this.className = ClassName.TextField;
			if(EngineLock.TextField == true)
			{
				DebugInfo.debug("|创建TextField| 创建失败，请访问TextField.create()方法创建");
				return;
			}
		}
		
		/**
		 *初始化内容，外部不可用 
		 * @param content
		 * @param size
		 * @param color
		 * 
		 */		
		private function initTextField(content:String,size:uint,color:uint):void
		{
			
			_show = BufferPool.createCCNode(ClassName.CCLabelTTF,content,"",size);
			(_show as CCLabelTTF).setString(content);
			(_show as CCLabelTTF).setFontSize(size);
			(_show as CCLabelTTF).setColor(cc.c3b(color>>16,color>>8&0xFF,color&0xFF));
			var s:CCSize = _show.getContentSize();
			_width = s.width;
			_height = s.height;
		}
		
		/**
		 *设置文字内容 
		 * @param content String 内容
		 * 
		 */		
		public function setText(content:String):void
		{
			(_show as CCLabelTTF).setString(content);
			var s:CCSize = _show.getContentSize();
			_width = s.width;
			_height = s.height;
		}
		
		/**
		 *设置字体大小 
		 * @param size
		 * 
		 */		
		public function setFontSize(size:uint):void
		{
			(_show as CCLabelTTF).setFontSize(size);
			var s:CCSize = _show.getContentSize();
			_width = s.width;
			_height = s.height;
		}
		
		/**
		 *设置颜色 ，如果要用r,g,b值请用setColor2(r,g,b)
		 * @param color 0~0xFFFFFF 颜色值
		 * 
		 */		
		public function setColor(color:uint):void
		{
			(_show as CCLabelTTF).setColor(cc.c3b(color>>16,color>>8&0xFF,color&0xFF));
		}
		
		/**
		 *设置颜色，如果要用单个颜色值请用setColor(color)
		 * @param r  0~256 红色值
		 * @param g 0~256 绿色值
		 * @param b 0~256 蓝色值
		 * 
		 */		
		public function setColor2(r:uint,g:uint,b:uint):void
		{
			(_show as CCLabelTTF).setColor(cc.c3b(r,g,b));
		}
		
		/**
		 *回收属性，外部不可调用，BufferPool自动调用
		 * 
		 */		
		override public function cycleBuffer():void
		{
			super.cycleBuffer();
			_show.cycle();
			BufferPool.cycyleCCNode(_show,ClassName.CCLabelTTF);
			_show = null;
		}
		
		/**
		 *设置父对象,外部类无需调用,否则会导致出错,如果需要添加对象请用addChild()
		 * @param val
		 * 
		 */	
		override public function setParent(val:DisplayObjectContainer):void
		{
			super.setParent(val);
			if(val == null)
			{
				BufferPool.cycle(ClassName.TextField,this,BufferPool.TextFieldMax);
			}
		}
		
		public static function creat(content:String,size:uint,color:uint):TextField
		{
			EngineLock.TextField = false;
			var txt:TextField = BufferPool.create(ClassName.TextField,TextField);
			EngineLock.TextField = true;
			txt.initTextField(content,size,color);
			return txt;
		}
	}
}