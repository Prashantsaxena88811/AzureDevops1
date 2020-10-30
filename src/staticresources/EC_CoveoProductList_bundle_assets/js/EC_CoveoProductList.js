(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("Coveo"));
	else if(typeof define === 'function' && define.amd)
		define(["Coveo"], factory);
	else if(typeof exports === 'object')
		exports["CoveoEcolabExtension"] = factory(require("Coveo"));
	else
		root["CoveoEcolabExtension"] = factory(root["Coveo"]);
})(window, function(__WEBPACK_EXTERNAL_MODULE__0__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/assets/";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 28);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE__0__;

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

/*
	MIT License http://www.opensource.org/licenses/mit-license.php
	Author Tobias Koppers @sokra
*/

var stylesInDom = {};

var	memoize = function (fn) {
	var memo;

	return function () {
		if (typeof memo === "undefined") memo = fn.apply(this, arguments);
		return memo;
	};
};

var isOldIE = memoize(function () {
	// Test for IE <= 9 as proposed by Browserhacks
	// @see http://browserhacks.com/#hack-e71d8692f65334173fee715c222cb805
	// Tests for existence of standard globals is to allow style-loader
	// to operate correctly into non-standard environments
	// @see https://github.com/webpack-contrib/style-loader/issues/177
	return window && document && document.all && !window.atob;
});

var getTarget = function (target, parent) {
  if (parent){
    return parent.querySelector(target);
  }
  return document.querySelector(target);
};

var getElement = (function (fn) {
	var memo = {};

	return function(target, parent) {
                // If passing function in options, then use it for resolve "head" element.
                // Useful for Shadow Root style i.e
                // {
                //   insertInto: function () { return document.querySelector("#foo").shadowRoot }
                // }
                if (typeof target === 'function') {
                        return target();
                }
                if (typeof memo[target] === "undefined") {
			var styleTarget = getTarget.call(this, target, parent);
			// Special case to return head of iframe instead of iframe itself
			if (window.HTMLIFrameElement && styleTarget instanceof window.HTMLIFrameElement) {
				try {
					// This will throw an exception if access to iframe is blocked
					// due to cross-origin restrictions
					styleTarget = styleTarget.contentDocument.head;
				} catch(e) {
					styleTarget = null;
				}
			}
			memo[target] = styleTarget;
		}
		return memo[target]
	};
})();

var singleton = null;
var	singletonCounter = 0;
var	stylesInsertedAtTop = [];

var	fixUrls = __webpack_require__(2);

module.exports = function(list, options) {
	if (typeof DEBUG !== "undefined" && DEBUG) {
		if (typeof document !== "object") throw new Error("The style-loader cannot be used in a non-browser environment");
	}

	options = options || {};

	options.attrs = typeof options.attrs === "object" ? options.attrs : {};

	// Force single-tag solution on IE6-9, which has a hard limit on the # of <style>
	// tags it will allow on a page
	if (!options.singleton && typeof options.singleton !== "boolean") options.singleton = isOldIE();

	// By default, add <style> tags to the <head> element
        if (!options.insertInto) options.insertInto = "head";

	// By default, add <style> tags to the bottom of the target
	if (!options.insertAt) options.insertAt = "bottom";

	var styles = listToStyles(list, options);

	addStylesToDom(styles, options);

	return function update (newList) {
		var mayRemove = [];

		for (var i = 0; i < styles.length; i++) {
			var item = styles[i];
			var domStyle = stylesInDom[item.id];

			domStyle.refs--;
			mayRemove.push(domStyle);
		}

		if(newList) {
			var newStyles = listToStyles(newList, options);
			addStylesToDom(newStyles, options);
		}

		for (var i = 0; i < mayRemove.length; i++) {
			var domStyle = mayRemove[i];

			if(domStyle.refs === 0) {
				for (var j = 0; j < domStyle.parts.length; j++) domStyle.parts[j]();

				delete stylesInDom[domStyle.id];
			}
		}
	};
};

function addStylesToDom (styles, options) {
	for (var i = 0; i < styles.length; i++) {
		var item = styles[i];
		var domStyle = stylesInDom[item.id];

		if(domStyle) {
			domStyle.refs++;

			for(var j = 0; j < domStyle.parts.length; j++) {
				domStyle.parts[j](item.parts[j]);
			}

			for(; j < item.parts.length; j++) {
				domStyle.parts.push(addStyle(item.parts[j], options));
			}
		} else {
			var parts = [];

			for(var j = 0; j < item.parts.length; j++) {
				parts.push(addStyle(item.parts[j], options));
			}

			stylesInDom[item.id] = {id: item.id, refs: 1, parts: parts};
		}
	}
}

function listToStyles (list, options) {
	var styles = [];
	var newStyles = {};

	for (var i = 0; i < list.length; i++) {
		var item = list[i];
		var id = options.base ? item[0] + options.base : item[0];
		var css = item[1];
		var media = item[2];
		var sourceMap = item[3];
		var part = {css: css, media: media, sourceMap: sourceMap};

		if(!newStyles[id]) styles.push(newStyles[id] = {id: id, parts: [part]});
		else newStyles[id].parts.push(part);
	}

	return styles;
}

function insertStyleElement (options, style) {
	var target = getElement(options.insertInto)

	if (!target) {
		throw new Error("Couldn't find a style target. This probably means that the value for the 'insertInto' parameter is invalid.");
	}

	var lastStyleElementInsertedAtTop = stylesInsertedAtTop[stylesInsertedAtTop.length - 1];

	if (options.insertAt === "top") {
		if (!lastStyleElementInsertedAtTop) {
			target.insertBefore(style, target.firstChild);
		} else if (lastStyleElementInsertedAtTop.nextSibling) {
			target.insertBefore(style, lastStyleElementInsertedAtTop.nextSibling);
		} else {
			target.appendChild(style);
		}
		stylesInsertedAtTop.push(style);
	} else if (options.insertAt === "bottom") {
		target.appendChild(style);
	} else if (typeof options.insertAt === "object" && options.insertAt.before) {
		var nextSibling = getElement(options.insertAt.before, target);
		target.insertBefore(style, nextSibling);
	} else {
		throw new Error("[Style Loader]\n\n Invalid value for parameter 'insertAt' ('options.insertAt') found.\n Must be 'top', 'bottom', or Object.\n (https://github.com/webpack-contrib/style-loader#insertat)\n");
	}
}

function removeStyleElement (style) {
	if (style.parentNode === null) return false;
	style.parentNode.removeChild(style);

	var idx = stylesInsertedAtTop.indexOf(style);
	if(idx >= 0) {
		stylesInsertedAtTop.splice(idx, 1);
	}
}

function createStyleElement (options) {
	var style = document.createElement("style");

	if(options.attrs.type === undefined) {
		options.attrs.type = "text/css";
	}

	if(options.attrs.nonce === undefined) {
		var nonce = getNonce();
		if (nonce) {
			options.attrs.nonce = nonce;
		}
	}

	addAttrs(style, options.attrs);
	insertStyleElement(options, style);

	return style;
}

function createLinkElement (options) {
	var link = document.createElement("link");

	if(options.attrs.type === undefined) {
		options.attrs.type = "text/css";
	}
	options.attrs.rel = "stylesheet";

	addAttrs(link, options.attrs);
	insertStyleElement(options, link);

	return link;
}

function addAttrs (el, attrs) {
	Object.keys(attrs).forEach(function (key) {
		el.setAttribute(key, attrs[key]);
	});
}

function getNonce() {
	if (false) {}

	return __webpack_require__.nc;
}

function addStyle (obj, options) {
	var style, update, remove, result;

	// If a transform function was defined, run it on the css
	if (options.transform && obj.css) {
	    result = typeof options.transform === 'function'
		 ? options.transform(obj.css) 
		 : options.transform.default(obj.css);

	    if (result) {
	    	// If transform returns a value, use that instead of the original css.
	    	// This allows running runtime transformations on the css.
	    	obj.css = result;
	    } else {
	    	// If the transform function returns a falsy value, don't add this css.
	    	// This allows conditional loading of css
	    	return function() {
	    		// noop
	    	};
	    }
	}

	if (options.singleton) {
		var styleIndex = singletonCounter++;

		style = singleton || (singleton = createStyleElement(options));

		update = applyToSingletonTag.bind(null, style, styleIndex, false);
		remove = applyToSingletonTag.bind(null, style, styleIndex, true);

	} else if (
		obj.sourceMap &&
		typeof URL === "function" &&
		typeof URL.createObjectURL === "function" &&
		typeof URL.revokeObjectURL === "function" &&
		typeof Blob === "function" &&
		typeof btoa === "function"
	) {
		style = createLinkElement(options);
		update = updateLink.bind(null, style, options);
		remove = function () {
			removeStyleElement(style);

			if(style.href) URL.revokeObjectURL(style.href);
		};
	} else {
		style = createStyleElement(options);
		update = applyToTag.bind(null, style);
		remove = function () {
			removeStyleElement(style);
		};
	}

	update(obj);

	return function updateStyle (newObj) {
		if (newObj) {
			if (
				newObj.css === obj.css &&
				newObj.media === obj.media &&
				newObj.sourceMap === obj.sourceMap
			) {
				return;
			}

			update(obj = newObj);
		} else {
			remove();
		}
	};
}

var replaceText = (function () {
	var textStore = [];

	return function (index, replacement) {
		textStore[index] = replacement;

		return textStore.filter(Boolean).join('\n');
	};
})();

function applyToSingletonTag (style, index, remove, obj) {
	var css = remove ? "" : obj.css;

	if (style.styleSheet) {
		style.styleSheet.cssText = replaceText(index, css);
	} else {
		var cssNode = document.createTextNode(css);
		var childNodes = style.childNodes;

		if (childNodes[index]) style.removeChild(childNodes[index]);

		if (childNodes.length) {
			style.insertBefore(cssNode, childNodes[index]);
		} else {
			style.appendChild(cssNode);
		}
	}
}

function applyToTag (style, obj) {
	var css = obj.css;
	var media = obj.media;

	if(media) {
		style.setAttribute("media", media)
	}

	if(style.styleSheet) {
		style.styleSheet.cssText = css;
	} else {
		while(style.firstChild) {
			style.removeChild(style.firstChild);
		}

		style.appendChild(document.createTextNode(css));
	}
}

function updateLink (link, options, obj) {
	var css = obj.css;
	var sourceMap = obj.sourceMap;

	/*
		If convertToAbsoluteUrls isn't defined, but sourcemaps are enabled
		and there is no publicPath defined then lets turn convertToAbsoluteUrls
		on by default.  Otherwise default to the convertToAbsoluteUrls option
		directly
	*/
	var autoFixUrls = options.convertToAbsoluteUrls === undefined && sourceMap;

	if (options.convertToAbsoluteUrls || autoFixUrls) {
		css = fixUrls(css);
	}

	if (sourceMap) {
		// http://stackoverflow.com/a/26603875
		css += "\n/*# sourceMappingURL=data:application/json;base64," + btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))) + " */";
	}

	var blob = new Blob([css], { type: "text/css" });

	var oldSrc = link.href;

	link.href = URL.createObjectURL(blob);

	if(oldSrc) URL.revokeObjectURL(oldSrc);
}


