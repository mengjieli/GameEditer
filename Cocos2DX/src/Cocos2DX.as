package
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	
	import cocos2dx.Cocos2dxSetup;
	import cocos2dx.cc;
	import cocos2dx.gameNet.GameNet;
	
	import game.managers.KeyMgr;
	import game.maps.utils.Point2D;
	import game.maps.utils.Traingle;
	
	import jc.EnterFrame;
	
	import net.GameSocket;
	
	[SWF(width="960",height="640")]
	public class Cocos2DX extends Sprite
	{
		public function Cocos2DX()
		{
			/*
			var list:Array = [231,167,209,230,139,201,0,0,189,28,67,0,0,0,0,0,200,2,230,7,0,0,0,0,64,92,15,10,0,0,0,0];
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte("一","utf-8");////.writeUTF("科拉");
			bytes.position = 0;
			var str:String = "";
			while(bytes.bytesAvailable)
			{
				str += bytes.readUnsignedByte() + ",";
			}
			trace(str);
			return;
			//*///466,211, 463,208 419,211 302,52
//			var t:Traingle = new Traingle(new Point2D(463,208),new Point2D(419,211),new Point2D(302,52));
//			trace(t.checkPoint(new Point2D(466,211)));
//			var cinfo = t.getIntersectioLine(286,197,286,197);
//			cc.log("cinfo = " + cinfo);
////			return;
			this.addEventListener(Event.ADDED_TO_STAGE,addToStage);
//			trace(0xf^1);
//			trace(Math.pow(2,31));//2147483648
//			trace(Math.pow(2,63));//9223372036854776000
//			trace(int.MAX_VALUE);//2147483647
//			return;
//			var load:Loader = new Loader();
//			load.load(new URLRequest("map1.png"));
//			addChild(load);
//			var sp:Sprite = new Sprite();
//			sp.graphics.beginFill(0,0.5);
//			sp.graphics.drawRect(0,0,1184,720);
			//addChild(sp);
		}
		
		private function addToStage(e:Event):void
		{
//			var list:Array = [[800,480],[1920,1080],[1280,720],[960,540],[1184,720],[854,480],[1280,800],[1776,1080],[960,640]];
//			for(var i:int = 0; i < list.length; i++)
//			{
//				trace(list[i][0]*640/list[i][1],list[i][0]/list[i][1]);
//			}
			
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 30;
			stage.color = 0x999999;
			
			//new CheckMonsterAction();
//			GameMain.run();
		}
		
		private function intTo2(val:int):String
		{
			var str:String = "";
			while(val)
			{
				str = ((val&1)?"1":"0") + str;
				val = val>>1;
			}
			return str;
		}
	}
}