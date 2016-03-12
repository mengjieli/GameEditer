package com.flower.bufferPool
{
	import com.flower.ClassName;
	
	import cocos2dx.cc;
	import cocos2dx.display.CCLabelTTF;
	import cocos2dx.display.CCNode;
	import cocos2dx.display.CCSprite;

	/**
	 *对象管理池 
	 * @author MengJie.Li
	 * 
	 */	
	public class BufferPool
	{
		/**对象池*/
		private static var pool:Object = {};
		
		/**
		 *创建对象，如果缓存池里有则不用重新创建，否则要重新创建 
		 * 注意>>>>缓存的class最好实现IBuffer的方法，也可以不实现
		 * @param className 类名
		 * @param cls 类
		 * @param args 初始化参数
		 * @return 
		 * 
		 */		
		public static function create(className:uint,cls:Class):*
		{
			var obj:*;
			if(!pool[className]) pool[className] = [];
			if(pool[className].length) obj = pool[className].pop();
			if(obj == null)  obj = new cls();
			if((IDE.TYPE == 1 && obj.hasOwnProperty("initBuffer")) || (IDE.TYPE == 2 && obj["initBuffer"]))
			{
				obj.initBuffer.apply(obj);
			}
			return obj;
		}
		
		/**
		 *回收对象 
		 * @param className 类名称
		 * @param obj 对象
		 * @param max 最大缓存数
		 * 
		 */		
		public static function cycle(className:uint,obj:*,max:int=1000):void
		{
			if(!pool[className]) pool[className] = [];
			if(pool[className].length > max) return;
			if((IDE.TYPE == 1 && obj.hasOwnProperty("cycleBuffer")) || (IDE.TYPE == 2 && obj["cycleBuffer"]))
			{
				obj.cycleBuffer();
			}
			pool[className].push(obj);
		}
		
		/**
		 *创建cocos2dx引擎的显示对象，如cc.Node cc.Sprite等 
		 * @param className 参见BufferPool.CCNodeClass CCSpriteClass等
		 * @return 返回相应的对象
		 * 
		 */		
		public static function createCCNode(className:uint,...args):CCNode
		{
			var node:CCNode;
			if(!pool[className]) pool[className] = [];
			if(pool[className].length) node = pool[className].pop();
			if(node == null)
			{
				if(className == ClassName.CCNode) node = CCNode.create();
				else if(className == ClassName.CCSprite) node = CCSprite.create();
				else if(className == ClassName.CCLabelTTF) node = CCLabelTTF.create.apply(null,args);
				node.retain();
			}
			return node;
		}
		
		/**
		 *回收cocos2dx引擎的显示对象，如cc.Node cc.Sprite等 
		 * [注意]：如果是外部对象调用此方法，记得先重置node的各种属性到最初的状态，否则别的地方获得了此缓存对象属性可能是不正确的
		 * @param node 回收对象
		 * @param className  参见BufferPool.CCNodeClass CCSpriteClass等
		 */		
		public static function cycyleCCNode(node:CCNode,className:uint):void
		{
			if(!pool[className]) pool[className] = [];
			var max:uint;
			if(className == ClassName.CCNode) max = CCNodeMax;
			else if(className == ClassName.CCSprite) max = CCSpriteMax;
			if(pool[className].length > max)
			{
				node.release();
				return;
			}
			pool[className].push(node);
		}
		
		/**
		 *创建CCPoint CCRect CCColor等非显示对象，此类对象暂时不需要缓存....因为在Cocos2DX中此对象都是Object  例如CCPoint = {x:0,y:0}  CCColor = {r:0,g:0,b:0}
		 * @param className
		 * @return 
		 * 
		 */		
		private static function createCCObject(className:uint):*
		{
			var node:*;
			if(!pool[className]) pool[className] = [];
			if(pool[className].length) node = pool[className].pop();
			if(node == null)
			{
				if(className == ClassName.CCPoint) node = cc.p(0,0);
				else if(className == ClassName.CCSize) node = cc.size(0,0);
				else if(className == ClassName.CCRect) node = cc.rect(0,0,0,0);
				else if(className == ClassName.CCColor) node = cc.c3b(0,0,0);
				else if(className == ClassName.CCColor4) node = cc.c4f(0,0,0,0);
			}
			return node;
		}
		
		/**
		 *回收CCPoint CCRect CCColor等非显示对象 
		 * @param node
		 * @param className
		 * 
		 */		
		private static function cycyleCCObject(node:*,className:uint):void
		{
			if(!pool[className]) pool[className] = [];
			var max:uint;
			if(className == ClassName.CCNode) max = CCNodeMax;
			else if(className == ClassName.CCSprite) max = CCSpriteMax;
			if(pool[className].length > max)
			{
				return;
			}
			pool[className].push(node);
		}
		
		/**CCNode最大缓存数*/
		public static const CCNodeMax:uint = 2000;
		/**CCSprite最大缓存数*/
		public static const CCSpriteMax:uint = 1000;
		
		/**DisplayObject最大缓存数，注意单纯的DisplayObject无意义*/
		public static const DisplayObjectMax:uint = 0;
		/**DisplayObjectContainer最大缓存数*/
		public static const DisplayObjectContainerMax:uint = 1500;
		/**Bitmap最大缓存数**/
		public static const BitmapMax:uint = 800;
		/**TextField最大缓存数**/
		public static const TextFieldMax:uint = 300;
	}
}