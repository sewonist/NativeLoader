package com.itpointlab.ane
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	public class NativeLoader extends EventDispatcher
	{
		[Event(name="complete", type="com.itpointlab.ane.NativeLoaderEvent")]
		
		private static const EXTENSION_ID : String = "com.itpointlab.ane.NativeLoader";
		private var _isSupported:Boolean;
		private var _context:ExtensionContext;
		
		private static var _instance:NativeLoader;
		private static var _singleton_lock:Boolean = false;
		
		public function NativeLoader()
		{
			if ( !_singleton_lock ) throw new Error( 'Use NativeLoader.instance' );
			
			try{
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				_context.addEventListener(StatusEvent.STATUS, onStatusContext);
				try{
					_isSupported = _context.call("isSupported");
				}catch(e:Error){
					_isSupported = false;
				}
				
			}catch(e:Error){
				_isSupported = false;
			}
		}
		
		protected function onStatusContext(event:StatusEvent):void
		{
			if(_isSupported){
				if(event.level == Event.COMPLETE){
					var loadedImageWidth:int = _context.call("getLoadedImageWidth", event.code) as int;
					var loadedImageHeight:int = _context.call("getLoadedImageHeight", event.code) as int;
					var loadedImageBitmapData:BitmapData = new BitmapData(loadedImageWidth, loadedImageHeight);
					_context.call("drawLoadedImageToBitmapData", event.code, loadedImageBitmapData);
					dispatchEvent(new NativeLoaderEvent(NativeLoaderEvent.COMPLETE, event.code, loadedImageBitmapData));
				}
			}
		}
		
		public function loadImage(url:String):void
		{
			//trace('[NativeLoader] loadImage( ',url,')', _isSupported);
			if(_isSupported) _context.call('loadImage', url);
		}
		
		public function get isSupported():Boolean{
			return _isSupported;
		}
		
		public static function get instance():NativeLoader 
		{
			if ( _instance == null )
			{
				_singleton_lock = true;
				_instance = new NativeLoader();
				_singleton_lock = false;
			}
			return _instance;
		}
		
	}
}