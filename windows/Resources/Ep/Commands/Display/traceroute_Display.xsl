<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Hop">
   <xsl:text>Hop </xsl:text>
   <xsl:value-of select="@hop" />
   <xsl:text> - </xsl:text>
   <xsl:choose>
    <xsl:when test="Timeout">
     <xsl:text>***TIMEOUT***</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="Destination" />
     <xsl:if test="HostName">
	<xsl:text> (</xsl:text>
	<xsl:value-of select="HostName"/>
	<xsl:text>)</xsl:text>
     </xsl:if>
     <xsl:call-template name="PrintReturn" />
     <xsl:text>&#x09;</xsl:text>
     <xsl:value-of select="Code" />
     <xsl:text> - </xsl:text>
     <xsl:value-of select="@time " />
     <xsl:text> ms</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
   <xsl:call-template name="PrintReturn" />
  </xsl:template>

</xsl:transform>