<?xml version="1.0" encoding="UTF-8"?>

<!-- 
    Version: 0.1
-->

<!--
    Copyright (c) 2012, Cryptonector, LLC.
    All rights reserved.
   
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
   
    - Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
   
    - Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the
      distribution.
   
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
    INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
    STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
    OF THE POSSIBILITY OF SUCH DAMAGE.
-->

<!DOCTYPE xsl:stylesheet [ ]>
<xsl:stylesheet version="2.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns="xml2rfc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:rfc="xml2rfc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="rfc"
    >

<!-- 
    This XSLT stylesheet applies to LyX native XHTML output and converts
    it into xml2rfc's input schema.
-->
<!--<xsl:import href="trim-simple.xsl"/>-->

<xsl:variable name="months">
    <m>January</m><m>February</m><m>March</m><m>April</m>
    <m>May</m><m>June</m><m>July</m><m>August</m>
    <m>September</m><m>October</m><m>November</m><m>December</m>
</xsl:variable>

<xsl:output method="xml" omit-xml-declaration="no"/>

<xsl:template match="/">
    <!-- Emit processing instructions -->
    <xsl:apply-templates select="//div[starts-with(@class, 'flex_pi_')]"/>
    <xsl:apply-templates select="//div[starts-with(@class, 'flex_pi')]"/>

    <!-- Emit toc="yes" PI by default -->
    <xsl:if test="not(//div[starts-with(@class, 'flex_pi_toc')]) and
                  not(//div[@class = 'flex_pi' and starts-with(normalize-space(.), 'toc=')])">
        <xsl:processing-instruction name="rfc">
            <xsl:text>toc="yes"</xsl:text>
        </xsl:processing-instruction>
    </xsl:if>

    <!-- Emit symrefs="yes" PI by default -->
    <xsl:if test="not(//div[starts-with(@class, 'flex_pi_symrefs')]) and
                  not(//div[@class = 'flex_pi' and starts-with(normalize-space(.), 'symrefs=')])">
        <xsl:processing-instruction name="rfc">
            <xsl:text>symrefs="yes"</xsl:text>
        </xsl:processing-instruction>
    </xsl:if>

    <!-- Emit the rfc element and its contents -->
    <xsl:apply-templates select="html"/>
</xsl:template>

<xsl:template match="html">
    <!-- Emit DOCTYPE -->
    <xsl:text>&#xA;</xsl:text>
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE rfc SYSTEM "rfc2629.dtd" [</xsl:text>
    <xsl:text>&#xA;</xsl:text>

    <!-- Emit XML ENTITY declarations for bibxml references -->
    <xsl:for-each
        select="//div[@class = 'flex_bibxml']//a[ends-with(@href, '.xml')]">
        <!-- NOTE: For some reason moving this into templates causes the
             ENTITY generation to fail... -->
        <xsl:text disable-output-escaping="yes">
            &lt;!ENTITY </xsl:text>

        <!-- Entity name -->
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text disable-output-escaping="yes"> PUBLIC "" "</xsl:text>

        <!-- URL -->
        <xsl:value-of select="./@href"/>
        <xsl:text disable-output-escaping="yes">"&gt;&#xA;</xsl:text>
    </xsl:for-each>

    <!-- Emit DOCTYPE close -->
    <xsl:text disable-output-escaping="yes">&#xA;]&gt;&#xA;</xsl:text>

    <!-- Emit <rfc> element -->
    <xsl:element name="rfc">
        <xsl:attribute name="docName"><xsl:value-of
                select="normalize-space(body//div[@class='flex_docname']/div)"/>
        </xsl:attribute>
        <xsl:attribute name="ipr"><xsl:value-of
                select="normalize-space(body//div[@class='flex_ipr']/div)"/>
        </xsl:attribute>
        <xsl:attribute name="category"><xsl:value-of
                select="normalize-space(body//div[@class='flex_intendedstatus']/div)"/>
        </xsl:attribute>

        <!-- Emit <front> element -->
        <xsl:element name="front">
            <!-- Grab the title -->
            <xsl:element name="title">
                <xsl:if test="//div[@class = 'flex_titleabbrev']">
                    <xsl:attribute name="abbrev"
                        select="normalize-space(//div[@class = 'flex_titleabbrev'])"/>
                </xsl:if>
                <xsl:value-of select="./head/title"/>
            </xsl:element>

            <!-- Emit the <author> elements -->
            <xsl:apply-templates select="//div[@class='author']/div[@class='author_item']"/>

            <!-- Emit <date> -->
            <xsl:element name="date">
                <xsl:attribute name="month"
                    select="$months/rfc:m[number(month-from-dateTime(current-dateTime()))]"/>
                <xsl:attribute name="year"
                    select="year-from-dateTime(current-dateTime())"/>
            </xsl:element>

            <!-- Emit <area> and <workgroup> elements -->
            <xsl:apply-templates select=".//div[starts-with(@class, 'flex_ietf')]"/>

            <!-- Emit <keyword> element -->
            <xsl:element name="keyword">
                <xsl:value-of select="normalize-space(.//div[@class='flex_xml_rfckeyword'])"/>
            </xsl:element>

            <!-- Grab the abstract (should use apply-templates instead
                 of for-each...) -->
            <xsl:element name="abstract">
                <xsl:for-each select="//div[@class='abstract_item']">
                    <xsl:element name="t">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>

        <!-- Process middle and back matter -->
        <xsl:apply-templates select="body"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_ietfarea']">
    <xsl:element name="area">
        <xsl:value-of select="."/>
    </xsl:element>
</xsl:template>
<xsl:template match="div[@class='flex_ietfworkinggroup']">
    <xsl:element name="workgroup">
        <xsl:value-of select="."/>
    </xsl:element>
</xsl:template>

<!-- Process middle and back matter -->
<xsl:template match="body">
    <!-- Middle matter (only top-level sections; the matching templates
         will recurse to get subsections and subsubsections). -->
    <xsl:element name="middle">
        <xsl:apply-templates
            select="h2[not(matches(normalize-space(string-join(text(), '')), '^(Normative |Informative |)References')) and
                not(matches(span, '^[A-Z].*'))]"/>
    </xsl:element>

    <!-- Back matter -->
    <xsl:element name="back">

        <!-- References -->
        <xsl:apply-templates
            select="h2[matches(normalize-space(string-join(text(), '')), '^(Normative |Informative |)References')]"/>

        <!-- Appendices, but don't include references since we've
             already handled those (just in case the references sections
             were made into appendices) -->
        <xsl:apply-templates
            select="h2[matches(span, '^[A-Z].*') and
                not(matches(normalize-space(string-join(text(), '')), '^(Normative |Informative |)References'))]"/>
    </xsl:element>
</xsl:template>

<!-- We don't have any use for the style elements in xml2rfc -->
<xsl:template match="style"/>
<!-- xml2rfc has its own way of handling toc, see PIs -->
<xsl:template match="div[@class='toc']"/>
<!-- Strip out things for the front matter that we handle above -->
<xsl:template match="h1[@class='title']"/>
<xsl:template match="div[@class='abstract']"/>

<!-- LyXHTML uses span elements for things we don't care about, like
     section numbering (but we do use that to distinguish between normal
     sections and appendices!).  Also ignore the table of contents and
     automatically-generated anchors.  -->
<xsl:template match="span"/>
<xsl:template match="div[@class='toc']"/>
<xsl:template match="a[starts-with(@id, 'magicparlabel-')]"/>

<!-- Plain paragraphs -->
<xsl:template match="div[@class='standard']">
    <xsl:choose>
        <xsl:when test="./table/tbody">
            <!-- Tables are generated inside an otherwise empty div with
                 class='standard'.  We don't want to generate an
                 unnecessary <t></t> around the <texttable>.  -->
            <xsl:apply-templates select="child::table"/>
        </xsl:when>
        <xsl:when test="..[name() = 'li']">
            <!-- Paragraphs in list items should generate vspace
                 elements but no t elements.  -->
                 <xsl:element name="vspace">
                     <xsl:attribute name="blankLines">1</xsl:attribute>
                 </xsl:element>
                 <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="t">
                <!-- Applies templates to the text() nodes and child elements in
                     order.  This is important.  Selecting the string-join() of
                     text() then applying templates to children would cause
                     <xref>s, <em>s, <a>s, and such to be added at the
                     end of the paragraphs, which would be incorrect.  -->
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- XXX What was this about? XXX Remove? -->
<xsl:template match="text()[starts-with(., ']') or ends-with(., '[')]">
    <xsl:value-of select="replace(replace(., '\[$', ''), '^\]', '')"/>
</xsl:template>

<!-- crefs (editorial comments) -->
<xsl:template match="div[@class='revisionremark']">
    <xsl:element name="t">
        <xsl:element name="cref">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:element>
</xsl:template>

<!-- xrefs to bibxml (citations) -->
<xsl:template match="div[@class = 'flex_entityxref']">
    <xsl:element name="xref">
        <xsl:attribute name="target">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<!-- Emphasis (<spanx>) -->
<xsl:template match="em">
    <xsl:element name="spanx">
        <xsl:attribute name="style" select="emph"/>
        <xsl:apply-templates/>
    </xsl:element>
    <xsl:text> </xsl:text>
</xsl:template>

<!-- Lists! -->
<xsl:template match="ul[../name() != 'dd' and ../name() != 'li']">
    <!-- Unnumbered list NOT nested in a another list -->
    <xsl:element name="t">
        <xsl:element name="list">
            <xsl:attribute name="style">symbols</xsl:attribute>
            <xsl:apply-templates select="li"/>
        </xsl:element>
    </xsl:element>
</xsl:template>
<xsl:template match="ul[../name() = 'dd' or ../name() = 'li']">
    <!-- Unnumbered list nested in a list.  In a nested list we don't
         want to nest <t> in <t>. -->
    <xsl:element name="list">
        <xsl:attribute name="style">symbols</xsl:attribute>
        <xsl:apply-templates select="li"/>
    </xsl:element>
</xsl:template>

<!-- Ditto numbered lists -->
<xsl:template match="ol[../name() != 'dd' and ../name() != 'li']">
    <xsl:element name="t">
        <xsl:element name="list">
            <xsl:attribute name="style">numbers</xsl:attribute>
            <xsl:apply-templates select="li"/>
        </xsl:element>
    </xsl:element>
</xsl:template>
<xsl:template match="ol[../name() = 'dd' or ../name() = 'li']">
    <xsl:element name="list">
        <xsl:attribute name="style">numbers</xsl:attribute>
        <xsl:apply-templates select="li"/>
    </xsl:element>
</xsl:template>

<!-- List elements -->
<xsl:template match="li">
    <xsl:element name="t">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<!-- Description lists -->
<xsl:template match="dl">
    <xsl:element name="t">
        <xsl:element name="list">
            <xsl:attribute name="style">hanging</xsl:attribute>
            <xsl:apply-templates select="dt"/>
        </xsl:element>
    </xsl:element>
</xsl:template>

<!-- Description list elements -->
<xsl:template match="dt">
    <xsl:element name="t">
        <!-- Since the dt goes in an attribute value using
             apply-templates here seems risky - we'd have to have a
             predicate on various templates checking that we're a child
             (or not) of a <dt> element.  If not risky, then at least
             very verbose. -->
        <xsl:attribute name="hangText" select="."/>
        <!-- Grab the immediately following dd element -->
        <xsl:apply-templates select="(following-sibling::dd)[1]"/>
    </xsl:element>
</xsl:template>
<xsl:template match="dd">
    <!-- Whereas here it's safe to apply-templates -->
    <xsl:apply-templates/>
</xsl:template>

<!-- Figures (we only really support ASCII figures) -->
<xsl:template match="div[@class='float float-figure']">
    <xsl:element name="t">
        <xsl:element name="figure">
            <!-- Any anchor will do, but hopefully we have one added by
                 the author -->
            <xsl:attribute name="anchor" select="(.//div/a/@id)[last()]"/>

            <!-- The actual figure (no need to deal with escaping!) -->
            <xsl:element name="artwork">
                <xsl:value-of select="div/pre"/>
            </xsl:element>

            <!-- Caption -->
            <xsl:element name="postamble">
                <xsl:value-of select="div/div[@class='float-caption float-caption-figure']"/>
            </xsl:element>
        </xsl:element>
    </xsl:element>
</xsl:template>

<!-- xrefs (internal cross-references) -->
<xsl:template match="a[@href and starts-with(@href, '#')]">
    <!-- We add a space here to avoid running this xref onto the end of
         the preceding text() node. -->
    <xsl:text> </xsl:text>
    <xsl:element name="xref">
        <xsl:attribute name="target">
            <xsl:value-of select="substring(./@href, 2)"/>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<!-- erefs -->
<xsl:template match="a[@href and not(starts-with(@href, '#')) and ../..[name() != 'div' or @class != 'flex_bibxml']]">
    <xsl:element name="eref">
        <xsl:attribute name="target">
            <xsl:value-of select="./@href"/>
        </xsl:attribute>
    </xsl:element>
</xsl:template>

<!-- Tables -->
<xsl:template match="table">
    <xsl:apply-templates select="tbody"/>
</xsl:template>
<xsl:template match="tbody">
    <xsl:element name="texttable">
        <!-- Anyways, so xml2rfc has no row element to contain column
             values, which is very strange and prevents one column value
             from spanning several columns, for example.  So first we
             generate column declarations (<ttcol> elements) for the
             columns (taken from the first row from the XHTML), then we
             generate column values (<c> elements) for all the <td>s
             from subsequent rows.  -->
        <!-- XXX This would probably be best done with apply-templates
             so that we can apply further templates as necessary. -->
        <xsl:for-each select='tr[position() = 1]/td/div'>
            <xsl:element name="ttcol">
                <xsl:apply-templates select="../@align"/>
                <!-- XXX Could this be an apply-templates?  Maybe...  -->
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="tr[position() > 1]/td/div">
            <xsl:element name="c">
                <!-- XXX Could this be an apply-templates?  Maybe...  -->
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
    </xsl:element>
</xsl:template>
<xsl:template match="@align">
    <xsl:attribute name="align">
        <xsl:value-of select="."/>
    </xsl:attribute>
</xsl:template>

<!-- Sections -->

<!-- XXX I could generalize this so one template handles h2, h3, and
     h4.  I could have an xsl:variable to hold a cast-as-integer form of
     the N in hN, then in the sub-sections XPath expression match on
     hN+1...  -->

<xsl:template match="h2[matches(@class, '^section') and
    not(matches(normalize-space(string-join(text(), '')), '^(Normative |Informative |)References'))]">
    <xsl:element name="section">
        <!-- LyXHTML sadly adds unnecessary newlines to hN elements'
             text nodes -->
        <xsl:attribute name="title"
            select="normalize-space(string-join(text(), ''))"/>

        <!-- Make sure there's an anchor -->
        <xsl:variable name="id"
            select="a[not(starts-with(@id, 'magicparlabel-'))]/@id"/>
        <xsl:attribute name="anchor"
            select="if (string-length($id) > 0) then $id else generate-id()"/>

        <!-- We refer to this <h2> in various XPath contexts below where
             current() will no longer be this <h2>, so we need to save it -->
        <xsl:variable name="cur_sect" select="current()"/>

        <!-- Handle the contents of just this section.  Ask for all
             siblings of this <h2> where the nodes we're looking for are
             NOT h2/h3/h4, and their preceding <h2> is this one. -->
        <xsl:apply-templates
            select="(following-sibling::*[not(matches(name(), '^h[234]')) and
                (preceding-sibling::*[matches(name(), '^h[234]')])[last()] is $cur_sect])"/>

        <!-- Handle sub-sections of this section.  Ask for all sibling
             h3 (and h4) nodes of this h2 where their preceding h2 is
             this one.  -->
        <xsl:apply-templates 
            select="following-sibling::*[matches(name(), '^h[34]') and
                (preceding-sibling::h2)[last()] is $cur_sect]"/>

    </xsl:element>
