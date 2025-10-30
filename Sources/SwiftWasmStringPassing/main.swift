import ExtrasJSON

@_expose(wasm, "process")
@_cdecl("process")
func process(string: UnsafeMutablePointer<UnsafePointer<UInt8>>, length: UnsafeMutablePointer<Int>) {
    let inputBufferPointer = UnsafeBufferPointer<UInt8>(start: string.pointee, count: length.pointee)
    let jsonInput = try! JSONParser().parse(bytes: inputBufferPointer)
    string.pointee.deallocate() // Free the string memory we allocated from JS. Keep the pointer to the pointer alive though, because we want to set its contents to another pointer, below.

    var byteArray: [UInt8] = []
    jsonInput.appendBytes(to: &byteArray)
    print(String(copying: try! UTF8Span(validating: byteArray.span)))

    var testValue = false
    switch jsonInput {
    case let .object(obj):
        let test = obj["test"]!
        guard case .bool(let boolVal) = test else {
            print("Couldn't get value of `test` from the input object!")
            break
        }

        testValue = boolVal
    default: break
    }

    // ... create return value...
    let finalJSONValue: JSONValue = .array([.number("123"), .null, .string("test was \(testValue)")])

    byteArray = []
    finalJSONValue.appendBytes(to: &byteArray)
    // byteArray now contains the bytes of the stringified json

    let returnValue = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: byteArray.count)
    _ = returnValue.initialize(fromContentsOf: byteArray) // copies the contents of array

    string.pointee = UnsafePointer(returnValue.baseAddress!) // the pointer is now pointing to the new memory, we can use it from JS
    length.pointee = returnValue.count // set the count so it can be used from JS
    // note: we again _copied_ `byteArray` to create `returnValue`: Swift will clean up `byteArray` but not `returnValue`
}

@_expose(wasm, "wasm_alloc")
@_cdecl("wasm_alloc")
func wasm_alloc(count: Int) -> Int {
    let ptr = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: MemoryLayout<Int>.alignment)
    return Int(bitPattern: ptr)
}

@_expose(wasm, "wasm_dealloc")
@_cdecl("wasm_dealloc")
func wasm_dealloc(ptr: Int) {
    UnsafeMutableRawPointer(bitPattern: ptr)?.deallocate()
}
