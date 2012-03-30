package domtools.single;

import js.w3c.level3.Core;
/*
JQuery has these classes, let's copy:

	//later? outerHTML()
	//later? setOuterHTML()
	clone() - create a deep copy of this set of matched elements
*/ 


class ElementManipulation
{
	static var NodeTypeElement = 1;
	static var NodeTypeAttribute = 2;
	static var NodeTypeText = 3;
	static var NodeTypeComment = 8;

	public static function isElement(node:Node):Bool
	{
		return node.nodeType == NodeTypeElement;
	}

	public static function isComment(node:Node):Bool
	{
		return node.nodeType == NodeTypeComment;
	}

	public static function isTextNode(node:Node):Bool
	{
		return node.nodeType == NodeTypeText;
	}

	public static function toQuery(n:Node):Query
	{
		return new Query(n);
	}

	public static function attr(elm:Node, attName:String):String
	{
		var ret = "";
		if (isElement(elm))
		{
			var element:Element = cast elm;
			ret = element.getAttribute(attName);
			if (ret == null) ret = "";
		}
		return ret;
	}

	public static function setAttr(elm:Node, attName:String, attValue:String):Node
	{
		if (elm.nodeType == NodeTypeElement)
		{
			var element:Element = cast elm;
			element.setAttribute(attName, attValue);
		}
		return elm;
	}

	public static function removeAttr(elm:Node, attName:String):Node
	{
		if (elm.nodeType == NodeTypeElement)
		{
			var element:Element = cast elm;
			element.removeAttribute(attName);
		}
		return elm;
	}

	private static inline function testForClass(elm:Node, className:String):Bool
	{
		return ((" " + attr(elm, "class") + " ").indexOf(" " + className + " ") > -1);
	}

	public static function hasClass(elm:Node, className:String):Bool
	{
		var hasClass = true;
		if (className.indexOf(' ') > -1)
		{
			// There are multiple class names
			for (name in className.split(' '))
			{
				hasClass = testForClass(elm, name);
				if (hasClass == false) break;
			}
		}
		else 
		{
			hasClass = testForClass(elm, className);
		}
		return hasClass;
	}

	public static function addClass(elm:Node, className:String):Node
	{
		for (name in className.split(' '))
		{
			if (hasClass(elm, className) == false)
			{
				var oldClassName = attr(elm, "class");
				var newClassName =  (oldClassName == "") ? className : oldClassName + " " + className;
				setAttr(elm, "class", newClassName);
			}
		}
		
		return elm;
	}

	public static function removeClass(elm:Node, className:String):Node
	{
		// Get the current list of classes
		var classes = attr(elm, "class").split(" ");

		for (name in className.split(' '))
		{
			// Remove the current one
			classes.remove(name);
		}

		// reassemble as a string
		var newClassValue = classes.join(" ");

		setAttr(elm, "class", newClassValue);
		
		return elm;
	}

	public static function toggleClass(elm:Node, className:String):Node
	{
		for (name in className.split(' '))
		{
			if (hasClass(elm, name))
			{
				removeClass(elm,name);
			}
			else 
			{
				addClass(elm,name);
			}
		}
		return elm;
	}

	public static inline function tagName(elm:Node):String
	{
		return elm.nodeName.toLowerCase();
	}

	public static function val(node:Node):String
	{
		var val = "";

		switch (node.nodeType)
		{
			case NodeTypeElement:
				val = Reflect.field(node, 'value');
				
				// If the value is null, that means
				// the element did not have a field
				// "value".  See if it has an attr
				// instead.  This will return "" if
				// it doesn't, which is a sane default
				// also.
				if (val == null)
				{
					val = attr(node, "value");
				}
			default:
				val = node.nodeValue;
		}

		return val;
	}

	public static inline function setVal(elm:Node, val:Dynamic)
	{
		return setAttr(elm, "value", Std.string(val));
	}
	
	public static inline function text(elm:Node):String
	{
		return elm.textContent;
	}
	
	public static inline function setText(elm:Node, text:String):Node
	{
		return { elm.textContent = text; elm; };
	}

	public static function innerHTML(elm:Node):String
	{
		var ret = "";
		switch (elm.nodeType)
		{
			case NodeTypeElement:
				var element:Element = cast elm;
				ret = element.innerHTML;
			default:
				ret = elm.textContent;
		}
		return ret;
	}

	public static function setInnerHTML(elm:Node, html:String):Node
	{
		switch (elm.nodeType)
		{
			case NodeTypeElement:
				var element:Element = cast elm;
				element.innerHTML = html;
			default:
				elm.textContent = html;
		}
		return elm;
	}

	public static inline function clone(elm:Node, ?deep:Bool = true):Node
	{
		return elm.cloneNode(deep);
	}

}
