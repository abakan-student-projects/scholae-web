package;

import haxe.Serializer;
import haxe.Unserializer;
import htmlparser.HtmlParser;
import htmlparser.HtmlNodeElement;
import htmlparser.HtmlNodeText;
import htmlparser.HtmlDocument;
import htmlparser.XmlDocument;

#if sys
import sys.io.File;
#end

class HtmlTest extends haxe.unit.TestCase
{
    public function getParsedAsString(str:String, tolerant=false) : String
    {
        var nodes = HtmlParser.run(str, tolerant);
        return nodes.join("");
    }
    
	public function testText()
    {
		var nodes = HtmlParser.run("abc");
        this.assertEquals(1, nodes.length);

        var node = nodes[0];
		this.assertTrue(Type.getClass(node) == HtmlNodeText);
        this.assertEquals('abc', cast(node, HtmlNodeText).text);
    }

    public function testTagWithClose()
    {
		var nodes = HtmlParser.run("<br p=2 />");
        this.assertEquals(1, nodes.length);

		this.assertTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
        
		var node : HtmlNodeElement = cast nodes[0];
        this.assertEquals('br', node.name);
		
		this.assertEquals("String", Type.getClassName(Type.getClass("abc")));
    }

    public function testTagAndText()
    {
        var nodes = HtmlParser.run("<a>abc</a>");
        this.assertEquals(1, nodes.length);

		this.assertTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
		
        var node : HtmlNodeElement = cast nodes[0];
        this.assertEquals('a', node.name);
    }

    public function testSimpleConvertDeconvert()
    {
        this.assertEquals("<a>abc</a>", this.getParsedAsString("<a>abc</a>"));
        this.assertEquals("<a p=2>abc</a>", this.getParsedAsString("<a p=2>abc</a>"));
        this.assertEquals("<a p=2>abc</a>", this.getParsedAsString("<a p = 2>abc</a>"));
        this.assertEquals("<a p='2'>abc</a>", this.getParsedAsString("<a p = '2'>abc</a>"));
        this.assertEquals('<a p="2">abc</a>', this.getParsedAsString('<a p = "2">abc</a>'));
        this.assertEquals('<br />', this.getParsedAsString('<br/>'));
        this.assertEquals('<br />', this.getParsedAsString('<br />'));
        this.assertEquals("<a href='http://ya.ru?a=5'>Все на Яндекс!</a>", this.getParsedAsString("<a href='http://ya.ru?a=5'>Все на Яндекс!</a>"));
    }

    public function testComplexConvertDeconvert()
    {
        this.assertEquals(this.getParsedAsString("<p><a>abc</a></p>"), "<p><a>abc</a></p>");
    }

    public function testManyRootNodes()
    {
        this.assertEquals(this.getParsedAsString("<p>abc</p>TEXT<a>def</a>"), "<p>abc</p>TEXT<a>def</a>");
    }

    public function testComment()
    {
        var nodes = HtmlParser.run("<a><!-- comment<p></p> --></a>");
        this.assertEquals(1, nodes.length);
        this.assertTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
        
        var node : HtmlNodeElement = cast nodes[0];
        var subnodes = node.nodes;
        this.assertEquals(1, subnodes.length);
        this.assertTrue(Type.getClass(subnodes[0]) == HtmlNodeText);
    }
    
    #if sys
	public function testComplexParseA()
    {
		var s = File.getContent('inputA.html');
		File.saveContent("outputA.html", getParsedAsString(s));
		assertEquals(s, File.getContent('outputA.html'));
    }
	
	public function testComplexParseB()
    {
		var s = File.getContent('inputB.html');
		var r = getParsedAsString(s, true);
		assertTrue(r != null && r != "");
    }
	#end
	
	public function testTolerantA()
    {
        assertEquals("<div><form></form></div>", getParsedAsString("<div><form></div>", true));
    }
	
	public function testTolerantB()
    {
        assertEquals("<div></div>", getParsedAsString("<div></form></div>", true));
    }
	