/***/ }),
/* 2 */
/***/ (function(module, exports) {


/**
 * When source maps are enabled, `style-loader` uses a link element with a data-uri to
 * embed the css on the page. This breaks all relative urls because now they are relative to a
 * bundle instead of the current page.
 *
 * One solution is to only use full urls, but that may be impossible.
 *
 * Instead, this function "fixes" the relative urls to be absolute according to the current page location.
 *
 * A rudimentary test suite is located at `test/fixUrls.js` and can be run via the `npm test` command.
 *
 */

module.exports = function (css) {
  // get current location
  var location = typeof window !== "undefined" && window.location;

  if (!location) {
    throw new Error("fixUrls requires window.location");
  }

	// blank or null?
	if (!css || typeof css !== "string") {
	  return css;
  }

  var baseUrl = location.protocol + "//" + location.host;
  var currentDir = baseUrl + location.pathname.replace(/\/[^\/]*$/, "/");

	// convert each url(...)
	/*
	This regular expression is just a way to recursively match brackets within
	a string.

	 /url\s*\(  = Match on the word "url" with any whitespace after it and then a parens
	   (  = Start a capturing group
	     (?:  = Start a non-capturing group
	         [^)(]  = Match anything that isn't a parentheses
	         |  = OR
	         \(  = Match a start parentheses
	             (?:  = Start another non-capturing groups
	                 [^)(]+  = Match anything that isn't a parentheses
	                 |  = OR
	                 \(  = Match a start parentheses
	                     [^)(]*  = Match anything that isn't a parentheses
	                 \)  = Match a end parentheses
	             )  = End Group
              *\) = Match anything and then a close parens
          )  = Close non-capturing group
          *  = Match anything
       )  = Close capturing group
	 \)  = Match a close parens

	 /gi  = Get all matches, not the first.  Be case insensitive.
	 */
	var fixedCss = css.replace(/url\s*\(((?:[^)(]|\((?:[^)(]+|\([^)(]*\))*\))*)\)/gi, function(fullMatch, origUrl) {
		// strip quotes (if they exist)
		var unquotedOrigUrl = origUrl
			.trim()
			.replace(/^"(.*)"$/, function(o, $1){ return $1; })
			.replace(/^'(.*)'$/, function(o, $1){ return $1; });

		// already a full url? no change
		if (/^(#|data:|http:\/\/|https:\/\/|file:\/\/\/|\s*$)/i.test(unquotedOrigUrl)) {
		  return fullMatch;
		}

		// convert the url to a full url
		var newUrl;

		if (unquotedOrigUrl.indexOf("//") === 0) {
		  	//TODO: should we add protocol?
			newUrl = unquotedOrigUrl;
		} else if (unquotedOrigUrl.indexOf("/") === 0) {
			// path should be relative to the base url
			newUrl = baseUrl + unquotedOrigUrl; // already starts with '/'
		} else {
			// path should be relative to current directory
			newUrl = currentDir + unquotedOrigUrl.replace(/^\.\//, ""); // Strip leading './'
		}

		// send back the fixed url(...)
		return "url(" + JSON.stringify(newUrl) + ")";
	});

	// send back the fixed css
	return fixedCss;
};


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

(function webpackUniversalModuleDefinition(root, factory) {
	if(true)
		module.exports = factory(__webpack_require__(0));
	else {}
})(window, function(__WEBPACK_EXTERNAL_MODULE__0__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 3);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE__0__;

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

// Commerce Data Layer Events
Object.defineProperty(exports, "__esModule", { value: true });
exports.CommerceDataLayerEvents = void 0;
var CommerceDataLayerEvents = /** @class */ (function () {
    function CommerceDataLayerEvents() {
    }
    CommerceDataLayerEvents.impression = 'CommerceDataLayerEventImpression';
    CommerceDataLayerEvents.productClick = 'CommerceDataLayerEventProductClick';
    CommerceDataLayerEvents.productDetail = 'CommerceDataLayerEventProductDetail';
    CommerceDataLayerEvents.addToCart = 'CommerceDataLayerEventAddToCart';
    CommerceDataLayerEvents.removeFromCart = 'CommerceDataLayerEventRemoveFromCart';
    return CommerceDataLayerEvents;
}());
exports.CommerceDataLayerEvents = CommerceDataLayerEvents;


/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

(function webpackUniversalModuleDefinition(root, factory) {
	if(true)
		module.exports = factory(__webpack_require__(0));
	else {}
})(window, function(__WEBPACK_EXTERNAL_MODULE__1__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 2);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.component = void 0;
var coveo_search_ui_1 = __webpack_require__(1);
function component(constructor) {
    coveo_search_ui_1.Initialization.registerAutoCreateComponent(constructor);
    return constructor;
}
exports.component = component;


/***/ }),
/* 1 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE__1__;

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(3);


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(4), exports);
__exportStar(__webpack_require__(6), exports);


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(0), exports);
__exportStar(__webpack_require__(5), exports);


/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.lazyComponent = exports.lazyDependentComponent = void 0;
var coveo_search_ui_1 = __webpack_require__(1);
var component_1 = __webpack_require__(0);
function lazyDependentComponent(dependentComponentId) {
    return function (constructor) {
        if (!coveo_search_ui_1.LazyInitialization) {
            return component_1.component(constructor);
        }
        coveo_search_ui_1.LazyInitialization.registerLazyComponent(constructor.ID, function () {
            return coveo_search_ui_1.load(dependentComponentId).then(function () { return component_1.component(constructor); });
        });
        return constructor;
    };
}
exports.lazyDependentComponent = lazyDependentComponent;
function lazyComponent(constructor) {
    if (!coveo_search_ui_1.LazyInitialization) {
        return component_1.component(constructor);
    }
    coveo_search_ui_1.LazyInitialization.registerLazyComponent(constructor.ID, component_1.component(constructor));
    return constructor;
}
exports.lazyComponent = lazyComponent;


/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(7), exports);


/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

// Webpack output a library target with a temporary name.
// It does not take care of merging the namespace if the global variable already exists.
// If another piece of code in the page use the Coveo namespace (eg: extension), then they get overwritten
// This code swap the current module to the "real" Coveo variable, without overwriting the whole global var.
// This is to allow end user to put CoveoPSComponents.js before or after the main CoveoJsSearch.js, without breaking
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.swapVar = void 0;
function swapVar(scope) {
    if (!window['Coveo']) {
        window['Coveo'] = scope;
        return;
    }
    window['Coveo'] = __assign(__assign({}, scope), window['Coveo']);
}
exports.swapVar = swapVar;


/***/ })
/******/ ]);
});

/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(4);


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(5), exports);
__exportStar(__webpack_require__(1), exports);
var turbo_core_1 = __webpack_require__(2);
turbo_core_1.swapVar(this);


/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CommerceDataLayer = void 0;
var coveo_search_ui_1 = __webpack_require__(0);
var CommerceDataLayerEvents_1 = __webpack_require__(1);
var turbo_core_1 = __webpack_require__(2);
var CommerceDataLayer = /** @class */ (function (_super) {
    __extends(CommerceDataLayer, _super);
    function CommerceDataLayer(element, options, bindings) {
        var _this = _super.call(this, element, CommerceDataLayer_1.ID, bindings) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        _this.displayedProducts = [];
        _this.options = coveo_search_ui_1.ComponentOptions.initComponentOptions(element, CommerceDataLayer_1, options);
        if (typeof _this.options.productFormatter == "function") {
            // Ensure that we have a valid dataLayer
            var uaComponent = Coveo.get(document.querySelector(".CoveoAnalytics"), Coveo.Analytics);
            window[uaComponent.options.gtmDataLayerName] = window[uaComponent.options.gtmDataLayerName] || [];
            // Query Success
            _this.bind.onRootElement(coveo_search_ui_1.QueryEvents.querySuccess, function (args) { return _this.handleQuerySuccess(args); });
            // Analytics Events
            _this.bind.onRootElement(coveo_search_ui_1.AnalyticsEvents.changeAnalyticsCustomData, function (args) {
                return _this.handleChangeAnalyticsCustomData(args);
            });
            // ResultList Events
            _this.bind.onRootElement(coveo_search_ui_1.ResultListEvents.newResultDisplayed, function (args) {
                return _this.handleNewResultDisplayed(args);
            });
            _this.bind.onRootElement(coveo_search_ui_1.ResultListEvents.newResultsDisplayed, function () {
                return _this.handleNewResultsDisplayed();
            });
            // Commerce Data Layer Events
            _this.bind.onRootElement(CommerceDataLayerEvents_1.CommerceDataLayerEvents.productClick, function (args) { return _this.handleProductClick(args); });
            _this.bind.onRootElement(CommerceDataLayerEvents_1.CommerceDataLayerEvents.productDetail, function (args) { return _this.handleProductDetail(args); });
            _this.bind.onRootElement(CommerceDataLayerEvents_1.CommerceDataLayerEvents.addToCart, function (args) { return _this.handleAddToCart(args); });
            _this.bind.onRootElement(CommerceDataLayerEvents_1.CommerceDataLayerEvents.removeFromCart, function (args) { return _this.handleRemoveFromCart(args); });
        }
        else {
            _this.logger.error("Missing valid function for productFormatter option.");
        }
        return _this;
    }
    CommerceDataLayer_1 = CommerceDataLayer;
    CommerceDataLayer.prototype.pushToDataLayer = function (commerceActivity) {
        try {
            // var uaComponent: Coveo.Analytics = <Coveo.Analytics>Coveo.get(
            //   document.querySelector(".CoveoAnalytics"),
            //   Coveo.Analytics
            // );
            var uaComponent = Coveo.get(document.querySelector(".CoveoAnalytics"), Coveo.Analytics);
            if (uaComponent) {
                this.logger.info("pushToDataLayer", commerceActivity);
                uaComponent.pushToGtmDataLayer(commerceActivity);
            }
        }
        catch (error) {
            this.logger.error("Cannot push to dataLayer.");
        }
    };
    /**
     * Query Success
     */
    CommerceDataLayer.prototype.handleQuerySuccess = function (args) {
        this.searchUid = args.results.searchUid;
    };
    /**
     * Change Analytics Custom Data
     */
    CommerceDataLayer.prototype.handleChangeAnalyticsCustomData = function (args) {
        if (args.type === "ClickEvent") {
            var product = this.options.productFormatter(args["resultData"]);
            this.pushToDataLayer({
                event: "productClick",
                ecommerce: {
                    click: {
                        actionField: { list: "coveo:search:" + this.searchUid },
                        products: [product],
                    },
                },
                eventCallback: function () {
                    // document.location = product.url;
                },
            });
        }
    };
    CommerceDataLayer.prototype.handleNewResultDisplayed = function (args) {
        var product = this.options.productFormatter(args.result);
        product.list = "coveo:search:" + this.searchUid;
        this.displayedProducts.push(product);
    };
    CommerceDataLayer.prototype.handleNewResultsDisplayed = function () {
        this.pushToDataLayer({
            // coveoSearchUid: this.searchUid,
            ecommerce: {
                impressions: this.displayedProducts,
            },
        });
    };
    CommerceDataLayer.prototype.handleProductClick = function (args) {
        var product = this.options.productFormatter(args);
        this.pushToDataLayer({
            event: "productClick",
            ecommerce: {
                click: {
                    actionField: { list: "coveo:search:" + this.searchUid },
                    products: [product],
                },
            },
            eventCallback: function () {
                // document.location = args.url
            },
        });
    };
    CommerceDataLayer.prototype.handleProductDetail = function (args) {
        var product = this.options.productFormatter(args);
        this.pushToDataLayer({
            coveoSearchUid: this.searchUid,
            ecommerce: {
                detail: {
                    actionField: { list: "coveo:search:" + this.searchUid },
                    products: [product],
                },
            },
        });
    };
    // Adding a Product to a Shopping Cart
    CommerceDataLayer.prototype.handleAddToCart = function (args) {
        var product = this.options.productFormatter(args);
        this.pushToDataLayer({
            event: "addToCart",
            ecommerce: {
                add: {
                    actionField: { list: "coveo:search:" + this.searchUid },
                    products: [product],
                },
            },
        });
    };
    CommerceDataLayer.prototype.handleRemoveFromCart = function (args) {
        var product = this.options.productFormatter(args);
        this.pushToDataLayer({
            event: "removeFromCart",
            coveoSearchUid: this.searchUid,
            ecommerce: {
                remove: {
                    actionField: { list: "coveo:search:" + this.searchUid },
                    products: [product],
                },
            },
        });
    };
    var CommerceDataLayer_1;
    CommerceDataLayer.ID = "CommerceDataLayer";
    CommerceDataLayer.options = {
        productFormatter: coveo_search_ui_1.ComponentOptions.buildCustomOption(function (_a) { return null; }),
    };
    CommerceDataLayer = CommerceDataLayer_1 = __decorate([
        turbo_core_1.lazyComponent
    ], CommerceDataLayer);
    return CommerceDataLayer;
}(coveo_search_ui_1.Component));
exports.CommerceDataLayer = CommerceDataLayer;


/***/ })
/******/ ]);
});

/***/ }),
/* 4 */,
/* 5 */,
/* 6 */,
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

function __export(m) {
    for (var p in m) if (!exports.hasOwnProperty(p)) exports[p] = m[p];
}
Object.defineProperty(exports, "__esModule", { value: true });
__export(__webpack_require__(8));
// your custo component
__export(__webpack_require__(13));
__export(__webpack_require__(14));
// your ui components here
var Price_1 = __webpack_require__(15);
exports.Price = Price_1.Price;
var AddToCart_1 = __webpack_require__(16);
exports.AddToCart = AddToCart_1.AddToCart;
var LastPurchasedDate_1 = __webpack_require__(17);
exports.LastPurchasedDate = LastPurchasedDate_1.LastPurchasedDate;
var CCResultList_1 = __webpack_require__(18);
exports.CCResultList = CCResultList_1.CCResultList;
var IndirectStreetBrandBanner_1 = __webpack_require__(19);
exports.IndirectStreetBrandBanner = IndirectStreetBrandBanner_1.IndirectStreetBrandBanner;
// export { GTM } from './ui/GTM/GTM';
__export(__webpack_require__(20));
__export(__webpack_require__(21));
__export(__webpack_require__(22));
__export(__webpack_require__(3));
var SwapVar_1 = __webpack_require__(23);
SwapVar_1.swapVar(this);
var CoveoCustomScripts_1 = __webpack_require__(24);
CoveoCustomScripts_1.setCoveoCustomScripts();
// your culture files here (for webpack)
__webpack_require__(25);
__webpack_require__(26);
__webpack_require__(27);


