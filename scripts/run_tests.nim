import std/[algorithm, os, sequtils, strutils]

const testDir = currentSourcePath.parentDir().parentDir() / "tests"

proc isRunnableUnitTest(path: string): bool =
  let name = path.extractFilename
  "golden" notin name and
    not name.endsWith("_visual_test.nim") and
    name != "test_utils.nim" and
    name != "golden_test_utils.nim"

proc runUnitTests*() =
  echo "Running unit tests..."
  echo "========================"

  var discovered: seq[string] = @[]
  discovered.add(toSeq(walkFiles(testDir / "*_test.nim")))
  discovered.add(toSeq(walkFiles(testDir / "test_*.nim")))

  let unitTestFiles = discovered
    .filterIt(isRunnableUnitTest(it))
    .deduplicate()
    .sorted(cmp[string])

  if unitTestFiles.len == 0:
    echo "No unit test files found in ", testDir
    return

  for testFile in unitTestFiles:
    let testFileName = testFile.extractFilename
    echo "\nRunning: ", testFileName
    let testName = testFileName.changeFileExt("")
    let nimcacheDir = ".nimcache_tests_" & testName
    let result = execShellCmd(
      "~/.nimble/bin/nim c -r --path:src --nimcache:" & nimcacheDir &
      " --hints:off --warnings:off " & testFile
    )
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
