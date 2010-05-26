
/**		
 * 
 *	geom.Polygon
 *	
 *	@version 1.00 | Apr 18, 2010
 *	@author Justin Windle
 *  
 **/
 
package geom 
{
	import math.Random;

	import flash.display.Sprite;
	import flash.geom.Matrix;

	/**
	 * Polygon
	 */
	public class Polygon extends Sprite 
	{
		//	----------------------------------------------------------------
		//	PUBLIC MEMBERS
		//	----------------------------------------------------------------
		
		public static var LINE_COLOUR : uint = 0x000000;		public static var FILL_COLOUR : uint = 0xFFFFFF;
		private var _vertices : Vector.<Vertex> = new Vector.<Vertex>();

		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------

		public function Polygon(...verts)
		{
			if(verts.length * 0.5 is int)
			{
				for (var i : int = 0;i < verts.length;i += 2) addVertex(verts[i], verts[i + 1]);
				draw();
			}
			else
			{
				trace("Invalid vertex list");
			}
		}

		//	----------------------------------------------------------------
		//	PUBLIC METHODS
		//	----------------------------------------------------------------

		public function draw() : void
		{
			if(_vertices.length == 0) return;
			
			var n1 : int = Random.integer(_vertices.length - 1);
			var n2 : int = (n1 + 1) % (_vertices.length - 1);
			
			var dx : Number = _vertices[n2].x - _vertices[n1].x;			var dy : Number = _vertices[n2].y - _vertices[n1].y;
			
			var ang : Number = Math.atan2(dy, dx);
			var scl : Number = Random.float(0.15, 0.25);
			var mat : Matrix = new Matrix();
			mat.scale(scl, scl);
			mat.rotate(ang);
			
			graphics.clear();
			graphics.lineStyle(0, LINE_COLOUR);
			graphics.beginFill(FILL_COLOUR);
			
			var v : Vertex = _vertices[0];
			
			graphics.moveTo(v.x, v.y);
			
			for (var i : int = 0;i < _vertices.length;i++)
			{
				v = _vertices[i];
				graphics.lineTo(v.x, v.y);
			}
			
			v = _vertices[0];
			graphics.lineTo(v.x, v.y);
		}

		public function addVertex(__x : Number, __y : Number) : void
		{
			_vertices.push(new Vertex(__x, __y));
			draw();
		}

		public function averageSideLength() : Number
		{
			var l : Number = 0.0;
			var v1 : Vertex, v2 : Vertex;
			var dx : Number, dy : Number;
			var i : int, n : int = _vertices.length - 1;
			
			for (i = 0;i < n;++i) 
			{
				v1 = _vertices[i];
				v2 = _vertices[int(i + 1)];
				
				dx = v2.x - v1.x;
				dy = v2.y - v1.y;
				
				l += dx * dx + dy * dy;
			}
			
			return Math.sqrt(l) / n;
		}

		public function subdivide(useLongestSidesProb : Number = 1.0, useRandomPointsProb : Number = 1.0) : Vector.<Polygon>
		{
			var i : int;
			var v : Vertex;
			var lp : Number;
			var li1 : int, li2 : int;
			var v1 : Vertex, v2 : Vertex; 
		
			// Number of sides
			var ns : int = _vertices.length;
			var mx : int = ns - 1;
			
			var useLongestSides : Boolean = Math.random() < useLongestSidesProb;			var useRandomPoints : Boolean = Math.random() < useRandomPointsProb;
			
			if(useLongestSides)
			{
				var sort : Array = [];
				var dx : Number, dy : Number;
				
				for (i = 0;i < ns;++i)
				{
					v1 = _vertices[i];
					v2 = _vertices[int(i + 1) % ns];
				
					dx = v2.x - v1.x;
					dy = v2.y - v1.y;
					
					sort.push({
						index : i,
						length : dx * dx + dy * dy
					});
				}
				
				sort.sortOn("length", Array.NUMERIC | Array.DESCENDING);
				
				li1 = sort[0].index;
				li2 = sort[1].index;
			}
			else
			{
				li1 = Random.integer(mx);
				li2 = Random.integer(mx);
				while(li2 == li1) li2 = Random.integer(mx);
			}
			
			// Cross start
			lp = useRandomPoints ? Math.random() : 0.5;
			v1 = _vertices[li1];			v2 = _vertices[int(li1 + 1) % ns];
			
			var cx1 : Number = v1.x + (v2.x - v1.x) * lp;			var cy1 : Number = v1.y + (v2.y - v1.y) * lp;
			
			// Cross end
			lp = useRandomPoints ? Math.random() : 0.5;
			v1 = _vertices[li2];
			v2 = _vertices[int(li2 + 1) % ns];
			
			var cx2 : Number = v1.x + (v2.x - v1.x) * lp;
			var cy2 : Number = v1.y + (v2.y - v1.y) * lp;
			
			/*
			 * Create the first subdivision
			 * cross start around to cross end (clockwise)
			 */

			var p1 : Polygon = new Polygon();
			p1.addVertex(cx1, cy1);
			
			var n1 : int = (li1 + 1) % ns;			var n2 : int = (li2 + 1) % ns;
			
			i = n1;
			while(i != n2)
			{
				v = _vertices[i];
				p1.addVertex(v.x, v.y);
				i = (i + 1) % ns;
			}
						p1.addVertex(cx2, cy2);
			
			/*
			 * Create the second subdivision
			 * cross end around to cross start (clockwise)
			 */

			var p2 : Polygon = new Polygon();
			p2.addVertex(cx2, cy2);
			
			i = n2;
			while(i != n1)
			{
				v = _vertices[i];
				p2.addVertex(v.x, v.y);
				i = (i + 1) % ns;
			}
			
			p2.addVertex(cx1, cy1);
			
			// Return new polys
			var result : Vector.<Polygon> = new Vector.<Polygon>(2, true);
			
			result[0] = p1;			result[1] = p2;

			return result;
		}
	}
}

internal class Vertex
{
	public var x : Number;
	public var y : Number;

	public function Vertex(__x : Number = 0.0, __y : Number = 0.0) 
	{
		x = __x;
		y = __y;
	}
}