/***/ }),
/* 8 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
__webpack_require__(9);
var UrlUtils_1 = __webpack_require__(10);
exports.UrlUtils = UrlUtils_1.UrlUtils;
var HttpUtils_1 = __webpack_require__(11);
exports.HttpUtils = HttpUtils_1.HttpUtils;
// export { CustomEvents } from './ui/PriceManager/PriceManagerEvents';
var EcolabHelper_1 = __webpack_require__(12);
exports.EcolabHelper = EcolabHelper_1.EcolabHelper;


/***/ }),
/* 9 */
/***/ (function(module, exports) {

String.prototype.getInitials = function (glue) {
    if (glue === void 0) { glue = true; }
    var initials = this.replace(/[^a-zA-Z- ]/g, '').match(/\b\w/g) || [];
    if (glue) {
        return initials.join('');
    }
    return initials;
};
String.prototype.capitalize = function () {
    return this.toLowerCase().replace(/\b\w/g, function (m) {
        return m.toUpperCase();
    });
};
/**
* Camelize a string, cutting the string by multiple separators like
* hyphens, underscores and spaces.
*
* @return string Camelized text
*/
String.prototype.camelize = function () {
    return this.replace(/^([A-Z])|[\s-_]+(\w)/g, function (match, p1, p2, offset) {
        if (p2)
            return p2.toUpperCase();
        return p1.toLowerCase();
    });
};
/**
 * Decamelizes a string with/without a custom separator (underscore by default).
 *
 * @param str String in camelcase
 * @param separator Separator for the new decamelized string.
 */
String.prototype.decamelize = function (separator) {
    separator = typeof separator === 'undefined' ? '_' : separator;
    return this
        .replace(/([a-z\d])([A-Z])/g, '$1' + separator + '$2')
        .replace(/([A-Z]+)([A-Z][a-z\d]+)/g, '$1' + separator + '$2')
        .toLowerCase();
};


/***/ }),
/* 10 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var UrlUtils = /** @class */ (function () {
    function UrlUtils() {
    }
    UrlUtils.getUrlParams = function (query) {
        if (!query) {
            return {};
        }
        var parser = document.createElement('a');
        var search = '';
        parser.href = query;
        var hash = parser.hash.substring(1);
        if (hash) {
            var hashParser = document.createElement('a');
            hashParser.href = hash;
            search = hashParser.search.substring(1);
        }
        else {
            search = parser.search.substring(1);
        }
        search = search || query;
        return (/^[?#]/.test(search) ? search.slice(1) : search)
            .split('&')
            .reduce(function (params, param) {
            var _a = param.split('='), key = _a[0], value = _a[1];
            params[key] = value ? decodeURIComponent(value.replace(/\+/g, ' ')) : '';
            return params;
        }, {});
    };
    UrlUtils.getLocationFromUri = function (query) {
        if (!query) {
            return {};
        }
        var anchor = document.createElement('a');
        anchor.href = query;
        var retVal = {
            href: anchor.href,
            pathname: anchor.pathname,
            hostname: anchor.hostname,
            host: anchor.host,
            search: anchor.search,
            protocol: anchor.protocol,
            hash: anchor.hash
        };
        return retVal;
    };
    return UrlUtils;
}());
exports.UrlUtils = UrlUtils;
;


/***/ }),
/* 11 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var HttpUtils = /** @class */ (function () {
    function HttpUtils() {
    }
    HttpUtils.get = function (aUrl, aCallback) {
        var anHttpRequest = new XMLHttpRequest();
        anHttpRequest.onreadystatechange = function () {
            if (anHttpRequest.readyState == 4 && anHttpRequest.status == 200)
                aCallback(anHttpRequest.responseText);
        };
        anHttpRequest.open("GET", aUrl, true);
        anHttpRequest.send(null);
    };
    return HttpUtils;
}());
exports.HttpUtils = HttpUtils;


/***/ }),
/* 12 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var EcolabHelper = /** @class */ (function () {
    function EcolabHelper() {
    }
    EcolabHelper.yourHelperMethod = function () {
        return '';
    };
    return EcolabHelper;
}());
exports.EcolabHelper = EcolabHelper;


/***/ }),
/* 13 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
var Component = Coveo.Component;
var Initialization = Coveo.Initialization;
var ComponentOptions = Coveo.ComponentOptions;
/**
 * Required customization specifically applied for your implementation
 */
var EcolabCusto = /** @class */ (function (_super) {
    __extends(EcolabCusto, _super);
    function EcolabCusto(element, options, bindings) {
        var _this = _super.call(this, element, EcolabCusto.ID, bindings) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        _this.options = ComponentOptions.initComponentOptions(element, EcolabCusto, options);
        _this.setupPipelineContext(_this.options.pipelineContext);
        _this.bind.onRootElement(Coveo.QueryEvents.buildingQuery, _this.handleBuildingQuery);
        _this.bind.onRootElement(Coveo.InitializationEvents.afterInitialization, _this.handleAfterInit);
        _this.bind.onRootElement(Coveo.QueryEvents.deferredQuerySuccess, _this.handleDeferredQuerySuccess);
        return _this;
    }
    EcolabCusto.prototype.handleDeferredQuerySuccess = function (args) {
        // Hide some components from page header on no results page
        var resultsColEl = document.querySelector('.coveo-results-column');
        var headerSection = document.querySelector('.coveo-results-header');
        if (resultsColEl &&
            headerSection &&
            Coveo.$$(resultsColEl).hasClass('coveo-no-results') == false &&
            Coveo.$$(headerSection).hasClass('coveo-no-results') == false &&
            args.results.totalCount == 0) {
            Coveo.$$(resultsColEl).addClass('coveo-no-results');
            Coveo.$$(headerSection).addClass('coveo-no-results');
        }
        //Hide Facet header if no facets are active
        var facetHeaderSection = document.querySelector('.coveo-facet-header-section');
        var dynamicFacets = document.querySelector('.CoveoDynamicFacet:not(.coveo-hidden)');
        if (facetHeaderSection && dynamicFacets) {
            Coveo.$$(facetHeaderSection).removeClass('coveo-hidden');
        }
        else if (facetHeaderSection) {
            Coveo.$$(facetHeaderSection).addClass('coveo-hidden');
        }
    };
    EcolabCusto.prototype.handleAfterInit = function () {
        var _a;
        //loading all CCRZ labels in Coveo dictionnary
        //TO-DO: move this logic to culture file? 
        if (CCRZ.pagevars.pageLabels) {
            String.toLocaleString((_a = {},
                _a['en'] = CCRZ.pagevars.pageLabels,
                _a));
        }
    };
    EcolabCusto.prototype.setupPipelineContext = function (data) {
        this.context = _.pick(data, _.identity) || {};
    };
    EcolabCusto.prototype.getPipelineContext = function () {
        return this.context;
    };
    EcolabCusto.prototype.handleBuildingQuery = function (data) {
        data.queryBuilder.addContext(this.context);
    };
    EcolabCusto.ID = 'EcolabCusto';
    EcolabCusto.options = {
        pipelineContext: Coveo.ComponentOptions.buildJsonOption()
    };
    return EcolabCusto;
}(Component));
exports.EcolabCusto = EcolabCusto;
;
Initialization.registerAutoCreateComponent(EcolabCusto);


/***/ }),
/* 14 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var EcolabCommerceProduct = /** @class */ (function () {
    function EcolabCommerceProduct() {
    }
    EcolabCommerceProduct.getFormattedProduct = function (data) {
        var productMeta = {
            id: undefined,
            name: undefined,
            price: undefined,
        };
        try {
            var raw = data.raw;
            // Id
            productMeta.id = raw['sfccrz__sku__c'];
            // Name
            productMeta.name = data['title'];
            // Price
            productMeta.price = raw['price'];
        }
        catch (error) { }
        return productMeta;
    };
    return EcolabCommerceProduct;
}());
exports.EcolabCommerceProduct = EcolabCommerceProduct;


/***/ }),
/* 15 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
var coveo_search_ui_1 = __webpack_require__(0);
// const fields = [
//   '@sfid'
// ];
var Price = /** @class */ (function (_super) {
    __extends(Price, _super);
    function Price(element, options, bindings, result) {
        var _this = _super.call(this, element, Price.ID, bindings) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        _this.result = result;
        _this.options = coveo_search_ui_1.ComponentOptions.initComponentOptions(element, Price, options);
        ///this.bind.oneRootElement(PriceListManagerEvents.priceListSuccess, this.handlePriceListSuccess);
        _this.result = result;
        var price = Coveo.Utils.getFieldValue(_this.result, _this.options.field);
        if (price) {
            _this.displayPrice(price);
        }
        return _this;
    }
    Price.prototype.displayPrice = function (price) {
        this.clearElement();
        var formattedPrice = this.formatPrice(price);
        var num = coveo_search_ui_1.$$('span', { className: 'price-wrap-num' }, formattedPrice.split('.')[0]);
        var dec = coveo_search_ui_1.$$('span', { className: 'price-wrap-dec' }, '.' + formattedPrice.split('.')[1]);
        var wrap = coveo_search_ui_1.$$('span', { className: 'price-wrap' });
        wrap.el.appendChild(num.el);
        wrap.el.appendChild(dec.el);
        this.element.appendChild(wrap.el);
    };
    Price.prototype.formatPrice = function (price) {
        if (price) {
            return "" + Coveo.CurrencyUtils.currencyToString(price, { decimals: 2 });
        }
        else {
            return '';
        }
    };
    Price.prototype.clearElement = function () {
        this.element.innerHTML = '';
    };
    Price.ID = 'Price';
    Price.options = {
        field: coveo_search_ui_1.ComponentOptions.buildFieldOption({ defaultValue: '@price' })
    };
    return Price;
}(coveo_search_ui_1.Component));
exports.Price = Price;
coveo_search_ui_1.Initialization.registerAutoCreateComponent(Price);


/***/ }),
/* 16 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
var coveo_search_ui_1 = __webpack_require__(0);
//   import { CustomEvents, IUdpateInventoryArgs } from '../../events/CustomEvents';
var commerce_data_layer_1 = __webpack_require__(3);
/**
 * This component renders an "Add To Cart" button
 *
 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
 *
 * @export
 * @class AddToCart
 * @extends {Component}
 * @implements {IComponentBindings}
 */
