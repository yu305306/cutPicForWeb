package com
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import model.Param;

	public class WebFile extends Sprite
	{
		private var file:FileReference;
		private var fun:Function;

		public function WebFile($fun:Function)
		{
			super();
			fun=$fun;
			file=new FileReference();
			file.addEventListener(Event.SELECT, selected); //添加“选择文件”事件
			//selectPic()
		}

		public function onClick():void
		{
			if (file != null)
				file.dispatchEvent(new Event(Event.SELECT));
		}

		public function selectPic():void
		{
			file.browse(getFilterTypes()); //浏览
		}

		private function getImageFilter():FileFilter
		{
			return new FileFilter("支持的图片类型(*.jpg;*.jpeg;*.gif;*.png)", "*.jpg;*.jpeg;*.gif;*.png");
		}

		private function getFilterTypes():Array
		{
			return [getImageFilter(), new FileFilter("GIF 文件 (*.gif)", "*.gif"), new FileFilter("PNG 文件 (*.png)", "*.png"), new FileFilter("JPG 文件 (*.jpg)", "*.jpg;*.jpeg")];
		}

		private function selected(e:Event):void
		{
			file.load(); //加载
			file.addEventListener(Event.COMPLETE, on_loaded); //添加加载完成事件
		}

		private function on_loaded(e:Event):void
		{
			trace(Param.fileSize);
			if (file.size <= Param.fileSize*1024)
			{
				var byteArray:ByteArray=ByteArray(e.target.data); //处理数据                  //这里非常关键 
				var loader:Loader=new Loader();
				loader.loadBytes(byteArray);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			}else{
				addCall("msgPicBig");
			}

		}

		protected function onError(event:IOErrorEvent):void
		{
			trace('出错了!' + file.name);
		}

		protected function complete(event:Event):void
		{
			var bitMap:Bitmap=event.target.content as Bitmap; //读取Bitmap    
			if (fun != null)
			{
				fun(bitMap);
			}
		}
		
		public function addCall(jsFun:String, ... arguments):void
		{
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call(jsFun, arguments);
				}
				catch (e:Error)
				{
					
				}
			}
		}

	}
}
