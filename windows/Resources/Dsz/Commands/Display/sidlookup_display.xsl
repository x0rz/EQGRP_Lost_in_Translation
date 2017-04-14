<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl" />
	
	<xsl:template match="Sid">
		<xsl:text>  Id : </xsl:text>
		<xsl:value-of select="Id"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Name : </xsl:text>
		<xsl:value-of select="Name"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>