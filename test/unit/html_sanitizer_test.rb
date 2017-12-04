
require 'test_helper'

class HtmlSanitizerTest < ActiveSupport::TestCase

  test 'xss' do
    assert_equal(HtmlSanitizer.strict('<b>123</b>'), '<b>123</b>')
    assert_equal(HtmlSanitizer.strict('<script><b>123</b></script>'), '&lt;b&gt;123&lt;/b&gt;')
    assert_equal(HtmlSanitizer.strict('<script><style><b>123</b></style></script>'), '&lt;style&gt;&lt;b&gt;123&lt;/b&gt;&lt;/style&gt;')
    assert_equal(HtmlSanitizer.strict('<abc><i><b>123</b><bbb>123</bbb></i></abc>'), '<i><b>123</b>123</i>')
    assert_equal(HtmlSanitizer.strict('<abc><i><b>123</b><bbb>123<i><ccc>abc</ccc></i></bbb></i></abc>'), '<i><b>123</b>123<i>abc</i></i>')
    assert_equal(HtmlSanitizer.strict('<not_existing>123</not_existing>'), '123')
    assert_equal(HtmlSanitizer.strict('<script type="text/javascript">alert("XSS!");</script>'), 'alert("XSS!");')
    assert_equal(HtmlSanitizer.strict('<SCRIPT SRC=http://xss.rocks/xss.js></SCRIPT>'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC="javascript:alert(\'XSS\');">'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC=javascript:alert(\'XSS\')>'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC=JaVaScRiPt:alert(\'XSS\')>'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC=`javascript:alert("RSnake says, \'XSS\'")`>'), '')
    assert_equal(HtmlSanitizer.strict('<IMG """><SCRIPT>alert("XSS")</SCRIPT>">'), '<img>alert("XSS")"&gt;')
    assert_equal(HtmlSanitizer.strict('<IMG SRC=# onmouseover="alert(\'xxs\')">'), '<img src="#">')
    assert_equal(HtmlSanitizer.strict('<IMG SRC="jav  ascript:alert(\'XSS\');">'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC="jav&#x09;ascript:alert(\'XSS\');">'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC="jav&#x0A;ascript:alert(\'XSS\');">'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC="jav&#x0D;ascript:alert(\'XSS\');">'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC=" &#14;  javascript:alert(\'XSS\');">'), '<img src="">')
    assert_equal(HtmlSanitizer.strict('<SCRIPT/XSS SRC="http://xss.rocks/xss.js"></SCRIPT>'), '')
    assert_equal(HtmlSanitizer.strict('<BODY onload!#$%&()*~+-_.,:;?@[/|\]^`=alert("XSS")>'), '')
    assert_equal(HtmlSanitizer.strict('<SCRIPT/SRC="http://xss.rocks/xss.js"></SCRIPT>'), '')
    assert_equal(HtmlSanitizer.strict('<<SCRIPT>alert("XSS");//<</SCRIPT>'), '&lt;alert("XSS");//&lt;')
    assert_equal(HtmlSanitizer.strict('<SCRIPT SRC=http://xss.rocks/xss.js?< B >'), '')
    assert_equal(HtmlSanitizer.strict('<SCRIPT SRC=//xss.rocks/.j>'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC="javascript:alert(\'XSS\')"'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC="javascript:alert(\'XSS\')" abc<b>123</b>'), '123')
    assert_equal(HtmlSanitizer.strict('<iframe src=http://xss.rocks/scriptlet.html <'), '')
    assert_equal(HtmlSanitizer.strict('</script><script>alert(\'XSS\');</script>'), 'alert(\'XSS\');')
    assert_equal(HtmlSanitizer.strict('<STYLE>li {list-style-image: url("javascript:alert(\'XSS\')");}</STYLE><UL><LI>XSS</br>'), '<ul><li>XSS</li></ul>')
    assert_equal(HtmlSanitizer.strict('<IMG SRC=\'vbscript:msgbox("XSS")\'>'), '')
    assert_equal(HtmlSanitizer.strict('<IMG SRC="livescript:[code]">'), '')
    assert_equal(HtmlSanitizer.strict('<svg/onload=alert(\'XSS\')>'), '')
    assert_equal(HtmlSanitizer.strict('<BODY ONLOAD=alert(\'XSS\')>'), '')
    assert_equal(HtmlSanitizer.strict('<LINK REL="stylesheet" HREF="javascript:alert(\'XSS\');">'), '')
    assert_equal(HtmlSanitizer.strict('<STYLE>@import\'http://xss.rocks/xss.css\';</STYLE>'), '')
    assert_equal(HtmlSanitizer.strict('<META HTTP-EQUIV="Link" Content="<http://xss.rocks/xss.css>; REL=stylesheet">'), '')
    assert_equal(HtmlSanitizer.strict('<IMG STYLE="java/*XSS*/script:(alert(\'XSS\'), \'\')">'), '<img>')
    assert_equal(HtmlSanitizer.strict('<IMG src="java/*XSS*/script:(alert(\'XSS\'), \'\')">'), '')
    assert_equal(HtmlSanitizer.strict('<IFRAME SRC="javascript:alert(\'XSS\');"></IFRAME>'), '')
    assert_equal(HtmlSanitizer.strict('<TABLE><TD BACKGROUND="javascript:alert(\'XSS\')">'), '<table><td></td></table>')
    assert_equal(HtmlSanitizer.strict('<DIV STYLE="background-image: url(javascript:alert(\'XSS\'), \'\')">'), '<div></div>')
    assert_equal(HtmlSanitizer.strict('<a href="/some/path">test</a>'), 'test (<a href="/some/path">/some/path</a>)')
    assert_equal(HtmlSanitizer.strict('<a href="https://some/path">test</a>'), 'test (<a href="https://some/path" rel="nofollow noreferrer noopener" target="_blank">https://some/path</a>)')
    assert_equal(HtmlSanitizer.strict('<a href="https://some/path">test</a>', true), 'test (<a href="https://some/path" rel="nofollow noreferrer noopener" target="_blank">https://some/path</a>)')
    assert_equal(HtmlSanitizer.strict('<XML ID="xss"><I><B><IMG SRC="javas<!-- -->cript:alert(\'XSS\')"></B></I></XML>'), '<i><b></b></i>')
    assert_equal(HtmlSanitizer.strict('<IMG SRC="javas<!-- -->cript:alert(\'XSS\')">'), '')
    assert_equal(HtmlSanitizer.strict(' <HEAD><META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=UTF-7"> </HEAD>+ADw-SCRIPT+AD4-alert(\'XSS\');+ADw-/SCRIPT+AD4-'), '  +ADw-SCRIPT+AD4-alert(\'XSS\');+ADw-/SCRIPT+AD4-')
    assert_equal(HtmlSanitizer.strict('<SCRIPT a=">" SRC="httx://xss.rocks/xss.js"></SCRIPT>'), '')
    assert_equal(HtmlSanitizer.strict('<A HREF="h
tt  p://6 6.000146.0x7.147/">XSS</A>'), 'XSS (<a href="http://66.000146.0x7.147/" rel="nofollow noreferrer noopener" target="_blank">http://66.000146.0x7.147/</a>)')
    assert_equal(HtmlSanitizer.strict('<A HREF="h
tt  p://6 6.000146.0x7.147/">XSS</A>', true), 'XSS (<a href="http://66.000146.0x7.147/" rel="nofollow noreferrer noopener" target="_blank">http://66.000146.0x7.147/</a>)')
    assert_equal(HtmlSanitizer.strict('<A HREF="//www.google.com/">XSS</A>'), 'XSS (<a href="//www.google.com/" rel="nofollow noreferrer noopener" target="_blank">//www.google.com/</a>)')
    assert_equal(HtmlSanitizer.strict('<A HREF="//www.google.com/">XSS</A>', true), 'XSS (<a href="//www.google.com/" rel="nofollow noreferrer noopener" target="_blank">//www.google.com/</a>)')
    assert_equal(HtmlSanitizer.strict('<form id="test"></form><button form="test" formaction="javascript:alert(1)">X</button>'), 'X')
    assert_equal(HtmlSanitizer.strict('<maction actiontype="statusline#http://google.com" xlink:href="javascript:alert(2)">CLICKME</maction>'), 'CLICKME')
    assert_equal(HtmlSanitizer.strict('<a xlink:href="javascript:alert(2)">CLICKME</a>'), 'CLICKME')
    assert_equal(HtmlSanitizer.strict('<a xlink:href="javascript:alert(2)">CLICKME</a>', true), 'CLICKME')
    assert_equal(HtmlSanitizer.strict('<!--<img src="--><img src=x onerror=alert(1)//">'), '<img src="x">')
    assert_equal(HtmlSanitizer.strict('<![><img src="]><img src=x onerror=alert(1)//">'), '<img src="%5D&gt;&lt;img%20src=x%20onerror=alert(1)//">')
    assert_equal(HtmlSanitizer.strict('<svg><![CDATA[><image xlink:href="]]><img src=xx:x onerror=alert(2)//"></svg>'), '')
    assert_equal(HtmlSanitizer.strict('<abc><img src="</abc><img src=x onerror=alert(1)//">'), '<img src="&lt;/abc&gt;&lt;img%20src=x%20onerror=alert(1)//">')
    assert_equal(HtmlSanitizer.strict('<object data="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=="></object>'), '')
    assert_equal(HtmlSanitizer.strict('<embed src="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=="></embed>'), '')
    assert_equal(HtmlSanitizer.strict('<img[a][b]src=x[d]onerror[c]=[e]"alert(1)">'), '<img>')
    assert_equal(HtmlSanitizer.strict('<a href="[a]java[b]script[c]:alert(1)">XXX</a>'), 'XXX')
    assert_equal(HtmlSanitizer.strict('<a href="[a]java[b]script[c]:alert(1)">XXX</a>', true), 'XXX')
    assert_equal(HtmlSanitizer.strict('<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script></svg>'), 'alert(1)')
    assert_equal(HtmlSanitizer.strict('<a style="position:fixed;top:0;left:0;width: 260px;height:100vh;background-color:red;display: block;" href="http://example.com"></a>'), '<a href="http://example.com" rel="nofollow noreferrer noopener" target="_blank">http://example.com</a>')
    assert_equal(HtmlSanitizer.strict('<a style="position:fixed;top:0;left:0;width: 260px;height:100vh;background-color:red;display: block;" href="http://example.com"></a>', true), '<a href="http://example.com" rel="nofollow noreferrer noopener" target="_blank">http://example.com</a>')
    assert_equal(HtmlSanitizer.strict('<div>
<style type="text/css">#outlook A {
.content { WIDTH: 100%; MAX-WIDTH: 740px }
A { COLOR: #666666; TEXT-DECORATION: none }
A:link { COLOR: #666666; TEXT-DECORATION: none }
A:hover { COLOR: #666666; TEXT-DECORATION: none }
A:active { COLOR: #666666; TEXT-DECORATION: none }
A:focus { COLOR: #666666; TEXT-DECORATION: none }
BODY { FONT-FAMILY: Calibri, Arial, Verdana, sans-serif }
</style>
<!--[if (gte mso 9)|(IE)]>
<META name=GENERATOR content="MSHTML 9.00.8112.16800"></HEAD>
<BODY bgColor=#ffffff>
<DIV><FONT size=2 face=Arial></FONT>&nbsp;</DIV>
<BLOCKQUOTE
style="BORDER-LEFT: #000000 2px solid; PADDING-LEFT: 5px; PADDING-RIGHT: 0px; MARGIN-LEFT: 5px; MARGIN-RIGHT: 0px">
  <DIV style="FONT: 10pt arial">----- Original Message ----- </DIV>
  <DIV style="FONT: 10pt arial"><B>To:</B> <A title=smith.test@example.dk
  href="mailto:smith.test@example.dk">smith.test@example.dk</A> </DIV>
  <DIV style="FONT: 10pt arial"><B>Sent:</B> Friday, November 10, 2017 9:11
  PM</DIV>
  <DIV style="FONT: 10pt arial"><B>Subject:</B> Din bestilling hos
  example.dk - M123 - KD1234</DIV>
  <div>&nbsp;</div>
<![endif]-->test 123
<blockquote></div>'), '<div>

test 123
<blockquote></blockquote>
</div>')

  end

end
