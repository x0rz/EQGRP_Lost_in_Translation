<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="Connected"/>
	<xsl:template match="SerialDataWriteFail"/>
	<xsl:template match="Disconnected"/>
	<xsl:template match="Exit"/>
	<xsl:template match="SerialDataWrite"/>

	
	<xsl:template match="SerialDataRead">
		<xsl:value-of select="."/>
	</xsl:template>
	
</xsl:transform>