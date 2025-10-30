# SwiftWasmStringPassing

A demo repo showing how to pass a JSON string in and out of Swift from JS.

As a bonus, we do some manipulation of the parsed JSON object.

Although Wasm itself supports multiple return types, which could make this even easier, that isn't supported by the C calling convention, so Swift doesn't currently have a way of accessing this.

So the way this repo is set up, this is not conceptually different from passing a String to C and back: we pass a pointer to a pointer to the String data, and a pointer to the string length. We consume the incoming string, and then update the pointers with the stringified JSON response.

Uses Swift Embedded: the resulting binary, including full unicode support (!), and JSON encoding / decoding, weighs in at 140kB after running `wasm-strip` on the release binary. With Embedded, Swift code size is competitive with Rust.


## Run

`npm start` -> this will build swift and then run the node test script

This assumes you have node 22+ installed (https://www.nodejs.org).

It also assumes you have Swift 6.2 installed (https://www.swift.org/install – or use `swiftly install 6.2`), and the Swift Wasm toolchain for Swift 6.2:

```
swift sdk install https://download.swift.org/swift-6.2-branch/wasm-sdk/swift-6.2-DEVELOPMENT-SNAPSHOT-2025-10-25-a/swift-6.2-DEVELOPMENT-SNAPSHOT-2025-10-25-a_wasm.artifactbundle.tar.gz --checksum 6c6e77e207cba1e14625931d6c6eb4d6924a33902300deba2c3466b2d53364fd
```

(or see https://www.swift.org/documentation/articles/wasm-getting-started.html).