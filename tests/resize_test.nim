import unittest
import std/options
import vmath
import pixie
import vex

suite "resize.nim - Resize handling":
  test "newHeadlessRenderContext initializes with correct viewport size":
    let ctx = newHeadlessRenderContext(vec2(800, 600))
    check ctx.viewportSize == vec2(800, 600)
    check ctx.resizeCallbacks.len == 0
    check ctx.rootNode.isNil

  test "resize updates viewport size":
    let ctx = newHeadlessRenderContext(vec2(800, 600))
    ctx.resize(vec2(1024, 768))
    check ctx.viewportSize == vec2(1024, 768)

  test "onResize registers callback":
    let ctx = newHeadlessRenderContext(vec2(800, 600))
    var called = false
    var receivedSize = vec2(0, 0)
    ctx.onResize(proc(newSize: Vec2) =
      called = true
      receivedSize = newSize
    )
    check ctx.resizeCallbacks.len == 1

  test "resize invokes registered callbacks":
    let ctx = newHeadlessRenderContext(vec2(800, 600))
    var called = false
    var receivedSize = vec2(0, 0)
    ctx.onResize(proc(newSize: Vec2) =
      called = true
      receivedSize = newSize
    )
    ctx.resize(vec2(1024, 768))
    check called == true
    check receivedSize == vec2(1024, 768)

  test "resize invokes multiple callbacks in order":
    let ctx = newHeadlessRenderContext(vec2(800, 600))
    var callOrder: seq[int] = @[]
    ctx.onResize(proc(newSize: Vec2) =
      callOrder.add(1)
    )
    ctx.onResize(proc(newSize: Vec2) =
      callOrder.add(2)
    )
    ctx.onResize(proc(newSize: Vec2) =
      callOrder.add(3)
    )
    ctx.resize(vec2(1024, 768))
    check callOrder == @[1, 2, 3]

  test "setRoot stores root node reference":
    let ctx = newHeadlessRenderContext(vec2(800, 600))
    let root = newNode()
    ctx.setRoot(root)
    check ctx.rootNode == root

  test "resize with rootNode invalidates layout":
    let ctx = newHeadlessRenderContext(vec2(800, 600))
    let root = newVBox()
    root.layoutValid = true
    ctx.setRoot(root)
    ctx.resize(vec2(1024, 768))
    check root.layoutValid == false

  test "resize without rootNode does not crash":
    let ctx = newHeadlessRenderContext(vec2(800, 600))
    ctx.rootNode = nil
    ctx.resize(vec2(1024, 768))
    check ctx.viewportSize == vec2(1024, 768)

  test "headless context supports resize callbacks":
    let ctx = newHeadlessRenderContext(vec2(800, 600))
    var called = false
    ctx.onResize(proc(newSize: Vec2) =
      called = true
    )
    ctx.resize(vec2(1024, 768))
    check called == true
