package main.panels.mobileView
{
	import flash.events.MouseEvent;
	
	import egret.collections.ArrayCollection;
	import egret.components.Button;
	import egret.components.Label;
	import egret.components.List;
	import egret.ui.components.Window;
	
	import main.data.ToolData;
	import main.model.errorTipModel.TipModel;
	import main.model.loginModel.GetClientRemote;
	import main.net.MyByteArray;
	import main.net.RemoteBase;

	public class ConnectMobilePanel extends Window
	{
		public function ConnectMobilePanel()
		{
			this.title = "链接游戏客户端";
			this.width = 500;
			this.height = 400;
			this.minimizable=this.maximizable=false;
		}
		
		private var tip:Label;
		private var list:List;
		private var btn:Button;
		private var data:ArrayCollection;
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			tip = new Label();
			tip.verticalCenter = 0;
			tip.horizontalCenter = 0;
			tip.text = "请求数据中..."
			this.addElement(tip);
			
			list = new List();
			list.horizontalCenter = 0;
			list.percentWidth = 100;
			list.top = 0;
			list.bottom = 50;
			list.dataProvider = data = new ArrayCollection();
			this.addElement(list);
			
			btn = new Button();
			btn.label = "连接";
			btn.horizontalCenter = 0;
			btn.bottom = 10;
			this.addElement(btn);
			btn.visible = false;
			btn.addEventListener(MouseEvent.CLICK,connectGame);
			
			var bytes:MyByteArray = new MyByteArray();
			bytes.writeUIntV(2002);
			bytes.writeUIntV((new RemoteBase(onGetClientBack)).id);
			ToolData.getInstance().server.send(bytes);
		}
		
		private function onGetClientBack(cmd:Number,msg:MyByteArray,remote:RemoteBase):void {
			var len:Number = msg.readUIntV();
			if(len == 0) {
				tip.visible = true;
				tip.text = "没有任何游戏客户端连接";
			} else {
				tip.visible = false;
				data.removeAll();
				for(var i:Number = 0; i < len; i++) {
					var id:Number = msg.readUIntV();
					var name:String = msg.readUTFV();
					data.addItem({"label":name,"id":id});
				}
				btn.visible = true;
				list.selectedIndex = 0;
			}
			remote.dispose();
		}
		
		private function connectGame(e:MouseEvent):void {
			var remote:RemoteBase = new RemoteBase(this.receiveConnectResult);
			var bytes:MyByteArray = new MyByteArray();
			bytes.writeUIntV(2004);
			bytes.writeUIntV(remote.id);
			remote.data = {id:list.selectedItem.id,name:list.selectedItem.label};
			bytes.writeUIntV(list.selectedItem.id);
			ToolData.getInstance().server.send(bytes);
			this.close();
		}
		
		private function receiveConnectResult(cmd:Number,bytes:MyByteArray,remote:RemoteBase):void {
			var bool:Boolean = bytes.readBoolean();
			if(bool) {
				ToolData.getInstance().mobile.name = remote.data.name;
				ToolData.getInstance().mobile.id = remote.data.id;
				ToolData.getInstance().mobile.connected = true;
				TipModel.show("链接成功");
			} else {
				TipModel.show("链接被拒绝");
			}
		}
	}
}