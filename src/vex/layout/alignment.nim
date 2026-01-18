import vmath

type
  Anchor* = enum
    TopLeft
    TopCenter
    TopRight
    CenterLeft
    Center
    CenterRight
    BottomLeft
    BottomCenter
    BottomRight

  Pivot* = enum
    TopLeft
    TopCenter
    TopRight
    CenterLeft
    Center
    CenterRight
    BottomLeft
    BottomCenter
    BottomRight

const
  anchorOffsets*: array[Anchor, Vec2] = [
    vec2(0.0, 0.0),
    vec2(0.5, 0.0),
    vec2(1.0, 0.0),
    vec2(0.0, 0.5),
    vec2(0.5, 0.5),
    vec2(1.0, 0.5),
    vec2(0.0, 1.0),
    vec2(0.5, 1.0),
    vec2(1.0, 1.0)
  ]

  pivotOffsets*: array[Pivot, Vec2] = [
    vec2(0.0, 0.0),
    vec2(0.5, 0.0),
    vec2(1.0, 0.0),
    vec2(0.0, 0.5),
    vec2(0.5, 0.5),
    vec2(1.0, 0.5),
    vec2(0.0, 1.0),
    vec2(0.5, 1.0),
    vec2(1.0, 1.0)
  ]

proc getAnchorOffset*(anchor: Anchor): Vec2 {.inline.} =
  anchorOffsets[anchor]

proc getPivotOffset*(pivot: Pivot): Vec2 {.inline.} =
  pivotOffsets[pivot]

proc anchorPoint*(rectSize: Vec2, anchor: Anchor): Vec2 {.inline.} =
  let offset = anchorOffsets[anchor]
  vec2(rectSize.x * offset.x, rectSize.y * offset.y)

proc pivotPoint*(rectSize: Vec2, pivot: Pivot): Vec2 {.inline.} =
  let offset = pivotOffsets[pivot]
  vec2(rectSize.x * offset.x, rectSize.y * offset.y)
