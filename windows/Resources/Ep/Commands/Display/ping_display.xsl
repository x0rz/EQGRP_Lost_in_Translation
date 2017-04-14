<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="PingResponses">
  <xsl:apply-templates select="Response" />
 </xsl:template>

 <xsl:template match="Response">
  <xsl:text>----------------------------------------------------------&#x0D;&#x0A;</xsl:text>
  <xsl:text>Response (length=</xsl:text>
  <xsl:value-of select="@length"/>
  <xsl:text> elapsed=</xsl:text>
  <xsl:value-of select="@elapsed"/>
  <xsl:text> ms)&#x0D;&#x0A;</xsl:text>

  <xsl:if test="Ip/Icmp">
    <xsl:choose>
	<xsl:when test="Ip/Icmp/@type = '0'">
	    <xsl:text>ECHO RESPONSE&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:when test="Ip/Icmp/@type = '3'">
	    <xsl:text>DESTINATION UNREACHABLE (code=</xsl:text>
	    <xsl:value-of select="Ip/Icmp/@code"/>
	    <xsl:text>)&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:otherwise>

	</xsl:otherwise>
    </xsl:choose>

    <xsl:text>&#x09;SRC: </xsl:text>
    <xsl:value-of select="Ip/@source"/>
    <xsl:text> -&gt; DST: </xsl:text>
    <xsl:value-of select="Ip/@destination"/>

    <xsl:text> -- TTL: </xsl:text>
    <xsl:value-of select="Ip/@ttl" />

    <xsl:call-template name="PrintReturn" />

  </xsl:if>
 </xsl:template>

</xsl:transform>