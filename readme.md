# supercop.wasm
[orlp/ed25519](https://github.com/orlp/ed25519) compiled to WebAssembly using Emscripten

Based on [supercop.js](https://github.com/1p6/supercop.js).
Works exactly the same way with the same API as supercop.js, but multiple times smaller, uses WebAssembly and works in (modern) browsers (AMD-compatible).

## How to install
```
npm install supercop.wasm
```

## How to use
Node.js:
``` javascript
var supercop = require('supercop.wasm')

var seed = supercop.createSeed()
var keys = supercop.createKeyPair(seed)
var msg = new Buffer('hello there')
var sig = supercop.sign(msg, keys.publicKey, keys.secretKey)
console.log(supercop.verify(sig, msg, keys.publicKey)) // true
```
Browser:
``` javascript
requirejs(['supercop.wasm'], function (supercop) {
    var seed = supercop.createSeed()
    var keys = supercop.createKeyPair(seed)
    var msg = new Buffer('hello there')
    var sig = supercop.sign(msg, keys.publicKey, keys.secretKey)
    console.log(supercop.verify(sig, msg, keys.publicKey)) // true
})
```

# API
### var seed = supercop.createSeed()
Generates a cryptographically-secure 32-byte seed.

### var keys = supercop.createKeyPair(seed)
Generates a keypair from the provided 32-byte seed with the following properties:
* `keys.publicKey` - A 32 byte public key as a buffer.
* `keys.secretKey` - A 64 byte private key as a buffer.

### var sig = supercop.sign(msg, publicKey, secretKey)
Signs a given message of any length.
* `msg` - A buffer of any length containing a message.
* `publicKey` - The public key to sign with as a buffer.
* `secretKey` - The private key to sign with as a buffer.
* `sig` - The resulting signature as a buffer of length 64 bytes.

### var valid = supercop.verify(sig, msg, publicKey)
Verifies a given signature goes with the message and key.
* `sig` - The signature to verify.
* `msg` - The message that the signature represents.
* `publicKey` - The public key used to generate the signature.
* `valid` - A boolean telling whether the signature is valid(`true`) or invalid(`false`).

## Contribution
Feel free to create issues and send pull requests (for big changes create an issue first and link it from the PR), they are highly appreciated!

## License
MIT, see license.txt
