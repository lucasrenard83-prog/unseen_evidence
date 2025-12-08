// lodash/isEmpty@4.17.21 downloaded from https://ga.jspm.io/npm:lodash@4.17.21/isEmpty.js

import{_ as r}from"./_/27d5b997.js";import t from"./_getTag.js";import i from"./isArguments.js";import s from"./isArray.js";import o from"./isArrayLike.js";import e from"./isBuffer.js";import{_ as m}from"./_/1d469fdd.js";import p from"./isTypedArray.js";import"./_/d2b8ecf6.js";import"./_/70a2d34d.js";import"./_/58273e1c.js";import"./isFunction.js";import"./_/052e9e66.js";import"./_/e65ed236.js";import"./_/b15bba73.js";import"./isObject.js";import"./_/38d0670d.js";import"./_Promise.js";import"./_/88299394.js";import"./_/7efbe7b0.js";import"./isObjectLike.js";import"./isLength.js";import"./stubFalse.js";import"./_/dcdb9fca.js";import"./_/9f64fdae.js";var j={};var f=r,a=t,n=i,_=s,u=o,d=e,b=m,c=p;var l="[object Map]",y="[object Set]";var v=Object.prototype;var g=v.hasOwnProperty;
/**
 * Checks if `value` is an empty object, collection, map, or set.
 *
 * Objects are considered empty if they have no own enumerable string keyed
 * properties.
 *
 * Array-like values such as `arguments` objects, arrays, buffers, strings, or
 * jQuery-like collections are considered empty if they have a `length` of `0`.
 * Similarly, maps and sets are considered empty if they have a `size` of `0`.
 *
 * @static
 * @memberOf _
 * @since 0.1.0
 * @category Lang
 * @param {*} value The value to check.
 * @returns {boolean} Returns `true` if `value` is empty, else `false`.
 * @example
 *
 * _.isEmpty(null);
 * // => true
 *
 * _.isEmpty(true);
 * // => true
 *
 * _.isEmpty(1);
 * // => true
 *
 * _.isEmpty([1, 2, 3]);
 * // => false
 *
 * _.isEmpty({ 'a': 1 });
 * // => false
 */function isEmpty(r){if(null==r)return true;if(u(r)&&(_(r)||"string"==typeof r||"function"==typeof r.splice||d(r)||c(r)||n(r)))return!r.length;var t=a(r);if(t==l||t==y)return!r.size;if(b(r))return!f(r).length;for(var i in r)if(g.call(r,i))return false;return true}j=isEmpty;var h=j;export{h as default};