</xsl:template>

<xsl:template match="h3[starts-with(@class, 'subsection')]">
    <xsl:element name="section">
        <xsl:attribute name="title"
            select="normalize-space(string-join(text(), ''))"/>
        <xsl:variable name="id"
            select="a[not(starts-with(@id, 'magicparlabel-'))]/@id"/>
        <xsl:attribute name="anchor"
            select="if (string-length($id) > 0) then $id else generate-id()"/>
        <xsl:variable name="cur_sect" select="current()"/>

        <!-- Handle the contents of just this section  -->
        <xsl:apply-templates
            select="(following-sibling::*[not(matches(name(), '^h[234]')) and
                (preceding-sibling::*[matches(name(), '^h[234]')])[last()] is $cur_sect])"/>

        <!-- Handle sub-sections of this section -->
        <xsl:apply-templates 
            select="following-sibling::h4[(preceding-sibling::h2)[last()] is $cur_sect]"/>

    </xsl:element>
</xsl:template>

<xsl:template match="h4[starts-with(@class, 'subsubsection')]">
    <xsl:element name="section">
        <xsl:attribute name="title"
            select="normalize-space(string-join(text(), ''))"/>
        <xsl:variable name="id"
            select="a[not(starts-with(@id, 'magicparlabel-'))]/@id"/>
        <xsl:attribute name="anchor"
            select="if (string-length($id) > 0) then $id else generate-id()"/>
        <xsl:variable name="cur_sect" select="current()"/>

        <!-- Handle the contents of just this section  -->
        <xsl:apply-templates
            select="(following-sibling::*[not(matches(name(), '^h[234]')) and
                (preceding-sibling::*[matches(name(), '^h[234]')])[last()] is $cur_sect])"/>

        <!-- There are no sub-sub-subsections -->
    </xsl:element>
