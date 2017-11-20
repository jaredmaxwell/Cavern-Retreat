package com.max.caverns {
	import com.max.caverns.state.PlayStateScroll;
	
	import org.flixel.*;
	
	public class Cave {
		public var data:Array;
		public var pos:FlxPoint;
		public var isPlaced:Boolean = false;

		public function Cave(width:int, height:int, probability:Number) {
			// make a new cave with random probability
			var cave:Array = [];
			for (var y=0; y<height; y++) {
				var row:Array = [];
				for (var x=0; x<width; x++) {
					row[x] = Math.random() > probability;
				}
				cave.push(row);
			}
			
			this.data = cave;
		}
		
		public function width():int {
			return this.data[0].length-1;
		}
		
		public function height():int {
			return this.data.length-1;
		}
		
		public function map(func:Function):Cave {
			var newCave = new Cave(0,0,0);
			var self = this;
			newCave.data = this.data.map(function(row, y) {
				return row.map(function(cell, x) {
					return func.call(self, cell, x, y);
				});
			});
			return newCave;
		}
		
		public function mapTimes(n, func) {
			if (n===0) {
				return this;
			}
			return this.map(func).mapTimes(n-1, func);
		}
		
		public function display() {
			for (var i=0,l=this.height(); i<l; i++) {
				trace(this.data[i].map(function(x) { return x?"#":" "; }).join(''));
			}
		}
		
		public function tilesAround(x, y, dist) {
			var width=this.width(), height=this.height();
			var sum = 0;
			
			for (var i = x-dist; i<=x+dist; i++) {
				for (var j = y-dist; j<=y+dist; j++) {
					if (i<0 || i>=width || j<0 || j>=height ||
						this.data[j][i]) {
						sum++;
					}
				}
			}
			return sum;
		}
		
	}
}