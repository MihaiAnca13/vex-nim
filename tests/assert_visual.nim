import std/[strutils, os]

const goldenDir = currentSourcePath.parentDir() / "golden"

type
  VisualCheckResult* = object
    passed*: bool
    message*: string
    details*: string

proc analyzeImageOllama*(imagePath: string, question: string): string {.
    raises: [OSError, ValueError].} =
  let cmd = "ollama_bridge_analyze_ui_screenshot '" & question & "' '" & imagePath & "'"
  let output = execShellCmd(cmd)
  if output != 0:
    raise newException(OSError, "ollama_bridge failed with code: " & $output)
  result = readFile("/tmp/ollama_result.txt")

proc checkVisualText*(imagePath: string, expectedText: string): VisualCheckResult =
  let question = "What text is visible in this image? List all text you see."
  try:
    let response = analyzeImageOllama(imagePath, question)
    let normalizedExpected = expectedText.toLower()
    let normalizedResponse = response.toLower()
    if normalizedExpected in normalizedResponse or normalizedResponse.contains(normalizedExpected):
      VisualCheckResult(passed: true, message: "Found expected text: " & expectedText)
    else:
      VisualCheckResult(passed: false, message: "Text not found", details: "Expected: " & expectedText & ", Got: " & response)
  except:
    VisualCheckResult(passed: false, message: "Analysis failed", details: getCurrentExceptionMsg())

proc checkVisualColor*(imagePath: string, expectedColor: string): VisualCheckResult =
  let question = "What is the dominant color of the main element in this image?"
  try:
    let response = analyzeImageOllama(imagePath, question)
    let normalizedExpected = expectedColor.toLower()
    let normalizedResponse = response.toLower()
    if normalizedExpected in normalizedResponse:
      VisualCheckResult(passed: true, message: "Found expected color: " & expectedColor)
    else:
      VisualCheckResult(passed: false, message: "Color mismatch", details: "Expected: " & expectedColor & ", Got: " & response)
  except:
    VisualCheckResult(passed: false, message: "Analysis failed", details: getCurrentExceptionMsg())

proc checkVisualPosition*(imagePath: string, item: string, expectedX, expectedY: float): VisualCheckResult =
  let question = "What is the position of the " & item & "? Give approximate x,y coordinates in pixels."
  try:
    let response = analyzeImageOllama(imagePath, question)
    let numbers = response.findAll(re"-?\d+\.?\d*")
    if numbers.len >= 2:
      let foundX = numbers[0].parseFloat()
      let foundY = numbers[1].parseFloat()
      let tolerance = 20.0
      if abs(foundX - expectedX) < tolerance and abs(foundY - expectedY) < tolerance:
        VisualCheckResult(passed: true, message: "Position matches", details: "Expected: (" & $expectedX & "," & $expectedY & "), Got: (" & $foundX & "," & $foundY & ")")
      else:
        VisualCheckResult(passed: false, message: "Position mismatch", details: "Expected: (" & $expectedX & "," & $expectedY & "), Got: (" & $foundX & "," & $foundY & ")")
    else:
      VisualCheckResult(passed: false, message: "Could not parse position", details: response)
  except:
    VisualCheckResult(passed: false, message: "Analysis failed", details: getCurrentExceptionMsg())

proc checkVisualExists*(imagePath: string, item: string): VisualCheckResult =
  let question = "Is there a " & item & " visible in this image? Answer yes or no."
  try:
    let response = analyzeImageOllama(imagePath, question)
    let normalized = response.toLower()
    if "yes" in normalized or "true" in normalized:
      VisualCheckResult(passed: true, message: "Item exists: " & item)
    else:
      VisualCheckResult(passed: false, message: "Item not found", details: response)
  except:
    VisualCheckResult(passed: false, message: "Analysis failed", details: getCurrentExceptionMsg())

template assertVisual*(condition: bool, message: string) =
  if not condition:
    raise newException(AssertionDefect, "Visual check failed: " & message)

template checkVisual*(checkResult: VisualCheckResult) =
  if not checkResult.passed:
    raise newException(AssertionDefect, checkResult.message & "\nDetails: " & checkResult.details)
