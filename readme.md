# supercop.wasm [![Travis CI](https://img.shields.io/travis/nazar-pc/supercop.wasm/master.svg?label=Travis%20CI)](https://travis-ci.org/nazar-pc/supercop.wasm)
[orlp/ed25519](https://github.com/orlp/ed25519) compiled to WebAssembly using Emscripten and optimized for small size

Based on [supercop.js](https://github.com/1p6/supercop.js).
Works exactly the same way with the same API as supercop.js (except using `Uint8Array` instead of `Buffer` for lower overhead in browser build), but multiple times smaller, uses WebAssembly and works in (modern) browsers (UMD-compatible).

## How to install
```
npm install supercop.wasm
```

## How to use
NOTE: In modern versions of Node.js (4.x and higher) `Buffer` inherits `Uint8Array`, so you can pass `Buffer` directly whenever `Uint8Array` is expected.

Node.js:
```javascript
var supercop = require('supercop.wasm')

supercop.ready(function () {
    var seed = supercop.createSeed()
    var keys = supercop.createKeyPair(seed)
    var msg = Buffer.from('hello there')
    var sig = supercop.sign(msg, keys.publicKey, keys.secretKey)
    console.log(supercop.verify(sig, msg, keys.publicKey)) // true
});
```
Browser:
```javascript
requirejs(['supercop.wasm'], function (supercop) {
    supercop.ready(function () {
        var seed = supercop.createSeed()
        var keys = supercop.createKeyPair(seed)
        var msg = (new TextEncoder("utf-8")).encode("hello there")
        var sig = supercop.sign(msg, keys.publicKey, keys.secretKey)
        console.log(supercop.verify(sig, msg, keys.publicKey)) // true
    });
})
```

# API
### supercop.ready(callback)
* `callback` - Callback function that is called when WebAssembly is loaded and library is ready for use

### var seed = supercop.createSeed()
Generates a cryptographically-secure 32-byte seed (`Uint8Array`)

### var keys = supercop.createKeyPair(seed)
Generates a keypair from the provided 32-byte seed (`Uint8Array`) with the following properties:
* `keys.publicKey` - A 32 byte public key (`Uint8Array`).
* `keys.secretKey` - A 64 byte private key (`Uint8Array`).

### var sig = supercop.sign(msg, publicKey, secretKey)
Signs a given message of any length.
* `msg` - `Uint8Array` of any length containing a message.
* `publicKey` - The public key to sign with (`Uint8Array`).
* `secretKey` - The private key to sign with (`Uint8Array`).
* `sig` - The resulting signature (`Uint8Array`) of length 64 bytes.

### var valid = supercop.verify(sig, msg, publicKey)
Verifies a given signature goes with the message and key.
* `sig` - The signature to verify (`Uint8Array`).
* `msg` - The message that the signature represents (`Uint8Array`).
* `publicKey` - The public key used to generate the signature (`Uint8Array`).
* `valid` - A boolean telling whether the signature is valid (`true`) or invalid (`false`).

## Contribution
Feel free to create issues and send pull requests (for big changes create an issue first and link it from the PR), they are highly appreciated!

## License
MIT, see license.txt
