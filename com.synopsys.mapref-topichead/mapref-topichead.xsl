<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    exclude-result-prefixes="xs dita-ot"
    version="2.0">

<!--

This file modifies behaviors defined in


-->

  <!--
    -| this plugin modifies the general-purpose <mapref>-reading template in
    -|
    -| <dita-ot>/plugins/org.dita.base/xsl/preprocess/maprefImpl.xsl
    -|
    -| to place submap contents into a <topichead> titled after the map
    -| when the <mapref> has @outputclass="topichead"
    -->


  <!-- get the default results, then post-process them -->
  <xsl:template match="*[contains(@class, ' map/topicref ')][(@format, @dita-ot:orig-format) = 'ditamap'][not(@scope = 'peer')]
                        [not(contains(@class, ' mapgroup-d/topichead '))]
                        [tokenize(@outputclass, '\s+') = 'topichead']" priority="10">
    <!-- we use moded templates because the <mapref> template can return multiple elements
         (e.g. if @keys is defined in the <mapref>) -->
    <xsl:variable name="original-results">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:apply-templates select="$original-results" mode="mapref-topichead">
      <xsl:with-param name="orig-mapref" select="."/>  <!-- include original <mapref> so we can promote some of its metadata -->
    </xsl:apply-templates>
  </xsl:template>


  <!-- for the <submap> element, wrap it in a <topichead> -->
  <xsl:template match="submap" mode="mapref-topichead">
    <xsl:param name="orig-mapref" as="item()"/>
    <!-- collect the attributes to promote from <submap> to <topichead> -->
    <xsl:variable name="attributes-to-promote" as="attribute()*">
      <xsl:sequence select="@keyscope"/>  <!-- <topichead> title should be evaluated in map's keyscope -->
      <xsl:sequence select="(@audience, @platform, @product, @props, @otherprops, @rev)"/>  <!-- <topichead> title should use map's profiling conditions -->
    </xsl:variable>

    <!-- collect the elements to promote from <submap> to <topichead> -->
    <xsl:variable name="elements-to-promote" as="node()*">
      <xsl:sequence select="ditavalref"/>  <!-- <topichead> title should use map's DITAVAL filtering -->
    </xsl:variable>

    <!-- compute a new @outputclass with the "topichead" keyword removed -->
    <xsl:variable name="outputclass-updated" as="attribute()?">
      <xsl:variable name="remaining-keywords" as="item()*" select="tokenize(@outputclass, '\s+')[. ne 'topichead']"/>
      <xsl:if test="count($remaining-keywords) > 0">
        <xsl:attribute name="outputclass">
          <xsl:value-of select="string-join($remaining-keywords, ' ')"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:variable>

    <!-- make our wrapper <topichead> element -->
    <topichead class="+ map/topicref mapgroup-d/topichead ">
      <xsl:sequence select="$attributes-to-promote"/>  <!-- copy the attributes to promote -->

      <!-- make a <navtitle> from the title metadata in our <submap> -->
      <topicmeta class="- map/topicmeta ">
        <navtitle class="- topic/navtitle ">
          <xsl:sequence select="submap-topicmeta/submap-title/node()"/>
        </navtitle>
        <xsl:sequence select="$orig-mapref/topicmeta/*[not(self::navtitle)]"/>  <!-- copy <mapref> metadata, such as <shortdesc> -->
      </topicmeta>

      <xsl:sequence select="$elements-to-promote"/>  <!-- copy the <submap> elements to promote -->

      <!-- copy the <submap>, minus the stuff we promoted -->
      <!-- (we deep-copy the contents because this template is not needed below <submap>) -->
      <xsl:copy select=".">
        <xsl:sequence select="$outputclass-updated"/>
        <xsl:sequence select="@* except (@outputclass, $attributes-to-promote)"/>
        <xsl:sequence select="node() except $elements-to-promote"/>
      </xsl:copy>
    </topichead>
  </xsl:template>


  <!-- copy other stuff as-is -->
  <xsl:template match="@*|node()" mode="mapref-topichead">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="mapref-topichead"/>
    </xsl:copy>
  </xsl:template>
 
</xsl:stylesheet>

