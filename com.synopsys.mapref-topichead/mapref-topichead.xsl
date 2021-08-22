<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    exclude-result-prefixes="xs dita-ot"
    version="2.0">

  <!--
    -| this enhances the general-purpose <mapref>-reading template in
    -|
    -|   <dita-ot>/plugins/org.dita.base/xsl/preprocess/maprefImpl.xsl
    -|
    -| so that for <mapref outputclass="topichead"> elements, the submap
    -| contents are placed into a <topichead> titled after the map
    -->
  <xsl:template match="*[contains(@class, ' map/topicref ')][(@format, @dita-ot:orig-format) = 'ditamap'][not(@scope = 'peer')]
                        [not(contains(@class, ' mapgroup-d/topichead '))]
                        [tokenize(@outputclass, '\s+') = 'topichead']" priority="10">
    <xsl:param name="refclass" select="(@dita-ot:orig-class, @class)[1]" as="xs:string"/>
    <xsl:param name="relative-path" as="xs:string" tunnel="yes">#none#</xsl:param>
    <xsl:param name="mapref-id-path" as="xs:string*"/>
    <xsl:param name="referTypeFlag" as="xs:string">#none#</xsl:param>

    <!-- get the template-applied <submap> element -->
    <xsl:variable name="submap" as="node()?">
      <xsl:next-match/>
    </xsl:variable>

    <!-- these are the attributes we will promote from <submap> to <topichead> -->
    <xsl:variable name="attributes-to-promote" as="attribute()*">
      <xsl:sequence select="$submap/(@keyscope)"/>  <!-- <topichead> title should be evaluated in map's keyscope -->
      <xsl:sequence select="$submap/(@audience, @platform, @product, @props, @otherprops, @rev)"/>  <!-- <topichead> title should use map's profiling conditions -->
    </xsl:variable>

    <!-- these are the elements we will promote from <submap> to <topichead> -->
    <xsl:variable name="elements-to-promote" as="node()*">
      <xsl:sequence select="$submap/ditavalref"/>  <!-- <topichead> title should use map's DITAVAL filtering -->
    </xsl:variable>

    <!-- compute a new @outputclass with the "topichead" keyword removed -->
    <xsl:variable name="outputclass-updated" as="attribute()?">
      <xsl:variable name="remaining-keywords" as="item()*" select="tokenize($submap/@outputclass, '\s+')[. ne 'topichead']"/>
      <xsl:if test="count($remaining-keywords) > 0">
        <xsl:attribute name="outputclass">
          <xsl:value-of select="string-join($remaining-keywords, ' ')"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:variable>

    <!-- make our wrapper <topichead> element -->
    <topichead class="+ map/topicref mapgroup-d/topichead ">
      <xsl:sequence select="$attributes-to-promote"/>  <!-- apply the attributes we promoted -->

      <!-- make a <navtitle> from the title metadata in our <submap> -->
      <topicmeta class="- map/topicmeta ">
        <navtitle class="- topic/navtitle ">
          <xsl:sequence select="$submap/submap-topicmeta/submap-title/node()"/>
        </navtitle>
      </topicmeta>

      <xsl:sequence select="$elements-to-promote"/>  <!-- apply the elements we promoted -->

      <!-- instantiate our <submap>, minus the stuff we promoted -->
      <xsl:copy select="$submap">
        <xsl:sequence select="$outputclass-updated"/>
        <xsl:sequence select="@* except (@outputclass, $attributes-to-promote)"/>
        <xsl:sequence select="node() except $elements-to-promote"/>
      </xsl:copy>
    </topichead>
  </xsl:template>
 
</xsl:stylesheet>

