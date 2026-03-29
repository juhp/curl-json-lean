import Lean.Data.Json
import Curl

open Lean
open Curl

def curlGet (url : String): IO (Except String String) := do
    let curl <- curl_easy_init
    let response <- IO.mkRef { : IO.FS.Stream.Buffer}
    let h <- IO.mkRef { : IO.FS.Stream.Buffer}

    curl_set_option curl (CurlOption.URL url)
    curl_set_option curl (CurlOption.VERBOSE 0)
    curl_set_option curl (CurlOption.FOLLOWLOCATION 1)
    curl_set_option curl (CurlOption.WRITEDATA response)
    curl_set_option curl (CurlOption.WRITEFUNCTION Curl.writeBytes)
    curl_set_option curl (CurlOption.HEADERDATA h)
    curl_set_option curl (CurlOption.HEADERFUNCTION Curl.writeBytes)
    curl_easy_perform curl

    let headers := String.fromUTF8! (<- h.get).data
    if List.any (Curl.getHeaderData headers) (·.status = 200)
    then
      let bytes <- response.get
      pure $ Except.ok $ String.fromUTF8! bytes.data
    else throw (IO.userError "curl failed for {url}")

def curlGetJson (url : String): IO (Except String Json) := do
    let res <- curlGet url
    pure $ res >>= Json.parse
