/**
 * @package   supercop.wasm
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2017, Nazar Mokrynskyi
 * @copyright Copyright (c) 2016-2017, https://github.com/1p6
 * @license   MIT License, see license.txt
 */
supercop	= require('./supercop')()
randombytes	= require('randombytes')

exports
	..createSeed = ->
		randombytes(32)
	..createKeyPair = (seed) ->
		if !Buffer.isBuffer(seed)
			throw new Error('not buffers!')
		seedPtr		= supercop._malloc(32)
		seedBuf		= new Uint8Array(supercop.HEAPU8.buffer, seedPtr, 32)
		pubKeyPtr	= supercop._malloc(32)
		publicKey	= new Uint8Array(supercop.HEAPU8.buffer, pubKeyPtr, 32)
		privKeyPtr	= supercop._malloc(64)
		privateKey	= new Uint8Array(supercop.HEAPU8.buffer, privKeyPtr, 64)
		seedBuf.set(seed)
		supercop
			.._create_keypair(pubKeyPtr, privKeyPtr, seedPtr)
			.._free(seedPtr)
			.._free(pubKeyPtr)
			.._free(privKeyPtr)
		{
			publicKey	: Buffer.from(publicKey)
			secretKey	: Buffer.from(privateKey)
		}
	..sign = (message, publicKey, privateKey) ->
		if !Buffer.isBuffer(message) || !Buffer.isBuffer(publicKey) || !Buffer.isBuffer(privateKey)
			throw new Error('not buffers!')
		msgArrPtr		= supercop._malloc(message.length)
		msgArr			= new Uint8Array(supercop.HEAPU8.buffer, msgArrPtr, message.length)
		pubKeyArrPtr	= supercop._malloc(32)
		pubKeyArr		= new Uint8Array(supercop.HEAPU8.buffer, pubKeyArrPtr, 32)
		privKeyArrPtr	= supercop._malloc(64)
		privKeyArr		= new Uint8Array(supercop.HEAPU8.buffer, privKeyArrPtr, 64)
		sigPtr			= supercop._malloc(64)
		sig				= new Uint8Array(supercop.HEAPU8.buffer, sigPtr, 64)
		msgArr.set(message)
		pubKeyArr.set(publicKey)
		privKeyArr.set(privateKey)
		supercop
			.._sign(sigPtr, msgArrPtr, message.length, pubKeyArrPtr, privKeyArrPtr)
			.._free(msgArrPtr)
			.._free(pubKeyArrPtr)
			.._free(privKeyArrPtr)
			.._free(sigPtr)
		Buffer.from(sig)
	..verify = (sig, message, publicKey) ->
		if !Buffer.isBuffer(message) || !Buffer.isBuffer(sig) || !Buffer.isBuffer(publicKey)
			throw new Error('not buffers!')
		msgArrPtr		= supercop._malloc(message.length)
		msgArr			= new Uint8Array(supercop.HEAPU8.buffer, msgArrPtr, message.length)
		sigArrPtr		= supercop._malloc(64)
		sigArr			= new Uint8Array(supercop.HEAPU8.buffer, sigArrPtr, 64)
		pubKeyArrPtr	= supercop._malloc(32)
		pubKeyArr		= new Uint8Array(supercop.HEAPU8.buffer, pubKeyArrPtr, 32)
		msgArr.set(message)
		sigArr.set(sig)
		pubKeyArr.set(publicKey)
		result = supercop._verify(sigArrPtr, msgArrPtr, message.length, pubKeyArrPtr) == 1
		supercop
			.._free(msgArrPtr)
			.._free(sigArrPtr)
			.._free(pubKeyArrPtr)
		result