var AddToCart = /** @class */ (function (_super) {
    __extends(AddToCart, _super);
    /**
     * Creates a new `AddToCart` component.
     * @param element The HTMLElement on which to instantiate the component.
     * @param options The options for the `AddToCart` component.
     * @param bindings The bindings that the component requires to function normally. If not set, these will be
     * automatically resolved (with a slower execution time).
     * @param result The result to associate the component with.
     */
    function AddToCart(element, options, bindings, result) {
        var _this = _super.call(this, element, AddToCart.ID, bindings) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        _this.result = result;
        _this.count = 1;
        _this.options = coveo_search_ui_1.ComponentOptions.initComponentOptions(element, AddToCart, options);
        _this.bind.onRootElement(coveo_search_ui_1.QueryEvents.querySuccess, function (data) { return _this.handleQuerySuccess(data); });
        _this.build();
        return _this;
    }
    AddToCart.prototype.clearElement = function () {
        this.element.innerHTML = "";
    };
    AddToCart.prototype.build = function () {
        if (Coveo.Utils.getFieldValue(this.result, this.options.isVisibleField)) {
            if (this.options.isQtyPickerVisible) {
                this.element.appendChild(this.buildIncrementorButtons());
            }
            if (this.options.isUnitOfMeasureVisible) {
                this.element.appendChild(this.buildUnitOfMeasure());
            }
            this.element.appendChild(this.buildAddToCartButton());
        }
    };
    AddToCart.prototype.buildAddToCartButton = function () {
        var _this = this;
        var button = coveo_search_ui_1.$$("button", {
            role: "button",
            tabindex: 0,
            className: "add-to-cart-button btn btn-default",
        }, coveo_search_ui_1.l(this.options.caption));
        button.on("click", function () { return _this.handleClick(); });
        return button.el;
    };
    AddToCart.prototype.buildIncrementorButtons = function () {
        var _this = this;
        var decrementorWrapper = coveo_search_ui_1.$$("span", {
            class: "input-group-btn cust-min cc_input_group_btn",
        });
        var decrementor = coveo_search_ui_1.$$("button", {
            role: "button",
            className: "decrement-icon btn btn-default custom-minus cc_minus material-icons remove",
        });
        decrementorWrapper.append(decrementor.el);
        var incrementorWrapper = coveo_search_ui_1.$$("span", {
            class: "input-group-btn cc_input_group_btn pluswidth minus-wrapper",
        });
        var incrementor = coveo_search_ui_1.$$("button", {
            role: "button",
            className: "increment-icon btn btn-default plus pludisbtn plus-width cc_plus material-icons add",
        });
        decrementor.on("click", function () { return _this.decreaseCount(); });
        incrementor.on("click", function () { return _this.increaseCount(); });
        var element = coveo_search_ui_1.$$("div", {
            className: "add-to-cart-increments fa-pull-left plp-quan-block input-group input-group-sm cc_input_group form-group",
        });
        element.addClass("in-cart");
        var inputNumber = coveo_search_ui_1.$$("input", {
            type: "text",
            value: "1",
            maxlength: "7",
            min: "1",
            max: "9999999",
            className: "current-qty plp-input plpinpdis qty qty entry cc_entry form-control",
        }, this.getQuantity().toString());
        var that = this;
        [
            "input",
            "keydown",
            "keyup",
            "mousedown",
            "mouseup",
            "select",
            "contextmenu",
            "drop",
        ].forEach(function (event) {
            inputNumber.on(event, function (evt) { return that.validateKey(evt); });
        });
        decrementorWrapper.append(decrementor.el);
        element.append(decrementorWrapper.el);
        element.append(inputNumber.el);
        incrementorWrapper.append(incrementor.el);
        element.append(incrementorWrapper.el);
        return element.el;
    };
    AddToCart.prototype.buildUnitOfMeasure = function () {
        var unitOfMeasure = Coveo.Utils.getFieldValue(this.result, this.options.unitOfMeasureField);
        var element = coveo_search_ui_1.$$("span", { className: "nalco-uom" }, unitOfMeasure);
        return element.el;
    };
    AddToCart.prototype.logAddToCartEvent = function () {
        Coveo.$$(this.root).trigger(commerce_data_layer_1.CommerceDataLayerEvents.addToCart, this.result);
    };
    AddToCart.prototype.getQuantity = function () {
        return this.count;
    };
    AddToCart.prototype.increaseCount = function () {
        this.count++;
        this.updateCountAppearance();
    };
    AddToCart.prototype.decreaseCount = function () {
        if (this.count > 1) {
            this.count--;
        }
        else {
            this.count = 1;
        }
        this.updateCountAppearance();
    };
    AddToCart.prototype.updateCountAppearance = function () {
        this.ensureDom();
        var currentQty = (this.element.querySelector(".current-qty"));
        currentQty.value = this.count.toString();
    };
    AddToCart.prototype.getAddToCartPayload = function () {
        var sku = Coveo.Utils.getFieldValue(this.result, this.options.skuField);
        var qty = this.getQuantity();
        return [sku, qty];
    };
    AddToCart.prototype.handleClick = function () {
        var _this = this;
        this.logAddToCartEvent();
        var _a = this.getAddToCartPayload(), sku = _a[0], qty = _a[1];
        this.enableAnimation();
        if (sku && qty) {
            this.options
                .addToCartRemoteAction(sku, qty)
                .then(function (data) {
                _this.handleAddToCartSuccess(data);
            })
                .catch(function (err) { return _this.handleAddToCartError(err); });
        }
    };
    AddToCart.prototype.handleAddToCartError = function (err) {
        this.logger.error("Unable to add to cart", err);
        this.disableAnimation();
    };
    AddToCart.prototype.handleAddToCartSuccess = function (data) {
        if (data && data.success) {
            // TODO: do not depend on that!
            this.ensureDom();
            this.element.querySelector(".add-to-cart-button").textContent = this.options.caption;
        }
        else {
            this.logger.error("Unable to add item to cart", data);
        }
        this.disableAnimation();
    };
    AddToCart.prototype.validateKey = function (evt) {
        // debugger;
        var inputFilter = function (value) {
            return /(^$|^[1-9]\d*$)/.test(value); // Allow digits and '.' only, using a RegExp
        };
        if (inputFilter(evt.currentTarget.value)) {
            evt.currentTarget.oldValue = evt.currentTarget.value;
        }
        else if (evt.currentTarget.hasOwnProperty("oldValue")) {
            evt.currentTarget.value = evt.currentTarget.oldValue;
        }
        else {
            evt.currentTarget.value = "";
        }
        this.count = evt.currentTarget.value;
        this.updateCountAppearance();
    };
    AddToCart.prototype.enableAnimation = function () {
        // this.resetButtonHtml();
        this.ensureDom();
        coveo_search_ui_1.$$(document.body).append(coveo_search_ui_1.$$("div", { id: "overlay", class: "modal-backdrop fade in" }).el);
    };
    AddToCart.prototype.disableAnimation = function () {
        // this.resetButtonHtml();
        document.getElementById("overlay").remove();
    };
    AddToCart.prototype.handleQuerySuccess = function (args) {
        this.checkIfProductIsInCart(this.result);
    };
    AddToCart.prototype.checkIfProductIsInCart = function (product) {
        // TODO: implement this method
        // this.option.getCartContentRemoteAction()...
    };
    AddToCart.ID = "AddToCart";
    AddToCart.options = {
        /**
         * Text value for the AddToCart button
         *
         */
        skuField: coveo_search_ui_1.ComponentOptions.buildFieldOption({
            defaultValue: "@sfccrz__sku__c",
        }),
        isVisibleField: coveo_search_ui_1.ComponentOptions.buildFieldOption({
            defaultValue: "@isaddtocartshow",
        }),
        caption: coveo_search_ui_1.ComponentOptions.buildStringOption({
            defaultValue: "Add To Cart",
        }),
        addToCartRemoteAction: coveo_search_ui_1.ComponentOptions.buildCustomOption(function () {
            return null;
        }),
        isQtyPickerVisible: coveo_search_ui_1.ComponentOptions.buildBooleanOption({
            defaultValue: false,
        }),
        isUnitOfMeasureVisible: coveo_search_ui_1.ComponentOptions.buildBooleanOption({
            defaultValue: false,
        }),
        unitOfMeasureField: coveo_search_ui_1.ComponentOptions.buildFieldOption({
            defaultValue: "@sfccrz__unitofmeasure__c",
        }),
    };
    return AddToCart;
}(coveo_search_ui_1.Component));
exports.AddToCart = AddToCart;
coveo_search_ui_1.Initialization.registerAutoCreateComponent(AddToCart);


/***/ }),
/* 17 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
var coveo_search_ui_1 = __webpack_require__(0);
var LastPurchasedDate = /** @class */ (function (_super) {
    __extends(LastPurchasedDate, _super);
    /**
     * Creates a new `LastPurchasedDate` component.
     * @param element The HTMLElement on which to instantiate the component.
     * @param options The options for the `ResultList` component.
     * @param bindings The bindings that the component requires to function normally. If not set, these will be
     * automatically resolved (with a slower execution time).
     */
    function LastPurchasedDate(element, options, bindings, result) {
        var _this = _super.call(this, element, LastPurchasedDate.ID, bindings) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        _this.result = result;
        _this.options = coveo_search_ui_1.ComponentOptions.initComponentOptions(element, LastPurchasedDate, options);
        // this.bind.oneRootElement(PriceListManagerEvents.priceListSuccess, this.handlePriceListSuccess);
        _this.result = result;
        var price = Coveo.Utils.getFieldValue(_this.result, _this.options.field);
        if (price) {
            _this.displayDate(price);
        }
        return _this;
    }
    // private handlePriceListSuccess(args: IPriceListSuccessArgs) {
    //     if (this.result.raw.sfid) {
    //         const LastPurchasedDate = this.getAttribureFromPriceLists(args.priceLists,this.result.raw.sfid, 'lastPurchaseDate');
    //         if (LastPurchasedDate) {
    //             this.displayDate(LastPurchasedDate);
    //         }
    //     }
    // }
    LastPurchasedDate.prototype.displayDate = function (lastPurchasedDate) {
        this.clearElement();
        var formattedDate = this.formatDate(lastPurchasedDate);
        var caption = coveo_search_ui_1.$$('span', { className: 'purchased-on-label' }, this.options.caption);
        var dateEl = coveo_search_ui_1.$$('span', { className: 'purchased-on' }, formattedDate);
        var wrap = coveo_search_ui_1.$$('span', { className: 'purchased-productSection' });
        wrap.el.appendChild(caption.el);
        wrap.el.appendChild(dateEl.el);
        this.element.appendChild(wrap.el);
    };
    LastPurchasedDate.prototype.formatDate = function (lastPurchasedDate) {
        // copied from Ecolab Helper 
        var d = new Date(lastPurchasedDate);
        var m = d.getMonth();
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        var monthName = months[m - 1 + 1];
        var day = d.getDate();
        var y = d.getFullYear();
        var fulldate = monthName + " " + day + ", " + y;
        return (fulldate);
    };
    LastPurchasedDate.prototype.clearElement = function () {
        this.element.innerHTML = '';
    };
    LastPurchasedDate.ID = 'LastPurchasedDate';
    LastPurchasedDate.options = {
        caption: coveo_search_ui_1.ComponentOptions.buildStringOption({ defaultValue: 'Purchased On ' }),
        field: coveo_search_ui_1.ComponentOptions.buildFieldOption({ defaultValue: '@lastpurchasedate' })
    };
    return LastPurchasedDate;
}(coveo_search_ui_1.Component));
exports.LastPurchasedDate = LastPurchasedDate;
coveo_search_ui_1.Initialization.registerAutoCreateComponent(LastPurchasedDate);


/***/ }),
/* 18 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
var coveo_search_ui_1 = __webpack_require__(0);
var fields = [
    '@sfid'
];
var CCResultList = /** @class */ (function (_super) {
    __extends(CCResultList, _super);
    /**
     * Creates a new `CCResultList` component.
     * @param element The HTMLElement on which to instantiate the component.
     * @param options The options for the `ResultList` component.
     * @param bindings The bindings that the component requires to function normally. If not set, these will be
     * automatically resolved (with a slower execution time).
     */
    function CCResultList(element, options, bindings) {
        var _this = _super.call(this, element, coveo_search_ui_1.ComponentOptions.initComponentOptions(element, CCResultList, options), bindings, CCResultList.ID) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        return _this;
    }
    CCResultList.prototype.getProductPayload = function (results) {
        var field = 'sfid';
        if (results.length > 0) {
            return results
                .filter(function (result) { return result.raw && result.raw[field]; })
                .map(function (result) { return result.raw.sfid; });
        }
        return [];
    };
    CCResultList.prototype.enableAnimation = function () {
        if (!document.getElementById('overlay')) {
            coveo_search_ui_1.$$(document.body).append(coveo_search_ui_1.$$('div', { id: 'overlay', class: 'modal-backdrop fade in' }).el);
        }
    };
    CCResultList.prototype.disableAnimation = function () {
        if (document.getElementById('overlay')) {
            document.getElementById('overlay').remove();
        }
    };
    CCResultList.prototype.renderResults = function (resultElements, append) {
        if (append === void 0) { append = false; }
        var res = _super.prototype.renderResults.call(this, resultElements, append);
        this.disableAnimation();
        return res;
    };
    CCResultList.prototype.buildResults = function (results) {
        return __awaiter(this, void 0, void 0, function () {
            var remoteResults, ret;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        this.enableAnimation();
                        return [4 /*yield*/, this.options.productRemoteAction(this.getProductPayload(results.results))
                                .then(function (data) {
                                return data;
                            }).catch(function (ex) {
                                console.log('Unable to fetch CCRZ Products');
                                return null;
                            })];
                    case 1:
                        remoteResults = _a.sent();
                        if (remoteResults && remoteResults.data) {
                            //Merge remote action results with Coveo Results
                            _.each(results.results, function (res) {
                                var match = _.findWhere(remoteResults.data.products, { sfid: res.raw['sfid'] });
                                for (var prob in match) {
                                    res.raw[prob.toLowerCase()] = match[prob];
                                }
                            });
                        }
                        ret = _super.prototype.buildResults.call(this, results);
                        return [2 /*return*/, ret];
                }
            });
        });
    };
    CCResultList.ID = 'CCResultList';
    CCResultList.options = {
        productRemoteAction: coveo_search_ui_1.ComponentOptions.buildCustomOption(function () {
            return null;
        }),
    };
    return CCResultList;
}(Coveo.ResultList));
exports.CCResultList = CCResultList;
coveo_search_ui_1.Initialization.registerAutoCreateComponent(CCResultList);
coveo_search_ui_1.Initialization.registerComponentFields(CCResultList.ID, fields);


/***/ }),
/* 19 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
var coveo_search_ui_1 = __webpack_require__(0);
var INDIRECT_STREET_BRAND_ROOT_CLASS = 'coveo-is-indirect-street-brand';
var INDIRECT_STREET_BRAND_BANNER_CLASS = 'coveo-indirect-street-brand-banner';
var IndirectStreetBrandBanner = /** @class */ (function (_super) {
    __extends(IndirectStreetBrandBanner, _super);
    /**
     * Creates a new `IndirectStreetBrandBanner` component.
     * @param element The HTMLElement on which to instantiate the component.
     * @param options The options for the `ResultList` component.
     * @param bindings The bindings that the component requires to function normally. If not set, these will be
     * automatically resolved (with a slower execution time).
     */
    function IndirectStreetBrandBanner(element, options, bindings) {
        var _this = _super.call(this, element, IndirectStreetBrandBanner.ID, bindings) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        _this.options = coveo_search_ui_1.ComponentOptions.initComponentOptions(element, IndirectStreetBrandBanner, options);
        _this.bind.onRootElement(Coveo.InitializationEvents.afterInitialization, _this.handleAfterInit);
        return _this;
    }
    IndirectStreetBrandBanner.prototype.handleAfterInit = function () {
        if (this.options.enable) {
            this.build();
        }
    };
    IndirectStreetBrandBanner.prototype.build = function () {
        var banner = coveo_search_ui_1.$$('div', {
            className: INDIRECT_STREET_BRAND_BANNER_CLASS,
        }, Coveo.l(this.options.caption));
        this.element.appendChild(banner.el);
        this.addIndirectStreetBrandClass();
    };
    IndirectStreetBrandBanner.prototype.addIndirectStreetBrandClass = function () {
        coveo_search_ui_1.$$(this.root).addClass(INDIRECT_STREET_BRAND_ROOT_CLASS);
        var container = document.querySelector('.cc_main_container');
        if (container) {
            coveo_search_ui_1.$$(container).addClass(INDIRECT_STREET_BRAND_ROOT_CLASS);
        }
    };
    IndirectStreetBrandBanner.ID = 'IndirectStreetBrandBanner';
    IndirectStreetBrandBanner.options = {
        caption: coveo_search_ui_1.ComponentOptions.buildLocalizedStringOption({ defaultValue: Coveo.l('Indirect_StreetBrand') }),
        enable: coveo_search_ui_1.ComponentOptions.buildBooleanOption({ defaultValue: false })
    };
    return IndirectStreetBrandBanner;
}(coveo_search_ui_1.Component));
exports.IndirectStreetBrandBanner = IndirectStreetBrandBanner;
coveo_search_ui_1.Initialization.registerAutoCreateComponent(IndirectStreetBrandBanner);