</xsl:template>

<!-- References -->

<xsl:template match="h2[matches(normalize-space(string-join(text(), '')), '^(Normative |Informative |)References')]">
    <xsl:element name="references">
        <xsl:attribute name="title"
            select="normalize-space(string-join(text(), ''))"/>
        <xsl:variable name="id"
            select="a[not(starts-with(@id, 'magicparlabel-'))]/@id"/>
        <xsl:attribute name="anchor"
            select="if (string-length($id) > 0) then $id else generate-id()"/>
        <xsl:variable name="cur_sect" select="current()"/>

        <xsl:apply-templates
            select="(following-sibling::div[
                (preceding-sibling::*[matches(name(), '^h[234]')])[last()] is $cur_sect]/div[
                @class = 'flex_bibxml']/div/a)"/>

        <!-- Sorry, no sub-sections for references, though there have
             been I-Ds and RFCs with such sub-sections.  Make this a
             TODO. -->
    </xsl:element>
</xsl:template>

<!-- Emit processing instructions -->
<xsl:template match="div[starts-with(@class, 'flex_pi_')]">
    <xsl:processing-instruction name="rfc">
        <xsl:value-of select="replace(@class, '^flex_pi_', '')"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>"</xsl:text>
    </xsl:processing-instruction>
</xsl:template>
<xsl:template match="div[@class = 'flex_pi']">
    <xsl:processing-instruction name="rfc">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:processing-instruction>
