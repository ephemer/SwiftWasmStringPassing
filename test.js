import { WASI } from "node:wasi";
import { readFile } from "fs/promises";

class SwiftModule {
    static async create() {
        const wasi = new WASI({ version: "preview1" });
        const wasm = await WebAssembly.compile(await readFile(".build/debug/SwiftWasmStringPassing.wasm"));
        const instance = await WebAssembly.instantiate(wasm, wasi.getImportObject());

        wasi.start(instance);
        return new SwiftModule(instance);
    }

    constructor(instance) {
        const { wasm_alloc, wasm_dealloc, process, memory } = instance.exports;
        this.memory = memory;
        this.wasm_alloc = wasm_alloc;
        this.wasm_dealloc = wasm_dealloc;
        this.process = process;
    }

    async run(input = {}) {
        const myUtf8EncodedString = new TextEncoder().encode(JSON.stringify(input));

        const stringPointer = this.wasm_alloc(myUtf8EncodedString.length);
        const memoryView = new DataView(this.memory.buffer);

        const isLittleEndian = true; // WebAssembly is little endian

        for (let i = 0; i < myUtf8EncodedString.length; i++) {
            memoryView.setUint8(stringPointer + i, myUtf8EncodedString[i], isLittleEndian);
        }

        // Remember: on 32bit platforms like wasm32, Int (and Pointer, by definition) is 32bits in size!
        const sizeOfPointer = 4; // 4 bytes == 32 bits

        const pointerToStringPointer = this.wasm_alloc(sizeOfPointer);
        memoryView.setInt32(pointerToStringPointer, stringPointer, isLittleEndian);

        const pointerToStringLength = this.wasm_alloc(sizeOfPointer);
        memoryView.setInt32(pointerToStringLength, myUtf8EncodedString.length, isLittleEndian);

        this.process(pointerToStringPointer, pointerToStringLength);

        // Now we can use pointerToStringPointer and pointerToStringLength
        // They both point to the same memory location as before, but the address
        // of the *pointer* the pointer points to, and the length, have now been updated by Swift.
        const newStringPointer = memoryView.getInt32(pointerToStringPointer, isLittleEndian); // set the `string` pointer
        const newStringLength = memoryView.getInt32(pointerToStringLength, isLittleEndian); // set `count`

        const stringMemory = this.memory.buffer.slice(newStringPointer, newStringPointer + newStringLength);
        const returnedString = new TextDecoder().decode(stringMemory);
        console.log(JSON.parse(returnedString))

        // clean up
        this.wasm_dealloc(newStringPointer);
        this.wasm_dealloc(pointerToStringPointer);
        this.wasm_dealloc(pointerToStringLength);
    }
}

const swiftModule = await SwiftModule.create()
await swiftModule.run({ look: "here", subobject: { works: 42 }, test: true })
