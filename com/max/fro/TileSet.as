package com.max.fro
{
	public class TileSet 
	{
		private var _firstGlobalID:uint = 0;
		private var _sourceName:String;
		
		public function TileSet(firstGlobalID:uint, sourceName:String) 
		{
			this._firstGlobalID = firstGlobalID;
			this._sourceName = sourceName;
		}
		
		public function get firstGlobalID():uint { return _firstGlobalID; }
		public function set firstGlobalID(value:uint):void 
		{
			_firstGlobalID = value;
		}
		
		public function get sourceName():String { return _sourceName; }
		public function set sourceName(value:String):void 
		{
			_sourceName = value;
		}
		
	}
	
}