<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="Hidden">
		<xsl:value-of select="@type"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="@value"/>
		<xsl:text> hidden</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:if test="MetaData">
			<xsl:text>    Data: </xsl:text>
			<xsl:value-of select="MetaData"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Unhidden">
		<xsl:value-of select="@type"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="@value"/>
		<xsl:text> unhidden</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>