<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Throttle">
    <xsl:choose>
	<xsl:when test=". = 0">
	    <xsl:text>Network throttling DISABLED&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:text>Network throttling set to </xsl:text>
	    <xsl:value-of select="format-number(., '###,###,###')"/>
	    <xsl:text> bytes per second&#x0D;&#x0A;</xsl:text>
	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>