</xsl:template>

<!-- Emit references -->
<xsl:template
    match="a[ends-with(@href, '.xml') and ../..[@class = 'flex_bibxml']]">
    <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text disable-output-escaping="yes">;&#xA;</xsl:text>
</xsl:template>

<!-- Author metadata templates (for the <author> elements) -->
<xsl:template match="div[@class='flex_authororg']">
    <xsl:element name='organization'>
        <xsl:choose>
            <xsl:when test="../div[@class = 'flex_authororgabbrev']">
                <xsl:attribute name="abbrev">
                    <xsl:value-of select="normalize-space(../div[@class = 'flex_authororgabbrev']/div)"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="normalize-space(div)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoraddrstreet']">
    <xsl:element name='street'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoraddrcity']">
    <xsl:element name='city'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoraddrregion']">
    <xsl:element name='region'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoraddrcode']">
    <xsl:element name='code'>
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoraddrcountry']">
    <!-- We don't want to have to nest insets for these things in LyX
         documents, but xml2rfc requires nesting, thus the use of ..
         here. -->
    <xsl:element name='postal'>
        <xsl:apply-templates select="../div[@class = 'flex_authoraddrstreet']"/>
        <xsl:apply-templates select="../div[@class = 'flex_authoraddrcity']"/>
        <xsl:apply-templates select="../div[@class = 'flex_authoraddrregion']"/>
        <xsl:apply-templates select="../div[@class = 'flex_authoraddrcode']"/>
        <xsl:element name="country">
            <xsl:value-of select="normalize-space(./div)"/>
        </xsl:element>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authorphone']">
    <xsl:element name='phone'>
        <xsl:value-of select="normalize-space(./div)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoruri']">
    <xsl:element name='uri'>
        <xsl:value-of select="normalize-space(./div)"/>
    </xsl:element>
