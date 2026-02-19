function wasmThreadsSupported() {
    // WebAssembly 1.0
    const source = Uint8Array.of(0x0, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00);
    if (typeof WebAssembly !== 'object' || typeof WebAssembly.validate !== 'function') return false;
    if (!WebAssembly.validate(source)) return false;

    // SharedArrayBuffer
    if (typeof SharedArrayBuffer !== 'function') return false;

    // Atomics
    if (typeof Atomics !== 'object') return false;

    // Shared memory
    const mem = new WebAssembly.Memory({shared: true, initial: 8, maximum: 16});
    if (!(mem.buffer instanceof SharedArrayBuffer)) return false;

    // Structured cloning
    try {
        // You have to make sure nobody cares about these messages!
        window.postMessage(mem, '*');
    } catch (e) {
        return false;
    }

    // Growable shared memory (optional)
    try {
        mem.grow(8);
    } catch (e) {
        return false;
    }

    return true;
}

/*
 * Loads the correct stockfish for the device and adds the message listener
 * the listener takes one argument, the string output of stockfish
 */
function load_stockfish(listener, after_load = function() {console.log("stockfish loaded")}) {
    if (typeof sf == "undefined") {
        if (wasmThreadsSupported()) {
            // use default stockfish
            // https://github.com/niklasf/stockfish.wasm
            Stockfish().then(sf => {
                window.sf = sf;
                sf.addMessageListener(listener);
                after_load();
            });
        } else {
            // use single-threaded or plain javascript stockfish
            // https://github.com/niklasf/stockfish.js
            let wasmSupported = typeof WebAssembly === 'object' && WebAssembly.validate(Uint8Array.of(0x0, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00));
            window.sf = new Worker(wasmSupported ? '/stockfish/js/stockfish.wasm.js' : '/stockfish/js/stockfish.js');
            sf.addEventListener('message', function (e) {
                listener(e.data);
            });
            after_load();
        }
    }
}

export { load_stockfish }
