import unittest
import vmath

import ../src/vex/layout/alignment

suite "alignment.nim - Anchor":
  test "Anchor enum has 9 values (3x3 grid)":
    check Anchor.high == Anchor.BottomRight
    check Anchor.low == Anchor.TopLeft
    check ord(Anchor.BottomRight) - ord(Anchor.TopLeft) == 8

  test "anchorOffsets returns correct values":
    check anchorOffsets[Anchor.TopLeft] == vec2(0.0, 0.0)
    check anchorOffsets[Anchor.Center] == vec2(0.5, 0.5)
    check anchorOffsets[Anchor.BottomRight] == vec2(1.0, 1.0)

  test "anchorOffsets corner values":
    check anchorOffsets[Anchor.TopRight] == vec2(1.0, 0.0)
    check anchorOffsets[Anchor.BottomLeft] == vec2(0.0, 1.0)

  test "anchorOffsets edge centers":
    check anchorOffsets[Anchor.TopCenter] == vec2(0.5, 0.0)
    check anchorOffsets[Anchor.CenterLeft] == vec2(0.0, 0.5)
    check anchorOffsets[Anchor.CenterRight] == vec2(1.0, 0.5)
    check anchorOffsets[Anchor.BottomCenter] == vec2(0.5, 1.0)

  test "getAnchorOffset returns correct offset":
    check getAnchorOffset(Anchor.TopLeft) == vec2(0.0, 0.0)
    check getAnchorOffset(Anchor.Center) == vec2(0.5, 0.5)
    check getAnchorOffset(Anchor.BottomRight) == vec2(1.0, 1.0)

  test "anchorPoint calculates position within rect":
    let size = vec2(100.0, 200.0)
    check anchorPoint(size, Anchor.TopLeft) == vec2(0.0, 0.0)
    check anchorPoint(size, Anchor.Center) == vec2(50.0, 100.0)
    check anchorPoint(size, Anchor.BottomRight) == vec2(100.0, 200.0)

  test "anchorPoint with TopRight and BottomLeft":
    let size = vec2(100.0, 200.0)
    check anchorPoint(size, Anchor.TopRight) == vec2(100.0, 0.0)
    check anchorPoint(size, Anchor.BottomLeft) == vec2(0.0, 200.0)

suite "alignment.nim - Pivot":
  test "Pivot enum has 9 values (3x3 grid)":
    check Pivot.high == Pivot.BottomRight
    check Pivot.low == Pivot.TopLeft
    check ord(Pivot.BottomRight) - ord(Pivot.TopLeft) == 8

  test "pivotOffsets returns correct values":
    check pivotOffsets[Pivot.TopLeft] == vec2(0.0, 0.0)
    check pivotOffsets[Pivot.Center] == vec2(0.5, 0.5)
    check pivotOffsets[Pivot.BottomRight] == vec2(1.0, 1.0)

  test "pivotOffsets corner values":
    check pivotOffsets[Pivot.TopRight] == vec2(1.0, 0.0)
    check pivotOffsets[Pivot.BottomLeft] == vec2(0.0, 1.0)

  test "getPivotOffset returns correct offset":
    check getPivotOffset(Pivot.TopLeft) == vec2(0.0, 0.0)
    check getPivotOffset(Pivot.Center) == vec2(0.5, 0.5)
    check getPivotOffset(Pivot.BottomRight) == vec2(1.0, 1.0)

  test "pivotPoint calculates origin within rect":
    let size = vec2(100.0, 200.0)
    check pivotPoint(size, Pivot.TopLeft) == vec2(0.0, 0.0)
    check pivotPoint(size, Pivot.Center) == vec2(50.0, 100.0)
    check pivotPoint(size, Pivot.BottomRight) == vec2(100.0, 200.0)

  test "pivotPoint with TopCenter and BottomCenter":
    let size = vec2(100.0, 200.0)
    check pivotPoint(size, Pivot.TopCenter) == vec2(50.0, 0.0)
    check pivotPoint(size, Pivot.BottomCenter) == vec2(50.0, 200.0)

suite "alignment.nim - Anchor == Pivot parity":
  test "Anchor and Pivot enums have same number of values":
    check ord(Anchor.high) == ord(Pivot.high)
    check ord(Anchor.low) == ord(Pivot.low)

  test "anchorOffsets and pivotOffsets have same structure":
    for i in 0..8:
      check anchorOffsets[Anchor(i)] == pivotOffsets[Pivot(i)]
