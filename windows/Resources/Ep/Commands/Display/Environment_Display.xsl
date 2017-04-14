<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>
 <xsl:template match="Environment">
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>Operation completed successfully</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
     <xsl:if test="@envValue">
  	<xsl:value-of select="@envVar"/>
	<xsl:text> has the following value:  </xsl:text>
	<xsl:text>&#x0D;&#x0A;</xsl:text>
	<xsl:text>&#x0D;&#x0A;</xsl:text>
	<xsl:value-of select="@envValue"/>
	<xsl:text>&#x0D;&#x0A;</xsl:text>
	<xsl:text> </xsl:text>
     </xsl:if>
 </xsl:template>
 <xsl:template match="Success" />
</xsl:transform>

