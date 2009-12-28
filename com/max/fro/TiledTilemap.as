package com.max.fro
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import com.max.fro.*;
	import com.adamatomic.flixel.*;
	import flash.utils.*;
	import com.dynamicflash.util.Base64;
	
	public class TiledTilemap
	{		
		private var _tilemaps:FlxArray;
		private var _layers:Array;
		private var _width:int;
		private var _height:int;
		private var _tileSize:int;
		
		public function TiledTilemap(mapdata:XML, objectLayer:Function, getTileGraphic:Function) 
		{
			_tilemaps = new FlxArray();
			_layers = new Array();
			var level:XML = mapdata;
			var i:int = 0;
			
			_width = level.@width;
			_height = level.@height;
			_tileSize = level.@tilewidth;
			
			var tilesets:Array = new Array();
			
			for (i = 0; i < level.tileset.length(); i++)
			{
				var temp:TileSet = new TileSet(level.tileset[i].@firstgid - 1, level.tileset[i].image.@source);
				
				tilesets[i] = temp;
			}
			
			for (i = 0; i < level.layer.length(); i++)
			{
				var layer:String = level.layer[i].data;
				
				var layerBytes:ByteArray = Base64.decodeToByteArray(layer);
				layerBytes.endian = Endian.LITTLE_ENDIAN;
				
				var tempLayer:String = new String();
				
				var tempTileset:TileSet = new TileSet(0, "");
				
				//trace(level.layer[i].@name);
				for (var y:int = 0; y < level.layer[i].@height; y++)
				{
					for (var x:int = 0; x < level.layer[i].@width; x++)
					{
						var tileId:int = 0;
						tileId = layerBytes.readInt()-1;
						
						for (var j:uint = 0; j < tilesets.length; j++)
						{
							if (tileId >= tilesets[j].firstGlobalID)
							{
								tempTileset = tilesets[j];
							}
						}
						
						if (tileId != -1)
						{
							tileId -= tempTileset.firstGlobalID;
						}
						
						if (x == level.layer[i].@width-1)
						{
							tempLayer += tileId;
						}
						else
						{
							tempLayer += tileId + ",";
						}
					}
					tempLayer += "\n";
				}
				
				var mapLayer:MapLayer = new MapLayer(tempLayer, tempTileset);
				
				mapLayer.scrollFactor = new Point(1,1);
				
				if (level.layer[i].properties.property.(@name == "scrollFactor.x")[0] != undefined)
				{
					//trace("x" + level.layer[i].properties.property.(@name == "scrollFactor.x")[0].@value);
					mapLayer.scrollFactor.x = level.layer[i].properties.property.(@name == "scrollFactor.x")[0].@value;
				}
				if (level.layer[i].properties.property.(@name == "scrollFactor.y")[0] != undefined)
				{
					//trace("y" + level.layer[i].properties.property.(@name == "scrollFactor.y")[0].@value);
					mapLayer.scrollFactor.y = level.layer[i].properties.property.(@name == "scrollFactor.y")[0].@value;
				}
				if (level.layer[i].properties.property.(@name == "collide")[0] != undefined)
				{
					mapLayer.layerType = LayerType.COLLIDE;
				}
				else if (level.layer[i].properties.property.(@name == "objects")[0] != undefined)
				{
					mapLayer.layerType = LayerType.OBJECTS;
				}
				else
				{
					mapLayer.layerType = LayerType.NOCOLLIDE;
				}
				
				//trace("layer " + i + " " + mapLayer.layerType);
				
				_layers[i] = mapLayer;
			}
			
			for (i = 0; i < _layers.length; i++)
			{
				//trace(_layers[i].layer);
				
				if (_layers[i].layerType != LayerType.OBJECTS) // represents the object layer. aka player, enemies, and other world objects.
				{
					var collideWithLayer:int = 0;
					
					if (_layers[i].layerType == LayerType.NOCOLLIDE)// This layer should not collide against the player.
					{
						collideWithLayer = 500;
					}
					
					var tileGraphic:Class = getTileGraphic(_layers[i].tileset.sourceName);
					//trace(_layers[i].tileset.sourceName);
					
					var tempTilemap:FlxTilemap = new FlxTilemap(_layers[i].layer, tileGraphic, collideWithLayer, 0);
					tempTilemap.scrollFactor = _layers[i].scrollFactor;
					//trace(tempTilemap.scrollFactor);
					
					_tilemaps.add(tempTilemap);
					
					FlxG.state.add(tempTilemap);					
				}
				else
				{
					//trace("objects");
					
					var widthInTiles:uint = 0;
					var heightInTiles:uint = 0;
					var mapArray:Array = new Array();
					var c:uint;
					var cols:Array;
					var rows:Array = _layers[i].layer.split("\n");
					heightInTiles = rows.length;
					for(var r:uint = 0; r < heightInTiles; r++)
					{
						cols = rows[r].split(",");
						if(cols.length <= 1)
						{
							heightInTiles--;
							continue;
						}
						if(widthInTiles == 0)
							widthInTiles = cols.length;
						
						mapArray.push(cols);
					}
					
					objectLayer(mapArray, widthInTiles, heightInTiles);
				}
			}
		}
		
		public function get tilemaps():FlxArray { return _tilemaps; }
		public function set tilemaps(value:FlxArray):void 
		{
			_tilemaps = value;
		}
		
		public function get layers():Array { return _layers; }
		public function set layers(value:Array):void 
		{
			_layers = value;
		}
		
		public function get width():int { return _width; }
		public function set width(value:int):void 
		{
			_width = value;
		}
		
		public function get height():int { return _height; }
		public function set height(value:int):void 
		{
			_height = value;
		}
		
		public function get tileSize():int { return _tileSize; }
		public function set tileSize(value:int):void 
		{
			_tileSize = value;
		}
	}
	
}