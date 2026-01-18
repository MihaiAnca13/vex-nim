import vmath
import bumpy
import ./types

proc transformPoint*(m: Mat3, p: Vec2): Vec2 =
  let homogeneous = m * vec3(p.x, p.y, 1.0)
  vec2(homogeneous.x, homogeneous.y)

proc transformPointInverse*(m: Mat3, p: Vec2): Vec2 =
  let inv = m.inverse
  transformPoint(inv, p)

proc localToGlobal*(node: Node, localPoint: Vec2): Vec2 =
  node.globalTransform.transformPoint(localPoint)

proc globalToLocal*(node: Node, globalPoint: Vec2): Vec2 =
  node.globalTransform.transformPointInverse(globalPoint)

proc transformRect*(m: Mat3, r: Rect): Rect =
  let topLeft = transformPoint(m, vec2(r.x, r.y))
  let topRight = transformPoint(m, vec2(r.x + r.w, r.y))
  let bottomLeft = transformPoint(m, vec2(r.x, r.y + r.h))
  let bottomRight = transformPoint(m, vec2(r.x + r.w, r.y + r.h))

  let minX = min(topLeft.x, min(topRight.x, min(bottomLeft.x, bottomRight.x)))
  let maxX = max(topLeft.x, max(topRight.x, max(bottomLeft.x, bottomRight.x)))
  let minY = min(topLeft.y, min(topRight.y, min(bottomLeft.y, bottomRight.y)))
  let maxY = max(topLeft.y, max(topRight.y, max(bottomLeft.y, bottomRight.y)))

  Rect(x: minX, y: minY, w: maxX - minX, h: maxY - minY)

proc getGlobalBounds*(node: Node): Rect =
  let localRect = Rect(x: 0, y: 0, w: node.size.x, h: node.size.y)
  node.globalTransform.transformRect(localRect)

proc getWorldPosition*(node: Node): Vec2 =
  let t = node.globalTransform
  vec2(t[2, 0], t[2, 1])

proc getWorldScale*(node: Node): Vec2 =
  let t = node.globalTransform
  let scaleX = vec2(t[0, 0], t[1, 0]).length
  let scaleY = vec2(t[0, 1], t[1, 1]).length
  vec2(scaleX, scaleY)

proc getWorldRotation*(node: Node): float32 =
  let t = node.globalTransform
  arctan2(t[1, 0], t[0, 0])

proc isTransformEqual*(a, b: Mat3, tolerance = 0.0001): bool =
  for i in 0..<3:
    for j in 0..<3:
      if abs(a[i, j] - b[i, j]) > tolerance:
        return false
  return true

proc decomposeTransform*(m: Mat3): tuple[pos: Vec2, scale: Vec2, rotation: float32] =
  let pos = vec2(m[2, 0], m[2, 1])
  let scaleX = vec2(m[0, 0], m[1, 0]).length
  let scaleY = vec2(m[0, 1], m[1, 1]).length
  let rotation = arctan2(m[1, 0], m[0, 0])
  (pos, vec2(scaleX, scaleY), rotation)

proc combineTransforms*(parent, child: Mat3): Mat3 =
  parent * child

proc invertTransform*(m: Mat3): Mat3 =
  m.inverse

proc lerpTransform*(a, b: Mat3, t: float32): Mat3 =
  let decomposedA = decomposeTransform(a)
  let decomposedB = decomposeTransform(b)
  let newPos = mix(decomposedA.pos, decomposedB.pos, t)
  let newScale = mix(decomposedA.scale, decomposedB.scale, t)
  let newRotation = mix(decomposedA.rotation, decomposedB.rotation, t)

  let tMat = translate(newPos)
  let rMat = rotate(newRotation)
  let sMat = scale(newScale)
  tMat * rMat * sMat
