package main.panels.components
{
	import flash.events.Event;
	
	import egret.collections.ArrayCollection;
	import egret.collections.ITreeCollection;
	import egret.events.CollectionEvent;
	import egret.events.CollectionEventKind;

	public class DirectionTreeCollection extends ArrayCollection implements ITreeCollection
	{
		private var root:Vector.<DirectionTreeCollectionItem> = new Vector.<DirectionTreeCollectionItem>();
		
		
		public function DirectionTreeCollection()
		{
		}
		
		/**
		 * 添加文件夹/文件夹
		 */
		public function addFile(name:String,desc:String,url:String,type:String,fileType:String="",sort:Boolean=true):Boolean {
			var urlArray:Array = url.split("/");
			var direction:DirectionTreeCollectionItem = new DirectionTreeCollectionItem(name,desc,url,"direction");
			var parent:DirectionTreeCollectionItem;
			var find:Boolean = true;
			var list:Vector.<DirectionTreeCollectionItem> = this.root;
			var currentURL:String = "";
			for(var i:Number = 0; i < urlArray.length; i++) {
				currentURL += (i == 0?"":"/") + urlArray[i];
				if(find) {
					find = false;
					for(var f:Number = 0; f < list.length; f++) {
						var item:DirectionTreeCollectionItem = list[f];
						if(item.url == currentURL) {
							parent = item;
							find = true;
							break;
						}
					}
				} else {
					
				}
				if(find == false) {
					var parentDirection:DirectionTreeCollectionItem = new DirectionTreeCollectionItem(urlArray[i],i==urlArray.length-1?desc:"",currentURL,i==urlArray.length-1?type:"direction",i==urlArray.length-1?fileType:"");
					var insert:Number;
					if(parent == null) {
						if(sort) {
							insert = findNewIndexAtList(item,root);
						} else {
							insert = root.length;
						}
						root.splice(insert,0,parentDirection);
						this.addNewItem(parentDirection,null,insert);
					} else {
						if(sort) {
							insert = findNewIndexAtList(item,parent.children);
						} else {
							insert = parent.children.length;
						}
						parent.children.splice(insert,0,parentDirection);
						this.addNewItem(parentDirection,parent,insert);
					}
					parent = parentDirection;
				} else {
					list = parent.children;
				}
			}
			return true;
		}
		
		private function addNewItem(item:DirectionTreeCollectionItem,parent:DirectionTreeCollectionItem,index:Number):void {
			item.addEventListener(CollectionEventKind.OPEN,onOpenItem);
			item.addEventListener(CollectionEventKind.CLOSE,onCloseItem);
			if(parent && isItemOpen(parent) == false) {
				return;
			}
			if(parent == null) {
				this.addItemAt(item,index);
			} else {
				for(var i:Number = 0; i < this.length; i++) {
					if(this.getItemAt(i) == parent) {
						this.addItemAt(item,i + index);
						break;
					}
				}
			}
		}
		
		private function removeItem(item:DirectionTreeCollectionItem):void {
			for(var i:Number = 0; i < this.length; i++) {
				if(this.getItemAt(i) == item) {
					this.removeItemAt(i);
					break;
				}
			}
		}
		
		private function findNewIndexAtList(item:DirectionTreeCollectionItem,list:Vector.<DirectionTreeCollectionItem>):Number {
			var index:Number = -1;
			for(var c:Number = 0; c < list.length; c++) {
				var a:DirectionTreeCollectionItem = item;
				var b:DirectionTreeCollectionItem = list[c];
				var flag:Boolean = true;
				var len:Number = a.url.length>b.url.length?b.url.length:a.url.length;
				for(var i:Number = 0; i < len; i++) {
					var codea:Number = a.url.charCodeAt(i);
					var codeb:Number = b.url.charCodeAt(i);
					if(codea < codeb) {
						flag = false;
						break;
					}
				}
				if(flag == true) {
					if(a.url.length > b.url.length) {
						index = c + 1;
					} else {
						index = c - 1;
					}
				}
			}
			if(index == -1) {
				index = list.length;
			}
			return index;
		}
		
		/**
		 * 检查指定的节点是否含有子节点
		 * @param item 要检查的节点
		 */		
		public function hasChildren(item:Object):Boolean {
			return (item as DirectionTreeCollectionItem).children.length?true:false;
		}
		
		/**
		 * 指定的节点是否打开
		 */		
		public function isItemOpen(item:Object):Boolean {
			return item.state==CollectionEventKind.OPEN?true:false;
		}
		
		/**
		 * 打开或关闭一个节点
		 * @param item 要打开或关闭的节点
		 * @param open true表示打开节点，反之关闭。
		 */		
		public function expandItem(item:Object,open:Boolean=true):void {
			var children:Vector.<DirectionTreeCollectionItem> = (item as DirectionTreeCollectionItem).children;
			var i:Number;
			if(open) {
				(item as DirectionTreeCollectionItem).changeState(CollectionEventKind.OPEN);
				showDirection(item as DirectionTreeCollectionItem);
			} else {
				(item as DirectionTreeCollectionItem).changeState(CollectionEventKind.CLOSE);
				for(i = 0; i < children.length; i++) {
					hideDirection(children[i]);
				}
			}
		}
		
		private function showDirection(item:DirectionTreeCollectionItem):void {
			var index:Number;
			for(var i:Number = 0; i < this.length; i++) {
				if(this.getItemAt(i) == item) {
					index = i;
					break;
				}
			}
			var children:Vector.<DirectionTreeCollectionItem> = item.children;
			for(i = 0; i < children.length; i++) {
				this.addNewItem(children[i],item as DirectionTreeCollectionItem,i + 1);
				if(children[i].isOpen){
					showDirection(children[i]);
				}
			}
		}
		
		private function hideDirection(item:DirectionTreeCollectionItem):void {
			this.removeItem(item);
			if(item.isOpen) {
				for(var i:Number = 0; i < item.children.length; i++) {
					hideDirection(item.children[i]);
				}
			}
		}
		
		/**
		 * 获取节点的深度
		 */		
		public function getDepth(item:Object):int {
			return item.url.split("/").length - 1;
		}
		
		private function onOpenItem(e:Event):void {
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			event.kind = CollectionEventKind.OPEN;
			event.location = this.getItemIndex(e.currentTarget);
			event.items.push(e.currentTarget);
			this.dispatchEvent(event);
		}
		
		private function onCloseItem(e:Event):void {
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			event.kind = CollectionEventKind.CLOSE;
			event.location = this.getItemIndex(e.currentTarget);
			event.items.push(e.currentTarget);
			this.dispatchEvent(event);
		}
	}
}