import pixie

template hex*(color: string): Color =
  parseHtmlColor(color)

proc solidPaint*(color: Color, opacity: float32 = 1.0): Paint =
  let paint = newPaint(SolidPaint)
  paint.color = color
  paint.opacity = opacity
  paint

const
  colBlue* = parseHtmlColor("#1f77b4")
  colOrange* = parseHtmlColor("#ff7f0e")
  colGreen* = parseHtmlColor("#2ca02c")
  colRed* = parseHtmlColor("#d62728")
  colPurple* = parseHtmlColor("#9467bd")
  colBrown* = parseHtmlColor("#8c564b")
  colPink* = parseHtmlColor("#e377c2")
  colGray* = parseHtmlColor("#7f7f7f")
  colOlive* = parseHtmlColor("#bcbd22")
  colCyan* = parseHtmlColor("#17becf")
