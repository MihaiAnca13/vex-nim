import pixie
import vmath
import ../core/types
import ../core/context
import ../core/transform

type
  SpriteNode* = ref object of Node
    imageKey*: string
    sourceRect*: Rect
    sliceInsets*: Vec4

proc newSpriteNode*(imageKey: string, size: Vec2 = vec2(100, 100)): SpriteNode =
  SpriteNode(
    globalTransform: identityTransform,
    size: size,
    imageKey: imageKey,
    sourceRect: rect(0, 0, 0, 0),
    sliceInsets: vec4(0, 0, 0, 0)
  )

proc newSpriteNodeWithSlice*(
  imageKey: string,
  size: Vec2,
  sliceInsets: Vec4
): SpriteNode =
  SpriteNode(
    globalTransform: identityTransform,
    size: size,
    imageKey: imageKey,
    sourceRect: rect(0, 0, 0, 0),
    sliceInsets: sliceInsets
  )

proc contains*(node: SpriteNode, point: Vec2): bool =
  let localPoint = node.globalToLocal(point)
  localPoint.x >= 0 and localPoint.x < node.size.x and
  localPoint.y >= 0 and localPoint.y < node.size.y

proc draw*(node: SpriteNode, renderCtx: context.RenderContext, image: Image) =
  if not renderCtx.contains(node.imageKey):
    return

  let srcImage = renderCtx.getImage(node.imageKey)

  if node.sliceInsets == vec4(0, 0, 0, 0):
    discard srcImage.resize(node.size.x.int, node.size.y.int)
  else:
    discard
