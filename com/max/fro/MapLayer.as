package com.max.fro
{
	import flash.geom.Point;
	public class MapLayer 
	{
		private var _layer:String;
		private var _tileset:TileSet;
		private var _scrollFactor:Point;
		private var _layerType:String;
		
		public function MapLayer(layer:String, tileset:TileSet, layerType:String="nocollide") 
		{
			this._layer = layer;
			this._tileset = tileset;
			this._layerType = layerType;
		}
		
		public function get layer():String { return _layer; }
		public function set layer(value:String):void 
		{
			_layer = value;
		}
		
		public function get tileset():TileSet { return _tileset; }
		public function set tileset(value:TileSet):void 
		{
			_tileset = value;
		}
		
		public function get scrollFactor():Point { return _scrollFactor; }
		public function set scrollFactor(value:Point):void 
		{
			_scrollFactor = value;
		}
		
		public function get layerType():String { return _layerType; }
		public function set layerType(value:String):void 
		{
			_layerType = value;
		}
	}
	
}