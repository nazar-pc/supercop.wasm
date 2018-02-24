/**
 * @package lib.wasm
 * @author  Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @license 0BSD
 */
randombytes	= require('./randombytes')
lib			= require('../supercop')()

allocate	= lib.allocateBytes

exports
	..ready = lib.then
	/**
	 * @return {!Uint8Array}
	 */
	..createSeed = ->
		randombytes(32)
	/**
	 * @param {!Uint8Array} seed
	 *
	 * @return {!Object}
	 */
	..createKeyPair = (seed) ->
		if !(seed instanceof Uint8Array)
			throw new Error('not Uint8Array!')
		seed		= allocate(0, seed)
		publicKey	= allocate(32)
		secretKey	= allocate(64)
		lib._ed25519_create_keypair(publicKey, secretKey, seed)
		publicKey	= publicKey.get()
		secretKey	= secretKey.get()
		lib.freeBytes()
		{publicKey, secretKey}
	/**
	 * @param {!Uint8Array} message
	 * @param {!Uint8Array} publicKey
	 * @param {!Uint8Array} secretKey
	 *
	 * @return {!Uint8Array}
	 */
	..sign = (message, publicKey, secretKey) ->
		if !(
			message instanceof Uint8Array &&
			publicKey instanceof Uint8Array &&
			secretKey instanceof Uint8Array
		)
			throw new Error('not Uint8Arrays!')
		message		= allocate(0, message)
		publicKey	= allocate(0, publicKey)
		secretKey	= allocate(0, secretKey)
		signature	= allocate(64)
		lib._ed25519_sign(signature, message, message.length, publicKey, secretKey)
		signature	= signature.get()
		lib.freeBytes()
		signature
	/**
	 * @param {!Uint8Array} signature
	 * @param {!Uint8Array} message
	 * @param {!Uint8Array} publicKey
	 *
	 * @return {boolean}
	 */
	..verify = (signature, message, publicKey) ->
		if !(
			signature instanceof Uint8Array &&
			message instanceof Uint8Array &&
			publicKey instanceof Uint8Array
		)
			throw new Error('not Uint8Arrays!')
		message		= allocate(0, message)
		publicKey	= allocate(0, publicKey)
		signature	= allocate(0, signature)
		result		= lib._ed25519_verify(signature, message, message.length, publicKey) == 1
		lib.freeBytes()
		result
