// lodash/isDate@4.17.21 downloaded from https://ga.jspm.io/npm:lodash@4.17.21/isDate.js

import{_ as a}from"./_/052e9e66.js";import r from"./isObjectLike.js";import{_ as e}from"./_/dcdb9fca.js";import{_ as s}from"./_/9f64fdae.js";import"./_/e65ed236.js";import"./_/b15bba73.js";var t={};var o=a,i=r;var m="[object Date]";
/**
 * The base implementation of `_.isDate` without Node.js optimizations.
 *
 * @private
 * @param {*} value The value to check.
 * @returns {boolean} Returns `true` if `value` is a date object, else `false`.
 */function baseIsDate$1(a){return i(a)&&o(a)==m}t=baseIsDate$1;var f=t;var v={};var b=f,j=e,_=s;var p=_&&_.isDate;
/**
 * Checks if `value` is classified as a `Date` object.
 *
 * @static
 * @memberOf _
 * @since 0.1.0
 * @category Lang
 * @param {*} value The value to check.
 * @returns {boolean} Returns `true` if `value` is a date object, else `false`.
 * @example
 *
 * _.isDate(new Date);
 * // => true
 *
 * _.isDate('Mon April 23 2012');
 * // => false
 */var c=p?j(p):b;v=c;var d=v;export{d as default};

