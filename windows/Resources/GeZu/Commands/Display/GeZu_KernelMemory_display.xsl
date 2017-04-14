<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  	
	<xsl:template match="GeZu_KernelMemoryResponse">
		<xsl:text>----------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Memory Dump: </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="MemDump" />
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>