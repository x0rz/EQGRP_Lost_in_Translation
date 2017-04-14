<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Alias">
	<xsl:value-of select="@original"/> 

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="20 - string-length(@original)" /> 
        </xsl:call-template> : <xsl:value-of select="@replace"/><xsl:text>
</xsl:text></xsl:template>

</xsl:transform>