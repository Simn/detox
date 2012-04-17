/****
* Copyright 2012 Jason O'Neil. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
* 
*    2. Redistributions in binary form must reproduce the above copyright notice, this list
*       of conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE "AS IS" AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Jason O'Neil.
* 
****/

package domtools;

/**
* new() - runs a new query, creates a new collection. Alternatively pass DOM Node
* slice
* not - removes elements (or selector) from set
* is("") - like filter, but returns Bool rather than new list if(element.is("li.menu"))
* has(selector) - does it have a certain children
* andSelf() - previous set of matched elements to the current set
* index(?selector) - 
* 
* All the rest provided through "using"
*
* Static methods:
* - create()
* - parse()
**/
import js.w3c.level3.Core;
import UserAgentContext;
import CommonJS;
import DOMTools;
using DOMTools;

class Query
{
	public var collection(default,null):Array<Node>;
	public var length(get_length,null):Int;
	public static var document(get_document,null):DocumentOrElement;
	public static var window(get_window,null):Window;

	public function new(?selector:String = "", ?node:Node = null, ?collection:Iterable<Node>)
	{
		this.collection = new Array();

		if (node != null)
		{
			add(node);
		}
		if (collection != null)
		{
			addCollection(collection);
		}
		if (selector != "")
		{
			var nodeList = document.querySelectorAll(selector, null);
			
			// performance cost of this operation
			// 1000000 times = 6sec;
			// 10000 times = 0.06sec
			// 1000 times = 0.006sec
			// Incredibly inaccurate but we're not on a scale I'm too worried about.
			addNodeList(nodeList);
		}
			
	}

	public inline function iterator()
	{
		return collection.iterator();
	}

	public inline function getNode(?i:Int = 0)
	{
		return collection[i];
	}

	public inline function eq(?i:Int = 0)
	{
		return new Query(getNode(i));
	}

	public inline function first()
	{
		return eq(0);
	}

	public inline function last()
	{
		return eq(this.length - 1);
	}

	public inline function add(node:Node):Query
	{
		if (node != null)
		{
			if (Lambda.has(collection, node) == false)
			{
				collection.push(node);
			}
		}
		return this;
	}

	public function addCollection(collection:Iterable<Node>, ?elementsOnly = false):Query
	{
		if (collection != null)
		{
			for (node in collection)
			{
				// Only add if we are allowing elements only or if it is in fact an element
				if (elementsOnly == false || domtools.single.ElementManipulation.isElement(node))
					add(node);
			}
		}
		return this;
	}

	public function addNodeList(nodeList:NodeList, ?elementsOnly = true):Query
	{
		for (i in 0...nodeList.length)
		{
			var node = nodeList.item(i);
			// Only add if we are allowing elements only or if it is in fact an element
			if (elementsOnly == false || domtools.single.ElementManipulation.isElement(node))
			{
				add(node);
			}
		}
		return this;
	}

	public function removeFromCollection(?node:Node, ?nodeCollection:Query):Query
	{
		if (node != null)
		{
			collection.remove(node);
		}
		if (nodeCollection != null)
		{
			for (n in nodeCollection)
			{
				collection.remove(n);
			}
		}
		return this;
	}

	public inline function each(f : Node -> Void):Query
	{
		if (f != null) { Lambda.iter(collection, f); }
		return this; 
	}

	/** Use a function to return a filtered list. In future might allow a selector as well. */
	public function filter(fn:Node->Bool)
	{
		var newCollection:Query;

		if (fn != null)
		{
			var filtered = Lambda.filter(collection, fn);
			newCollection = new Query(filtered);
		}
		else 
		{
			newCollection = new Query(collection);
		}

		return newCollection;
	}

	public function clone(?deep:Bool = true):Query
	{
		var q = new Query();
		for (node in this)
		{
			q.add(node.cloneNode(deep));
		}
		return q;
	}

	inline function get_length():Int
	{
		return collection.length;
	}

	public static inline function create(name:String):Node
	{
		var elm:Node = null;
		if (name != null)
		{
			try {
				elm = untyped __js__("document").createElement(name);
			} catch (e:Dynamic)
			{
				trace ("broken");
				elm = null;
			}
		}
		return elm;
	}

	public static function parse(html:String):Query
	{
		var q:Query ;
		if (html != null)
		{
			var n:Node = Query.create('div');
			//
			// TODO: report this bug to haxe mailing list.
			// this is allowed:
			// n.setInnerHTML("");
			// But this doesn't get swapped out to it's "using" function
			// Presumably because this class is a dependency of the DOMTools?
			// Either way haxe shouldn't do that...
			domtools.single.ElementManipulation.setInnerHTML(n, html);
			q = domtools.single.Traversing.children(n, false);
		}
		else 
		{
			q = new Query();
		}
		return q;
	}

	/*public static inline function create(str:String):Query
	{
		return new Query(Query.createElement(str));
	}*/


	static inline function get_window():Window
	{
		return untyped __js__("window");
	}

	static inline function get_document():DocumentOrElement
	{
		if (document == null) 
		{
			// Sensible default: window.document in JS
			document = untyped __js__("document");
		}
		return document;
	}

	public static function setDocument(newDocument:Node)
	{
		// Only change the document if it has the right NodeType
		if (newDocument != null)
		{
			if (newDocument.nodeType == Node.DOCUMENT_NODE 
				|| newDocument.nodeType == Node.ELEMENT_NODE)
			{
				// Because of the NodeType we can safely use this node as our document
				document = untyped newDocument;
			}
		}
	}
}

typedef Node = js.w3c.level3.Core.Node;
typedef Event = js.w3c.level3.Events.Event;

typedef DocumentOrElement = {> Node,
	var querySelector:DOMString->Dynamic->Element;
	var querySelectorAll:DOMString->Dynamic->NodeList;
}

import domtools.Tools;