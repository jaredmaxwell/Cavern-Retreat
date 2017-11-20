package com.max.caverns.state {
	
	import com.max.caverns.*;
	
	import org.flixel.*;

	public class PlayStateScroll extends FlxState {
		
		[Embed(source="../../../../data/shadow.png")] private var ImgShadow:Class;
		[Embed(source="../../../../data/smallshadow.png")] private var ImgSmallShadow:Class;
		[Embed(source="../../../../data/largeshadow.png")] private var ImgLargeShadow:Class;
		[Embed(source = "../../../../data/cavernblock.png")] private var ImgCavernBlock:Class;
		[Embed(source = "../../../../data/rockblock.png")] private var ImgRockBlock:Class;	
		[Embed(source = "../../../../data/treasureblock.png")] private var ImgTreasureBlock:Class;
		[Embed(source = "../../../../data/gem.png")] private var ImgGemBlock:Class;		
		[Embed(source = "../../../../data/backgroundcavernblock.png")] private var ImgBackgroundCavernBlock:Class;
		[Embed(source = "../../../../data/waterblock.png")] private var ImgWaterBlock:Class;
		[Embed(source = "../../../../data/hitBlock.mp3")] private var SndHitBlock:Class;
		[Embed(source = "../../../../data/breakRock.mp3")] private var SndHitRock:Class;
		[Embed(source = "../../../../data/breakTreasure.mp3")] private var SndHitTreasure:Class;
		
		
		private const WIDTH_IN_TILES:uint = 42;
		private const HEIGHT_IN_TILES:uint = 30;
		private const SCROLL_BUFFER:uint = 5;
		private const X_OFFSET_OF_GRID:uint = 8000;
		private const Y_OFFSET_OF_GRID:uint = 16;
		private const BLOCK_SIZE:uint = 8;
		
		
		// Upgradable stuff
		public static var shadowSize:uint = 0;
		public static var canDoubleJump:Boolean = false;
		public static var canHover:Boolean = true;
		public static var pickAxeLvl:uint = 5;
		
		private var _background:FlxTileblock
		
		private var _map:Array;
		private var _caves:Array;
		private var _clouds:FlxGroup;
		private var _pools:FlxGroup;
		
		private var _pickAxe:PickAxe;
		private var _player:Player;
		private var _shadow:FlxSprite;
		
		private var _goldText:OutlineText;
		private var _goldCounter:uint;
		
		private var _scoreText:FlxText;
		
		private var isPlayingHitSnd:Number = 0;
		
		public function addPool(pool:Pool):void {
			_pools.add(this.add(pool));
		}
		
		public function cavernDistance(x:int, y:int):int {
			var distance:uint = int.MAX_VALUE;
			for (var i:uint = 0; i < _caves.length; i++) {
				if (_caves[i].pos != undefined) {
					var tempDist:int = Math.abs(Math.sqrt(Math.pow(_caves[i].pos.x - x, 2) + Math.pow(_caves[i].pos.y - y, 2))*2);
					if (tempDist < distance) {
						distance = tempDist;
					}
				}
			}
			if (distance == int.MAX_VALUE) {
				distance = 150;
			}
			return distance;
		}
		
		override public function create():void {
			
			_caves = new Array();
			for (var i:uint = 0; i < 3; i++) {
				
				var cave:Cave = new Cave(Math.random()*100+20, Math.random()*100+20, .55);
				cave = cave.mapTimes(5, function(cell, x, y) {
					return this.tilesAround(x, y, 1) >= 5 ||
					this.tilesAround(x, y, 2) <= 2;
				}).mapTimes(3, function(cell, x, y) {
					return this.tilesAround(x, y, 1) >= 5;
				});
				_caves.push(cave);
			}
			
			_pickAxe = new PickAxe();
			_goldText = new OutlineText(-20,-20,40,"+10");
			_scoreText = new FlxText(FlxG.width-30,10,30,FlxG.score.toString());
			
			_background = new FlxTileblock(-8, -8, 336, 256);
			_background.loadGraphic(ImgBackgroundCavernBlock);
			this.add(_background);
			
			var i:uint = 0;
			
			_map = new Array(WIDTH_IN_TILES);
			for (i = 0; i < _map.length; i++) {
				_map[i] = new Array(HEIGHT_IN_TILES);
			}
			
			if (PlayStateScroll.shadowSize == 0) {
				_shadow = new FlxSprite(0,0,ImgSmallShadow);
			} else if (PlayStateScroll.shadowSize == 1) {
				_shadow = new FlxSprite(0,0,ImgShadow);				
			} else if (PlayStateScroll.shadowSize == 2) {
				_shadow = new FlxSprite(0,0,ImgLargeShadow);
			}
			_shadow.alpha = 1;
			
			instantiateObjects(WIDTH_IN_TILES, HEIGHT_IN_TILES);
			
			_pools = new FlxGroup();
			_clouds = new FlxGroup();
			for (i = 0; i < 20; i++) {
				_clouds.add(this.add(new Cloud(_player)));
			}
		}		
		
		private function instantiateObjects(widthInTiles:uint, heightInTiles:uint):void {
			
			for (var x:uint = 0; x < widthInTiles; x++) {
				for (var y:uint = 0; y < heightInTiles; y++) {
					fillBlock(x, y);
				}
			}
			
			//Don't want to add to the game more then once.
			if (_player == null) {
				_player = new Player((widthInTiles/2) * BLOCK_SIZE + X_OFFSET_OF_GRID, -1 * BLOCK_SIZE + Y_OFFSET_OF_GRID, _pickAxe);
				this.add(_player);
				FlxG.follow(_player,2.5);
				FlxG.followAdjust(0.5,0.0);
				this.add(_pickAxe);
				_goldText.addChildren();
				this.add(_goldText);
				//this.add(_shadow);
			}
		}
		
		private function fillBlock(x:int, y:int):void {
			var rndNum:Number = Math.random();
			
			if (_map[x] != undefined) {
				var blockX:int = x * BLOCK_SIZE + X_OFFSET_OF_GRID;
				var blockY:int = y * BLOCK_SIZE + Y_OFFSET_OF_GRID;
				
				var isEmpty = false;
				
				for (var i:int = 0; i < _caves.length; i++) {
					if (_caves[i].pos != undefined) {
						if (_caves[i].pos.x <= x && (_caves[i].pos.x + _caves[i].width()) >= x 
							&& _caves[i].pos.y <= y &&  (_caves[i].pos.y + _caves[i].height()) >= y) {
							if (!_caves[i].data[y-_caves[i].pos.y][x-_caves[i].pos.x]) {
								isEmpty = true;
							}
						}
					}
				}
				
				if (!isEmpty) {
					if (rndNum > .2) {
						this.add(_map[x][y] = new CavernBlock(x * BLOCK_SIZE + X_OFFSET_OF_GRID, y * BLOCK_SIZE + Y_OFFSET_OF_GRID, BLOCK_SIZE, BLOCK_SIZE, ImgCavernBlock));
					} else if (rndNum > .05)	{
						this.add(_map[x][y] = new CavernBlock(x * BLOCK_SIZE + X_OFFSET_OF_GRID, y * BLOCK_SIZE + Y_OFFSET_OF_GRID, BLOCK_SIZE, BLOCK_SIZE, ImgTreasureBlock, 0, 100));
					} else if (rndNum > 0) {
						this.add(_map[x][y] = new CavernBlock(x * BLOCK_SIZE + X_OFFSET_OF_GRID, y * BLOCK_SIZE + Y_OFFSET_OF_GRID, BLOCK_SIZE, BLOCK_SIZE, ImgRockBlock, 0, 800));
					}
				}
			}
		}

		override public function update():void {			
			super.update();
			FlxU.setWorldBounds((_player.x-((WIDTH_IN_TILES/2)*8)),(_player.y-((HEIGHT_IN_TILES/2)*8)),WIDTH_IN_TILES*8,HEIGHT_IN_TILES*8);
			
			var tempBlocks:FlxGroup = new FlxGroup();
			
			var leftX:int = (_player.x/BLOCK_SIZE)-((WIDTH_IN_TILES/2)+X_OFFSET_OF_GRID/BLOCK_SIZE)-6;
			var rightX:int = (_player.x/BLOCK_SIZE)+((WIDTH_IN_TILES/2)-X_OFFSET_OF_GRID/BLOCK_SIZE)+6;
			var topY:int = (_player.y/BLOCK_SIZE)-((HEIGHT_IN_TILES/2))-6;
			var bottomY:int = (_player.y/BLOCK_SIZE)+((HEIGHT_IN_TILES/2))+6;
			
			// the top of the world
			if (topY < 0) {
				topY = 0;
				if (bottomY < 0) {
					bottomY = 0;
				}
			}
			
			for (var i:int = leftX; i < rightX; i++) {
				for (var j:int = topY; j < bottomY; j++) {
					if (_map[i] != undefined && _map[i][j] != undefined) {
						tempBlocks.add(_map[i][j]);
					}
				}
			} 
			
			if (!_pickAxe.finished) {
				FlxU.overlap(tempBlocks, _pickAxe, pickAxeHitBlock);
			}
			
			FlxU.collide(_clouds, _player);
			for (var i = 0; i < _clouds.members.length; i++) {
				FlxU.collide(tempBlocks, _clouds.members[i].droplets);
				FlxU.collide(_pools, _clouds.members[i].droplets);
			}
			
			FlxU.collide(tempBlocks, _player);
			
			_shadow.x = _player.x - 320;
			_shadow.y = _player.y - 240;
			
			var generationPos:FlxPoint;
			var isLeft:Boolean = false;
			if (_map[rightX] == undefined) { //Fills the right columns of the screen
				for (var i = rightX-6; i < rightX; i++) {
					if (_map[i] == undefined) {
						_map[i] = new Array(bottomY-topY);
						for (var j:int = topY; j < bottomY-topY; j++) {
							fillBlock(i, j);
						}
					}
				}
				generationPos = new FlxPoint(rightX+10, (bottomY-topY/2)+topY);
			}
			
			if (_map[leftX] == undefined) { //Fills the left columns of the screen
				for (var i = leftX; i < leftX+6; i++) {
					if (_map[i] == undefined) {
						_map[i] = new Array(bottomY-topY);
						for (var j:int = topY; j < bottomY-topY; j++) {
							fillBlock(i, j);
						}
					}
				}
				generationPos = new FlxPoint(leftX+10, (bottomY-topY/2)+topY);
				isLeft = true;
			}
			
			for (var i:int = leftX; i < rightX; i++) { //Fills The Bottom rows of the screen
				for (var j:int = topY; j < bottomY; j++) {
					if (_map[i][j] == undefined) {
						fillBlock(i, j);
					}
				}
				generationPos = new FlxPoint(leftX, bottomY+10);
			}
			
			if (generationPos != undefined) {
				if (cavernDistance(generationPos.x, generationPos.y) > 140) {
					if (Math.random() > .95) {
						for (var i:int = 0; i < _caves.length; i++) {
							if (!_caves[i].isPlaced) {
								if (isLeft) {
									generationPos.x = _caves.data.length - generationPos.x; 
								}
								
								_caves[i].pos = generationPos;
								
								_caves[i].isPlaced = true;
								break;
							}
						}
					}
				}
			}
			
			if (!_player.visible) {
				//FlxG.state = new GameOverState();
			}
			
			if (_goldCounter > 0) {
				_goldText.setVisible(true);
				_goldCounter = _goldCounter - .1;
				_goldText.yPos = _goldText.y - .5;
			} else {
				_goldText.setVisible(false);
			}
		}
		
		private function pickAxeHitBlock(block:CavernBlock, pickAxe:PickAxe):void {
			block.hurt(5*(PlayStateScroll.pickAxeLvl+1));
			if (block.dead)	{
				FlxG.scores[0] = FlxG.scores[0] + 1;
				
				if (block.tileType == "[class PlayStateScroll_ImgTreasureBlock]") {
					FlxG.score += 10;
					
					_goldText.setText("+10");
					_goldText.xPos = _player.x;
					_goldText.yPos = _player.y;
					_goldCounter = 60;
					FlxG.play(SndHitTreasure);
				} else if (block.tileType == "[class PlayStateScroll_ImgRockBlock]") {
					FlxG.play(SndHitRock);
				} else if (block.tileType == "[class PlayStateScroll_ImgGemBlock]") {
					FlxG.score += 100;
					
					_goldText.setText("+100");
					_goldText.xPos = _player.x;
					_goldText.yPos = _player.y;
					_goldCounter = 60;
					FlxG.play(SndHitTreasure);
				} else {
					FlxG.play(SndHitBlock,.5);
				}
				
			} else {
				if (isPlayingHitSnd < 0) {
					FlxG.play(SndHitBlock,.5);
					isPlayingHitSnd = .3;
				} else {
					isPlayingHitSnd -= FlxG.elapsed;
				}
			}
		}
		
		private function playerIsInWater(water:FlxSprite, player:Player):void {
			player.isDrowning()
		}
	}
}