/***/ }),
/* 20 */
/***/ (function(module, exports, __webpack_require__) {

(function webpackUniversalModuleDefinition(root, factory) {
	if(true)
		module.exports = factory(__webpack_require__(0));
	else {}
})(window, function(__WEBPACK_EXTERNAL_MODULE__0__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 2);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE__0__;

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

(function webpackUniversalModuleDefinition(root, factory) {
	if(true)
		module.exports = factory(__webpack_require__(0));
	else {}
})(window, function(__WEBPACK_EXTERNAL_MODULE__1__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 2);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.component = void 0;
var coveo_search_ui_1 = __webpack_require__(1);
function component(constructor) {
    coveo_search_ui_1.Initialization.registerAutoCreateComponent(constructor);
    return constructor;
}
exports.component = component;


/***/ }),
/* 1 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE__1__;

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(3);


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(4), exports);
__exportStar(__webpack_require__(6), exports);


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(0), exports);
__exportStar(__webpack_require__(5), exports);


/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.lazyComponent = exports.lazyDependentComponent = void 0;
var coveo_search_ui_1 = __webpack_require__(1);
var component_1 = __webpack_require__(0);
function lazyDependentComponent(dependentComponentId) {
    return function (constructor) {
        if (!coveo_search_ui_1.LazyInitialization) {
            return component_1.component(constructor);
        }
        coveo_search_ui_1.LazyInitialization.registerLazyComponent(constructor.ID, function () {
            return coveo_search_ui_1.load(dependentComponentId).then(function () { return component_1.component(constructor); });
        });
        return constructor;
    };
}
exports.lazyDependentComponent = lazyDependentComponent;
function lazyComponent(constructor) {
    if (!coveo_search_ui_1.LazyInitialization) {
        return component_1.component(constructor);
    }
    coveo_search_ui_1.LazyInitialization.registerLazyComponent(constructor.ID, component_1.component(constructor));
    return constructor;
}
exports.lazyComponent = lazyComponent;


/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(7), exports);


/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

// Webpack output a library target with a temporary name.
// It does not take care of merging the namespace if the global variable already exists.
// If another piece of code in the page use the Coveo namespace (eg: extension), then they get overwritten
// This code swap the current module to the "real" Coveo variable, without overwriting the whole global var.
// This is to allow end user to put CoveoPSComponents.js before or after the main CoveoJsSearch.js, without breaking
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.swapVar = void 0;
function swapVar(scope) {
    if (!window['Coveo']) {
        window['Coveo'] = scope;
        return;
    }
    window['Coveo'] = __assign(__assign({}, scope), window['Coveo']);
}
exports.swapVar = swapVar;


/***/ })
/******/ ]);
});

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

__webpack_require__(3);
module.exports = __webpack_require__(5);


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(4), exports);
var turbo_core_1 = __webpack_require__(1);
turbo_core_1.swapVar(this);


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ResultsPerPageDropdown = void 0;
var coveo_search_ui_1 = __webpack_require__(0);
var turbo_core_1 = __webpack_require__(1);
/**
* The `ResultsPerPageDropdown` component renders a dropdown that the end user can interact with to select the criteria to to choose how many results to
* display per page.
*
* **Note:** Adding a ResultsPerPageDropdown component to your page overrides the value of
* {@link SearchInterface.options.resultsPerPage}.
*/
var ResultsPerPageDropdown = /** @class */ (function (_super) {
    __extends(ResultsPerPageDropdown, _super);
    function ResultsPerPageDropdown(element, options, bindings) {
        var _this = _super.call(this, element, ResultsPerPageDropdown_1.ID, bindings) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        _this.options = coveo_search_ui_1.ComponentOptions.initComponentOptions(element, ResultsPerPageDropdown_1, options);
        _this.bind.onRootElement(coveo_search_ui_1.InitializationEvents.afterComponentsInitialization, function () {
        });
        _this.bind.onQueryState(coveo_search_ui_1.QueryStateModel.eventTypes.changeOne, coveo_search_ui_1.QueryStateModel.attributesEnum.numberOfResults, _this.handleNumberOfResultsChanged);
        _this.select = _this.getSelectElement();
        coveo_search_ui_1.$$(_this.select).addClass('coveo-custom-select-hidden');
        var resultsPerPageDom = coveo_search_ui_1.$$('div');
        _this.element.appendChild(resultsPerPageDom.el);
        var resultsPerPageOption = {
            initialChoice: _this.options.initialChoice,
            choicesDisplayed: _this.options.choicesDisplayed
        };
        var promiseResultsPerPage = new Promise(function (resolve, reject) {
            if (coveo_search_ui_1.LazyInitialization) {
                coveo_search_ui_1.load('ResultsPerPage').then(function (ResultsPerPage) {
                    resolve(new ResultsPerPage(resultsPerPageDom.el, resultsPerPageOption, bindings));
                });
            }
            else {
                resolve(new coveo_search_ui_1.ResultsPerPage(resultsPerPageDom.el, resultsPerPageOption, bindings));
            }
        });
        _this.buildSelectStyled();
        promiseResultsPerPage.then(function (component) {
            _this.resultsPerPage = component;
            _this.resultsPerPage.disable();
            coveo_search_ui_1.$$(_this.resultsPerPage.element).hide();
            _this.renderSelectStyled();
            _this.selectOptionAction(_this.getSelectedOption());
        });
        return _this;
    }
    ResultsPerPageDropdown_1 = ResultsPerPageDropdown;
    ResultsPerPageDropdown.prototype.handleNumberOfResultsChanged = function (args) {
        if (this.getSelectedOption() != args.value.toString()) {
            this.updateSelectedOption(args.value.toString());
        }
    };
    ResultsPerPageDropdown.prototype.getSelectElement = function () {
        var selectEl = (this.element instanceof HTMLSelectElement ? this.element : coveo_search_ui_1.$$(this.element).find('select'));
        if (!selectEl) {
            selectEl = coveo_search_ui_1.$$('select').el;
            this.element.appendChild(selectEl);
        }
        return selectEl;
    };
    ResultsPerPageDropdown.prototype.buildCaptionElement = function () {
        return coveo_search_ui_1.$$('span', { className: 'coveo-resultsperpage-dropdown-caption' }, this.options.caption).el;
    };
    ResultsPerPageDropdown.prototype.buildSelectStyled = function () {
        var _this = this;
        // create wrapper container
        var wrapper = coveo_search_ui_1.$$('div', { className: 'coveo-custom-select' });
        // insert wrapper before select element in the DOM tree
        this.select.parentNode.insertBefore(wrapper.el, this.select);
        // move select into wrapper
        wrapper.append(this.select);
        if (this.options.displayCaption) {
            this.element.insertBefore(this.buildCaptionElement(), wrapper.el);
        }
        this.selectStyled = coveo_search_ui_1.$$('div', { className: 'coveo-custom-select-styled' });
        this.listOptions = coveo_search_ui_1.$$('ul', { className: 'coveo-custom-select-options' });
        wrapper.append(this.selectStyled.el);
        wrapper.append(this.listOptions.el);
        this.renderSelectStyled();
        this.selectStyled.on('click', function (e) {
            e.stopPropagation();
            _this.selectStyled.toggleClass('active');
            _this.listOptions.toggle();
        });
        document.addEventListener('click', function () {
            _this.selectStyled.removeClass('active');
            _this.listOptions.hide();
        });
    };
    ResultsPerPageDropdown.prototype.renderSelectStyled = function () {
        var self = this;
        this.listOptions.empty();
        if (!this.select.options.length) {
            this.buildSelectOptions();
        }
        var current = this.select.options.length ? this.select.options[this.select.selectedIndex].text : '';
        this.selectStyled.text(current);
        var _loop_1 = function () {
            var listItem = coveo_search_ui_1.$$('li', {
                value: this_1.select.options.item(i).value
            }, this_1.select.options.item(i).text);
            this_1.listOptions.append(listItem.el);
            if (current == this_1.select.options.item(i).text) {
                listItem.addClass('active');
            }
            listItem.on('click', function (e) {
                e.stopPropagation();
                self.select.value = listItem.getAttribute('value');
                self.selectOptionAction(self.getSelectedOption());
                self.selectStyled.text(listItem.text());
                self.selectStyled.removeClass('active');
                _.each(self.listOptions.children(), function (li) { coveo_search_ui_1.$$(li).removeClass('active'); });
                listItem.addClass('active');
                self.listOptions.hide();
            });
        };
        var this_1 = this;
        for (var i = 0; i < this.select.options.length; i++) {
            _loop_1();
        }
    };
    ResultsPerPageDropdown.prototype.buildSelectOptions = function () {
        var _this = this;
        coveo_search_ui_1.$$(this.select).empty();
        this.options.choicesDisplayed.forEach(function (o) {
            var selectOptionEl = coveo_search_ui_1.$$('option', {
                value: o,
            }, o.toString()).el;
            if (_this.options.initialChoice === o) {
                selectOptionEl.selected = true;
            }
            coveo_search_ui_1.$$(_this.select).append(selectOptionEl);
        });
    };
    ResultsPerPageDropdown.prototype.getSelectedOption = function () {
        return this.select.options[this.select.selectedIndex].value;
    };
    ResultsPerPageDropdown.prototype.updateSelectedOption = function (value) {
        var nextSelectedIndex = _.findIndex(this.select.options, function (o) {
            return o.value === value;
        });
        // if value not found falling back on default/first options.
        nextSelectedIndex = nextSelectedIndex < 0 ? 0 : nextSelectedIndex;
        if (nextSelectedIndex >= 0) {
            this.select.value = this.select.options[nextSelectedIndex].value;
            this.searchInterface.resultsPerPage = (Number(this.getSelectedOption()));
            this.selectStyled.text(this.select.options[nextSelectedIndex].text);
            this.selectStyled.removeClass('active');
        }
    };
    ResultsPerPageDropdown.prototype.selectOptionAction = function (value) {
        if (this.queryController.firstQuery) {
            this.searchInterface.resultsPerPage = (Number(value));
        }
        else {
            this.resultsPerPage.setResultsPerPage(Number(value));
        }
    };
    var ResultsPerPageDropdown_1;
    ResultsPerPageDropdown.ID = 'ResultsPerPageDropdown';
    ResultsPerPageDropdown.options = {
        caption: coveo_search_ui_1.ComponentOptions.buildLocalizedStringOption({ localizedString: function () { return coveo_search_ui_1.l('ResultsPerPage'); }, depend: 'displayCaption' }),
        displayCaption: coveo_search_ui_1.ComponentOptions.buildBooleanOption({ defaultValue: true }),
        /**
         * Specifies the possible values of number of results to display per page that the end user can select from.
         *
         * See also {@link ResultsPerPage.options.initialChoice}.
         *
         * Default value is `[10, 25, 50, 100]`.
         */
        choicesDisplayed: coveo_search_ui_1.ComponentOptions.buildCustomListOption(function (list) {
            var values = _.map(list, function (value) {
                return parseInt(value, 10);
            });
            return values.length == 0 ? null : values;
        }, {
            defaultFunction: function () {
                if (coveo_search_ui_1.DeviceUtils.isMobileDevice()) {
                    return [10, 25, 50];
                }
                else {
                    return [10, 25, 50, 100];
                }
            }
        }),
        /**
         * Specifies the value to select by default for the number of results to display per page.
         *
         * Default value is the first value of {@link ResultsPerPage.options.choicesDisplayed}.
         */
        initialChoice: coveo_search_ui_1.ComponentOptions.buildNumberOption()
    };
    ResultsPerPageDropdown = ResultsPerPageDropdown_1 = __decorate([
        turbo_core_1.lazyComponent
    ], ResultsPerPageDropdown);
    return ResultsPerPageDropdown;
}(coveo_search_ui_1.Component));
exports.ResultsPerPageDropdown = ResultsPerPageDropdown;


/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

var api = __webpack_require__(6);
            var content = __webpack_require__(7);

            content = content.__esModule ? content.default : content;

            if (typeof content === 'string') {
              content = [[module.i, content, '']];
            }

var options = {};

options.insert = "head";
options.singleton = false;

var update = api(content, options);



module.exports = content.locals || {};

