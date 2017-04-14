<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="include/StandardTransforms.xsl"/>
  
  <xsl:template match="Environment">
	<xsl:text>  </xsl:text>
	
	<xsl:choose>
		<xsl:when test="@address = 'z0.0.0.0'">
			<xsl:text>     ANY</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="@address"/>
		</xsl:otherwise>
	</xsl:choose>
	
	<xsl:call-template name="Whitespace">
		<xsl:with-param name="i" select="5" /> 
	</xsl:call-template>

	<xsl:value-of select="Name"/>
	<xsl:text> = </xsl:text>
	<xsl:value-of select="Value"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="Static"/>
	<xsl:call-template name="PrintReturn"/>
  </xsl:template>

  <xsl:template match="Static">
	<xsl:text>(system)</xsl:text>
  </xsl:template>

</xsl:transform>