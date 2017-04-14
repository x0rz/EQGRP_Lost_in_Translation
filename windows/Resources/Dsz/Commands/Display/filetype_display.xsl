<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="FileType">
		<xsl:if test="Unknown">
			<xsl:text>Unable to determine file type</xsl:text>
		</xsl:if>
		<xsl:if test="FileType">
			<xsl:text>File type is: </xsl:text>
			<xsl:value-of select="FileType"/>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>