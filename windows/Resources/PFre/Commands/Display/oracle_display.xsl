<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="PassFreelyMemCheck">
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Data:</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

	<xsl:template match="PassFreelyCrc">
		<xsl:text>CRC calculation successful.</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Data:</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

	<xsl:template match="PassFreelyMemCheckStart">
		<xsl:text>Running CheckOracle() command</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="PassFreelyCrcStart">
		<xsl:text>Running CrcOracle() command</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="PassFreelyOpenStart">
		<xsl:text>Running OpenOracle() command</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="PassFreelyCloseStart">
		<xsl:text>Running CloseOracle() command</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

	<xsl:template match="PassFreelyOpenSuccess">
		<xsl:text>Oracle process memory successfully modified!</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="PassFreelyCloseSuccess">
		<xsl:text>Oracle process memory successfully modified!</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

</xsl:transform>