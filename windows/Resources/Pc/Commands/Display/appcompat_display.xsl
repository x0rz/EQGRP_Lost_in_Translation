<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="AppCompat">
		<xsl:text>Status: </xsl:text>
		<xsl:value-of select="@status"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>