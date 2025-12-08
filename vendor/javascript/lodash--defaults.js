// lodash/defaults@4.17.21 downloaded from https://ga.jspm.io/npm:lodash@4.17.21/defaults.js

import r from"./_baseRest.js";import t from"./eq.js";import{_ as s}from"./_/7781ca7a.js";import i from"./keysIn.js";import"./identity.js";import"./_overRest.js";import"./_apply.js";import"./_/ead8ed36.js";import"./constant.js";import"./_/d35a7fd6.js";import"./_/70a2d34d.js";import"./_/58273e1c.js";import"./isFunction.js";import"./_/052e9e66.js";import"./_/e65ed236.js";import"./_/b15bba73.js";import"./isObject.js";import"./isArrayLike.js";import"./isLength.js";import"./_isIndex.js";import"./_/d533f765.js";import"./_/c8441f51.js";import"./isArguments.js";import"./isObjectLike.js";import"./isArray.js";import"./isBuffer.js";import"./stubFalse.js";import"./isTypedArray.js";import"./_/dcdb9fca.js";import"./_/9f64fdae.js";import"./_/1d469fdd.js";var o={};var p=r,e=t,m=s,a=i;var j=Object.prototype;var d=j.hasOwnProperty;
/**
 * Assigns own and inherited enumerable string keyed properties of source
 * objects to the destination object for all destination properties that
 * resolve to `undefined`. Source objects are applied from left to right.
 * Once a property is set, additional values of the same property are ignored.
 *
 * **Note:** This method mutates `object`.
 *
 * @static
 * @since 0.1.0
 * @memberOf _
 * @category Object
 * @param {Object} object The destination object.
 * @param {...Object} [sources] The source objects.
 * @returns {Object} Returns `object`.
 * @see _.defaultsDeep
 * @example
 *
 * _.defaults({ 'a': 1 }, { 'b': 2 }, { 'a': 3 });
 * // => { 'a': 1, 'b': 2 }
 */var v=p((function(r,t){r=Object(r);var s=-1;var i=t.length;var o=i>2?t[2]:void 0;o&&m(t[0],t[1],o)&&(i=1);while(++s<i){var p=t[s];var v=a(p);var _=-1;var f=v.length;while(++_<f){var n=v[_];var c=r[n];(void 0===c||e(c,j[n])&&!d.call(r,n))&&(r[n]=p[n])}}return r}));o=v;var _=o;export{_ as default};

