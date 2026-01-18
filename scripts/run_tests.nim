import std/[os, sequtils, strutils]

const testDir = currentSourcePath.parentDir() / "tests"

proc runUnitTests*() =
  echo "Running unit tests..."
  echo "========================"

  let unitTestFiles = testDir.listFiles().filterIt(
    it.name.startsWith("test_") and it.name.endsWith(".nim") and
    "golden" notin it.name
  )

  if unitTestFiles.len == 0:
    echo "No unit test files found in ", testDir
    return

  for testFile in unitTestFiles:
    echo "\nRunning: ", testFile.name
    let testName = testFile.name.changeFileExt("")
    let result = execShellCmd("nim c -r --hints:off --warnings:off " & testFile)
    if result == 0:
      echo "  PASS: ", testName
    else:
      echo "  FAIL: ", testName
      quit(1)

  echo "\n========================"
  echo "All unit tests passed!"

proc runGoldenTests*() =
  echo "Running golden tests..."
  echo "========================"
  echo "Note: Golden tests require manual review"
  echo "Run: nim c -r tests/test_golden_*.nim"
  echo "Then review images in tests/golden/"

when isMainModule:
  let args = commandLineParams()
  if args.len > 0 and args[0] == "--golden":
    runGoldenTests()
  else:
    runUnitTests()
