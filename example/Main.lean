import CurlJson

open Lean

def getSnapshot(snap: String): IO (Except String String) := do
  let json <- curlGetJson "https://stackage-haddock.haskell.org/snapshots.json"
  pure $ json.getObjVal? snap >>= Json.getStr?

def main : IO Unit := do
  let snap := (<- getSnapshot "nightly")
  IO.println (<- IO.ofExcept snap)
