/**
 * @package   supercop.wasm
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2017, Nazar Mokrynskyi
 * @copyright Copyright (c) 2016-2017, https://github.com/1p6
 * @license   MIT License, see license.txt
 */
var test        = require('tape');
var supercop    = require('..');
var randombytes = require('randombytes');

var known = {
	seed      : '370ebebfd430839c75926f459045b2e93718f01ae438a5c145810bb5de83fc45',
	publicKey : '840051a7de9a18cda36f4eb39adcf0c88504a7d61ea1bae7e2ade5163cd9923f',
	secretKey : '905aeceada1b52a8fd29aff9ab43a3a8e0af4ee59b4d2a0f1151c13513ca35679fb11e8b70e625aafb827269fb2fcf7eab377958f0aa3692368c03264392ca18',
	signature : 'bd8738ae0c22b69db5e8d0bcaf48dbc14ac1357c732bb3b12134fddb44c764807423319545179b1df361133752da87308bb2ff1e0a16a120c9d3a89342c46e0c'
};

test('key generation', function (t) {
	t.plan(6);

	var seed = supercop.createSeed();
	t.is(Buffer.isBuffer(seed), true, 'seed is a buffer');
	t.is(seed.length, 32, "seed's length is 32");

	var keys = supercop.createKeyPair(seed);
	t.is(Buffer.isBuffer(keys.publicKey), true, 'public key is a buffer');
	t.is(keys.publicKey.length, 32, "public key's length is 32");
	t.is(Buffer.isBuffer(keys.secretKey), true, 'private key is a buffer');
	t.is(keys.secretKey.length, 64, "private key's length is 64");
});

test('key generation (known seed)', function (t) {
	t.plan(6);

	var keys = supercop.createKeyPair(Buffer.from(known.seed, 'hex'));

	t.is(Buffer.isBuffer(keys.publicKey), true, 'public key is a buffer');
	t.is(keys.publicKey.length, 32, "public key's length is 32");
	t.is(keys.publicKey.toString('hex'), known.publicKey, "public key has expected value");

	t.is(Buffer.isBuffer(keys.secretKey), true, 'private key is a buffer');
	t.is(keys.secretKey.length, 64, "private key's length is 64");
	t.is(keys.secretKey.toString('hex'), known.secretKey, "private key has expected value");
});

test('signatures', function (t) {
	t.plan(2);

	var seed      = supercop.createSeed();
	var keys      = supercop.createKeyPair(seed);
	var signature = supercop.sign(Buffer.from('hello there m8'), keys.publicKey, keys.secretKey);

	t.is(Buffer.isBuffer(signature), true, 'is signature buffer');
	t.is(signature.length, 64, "is signature's length 64");
});

test('signatures (known seed)', function (t) {
	t.plan(3);

	var keys      = supercop.createKeyPair(Buffer.from(known.seed, 'hex'));
	var signature = supercop.sign(Buffer.from('hello there m8'), keys.publicKey, keys.secretKey);

	t.is(Buffer.isBuffer(signature), true, 'is signature buffer');
	t.is(signature.length, 64, "is signature's length 64");
	t.is(signature.toString('hex'), known.signature, "signature has expected value");
});

test('verify', function (t) {
	t.plan(3);

	var seed      = supercop.createSeed();
	var keys      = supercop.createKeyPair(seed);
	var msg       = Buffer.from('hello there m8');
	var signature = supercop.sign(msg, keys.publicKey, keys.secretKey);

	var wrongMsg  = randombytes(msg.length);
	var wrongSeed = supercop.createSeed();
	var wrongKeys = supercop.createKeyPair(wrongSeed);

	t.is(supercop.verify(signature, msg, keys.publicKey), true, 'right stuff verifies correctly');
	t.is(supercop.verify(signature, wrongMsg, keys.publicKey), false, 'wrong message is incorrect');
	t.is(supercop.verify(signature, msg, wrongKeys.publicKey), false, 'wrong key is incorrect');
});
