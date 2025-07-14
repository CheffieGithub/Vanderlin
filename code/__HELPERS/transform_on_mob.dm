/*
 * We have a system to generate on mob sprites.
 *
 * It involves transforming the world sprite to create an icon to represent it.
 *
 * It can be used in place of the regular inhands system.
 *
 * More complex sprites may need dedicated inhands but for the majority of cases this can be used much quicker
 * to somewhat the same result.
 */

/// Shrink the sprite by this much
#define ON_MOB_SHRINK(shrink) \
	SHRINK = shrink

/// Shift the sprite in X when facing NORTH / EAST / SOUTH / WEST
#define ON_MOB_SHIFT_X(north, east, south, west) \
	NORTH_X = north,\
	EAST_X = east,\
	SOUTH_X = south,\
	WEST_X = west

/// Shift the sprite in Y when facing NORTH / EAST / SOUTH / WEST
#define ON_MOB_SHIFT_Y(north, east, south, west) \
	NORTH_Y = north,\
	EAST_Y = east,\
	SOUTH_Y = south,\
	WEST_Y = west

/// Turn the sprite in degrees when facing NORTH / EAST / SOUTH / WEST
#define ON_MOB_TURN(north, east, south, west) \
	NORTH_TURN = north,\
	EAST_TURN = east,\
	SOUTH_TURN = south,\
	WEST_TURN = west

/// Flip the sprite in HORIZONTAL, VERTICAL or NONE when in NORTH / EAST / SOUTH / WEST
#define ON_MOB_FLIP(north, east, south, west) \
	NORTH_FLIP = north,\
	EAST_FLIP = east,\
	SOUTH_FLIP = south,\
	WEST_FLIP = west

/// Sprite layers above the mob when facing NORTH / EAST / SOUTH / WEST
#define ON_MOB_ABOVE(north, east, south, west) \
	NORTH_ABOVE = north,\
	EAST_ABOVE = east,\
	SOUTH_ABOVE = south,\
	WEST_ABOVE = west

/// Default in-hand, centered on a male humen's hands
#define ON_MOB_DEFAULT_HANDS list(\
	ON_MOB_SHRINK(0.2),\
	ON_MOB_SHIFT_X(7, 2, -7, -4),\
	ON_MOB_SHIFT_Y(-4, -4, -5, -4),\
	ON_MOB_TURN(0, 0, 0, 0),\
	ON_MOB_FLIP(NONE, NONE, NONE, NONE),\
	ON_MOB_ABOVE(FALSE, TRUE, TRUE, FALSE),\
)

/// Default on-belt
#define ON_MOB_DEFAULT_BELT list(\
	ON_MOB_SHRINK(0.2),\
	ON_MOB_SHIFT_X(-4, 2, -2, 0),\
	ON_MOB_SHIFT_Y(-5, -5, -5, -5),\
	ON_MOB_TURN(0, 0, 0, 0),\
	ON_MOB_FLIP(NONE, NONE, NONE, NONE),\
	ON_MOB_ABOVE(FALSE, TRUE, TRUE, FALSE),\
)

/// Default on-back
#define ON_MOB_DEFAULT_BACK list(\
	ON_MOB_SHRINK(0.5),\
	ON_MOB_SHIFT_X(1, -1, 1, 4),\
	ON_MOB_SHIFT_Y(-1, -1, -1, -1),\
	ON_MOB_TURN(0, 0, 0, 0),\
	ON_MOB_FLIP(VERTICAL, NONE, NONE, NONE),\
	ON_MOB_ABOVE(TRUE, FALSE, FALSE, FALSE),\
)
