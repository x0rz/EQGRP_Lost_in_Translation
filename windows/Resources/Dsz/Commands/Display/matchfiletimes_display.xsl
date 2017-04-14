<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="Results">
		<xsl:text>Times matched</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>Source File : </xsl:text>
		<xsl:value-of select="Src"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>  Dest File : </xsl:text>
		<xsl:value-of select="Dst"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
  
	<xsl:template match="Success"/>

</xsl:transform>