/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var isOldIE = function isOldIE() {
  var memo;
  return function memorize() {
    if (typeof memo === 'undefined') {
      // Test for IE <= 9 as proposed by Browserhacks
      // @see http://browserhacks.com/#hack-e71d8692f65334173fee715c222cb805
      // Tests for existence of standard globals is to allow style-loader
      // to operate correctly into non-standard environments
      // @see https://github.com/webpack-contrib/style-loader/issues/177
      memo = Boolean(window && document && document.all && !window.atob);
    }

    return memo;
  };
}();

var getTarget = function getTarget() {
  var memo = {};
  return function memorize(target) {
    if (typeof memo[target] === 'undefined') {
      var styleTarget = document.querySelector(target); // Special case to return head of iframe instead of iframe itself

      if (window.HTMLIFrameElement && styleTarget instanceof window.HTMLIFrameElement) {
        try {
          // This will throw an exception if access to iframe is blocked
          // due to cross-origin restrictions
          styleTarget = styleTarget.contentDocument.head;
        } catch (e) {
          // istanbul ignore next
          styleTarget = null;
        }
      }

      memo[target] = styleTarget;
    }

    return memo[target];
  };
}();

var stylesInDom = [];

function getIndexByIdentifier(identifier) {
  var result = -1;

  for (var i = 0; i < stylesInDom.length; i++) {
    if (stylesInDom[i].identifier === identifier) {
      result = i;
      break;
    }
  }

  return result;
}

function modulesToDom(list, options) {
  var idCountMap = {};
  var identifiers = [];

  for (var i = 0; i < list.length; i++) {
    var item = list[i];
    var id = options.base ? item[0] + options.base : item[0];
    var count = idCountMap[id] || 0;
    var identifier = "".concat(id, " ").concat(count);
    idCountMap[id] = count + 1;
    var index = getIndexByIdentifier(identifier);
    var obj = {
      css: item[1],
      media: item[2],
      sourceMap: item[3]
    };

    if (index !== -1) {
      stylesInDom[index].references++;
      stylesInDom[index].updater(obj);
    } else {
      stylesInDom.push({
        identifier: identifier,
        updater: addStyle(obj, options),
        references: 1
      });
    }

    identifiers.push(identifier);
  }

  return identifiers;
}

function insertStyleElement(options) {
  var style = document.createElement('style');
  var attributes = options.attributes || {};

  if (typeof attributes.nonce === 'undefined') {
    var nonce =  true ? __webpack_require__.nc : undefined;

    if (nonce) {
      attributes.nonce = nonce;
    }
  }

  Object.keys(attributes).forEach(function (key) {
    style.setAttribute(key, attributes[key]);
  });

  if (typeof options.insert === 'function') {
    options.insert(style);
  } else {
    var target = getTarget(options.insert || 'head');

    if (!target) {
      throw new Error("Couldn't find a style target. This probably means that the value for the 'insert' parameter is invalid.");
    }

    target.appendChild(style);
  }

  return style;
}

function removeStyleElement(style) {
  // istanbul ignore if
  if (style.parentNode === null) {
    return false;
  }

  style.parentNode.removeChild(style);
}
/* istanbul ignore next  */


var replaceText = function replaceText() {
  var textStore = [];
  return function replace(index, replacement) {
    textStore[index] = replacement;
    return textStore.filter(Boolean).join('\n');
  };
}();

function applyToSingletonTag(style, index, remove, obj) {
  var css = remove ? '' : obj.media ? "@media ".concat(obj.media, " {").concat(obj.css, "}") : obj.css; // For old IE

  /* istanbul ignore if  */

  if (style.styleSheet) {
    style.styleSheet.cssText = replaceText(index, css);
  } else {
    var cssNode = document.createTextNode(css);
    var childNodes = style.childNodes;

    if (childNodes[index]) {
      style.removeChild(childNodes[index]);
    }

    if (childNodes.length) {
      style.insertBefore(cssNode, childNodes[index]);
    } else {
      style.appendChild(cssNode);
    }
  }
}

function applyToTag(style, options, obj) {
  var css = obj.css;
  var media = obj.media;
  var sourceMap = obj.sourceMap;

  if (media) {
    style.setAttribute('media', media);
  } else {
    style.removeAttribute('media');
  }

  if (sourceMap && btoa) {
    css += "\n/*# sourceMappingURL=data:application/json;base64,".concat(btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))), " */");
  } // For old IE

  /* istanbul ignore if  */


  if (style.styleSheet) {
    style.styleSheet.cssText = css;
  } else {
    while (style.firstChild) {
      style.removeChild(style.firstChild);
    }

    style.appendChild(document.createTextNode(css));
  }
}

var singleton = null;
var singletonCounter = 0;

function addStyle(obj, options) {
  var style;
  var update;
  var remove;

  if (options.singleton) {
    var styleIndex = singletonCounter++;
    style = singleton || (singleton = insertStyleElement(options));
    update = applyToSingletonTag.bind(null, style, styleIndex, false);
    remove = applyToSingletonTag.bind(null, style, styleIndex, true);
  } else {
    style = insertStyleElement(options);
    update = applyToTag.bind(null, style, options);

    remove = function remove() {
      removeStyleElement(style);
    };
  }

  update(obj);
  return function updateStyle(newObj) {
    if (newObj) {
      if (newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap) {
        return;
      }

      update(obj = newObj);
    } else {
      remove();
    }
  };
}

module.exports = function (list, options) {
  options = options || {}; // Force single-tag solution on IE6-9, which has a hard limit on the # of <style>
  // tags it will allow on a page

  if (!options.singleton && typeof options.singleton !== 'boolean') {
    options.singleton = isOldIE();
  }

  list = list || [];
  var lastIdentifiers = modulesToDom(list, options);
  return function update(newList) {
    newList = newList || [];

    if (Object.prototype.toString.call(newList) !== '[object Array]') {
      return;
    }

    for (var i = 0; i < lastIdentifiers.length; i++) {
      var identifier = lastIdentifiers[i];
      var index = getIndexByIdentifier(identifier);
      stylesInDom[index].references--;
    }

    var newLastIdentifiers = modulesToDom(newList, options);

    for (var _i = 0; _i < lastIdentifiers.length; _i++) {
      var _identifier = lastIdentifiers[_i];

      var _index = getIndexByIdentifier(_identifier);

      if (stylesInDom[_index].references === 0) {
        stylesInDom[_index].updater();

        stylesInDom.splice(_index, 1);
      }
    }

    lastIdentifiers = newLastIdentifiers;
  };
};

/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

// extracted by mini-css-extract-plugin

/***/ })
/******/ ]);
});

/***/ }),
/* 21 */
/***/ (function(module, exports, __webpack_require__) {

(function webpackUniversalModuleDefinition(root, factory) {
	if(true)
		module.exports = factory(__webpack_require__(0));
	else {}
})(window, function(__WEBPACK_EXTERNAL_MODULE__0__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 2);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE__0__;

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

(function webpackUniversalModuleDefinition(root, factory) {
	if(true)
		module.exports = factory(__webpack_require__(0));
	else {}
})(window, function(__WEBPACK_EXTERNAL_MODULE__1__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 2);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.component = void 0;
var coveo_search_ui_1 = __webpack_require__(1);
function component(constructor) {
    coveo_search_ui_1.Initialization.registerAutoCreateComponent(constructor);
    return constructor;
}
exports.component = component;


/***/ }),
/* 1 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE__1__;

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(3);


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(4), exports);
__exportStar(__webpack_require__(6), exports);


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(0), exports);
__exportStar(__webpack_require__(5), exports);


/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.lazyComponent = exports.lazyDependentComponent = void 0;
var coveo_search_ui_1 = __webpack_require__(1);
var component_1 = __webpack_require__(0);
function lazyDependentComponent(dependentComponentId) {
    return function (constructor) {
        if (!coveo_search_ui_1.LazyInitialization) {
            return component_1.component(constructor);
        }
        coveo_search_ui_1.LazyInitialization.registerLazyComponent(constructor.ID, function () {
            return coveo_search_ui_1.load(dependentComponentId).then(function () { return component_1.component(constructor); });
        });
        return constructor;
    };
}
exports.lazyDependentComponent = lazyDependentComponent;
function lazyComponent(constructor) {
    if (!coveo_search_ui_1.LazyInitialization) {
        return component_1.component(constructor);
    }
    coveo_search_ui_1.LazyInitialization.registerLazyComponent(constructor.ID, component_1.component(constructor));
    return constructor;
}
exports.lazyComponent = lazyComponent;


/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(7), exports);


/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

// Webpack output a library target with a temporary name.
// It does not take care of merging the namespace if the global variable already exists.
// If another piece of code in the page use the Coveo namespace (eg: extension), then they get overwritten
// This code swap the current module to the "real" Coveo variable, without overwriting the whole global var.
// This is to allow end user to put CoveoPSComponents.js before or after the main CoveoJsSearch.js, without breaking
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.swapVar = void 0;
function swapVar(scope) {
    if (!window['Coveo']) {
        window['Coveo'] = scope;
        return;
    }
    window['Coveo'] = __assign(__assign({}, scope), window['Coveo']);
}
exports.swapVar = swapVar;


/***/ })
/******/ ]);
});

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

__webpack_require__(3);
module.exports = __webpack_require__(5);


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(4), exports);
var turbo_core_1 = __webpack_require__(1);
turbo_core_1.swapVar(this);


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CustomSortDropdown = void 0;
var coveo_search_ui_1 = __webpack_require__(0);
var turbo_core_1 = __webpack_require__(1);
var CustomSortDropdown = /** @class */ (function (_super) {
    __extends(CustomSortDropdown, _super);
    function CustomSortDropdown(element, options, bindings) {
        var _this = _super.call(this, element, CustomSortDropdown_1.ID, bindings) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        _this.options = coveo_search_ui_1.ComponentOptions.initComponentOptions(element, CustomSortDropdown_1, options);
        // Init Events
        _this.bind.onRootElement(Coveo.InitializationEvents.afterInitialization, _this.handleAfterInit);
        // State Events
        var changeSortEvtName = _this.getStateEventName(Coveo.QueryStateModel.eventTypes.changeOne + Coveo.QueryStateModel.attributesEnum.sort);
        _this.bind.onRootElement(changeSortEvtName, function (args) { return _this.handleCoveoStateChanged(args); });
        // Query Events
        _this.bind.onRootElement(Coveo.QueryEvents.querySuccess, function (args) { return _this.handleQuerySuccess(args); });
        _this.bind.onRootElement(Coveo.QueryEvents.queryError, function (args) { return _this.handleQueryError(args); });
        if (_this.options.displayCaption) {
            Coveo.$$(_this.element).append(_this.buildLabel());
        }
        _this.select = _this.buildSelectElement();
        if (!_this.options.displayAsSelect) {
            Coveo.$$(_this.select).addClass('coveo-custom-select-hidden');
        }
        Coveo.$$(_this.element).append(_this.select);
        return _this;
    }
    CustomSortDropdown_1 = CustomSortDropdown;
    CustomSortDropdown.prototype.handleCoveoStateChanged = function (args) {
        this.currentSearchSort = args.value;
    };
    CustomSortDropdown.prototype.handleQuerySuccess = function (data) {
        if (data.results.results.length == 0) {
            coveo_search_ui_1.$$(this.element).addClass('coveo-sort-hidden');
        }
        else {
            coveo_search_ui_1.$$(this.element).removeClass('coveo-sort-hidden');
        }
    };
    CustomSortDropdown.prototype.handleQueryError = function (data) {
        coveo_search_ui_1.$$(this.element).addClass('coveo-sort-hidden');
    };
    CustomSortDropdown.prototype.getStateEventName = function (event) {
        return Coveo.QueryStateModel.ID + ':' + event;
    };
    CustomSortDropdown.prototype.handleAfterInit = function () {
        this.buildSelectOptions();
        if (!this.options.displayAsSelect) {
            this.buildStyledSelect();
        }
    };
    CustomSortDropdown.prototype.buildStyledSelect = function () {
        var _this = this;
        var wrapper = Coveo.$$('div', { className: 'coveo-custom-select' });
        this.select.parentNode.insertBefore(wrapper.el, this.select);
        wrapper.append(this.select);
        this.selectStyled = Coveo.$$('div', { className: 'coveo-custom-select-styled' });
        this.listOptions = Coveo.$$('ul', { className: 'coveo-custom-select-options' });
        wrapper.append(this.selectStyled.el);
        wrapper.append(this.listOptions.el);
        this.renderSelectStyled();
        this.selectStyled.on('click', function (e) {
            e.stopPropagation();
            _this.selectStyled.toggleClass('active');
            _this.listOptions.toggle();
        });
        document.addEventListener('click', function () {
            _this.selectStyled.removeClass('active');
            _this.listOptions.hide();
        });
    };
    CustomSortDropdown.prototype.renderSelectStyled = function () {
        var self = this;
        self.listOptions.empty();
        // Hack for Typescript issue
        var opt = this.select.options;
        var current = opt.length ? opt[self.select.selectedIndex].text : '';
        self.selectStyled.text(current);
        var _loop_1 = function () {
            var listItem = Coveo.$$('li', {
                value: opt.item(i).value
            }, opt.item(i).text);
            self.listOptions.append(listItem.el);
            if (current == opt.item(i).text) {
                listItem.addClass('active');
            }
            listItem.on('click', function (e) {
                e.stopPropagation();
                self.select.value = listItem.getAttribute('value');
                self.updateSort(listItem.getAttribute('value'));
                self.selectStyled.text(listItem.text());
                self.selectStyled.removeClass('active');
                _.each(self.listOptions.children(), function (li) { Coveo.$$(li).removeClass('active'); });
                listItem.addClass('active');
                self.listOptions.hide();
            });
        };
        for (var i = 0; i < opt.length; i++) {
            _loop_1();
        }
    };
    CustomSortDropdown.prototype.buildLabel = function () {
        var label = Coveo.$$('span', { className: 'coveo-custom-sort-dropdown-text' }, this.options.caption).el;
        return label;
    };
    CustomSortDropdown.prototype.buildSelectElement = function () {
        var _this = this;
        var selectEl = Coveo.$$('select', { className: 'coveo-custom-sort-dropdown-picker' });
        var changeAction = function () { return _this.handleSelectChangeCriteria(); };
        selectEl.on('change', changeAction);
        return selectEl.el;
    };
    CustomSortDropdown.prototype.buildSelectOptions = function () {
        var _this = this;
        Coveo.$$(this.select).empty();
        var sorts = this.element.querySelectorAll('.CoveoSort:not(.coveo-tab-disabled):not(.coveo-sort-hidden)');
        _.each(sorts, function (Sort) {
            var sort = Coveo.get(Sort, 'Sort');
            var selectedOption;
            sort.options.sortCriteria.forEach(function (crit) {
                var key = (crit.sort + ' ' + crit['direction']).trim();
                if (key == _this.currentSearchSort) {
                    selectedOption = true;
                }
            });
            var optionLink = Coveo.$$('option', { value: sort.options.caption }, sort.options.caption).el;
            if (selectedOption) {
                optionLink.selected = true;
            }
            Coveo.$$(_this.select).append(optionLink);
        });
    };
    CustomSortDropdown.prototype.handleSelectChangeCriteria = function () {
        var sortCaption = (event.currentTarget).value;
        this.updateSort(sortCaption);
    };
    ;
    CustomSortDropdown.prototype.updateSort = function (value) {
        var sorts = this.element.querySelectorAll('.CoveoSort:not(.coveo-tab-disabled):not(.coveo-sort-hidden)');
        _.each(sorts, function (Sort) {
            var sort = Coveo.get(Sort, 'Sort');
            if (value == sort.options.caption) {
                sort.element.click();
            }
        });
    };
    var CustomSortDropdown_1;
    CustomSortDropdown.ID = 'CustomSortDropdown';
    CustomSortDropdown.options = {
        caption: coveo_search_ui_1.ComponentOptions.buildLocalizedStringOption({ localizedString: function () { return coveo_search_ui_1.l('SortBy'); } }),
        displayCaption: coveo_search_ui_1.ComponentOptions.buildBooleanOption({ defaultValue: false }),
        displayAsSelect: coveo_search_ui_1.ComponentOptions.buildBooleanOption({ defaultValue: false })
    };
    CustomSortDropdown = CustomSortDropdown_1 = __decorate([
        turbo_core_1.lazyComponent
    ], CustomSortDropdown);
    return CustomSortDropdown;
}(coveo_search_ui_1.Component));
exports.CustomSortDropdown = CustomSortDropdown;


