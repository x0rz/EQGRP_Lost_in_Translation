<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="RemoteProcess">
		<xsl:text>Process started:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintTab"/>
		<xsl:choose>
			<xsl:when test="RetVal = '0'">
				<xsl:text>Process Id:</xsl:text>
				<xsl:value-of select="Id" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Return Value:</xsl:text>
				<xsl:value-of select="RetVal" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>