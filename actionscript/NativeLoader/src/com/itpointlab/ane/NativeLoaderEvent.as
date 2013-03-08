package com.itpointlab.ane
{
	import flash.events.Event;
	
	public class NativeLoaderEvent extends Event
	{
		public static const COMPLETE:String = 'complete';
		
		private var _key:String;
		private var _data:*;
		
		public function NativeLoaderEvent(type:String, key:String, data:*)
		{
			_key = key;
			_data = data;
			
			super(type, false, false);
		}

		public function get key():String
		{
			return _key;
		}
		
		public function get data():*
		{
			return _data;
		}

	}
}