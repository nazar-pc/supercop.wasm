/**
 * @package lib.wasm
 * @author  Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @license 0BSD
 */
if typeof crypto != 'undefined'
	/**
	 * @param {number} size
	 *
	 * @return {!Uint8Array}
	 */
	random_bytes	= (size) ->
		array = new Uint8Array(size)
		crypto.getRandomValues(array)
		array
else
	/**
	 * @param {string} size
	 *
	 * @return {!Uint8Array}
	 */
	random_bytes	= require('crypto').randomBytes

function Wrapper (lib)
	lib			= lib()
	allocate	= lib['allocateBytes']
	free		= lib['freeBytes']
	/**
	 * @return {!Uint8Array}
	 */
	function createSeed
		random_bytes(32)
	/**
	 * @param {!Uint8Array} seed
	 *
	 * @return {!Object}
	 */
	function createKeyPair (seed)
		if !(seed instanceof Uint8Array)
			throw new Error('not Uint8Array!')
		seed		= allocate(0, seed)
		publicKey	= allocate(32)
		secretKey	= allocate(64)
		lib['_ed25519_create_keypair'](publicKey, secretKey, seed)
		publicKey	= publicKey['get']()
		secretKey	= secretKey['get']()
		free()
		{publicKey, secretKey}
	/**
	 * @param {!Uint8Array} message
	 * @param {!Uint8Array} publicKey
	 * @param {!Uint8Array} secretKey
	 *
	 * @return {!Uint8Array}
	 */
	function sign (message, publicKey, secretKey)
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
		lib['_ed25519_sign'](signature, message, message.length, publicKey, secretKey)
		signature	= signature['get']()
		free()
		signature
	/**
	 * @param {!Uint8Array} signature
	 * @param {!Uint8Array} message
	 * @param {!Uint8Array} publicKey
	 *
	 * @return {boolean}
	 */
	function verify (signature, message, publicKey)
		if !(
			signature instanceof Uint8Array &&
			message instanceof Uint8Array &&
			publicKey instanceof Uint8Array
		)
			throw new Error('not Uint8Arrays!')
		message		= allocate(0, message)
		publicKey	= allocate(0, publicKey)
		signature	= allocate(0, signature)
		result		= lib['_ed25519_verify'](signature, message, message.length, publicKey) == 1
		free()
		result
	{
		'ready'			: lib['then']
		'createSeed'	: createSeed
		'createKeyPair'	: createKeyPair
		'sign'			: sign
		'verify'		: verify
	}

if typeof define == 'function' && define['amd']
	# AMD
	define(['./supercop'], Wrapper)
else if typeof exports == 'object'
	# CommonJS
	module.exports = Wrapper(require('../supercop'))
else
	# Browser globals
	@'supercop_wasm' = Wrapper(@'__supercopwasm')
