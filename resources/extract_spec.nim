import os
import sequtils
import strutils
import sugar

type
    CodeCollect = object
        collect*: bool
        code*: seq[string]
        collectionCount*: int

proc isCloseCode(accumulate: CodeCollect, nextItem: string): bool = 
    result = (nextItem.len > 2 and nextItem[0..2] == "```" and not nextItem.contains("typescript")) or
        (accumulate.collectionCount == 1 and nextItem.len > 0 and nextItem[0..0] == "{")

proc collect(accumulate: CodeCollect, nextItem: string): CodeCollect =
    result = accumulate
    result.collectionCount = result.collectionCount + 1
    if isCloseCode(result, nextItem): 
        result.collect = false
        result.code.add "\n\n"
        echo "CLOSE: " & $result.collectionCount & nextItem 
    if result.collect:
        result.code.add nextItem 
        echo "ACCUMULATE: " & $result.collectionCount & nextItem
    elif nextItem.len > 12 and nextItem[0..12] == "```typescript":
        result.collect = true
        result.collectionCount = 0
        echo "OPEN: "

proc main(): void =
    const specMarkdown = slurp("./specification.md").splitLines()

    var code = specMarkdown
                .foldl(collect(a, b), CodeCollect(collect: false, code: @[""], collectionCount: 0))
                .code.join("\n")
    
    writeFile("./specification.ts", code)

when isMainModule:
    main()