package layouts
{
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;

	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	import flash.geom.Point;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;

	/**
	 * Flex 4 Time Machine Layout
	 */
	public class TimeMachineLayout extends LayoutBase
	{

		private var _distance : Number = 50;
		private var _horizontalDisplacement : Number = -.2;
		private var _verticalDisplacement : Number = -.2;
		private var _totalHeight : Number;
		private var _layoutHeight : Number;
		private var _index : Number = 0;

		/**
		 * Index of centered item
		 */
		[Bindable]
		public function get index() : Number
		{
			return _index;
		}

		public function set index( value : Number ) : void
		{
			if ( _index != value )
			{
				_index = value;
				invalidateTarget();
			}
		}

		/**
		 * Distance between each item
		 */
		public function get distance() : Number
		{
			return _distance;
		}

		public function set distance( value : Number ) : void
		{
			if ( _distance != value )
			{
				_distance = value;
				invalidateTarget();
			}
		}

		public function get horizontalDisplacement() : Number
		{
			return _horizontalDisplacement;
		}

		public function set horizontalDisplacement( value : Number ) : void
		{
			if ( _horizontalDisplacement != value )
			{
				_horizontalDisplacement = value * .01;
				invalidateTarget();
			}
		}

		public function get verticalDisplacement() : Number
		{
			return _verticalDisplacement;
		}

		public function set verticalDisplacement( value : Number ) : void
		{
			if ( _verticalDisplacement != value )
			{
				_verticalDisplacement = value * .01;
				invalidateTarget();
			}
		}

		public function TimeMachineLayout()
		{
			super();
		}


		override public function updateDisplayList( width : Number, height : Number ) : void
		{
			var numElements : int = target.numElements;
			var selectedIndex : int = Math.max( index, 0 );

			_totalHeight = height + ( numElements - 1 ) * distance;
			_layoutHeight = height;

			target.setContentSize( width, _totalHeight );

			for ( var i : int = 0; i < numElements; i++ )
			{

				var element : ILayoutElement = useVirtualLayout ?
					target.getVirtualElementAt( i ) :
					target.getElementAt( i );

				element.setLayoutBoundsSize( NaN, NaN, false ); // reset size

				var matrix : Matrix3D = new Matrix3D();
				var position : Number = distance * i - target.verticalScrollPosition;

				if ( position < 0 )
					IVisualElement( element ).alpha = 1 - ( -position / distance );
				else
					IVisualElement( element ).alpha = 1 - ( position / 1000 );

				matrix.appendTranslation( position * horizontalDisplacement, position * verticalDisplacement, position );
				matrix.appendTranslation( width * .5 - ( element.getPreferredBoundsWidth() * .5 ), height * .5 - ( element.getPreferredBoundsHeight() * .5 ), 0 ); // center element in container
				element.setLayoutMatrix3D( matrix, false );

				if ( element is IVisualElement )
				{
					IVisualElement( element ).depth = -position;
				}
			}
		}

		override protected function scrollPositionChanged() : void
		{
			if ( target )
				target.invalidateDisplayList();
		}

		override public function updateScrollRect( w : Number, h : Number ) : void
		{
			var g : GroupBase = target;
			if ( !g )
				return;

			if ( clipAndEnableScrolling )
			{
				// Since scroll position is reflected in our 3D calculations,
				// always set the top-left of the srcollRect to (0,0).
				g.scrollRect = new Rectangle( 0, 0, w, h );
			}
			else
				g.scrollRect = null;
		}

		override public function getScrollPositionDeltaToElement( index : int ) : Point
		{
			var scrollPos : int = (( _totalHeight - _layoutHeight ) / ( target.numElements - 1 )) * index;
			return new Point( 0, scrollPos );
		}

		protected function invalidateTarget() : void
		{
			if ( target )
			{
				target.invalidateSize();
				target.invalidateDisplayList();
			}
		}
	}
}