package
{
	/**
	 *	lazy_yu
	 * 	yu305306@163.com
	 *	2017-11-30
	 */
	import com.adobe.images.PNGEncoder;

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;

	public class savePic extends Sprite
	{
		private var file:File;
		private var imageTypes:FileFilter;

		private var mc:loadmc;

		private var bit:Bitmap;

		public function savePic()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init():void
		{
			mc=new loadmc();
			file=new File();
			imageTypes=new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png");
			file.addEventListener(Event.SELECT, this.onSelect);
			mc.loadFilePic.addEventListener(MouseEvent.CLICK, onClick);
			mc.yes.addEventListener(MouseEvent.CLICK, cutPic);
			mc.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragIn);
			mc.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dragDropHandler);
			mc.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, dragExitHandler);
			addChild(mc);
		}

		protected function dragExitHandler(e:NativeDragEvent):void
		{
			trace('exit');
		}

		protected function dragDropHandler(e:NativeDragEvent):void
		{
			// TODO Auto-generated method stub


		}

		protected function onDragIn(e:NativeDragEvent):void
		{
//			var clipBoard:Clipboard=e.clipboard;
//			if (clipBoard.hasFormat(ClipboardFormats.BITMAP_FORMAT) || clipBoard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
////				NativeDragManager.acceptDragDrop(_sp);
//				trace(e.target.file);
//			}
			if (e.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
				var files:Array=e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				var f:File=files[0];
				var fileByte:ByteArray=new ByteArray();
				var fs:FileStream=new FileStream();
				fs.open(f, FileMode.READ);
				fs.readBytes(fileByte, 0, fs.bytesAvailable);
				fs.close();
				mc.fileStr.text=f.nativePath;
				var loader:Loader=new Loader();
				loader.unload();
				loader.loadBytes(fileByte);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_completeHandler);
			}
		}

		private function onClick(e:MouseEvent):void
		{
			file.browseForOpen("Open", [imageTypes]);
		}

		private function onSelect(e:Event):void
		{
			//e.target.name 文件名称
			//e.target.nativePath 文件路径

			//获得读取图像文件的二进制数据
			var fileByte:ByteArray=new ByteArray();
			var fs:FileStream=new FileStream();
			trace(e.target);
			fs.open(File(e.target), FileMode.READ);
			fs.readBytes(fileByte, 0, fs.bytesAvailable);
			fs.close();
			mc.fileStr.text=File(e.target).nativePath;
			//使用Loader 对象将图像文件二进制数据加载进来（可加载SWF、GIF、JPEG 或 PNG 格式的文件）
			//使用Loader 是方便通过loader.contentLoaderInfo获得Bitmap对象
			var loader:Loader=new Loader();
			loader.unload();
			loader.loadBytes(fileByte);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_completeHandler);
		}

		private function image_completeHandler(event:Event):void
		{
			bit=new Bitmap();
			bit.bitmapData=Bitmap(event.currentTarget.content).bitmapData;
			bit.smoothing=true;

		}

		private function cutPic(e:MouseEvent=null):void
		{
			if (mc.num.text.length > 0 || mc.numSize.text.length > 0) {
				var i:int=int(mc.num.text);
				var numSize:int=int(mc.numSize.text);
				var hNum:int=Math.ceil(bit.height);
				var numPic:int=Math.ceil(hNum / i);
				var picGetMore:int=hNum % numPic;
				if (numSize > 0) {
					i=Math.ceil(bit.height / numSize);
					numPic=numSize;
					picGetMore=bit.height - (i - 1) * numSize;
				}

				for (var j:int=0; j < i; j++) {
					var bitmapData:BitmapData;
					if (j + 1 == i && picGetMore > 0) {
						bitmapData=new BitmapData(bit.width, picGetMore, true, 0);
					} else {
						bitmapData=new BitmapData(bit.width, numPic, true, 0);
					}
					bitmapData.draw(bit, new Matrix(1, 0, 0, 1, 0, -numPic * j), null, null, null, true);
					var bitmap:Bitmap=new Bitmap(bitmapData, 'auto', true);
					var imgByteArray:ByteArray=PNGEncoder.encode(bitmap.bitmapData);

					var filStr:String=mc.fileStr.text;
					var arr:Array=filStr.split('\\', -1);
					var iNum:int=filStr.length - arr[arr.length - 1].length;
					var p:String=filStr.slice(0, iNum) + mc.nameStr.text + '_' + j + '.png';

					var fl:File=File.applicationStorageDirectory.resolvePath(p);
					var fs:FileStream=new FileStream();
					fs.open(fl, FileMode.WRITE);
					fs.addEventListener(IOErrorEvent.IO_ERROR, writeIOErrorHandler);
					fs.addEventListener(Event.COMPLETE, writeCompleteHandler);
					fs.writeBytes(imgByteArray);
					fs.close();
				}
			}
		}

		private function writeCompleteHandler(e:Event):void
		{
			trace('writeCompleteHandler');
		}

		private function writeIOErrorHandler(e:Event):void
		{
			trace('IO_ERROR');
		}
	}
}
