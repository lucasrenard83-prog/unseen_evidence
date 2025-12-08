// lodash/assign@4.17.21 downloaded from https://ga.jspm.io/npm:lodash@4.17.21/assign.js

import r from"./_assignValue.js";import{_ as s}from"./_/b1449f65.js";import{_ as i}from"./_/d7952e2b.js";import t from"./isArrayLike.js";import{_ as o}from"./_/1d469fdd.js";import m from"./keys.js";import"./_/762679ff.js";import"./_/d35a7fd6.js";import"./_/70a2d34d.js";import"./_/58273e1c.js";import"./isFunction.js";import"./_/052e9e66.js";import"./_/e65ed236.js";import"./_/b15bba73.js";import"./isObject.js";import"./eq.js";import"./_baseRest.js";import"./identity.js";import"./_overRest.js";import"./_apply.js";import"./_/ead8ed36.js";import"./constant.js";import"./_/7781ca7a.js";import"./_isIndex.js";import"./isLength.js";import"./_/d533f765.js";import"./_/c8441f51.js";import"./isArguments.js";import"./isObjectLike.js";import"./isArray.js";import"./isBuffer.js";import"./stubFalse.js";import"./isTypedArray.js";import"./_/dcdb9fca.js";import"./_/9f64fdae.js";import"./_/27d5b997.js";import"./_/d2b8ecf6.js";var p={};var j=r,e=s,a=i,_=t,f=o,d=m;var b=Object.prototype;var c=b.hasOwnProperty;
/**
 * Assigns own enumerable string keyed properties of source objects to the
 * destination object. Source objects are applied from left to right.
 * Subsequent sources overwrite property assignments of previous sources.
 *
 * **Note:** This method mutates `object` and is loosely based on
 * [`Object.assign`](https://mdn.io/Object/assign).
 *
 * @static
 * @memberOf _
 * @since 0.10.0
 * @category Object
 * @param {Object} object The destination object.
 * @param {...Object} [sources] The source objects.
 * @returns {Object} Returns `object`.
 * @see _.assignIn
 * @example
 *
 * function Foo() {
 *   this.a = 1;
 * }
 *
 * function Bar() {
 *   this.c = 3;
 * }
 *
 * Foo.prototype.b = 2;
 * Bar.prototype.d = 4;
 *
 * _.assign({ 'a': 0 }, new Foo, new Bar);
 * // => { 'a': 1, 'c': 3 }
 */var n=a((function(r,s){if(f(s)||_(s))e(s,d(s),r);else for(var i in s)c.call(s,i)&&j(r,i,s[i])}));p=n;var y=p;export{y as default};

