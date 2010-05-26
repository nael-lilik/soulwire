
/**		
 * 
 *	Subdivision
 *	
 *	@version 1.00 | May 26, 2010
 *	@author Justin Windle
 *  
 **/
 
package  
{
	import flash.geom.Matrix;
	import geom.Polygon;

	import math.Random;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Subdivision
	 */
	public class Subdivision extends Sprite 
	{
		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------
		
		private static const DRAW_SCALE : Number = 2.0;		private static const INV_DRAW_SCALE : Number = 1.0 / DRAW_SCALE;

		//	----------------------------------------------------------------
		//	PUBLIC MEMBERS
		//	----------------------------------------------------------------

		public var minAverageSideLength : int = 4;
		public var useLongestSideChance : Number = 0.5;
		public var useRandomPointsChance : Number = 0.5;
		public var subdividePolygonChance : Number = 0.95;

		//	----------------------------------------------------------------
		//	PRIVATE MEMBERS
		//	----------------------------------------------------------------

		private var _width : int;
		private var _height : int;
		private var _matrix : Matrix;
		private var _render : Bitmap;
		private var _canvas : BitmapData;
		private var _isFirstStep : Boolean;
		private var _container : Sprite = new Sprite();
		private var _polygons : Vector.<Polygon> = new Vector.<Polygon>();

		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------

		public function Subdivision(__width : int, __height : int)
		{
			_width = __width;
			_height = __height;
			
			_canvas = new BitmapData(_width * DRAW_SCALE, _height * DRAW_SCALE, true, 0x0);
			_render = new Bitmap(_canvas, PixelSnapping.AUTO, true);
			_render.scaleX = _render.scaleY = INV_DRAW_SCALE;
			_matrix = new Matrix(DRAW_SCALE, 0, 0, DRAW_SCALE);
			
			addChild(_render);
		}

		//	----------------------------------------------------------------
		//	PUBLIC METHODS
		//	----------------------------------------------------------------

		public function step( iterations : int = 50 ) : void
		{ 
			var i : int, j : int, k : int, n : int;
			var r : Vector.<Polygon>;
			var p : Polygon;
			
			while(_container.numChildren > 0) 
			{ 
				_container.removeChildAt(0); 
			}
			
			for(i = 0;i < iterations;++i)
			{
				if(_polygons.length == 0)
				{
					dispatchEvent(new Event(Event.COMPLETE));
					return;
				}
				
				k = Random.integer(_polygons.length - 1);
				p = _polygons[k];
				
				_polygons.splice(k, 1);
				
				if(_isFirstStep)
				{
					r = p.subdivide(1.0, 1.0);
				}
				else
				{
					r = p.subdivide(useLongestSideChance, useRandomPointsChance);
				}
				
				n = r.length;
				
				for(j = 0;j < n;++j)
				{
					p = r[j];
					
					if(_isFirstStep)
					{
						_polygons.push(p);
					}
					else if(p.averageSideLength() >= minAverageSideLength && Math.random() < subdividePolygonChance)
					{
						_polygons.push(p);
					}
					
					_container.addChild(p);
				}
				
				_isFirstStep = false;
			}

			_canvas.draw(_container, _matrix, null, null, null, true);
		}

		public function reset() : void
		{
			_isFirstStep = true;
			_polygons.length = 0;
			_canvas.fillRect(_canvas.rect, 0xFF);
			
			while(_container.numChildren > 0) 
			{ 
				_container.removeChildAt(0); 
			}
			var poly : Polygon = new Polygon(0, 0, _width, 0, _width, _height, 0, _height);
			
			_polygons.push(poly);
			_container.addChild(poly);
		}
		
		//	----------------------------------------------------------------
		//	PUBLIC ACCESSORS
		//	----------------------------------------------------------------
		
		public function get canvas() : BitmapData
		{
			return _canvas;
		}
	}
}