/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

var api = __webpack_require__(6);
            var content = __webpack_require__(7);

            content = content.__esModule ? content.default : content;

            if (typeof content === 'string') {
              content = [[module.i, content, '']];
            }

var options = {};

options.insert = "head";
options.singleton = false;

var update = api(content, options);



module.exports = content.locals || {};

/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var isOldIE = function isOldIE() {
  var memo;
  return function memorize() {
    if (typeof memo === 'undefined') {
      // Test for IE <= 9 as proposed by Browserhacks
      // @see http://browserhacks.com/#hack-e71d8692f65334173fee715c222cb805
      // Tests for existence of standard globals is to allow style-loader
      // to operate correctly into non-standard environments
      // @see https://github.com/webpack-contrib/style-loader/issues/177
      memo = Boolean(window && document && document.all && !window.atob);
    }

    return memo;
  };
}();

var getTarget = function getTarget() {
  var memo = {};
  return function memorize(target) {
    if (typeof memo[target] === 'undefined') {
      var styleTarget = document.querySelector(target); // Special case to return head of iframe instead of iframe itself

      if (window.HTMLIFrameElement && styleTarget instanceof window.HTMLIFrameElement) {
        try {
          // This will throw an exception if access to iframe is blocked
          // due to cross-origin restrictions
          styleTarget = styleTarget.contentDocument.head;
        } catch (e) {
          // istanbul ignore next
          styleTarget = null;
        }
      }

      memo[target] = styleTarget;
    }

    return memo[target];
  };
}();

var stylesInDom = [];

function getIndexByIdentifier(identifier) {
  var result = -1;

  for (var i = 0; i < stylesInDom.length; i++) {
    if (stylesInDom[i].identifier === identifier) {
      result = i;
      break;
    }
  }

  return result;
}

function modulesToDom(list, options) {
  var idCountMap = {};
  var identifiers = [];

  for (var i = 0; i < list.length; i++) {
    var item = list[i];
    var id = options.base ? item[0] + options.base : item[0];
    var count = idCountMap[id] || 0;
    var identifier = "".concat(id, " ").concat(count);
    idCountMap[id] = count + 1;
    var index = getIndexByIdentifier(identifier);
    var obj = {
      css: item[1],
      media: item[2],
      sourceMap: item[3]
    };

    if (index !== -1) {
      stylesInDom[index].references++;
      stylesInDom[index].updater(obj);
    } else {
      stylesInDom.push({
        identifier: identifier,
        updater: addStyle(obj, options),
        references: 1
      });
    }

    identifiers.push(identifier);
  }

  return identifiers;
}

function insertStyleElement(options) {
  var style = document.createElement('style');
  var attributes = options.attributes || {};

  if (typeof attributes.nonce === 'undefined') {
    var nonce =  true ? __webpack_require__.nc : undefined;

    if (nonce) {
      attributes.nonce = nonce;
    }
  }

  Object.keys(attributes).forEach(function (key) {
    style.setAttribute(key, attributes[key]);
  });

  if (typeof options.insert === 'function') {
    options.insert(style);
  } else {
    var target = getTarget(options.insert || 'head');

    if (!target) {
      throw new Error("Couldn't find a style target. This probably means that the value for the 'insert' parameter is invalid.");
    }

    target.appendChild(style);
  }

  return style;
}

function removeStyleElement(style) {
  // istanbul ignore if
  if (style.parentNode === null) {
    return false;
  }

  style.parentNode.removeChild(style);
}
/* istanbul ignore next  */


var replaceText = function replaceText() {
  var textStore = [];
  return function replace(index, replacement) {
    textStore[index] = replacement;
    return textStore.filter(Boolean).join('\n');
  };
}();

function applyToSingletonTag(style, index, remove, obj) {
  var css = remove ? '' : obj.media ? "@media ".concat(obj.media, " {").concat(obj.css, "}") : obj.css; // For old IE

  /* istanbul ignore if  */

  if (style.styleSheet) {
    style.styleSheet.cssText = replaceText(index, css);
  } else {
    var cssNode = document.createTextNode(css);
    var childNodes = style.childNodes;

    if (childNodes[index]) {
      style.removeChild(childNodes[index]);
    }

    if (childNodes.length) {
      style.insertBefore(cssNode, childNodes[index]);
    } else {
      style.appendChild(cssNode);
    }
  }
}

function applyToTag(style, options, obj) {
  var css = obj.css;
  var media = obj.media;
  var sourceMap = obj.sourceMap;

  if (media) {
    style.setAttribute('media', media);
  } else {
    style.removeAttribute('media');
  }

  if (sourceMap && btoa) {
    css += "\n/*# sourceMappingURL=data:application/json;base64,".concat(btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))), " */");
  } // For old IE

  /* istanbul ignore if  */


  if (style.styleSheet) {
    style.styleSheet.cssText = css;
  } else {
    while (style.firstChild) {
      style.removeChild(style.firstChild);
    }

    style.appendChild(document.createTextNode(css));
  }
}

var singleton = null;
var singletonCounter = 0;

function addStyle(obj, options) {
  var style;
  var update;
  var remove;

  if (options.singleton) {
    var styleIndex = singletonCounter++;
    style = singleton || (singleton = insertStyleElement(options));
    update = applyToSingletonTag.bind(null, style, styleIndex, false);
    remove = applyToSingletonTag.bind(null, style, styleIndex, true);
  } else {
    style = insertStyleElement(options);
    update = applyToTag.bind(null, style, options);

    remove = function remove() {
      removeStyleElement(style);
    };
  }

  update(obj);
  return function updateStyle(newObj) {
    if (newObj) {
      if (newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap) {
        return;
      }

      update(obj = newObj);
    } else {
      remove();
    }
  };
}

module.exports = function (list, options) {
  options = options || {}; // Force single-tag solution on IE6-9, which has a hard limit on the # of <style>
  // tags it will allow on a page

  if (!options.singleton && typeof options.singleton !== 'boolean') {
    options.singleton = isOldIE();
  }

  list = list || [];
  var lastIdentifiers = modulesToDom(list, options);
  return function update(newList) {
    newList = newList || [];

    if (Object.prototype.toString.call(newList) !== '[object Array]') {
      return;
    }

    for (var i = 0; i < lastIdentifiers.length; i++) {
      var identifier = lastIdentifiers[i];
      var index = getIndexByIdentifier(identifier);
      stylesInDom[index].references--;
    }

    var newLastIdentifiers = modulesToDom(newList, options);

    for (var _i = 0; _i < lastIdentifiers.length; _i++) {
      var _identifier = lastIdentifiers[_i];

      var _index = getIndexByIdentifier(_identifier);

      if (stylesInDom[_index].references === 0) {
        stylesInDom[_index].updater();

        stylesInDom.splice(_index, 1);
      }
    }

    lastIdentifiers = newLastIdentifiers;
  };
};

/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

// extracted by mini-css-extract-plugin

/***/ })
/******/ ]);
});

/***/ }),
/* 22 */
/***/ (function(module, exports, __webpack_require__) {

(function webpackUniversalModuleDefinition(root, factory) {
	if(true)
		module.exports = factory(__webpack_require__(0));
	else {}
})(window, function(__WEBPACK_EXTERNAL_MODULE__0__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 2);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE__0__;

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

(function webpackUniversalModuleDefinition(root, factory) {
	if(true)
		module.exports = factory(__webpack_require__(0));
	else {}
})(window, function(__WEBPACK_EXTERNAL_MODULE__1__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 2);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.component = void 0;
var coveo_search_ui_1 = __webpack_require__(1);
function component(constructor) {
    coveo_search_ui_1.Initialization.registerAutoCreateComponent(constructor);
    return constructor;
}
exports.component = component;


/***/ }),
/* 1 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE__1__;

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(3);


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(4), exports);
__exportStar(__webpack_require__(6), exports);


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(0), exports);
__exportStar(__webpack_require__(5), exports);


/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.lazyComponent = exports.lazyDependentComponent = void 0;
var coveo_search_ui_1 = __webpack_require__(1);
var component_1 = __webpack_require__(0);
function lazyDependentComponent(dependentComponentId) {
    return function (constructor) {
        if (!coveo_search_ui_1.LazyInitialization) {
            return component_1.component(constructor);
        }
        coveo_search_ui_1.LazyInitialization.registerLazyComponent(constructor.ID, function () {
            return coveo_search_ui_1.load(dependentComponentId).then(function () { return component_1.component(constructor); });
        });
        return constructor;
    };
}
exports.lazyDependentComponent = lazyDependentComponent;
function lazyComponent(constructor) {
    if (!coveo_search_ui_1.LazyInitialization) {
        return component_1.component(constructor);
    }
    coveo_search_ui_1.LazyInitialization.registerLazyComponent(constructor.ID, component_1.component(constructor));
    return constructor;
}
exports.lazyComponent = lazyComponent;


/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(7), exports);


/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

// Webpack output a library target with a temporary name.
// It does not take care of merging the namespace if the global variable already exists.
// If another piece of code in the page use the Coveo namespace (eg: extension), then they get overwritten
// This code swap the current module to the "real" Coveo variable, without overwriting the whole global var.
// This is to allow end user to put CoveoPSComponents.js before or after the main CoveoJsSearch.js, without breaking
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.swapVar = void 0;
function swapVar(scope) {
    if (!window['Coveo']) {
        window['Coveo'] = scope;
        return;
    }
    window['Coveo'] = __assign(__assign({}, scope), window['Coveo']);
}
exports.swapVar = swapVar;


/***/ })
/******/ ]);
});

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