</xsl:template>

<xsl:template match="div[@class='flex_authoremailaddr']">
    <xsl:element name='email'>
        <xsl:value-of select="normalize-space(./div)"/>
    </xsl:element>
</xsl:template>

<!-- Process author data -->
<xsl:template match="div[@class='author_item']">
    <!-- Author element -->
    <xsl:element name='author'>
        <!-- Initials and surname attributes and various sub-elements...

             Try to be user-friendly by deriving the initials and
             surname from the fullname.

             XSLT conditionals are exceedingly verbose! :( -->
        <xsl:attribute name="initials">
            <xsl:choose>
                <xsl:when test="./div[@class='flex_authorinitials']/div">
                    <xsl:value-of select="normalize-space(./div[@class='flex_authorinitials']/div)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat(substring(normalize-space(string-join(text(), '')), 1, 1), '.')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="surname">
            <xsl:choose>
                <xsl:when test="./div[@class='flex_authorsurname']/div">
                    <xsl:value-of select="normalize-space(./div[@class='flex_authorsurname']/div)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="replace(normalize-space(normalize-space(string-join(text(), ''))), '^.* ', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="fullname">
            <xsl:value-of select="normalize-space(string-join(text(), ''))"/>
        </xsl:attribute>

        <!-- Organization element -->
        <xsl:apply-templates select=".//div[@class='flex_authororg']"/>

        <!-- Address element.  We try hard to avoid an empty address
             element.  It'd be so nice to have an attribute of
             xsl:element by which to say "don't output this element if
             it is empty"... :( -->
        <xsl:choose>
            <!-- Add an address element IFF there are either author
                 postal address elements, author phone number, author
                 URI, or author e-mail elements -->
            <xsl:when test=".//div[@class='flex_authoremailaddr'] |
                            .//div[@class='flex_authoruri'] |
                            .//div[@class='flex_authorphone'] |
                            .//div[@class='flex_authoraddrcountry']">
                <xsl:element name='address'>
                    <!-- Add a postal element IFF there's a country name -->
                    <xsl:apply-templates select=".//div[@class='flex_authoraddrcountry']"/>
                    <!-- Add phone, email, uri elements -->
                    <xsl:apply-templates select=".//div[@class='flex_authoremailaddr']"/>
                    <xsl:apply-templates select=".//div[@class='flex_authorphone']"/>
                    <xsl:apply-templates select=".//div[@class='flex_authoruri']"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>

    </xsl:element>
</xsl:template>

</xsl:stylesheet>