	public function testTolerantC()
    {
        assertEquals("<form><div></div></form>", getParsedAsString("<form><div></form></div>", true));
    }
	
	public function testTolerantD()
    {
        assertEquals
		(
			                  "<div><dl><dd>D</dd></dl><a>A</a></div>",
			getParsedAsString("<div><dl><dd>D</dl><a>A</a></div>", true)
		);
    }
	
	public function testNotTolerantA()
    {
        try getParsedAsString("<div><form></div>")
		catch (_:Dynamic) { assertTrue(true); return; }
		assertTrue(false);
    }
	
	public function testNotTolerantB()
    {
        try getParsedAsString("<div></form></div>")
		catch (_:Dynamic) { assertTrue(true); return; }
		assertTrue(false);
    }
	
	public function testNotTolerantC()
    {
        try getParsedAsString("<form><div></form></div>")
		catch (_:Dynamic) { assertTrue(true); return; }
		assertTrue(false);
    }
    
    public function testSelectors()
    {
        var xml = new HtmlDocument("<div class='first second'><p id='myp' class='first'><a href='b'>cde</a></p></div>");
        
        var nodes = xml.find('');
        this.assertEquals(0, nodes.length);
        
        var nodes = xml.find('div');
        this.assertEquals(1, nodes.length);
        
        var divs = xml.find('div');
        nodes = divs[0].find('div');
        this.assertEquals(0, nodes.length);
        
        nodes = divs[0].find('*');
        this.assertEquals(2, nodes.length);
        
        nodes = xml.find('#no');
        this.assertEquals(0, nodes.length);

        nodes = xml.find('.no');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('a');
        this.assertEquals(1, nodes.length);
        this.assertEquals('a', nodes[0].name);
        this.assertEquals('b', nodes[0].getAttribute('href'));
        
        nodes = xml.find('.first');
        this.assertEquals(2, nodes.length);
        this.assertEquals('p', nodes[0].name);
        this.assertEquals('div', nodes[1].name);
        
        nodes = xml.find('.first.second');
        this.assertEquals(1, nodes.length);
        this.assertEquals('div', nodes[0].name);
        
        nodes = xml.find('#myp');
        this.assertEquals(1, nodes.length);
        this.assertEquals('p', nodes[0].name);
        
        nodes = xml.find('.first#myp');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('.second#myp');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.first.second a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('.first.second>a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.first.second >a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.second>a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.second a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('.first>a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('div>p>a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('div>a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('div>*>a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('*');
        this.assertEquals(3, nodes.length);
        
        nodes = xml.find('a,p');
        this.assertEquals(2, nodes.length);
        
        nodes = xml.find('a , p');
        this.assertEquals(2, nodes.length);
        
        nodes = xml.find('a, a');
        this.assertEquals(1, nodes.length);
        
		nodes = xml.find('div>p>a[0]');
        this.assertEquals(0, nodes.length);
		
		nodes = xml.find('div>p>a[1]');
        this.assertEquals(1, nodes.length);
		
		nodes = xml.find('div>p>a[2]');
        this.assertEquals(0, nodes.length);
		
		nodes = xml.find('div>p>a[3]');
        this.assertEquals(0, nodes.length);
    }

    public function testSiblings()
    {
        var xml = new HtmlDocument("<br />\n        <div id='m'>test</div>");
        var nodes = xml.find("#m");
		
        this.assertEquals(1, nodes.length);
		this.assertTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
        
		var node = nodes[0];
        this.assertEquals("m", node.getAttribute('id'));
        
		var prev = node.getPrevSiblingNode();
		this.assertTrue(Type.getClass(prev) == HtmlNodeText);
        this.assertEquals("\n        ", cast(prev, HtmlNodeText).text);
    }
	
	public function testStyle()
	{
		var html = "
<style>
    .randnum
    {
        color: blue;
    }
</style>

<div id='n'>0</div>
";

		var xml = new HtmlDocument(html);
		assertEquals(2, xml.children.length);
        
		var nodes = xml.find("#n");
        assertEquals(1, nodes.length);
		assertTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
	}
	
	public function testReplaceChildWithInner()
	{
		var xml = new HtmlDocument("b<ph>c</ph>d<con>e</con>");
		
		var nodesPH = xml.find("ph");
		assertEquals(1, nodesPH.length);
		assertEquals(0, nodesPH[0].children.length);
		
		var nodesCON = xml.find("con");
		assertEquals(1, nodesCON.length);
		assertEquals(0, nodesCON[0].children.length);
		
		xml.replaceChildWithInner(nodesPH[0], nodesCON[0]);
		assertEquals("bed<con>e</con>", xml.innerHTML);
		assertEquals(1, xml.children.length);
	}
	
	public function testRemove()
	{
		var xml = new HtmlDocument("<a></a><b></b><c></c>");
		assertEquals(3, xml.children.length);
		assertEquals(3, xml.nodes.length);
		
		var nodes = xml.find(">b");
		assertTrue(nodes != null);
		assertTrue(nodes.length == 1);
		nodes[0].remove();
		
		assertEquals(2, xml.children.length);
		assertEquals(2, xml.nodes.length);
	}
	
	public function testHeader()
	{
		var xml = new HtmlDocument("<?xml version='1.0' encoding='UTF-8'?><doc>abc</doc>");
		assertEquals(1, xml.children.length);
		assertEquals(2, xml.nodes.length);
		assertTrue(Std.is(xml.nodes[0], HtmlNodeText));
		assertTrue(Std.is(xml.nodes[1], HtmlNodeElement));
	}
	
	public function testNamespacedAttr()
	{
		var xml = new HtmlDocument("<S:Envelope xmlns:S=\"abc\"><S:Body><ns2:OperationHistoryData xmlns:ns2=\"def\"/></S:Body></S:Envelope>");
		assertEquals(1, xml.children.length);
		assertEquals(1, xml.nodes.length);
	}
	
	public function testTagCase()
	{
		var xml = new HtmlDocument("<A />");
		
		var r = xml.find("A");
		assertEquals(1, r.length);
		
		r = xml.find("a");
		assertEquals(1, r.length);
	}
	
	public function testBadXmlA()
	{
		try
		{
			new HtmlDocument("<root><link></link></root>");
		}
		catch (_:Dynamic)
		{
			assertTrue(true);
			return;
		}
		assertTrue(false);
	}
	
	public function testBoolAttrA()
	{
		var doc = new HtmlDocument("<a><b disabled></b></a>");
		var bb = doc.find(">a>b");
		assertEquals(1, bb.length);
		assertTrue(bb[0].hasAttribute("disabled"));
		assertEquals(null, bb[0].getAttribute("disabled"));
	}
	
	public function testBoolAttrB()
	{
		var doc = new HtmlDocument("<a><b disabled new-attr></b></a>");
		var bb = doc.find(">a>b");
		assertEquals(1, bb.length);
		assertTrue(bb[0].hasAttribute("disabled"));
		assertTrue(bb[0].hasAttribute("new-attr"));
		assertEquals(null, bb[0].getAttribute("disabled"));
		assertEquals(null, bb[0].getAttribute("new-attr"));
	}
	
	/*
	#if sys
	public function testSpeed()
    {
        var str = File.getContent('support/input.html');
        var loops = 1000;
        
        var start = Date.now();
		for (i in 0...loops)
        {
            var xml = new HtmlDocument(str);
        }
        var parseTime = (Date.now().getTime() - start.getTime()) / loops;
		
        var xml = new HtmlDocument(str);
        var ser = new Serializer();
		ser.useCache = true;
		ser.serialize(xml);
		var saved = ser.toString();
        start = Date.now();
        for (i in 0...loops)
        {
            xml = Unserializer.run(saved);
        }
        var unserializeTime = (Date.now().getTime() - start.getTime()) / loops;
        
		print("[time parse/unserialize: " + parseTime + "/" + unserializeTime + "]");
		
		assertTrue(true);
    }
	#end
	*/
}