__webpack_require__(3);
module.exports = __webpack_require__(6);


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !exports.hasOwnProperty(p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(__webpack_require__(4), exports);
__exportStar(__webpack_require__(5), exports);
var turbo_core_1 = __webpack_require__(1);
turbo_core_1.swapVar(this);


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CcWishlist = void 0;
var coveo_search_ui_1 = __webpack_require__(0);
var turbo_core_1 = __webpack_require__(1);
var CcWishlist = /** @class */ (function (_super) {
    __extends(CcWishlist, _super);
    function CcWishlist(element, options, bindings) {
        var _this = _super.call(this, element, CcWishlist_1.ID, bindings) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        _this.options = coveo_search_ui_1.ComponentOptions.initComponentOptions(element, CcWishlist_1, options);
        _this.bind.onRootElement(Coveo.ResultListEvents.newResultsDisplayed, _this.handleNewResultsDisplayed);
        return _this;
    }
    CcWishlist_1 = CcWishlist;
    CcWishlist.prototype.handleNewResultsDisplayed = function () {
        try {
            // TODO::LGCARRIER
            // We could pass this function as an option: CCRZ.views.wishlistPickerModal
            var pickerView = _.isUndefined(CCRZ.views.wishlistPickerModal)
                ? false
                : new CCRZ.views.wishlistPickerModal();
        }
        catch (error) {
            console.warn("CCRZ object was expected to be found but it wasn't.\n        Either you are outside of Salesforce B2B CloudCraze or something is not configured properly in your VF pages and/or VF components.");
        }
    };
    var CcWishlist_1;
    CcWishlist.ID = "CcWishlist";
    CcWishlist.options = {};
    CcWishlist = CcWishlist_1 = __decorate([
        turbo_core_1.lazyComponent
    ], CcWishlist);
    return CcWishlist;
}(coveo_search_ui_1.Component));
exports.CcWishlist = CcWishlist;


/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CcWishlistButton = void 0;
var coveo_search_ui_1 = __webpack_require__(0);
var turbo_core_1 = __webpack_require__(1);
var CcWishlistButton = /** @class */ (function (_super) {
    __extends(CcWishlistButton, _super);
    function CcWishlistButton(element, options, bindings, result) {
        var _this = _super.call(this, element, CcWishlistButton_1.ID, bindings) || this;
        _this.element = element;
        _this.options = options;
        _this.bindings = bindings;
        _this.result = result;
        _this.options = coveo_search_ui_1.ComponentOptions.initComponentOptions(element, CcWishlistButton_1, options);
        _this.build();
        return _this;
    }
    CcWishlistButton_1 = CcWishlistButton;
    CcWishlistButton.prototype.build = function () {
        if (Coveo.Utils.getFieldValue(this.result, this.options.isVisibleField)) {
            this.element.appendChild(this.buildWishlistButton());
        }
    };
    CcWishlistButton.prototype.getSkuValue = function () {
        return Coveo.Utils.getFieldValue(this.result, this.options.skuField);
    };
    CcWishlistButton.prototype.buildWishlistButton = function () {
        var ccWishlistButtonContainer = coveo_search_ui_1.$$("div", {
            className: "cc_wishlist",
        }, coveo_search_ui_1.$$("div", {
            className: "wishFinder",
            "data-sku": this.getSkuValue(),
        }, coveo_search_ui_1.$$("div", {
            className: "wishButtons",
        })));
        return ccWishlistButtonContainer.el;
    };
    var CcWishlistButton_1;
    CcWishlistButton.ID = "CcWishlistButton";
    CcWishlistButton.options = {
        skuField: coveo_search_ui_1.ComponentOptions.buildFieldOption({ defaultValue: '@sfccrz__sku__c' }),
        isVisibleField: coveo_search_ui_1.ComponentOptions.buildFieldOption({ defaultValue: '@isaddtocartshow' })
    };
    CcWishlistButton = CcWishlistButton_1 = __decorate([
        turbo_core_1.lazyComponent
    ], CcWishlistButton);
    return CcWishlistButton;
}(coveo_search_ui_1.Component));
exports.CcWishlistButton = CcWishlistButton;


/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

var api = __webpack_require__(7);
            var content = __webpack_require__(8);

            content = content.__esModule ? content.default : content;

            if (typeof content === 'string') {
              content = [[module.i, content, '']];
            }

var options = {};

options.insert = "head";
options.singleton = false;

var update = api(content, options);



module.exports = content.locals || {};

/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var isOldIE = function isOldIE() {
  var memo;
  return function memorize() {
    if (typeof memo === 'undefined') {
      // Test for IE <= 9 as proposed by Browserhacks
      // @see http://browserhacks.com/#hack-e71d8692f65334173fee715c222cb805
      // Tests for existence of standard globals is to allow style-loader
      // to operate correctly into non-standard environments
      // @see https://github.com/webpack-contrib/style-loader/issues/177
      memo = Boolean(window && document && document.all && !window.atob);
    }

    return memo;
  };
}();

var getTarget = function getTarget() {
  var memo = {};
  return function memorize(target) {
    if (typeof memo[target] === 'undefined') {
      var styleTarget = document.querySelector(target); // Special case to return head of iframe instead of iframe itself

      if (window.HTMLIFrameElement && styleTarget instanceof window.HTMLIFrameElement) {
        try {
          // This will throw an exception if access to iframe is blocked
          // due to cross-origin restrictions
          styleTarget = styleTarget.contentDocument.head;
        } catch (e) {
          // istanbul ignore next
          styleTarget = null;
        }
      }

      memo[target] = styleTarget;
    }

    return memo[target];
  };
}();

var stylesInDom = [];

function getIndexByIdentifier(identifier) {
  var result = -1;

  for (var i = 0; i < stylesInDom.length; i++) {
    if (stylesInDom[i].identifier === identifier) {
      result = i;
      break;
    }
  }

  return result;
}

function modulesToDom(list, options) {
  var idCountMap = {};
  var identifiers = [];

  for (var i = 0; i < list.length; i++) {
    var item = list[i];
    var id = options.base ? item[0] + options.base : item[0];
    var count = idCountMap[id] || 0;
    var identifier = "".concat(id, " ").concat(count);
    idCountMap[id] = count + 1;
    var index = getIndexByIdentifier(identifier);
    var obj = {
      css: item[1],
      media: item[2],
      sourceMap: item[3]
    };

    if (index !== -1) {
      stylesInDom[index].references++;
      stylesInDom[index].updater(obj);
    } else {
      stylesInDom.push({
        identifier: identifier,
        updater: addStyle(obj, options),
        references: 1
      });
    }

    identifiers.push(identifier);
  }

  return identifiers;
}

function insertStyleElement(options) {
  var style = document.createElement('style');
  var attributes = options.attributes || {};

  if (typeof attributes.nonce === 'undefined') {
    var nonce =  true ? __webpack_require__.nc : undefined;

    if (nonce) {
      attributes.nonce = nonce;
    }
  }

  Object.keys(attributes).forEach(function (key) {
    style.setAttribute(key, attributes[key]);
  });

  if (typeof options.insert === 'function') {
    options.insert(style);
  } else {
    var target = getTarget(options.insert || 'head');

    if (!target) {
      throw new Error("Couldn't find a style target. This probably means that the value for the 'insert' parameter is invalid.");
    }

    target.appendChild(style);
  }

  return style;
}

function removeStyleElement(style) {
  // istanbul ignore if
  if (style.parentNode === null) {
    return false;
  }

  style.parentNode.removeChild(style);
}
/* istanbul ignore next  */


var replaceText = function replaceText() {
  var textStore = [];
  return function replace(index, replacement) {
    textStore[index] = replacement;
    return textStore.filter(Boolean).join('\n');
  };
}();

function applyToSingletonTag(style, index, remove, obj) {
  var css = remove ? '' : obj.media ? "@media ".concat(obj.media, " {").concat(obj.css, "}") : obj.css; // For old IE

  /* istanbul ignore if  */

  if (style.styleSheet) {
    style.styleSheet.cssText = replaceText(index, css);
  } else {
    var cssNode = document.createTextNode(css);
    var childNodes = style.childNodes;

    if (childNodes[index]) {
      style.removeChild(childNodes[index]);
    }

    if (childNodes.length) {
      style.insertBefore(cssNode, childNodes[index]);
    } else {
      style.appendChild(cssNode);
    }
  }
}

function applyToTag(style, options, obj) {
  var css = obj.css;
  var media = obj.media;
  var sourceMap = obj.sourceMap;

  if (media) {
    style.setAttribute('media', media);
  } else {
    style.removeAttribute('media');
  }

  if (sourceMap && btoa) {
    css += "\n/*# sourceMappingURL=data:application/json;base64,".concat(btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))), " */");
  } // For old IE

  /* istanbul ignore if  */


  if (style.styleSheet) {
    style.styleSheet.cssText = css;
  } else {
    while (style.firstChild) {
      style.removeChild(style.firstChild);
    }

    style.appendChild(document.createTextNode(css));
  }
}

var singleton = null;
var singletonCounter = 0;

function addStyle(obj, options) {
  var style;
  var update;
  var remove;

  if (options.singleton) {
    var styleIndex = singletonCounter++;
    style = singleton || (singleton = insertStyleElement(options));
    update = applyToSingletonTag.bind(null, style, styleIndex, false);
    remove = applyToSingletonTag.bind(null, style, styleIndex, true);
  } else {
    style = insertStyleElement(options);
    update = applyToTag.bind(null, style, options);

    remove = function remove() {
      removeStyleElement(style);
    };
  }

  update(obj);
  return function updateStyle(newObj) {
    if (newObj) {
      if (newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap) {
        return;
      }

      update(obj = newObj);
    } else {
      remove();
    }
  };
}

module.exports = function (list, options) {
  options = options || {}; // Force single-tag solution on IE6-9, which has a hard limit on the # of <style>
  // tags it will allow on a page

  if (!options.singleton && typeof options.singleton !== 'boolean') {
    options.singleton = isOldIE();
  }

  list = list || [];
  var lastIdentifiers = modulesToDom(list, options);
  return function update(newList) {
    newList = newList || [];

    if (Object.prototype.toString.call(newList) !== '[object Array]') {
      return;
    }

    for (var i = 0; i < lastIdentifiers.length; i++) {
      var identifier = lastIdentifiers[i];
      var index = getIndexByIdentifier(identifier);
      stylesInDom[index].references--;
    }

    var newLastIdentifiers = modulesToDom(newList, options);

    for (var _i = 0; _i < lastIdentifiers.length; _i++) {
      var _identifier = lastIdentifiers[_i];

      var _index = getIndexByIdentifier(_identifier);

      if (stylesInDom[_index].references === 0) {
        stylesInDom[_index].updater();

        stylesInDom.splice(_index, 1);
      }
    }

    lastIdentifiers = newLastIdentifiers;
  };
};

/***/ }),
/* 8 */
/***/ (function(module, exports, __webpack_require__) {

// extracted by mini-css-extract-plugin

/***/ })
/******/ ]);
});

/***/ }),
/* 23 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

// Webpack output a library target with a temporary name.
// It does not take care of merging the namespace if the global variable already exists.
// If another piece of code in the page use the Coveo namespace (eg: extension), then they get overwritten
// This code swap the current module to the "real" Coveo variable, without overwriting the whole global var.
// This is to allow end user to put CoveoPSComponents.js before or after the main CoveoJsSearch.js, without breaking
Object.defineProperty(exports, "__esModule", { value: true });
function swapVar(scope) {
    if (window['Coveo'] == undefined) {
        window['Coveo'] = scope;
    }
    else {
        _.each(_.keys(scope), function (k) {
            window['Coveo'][k] = scope[k];
        });
    }
}
exports.swapVar = swapVar;


/***/ }),
/* 24 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var coveoCustomScripts = function (promise, cmp) {
    // Patch for known issue : https://coveord.atlassian.net/browse/SFINT-2137
    Coveo.SearchInterface.prototype['setupMobileFastclick'] = function () { };
    // Ensure String.locale match the current locale on community
    String['locale'] = $A.get("$Locale.language") || 'en';
    String['locale'] = String['locale'] == 'es' ? 'es-es' : String['locale'];
    // Ensure to set custom language dictionary properly for lightning community. 
    Coveo['setCustomLanguageDict']();
};
function setCoveoCustomScripts() {
    window['coveoCustomScripts'] = {
        'default': coveoCustomScripts
    };
}
exports.setCoveoCustomScripts = setCoveoCustomScripts;


/***/ }),
/* 25 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__.p + "js/cultures/en.js";

/***/ }),
/* 26 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__.p + "js/cultures/fr.js";

/***/ }),
/* 27 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__.p + "js/cultures/es-es.js";

/***/ }),
/* 28 */
/***/ (function(module, exports, __webpack_require__) {

__webpack_require__(7);
module.exports = __webpack_require__(29);


/***/ }),
/* 29 */
/***/ (function(module, exports, __webpack_require__) {


var content = __webpack_require__(30);

if(typeof content === 'string') content = [[module.i, content, '']];

var transform;
var insertInto;



var options = {"hmr":true}

options.transform = transform
options.insertInto = undefined;

var update = __webpack_require__(1)(content, options);

if(content.locals) module.exports = content.locals;

if(false) {}

/***/ }),
/* 30 */
/***/ (function(module, exports, __webpack_require__) {

// extracted by mini-css-extract-plugin

/***/ })
/******/ ]);
});