import CurlJson

open Lean

def getSnapshot(stream: String): IO (Except String String) := do
  let json <- curlGetJson "https://stackage-haddock.haskell.org/snapshots.json"
  pure $ json.getObjVal? stream >>= Json.getStr?

def main : IO Unit := do
  let snap <- getSnapshot "nightly"
  IO.println (<- IO.ofExcept snap)
