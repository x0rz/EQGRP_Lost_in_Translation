<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="TargetProcess">
		<xsl:text>Attempting to suspend: </xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Suspended">
		<xsl:text>Process Has Been Suspended</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="SuspendFailed">
		<xsl:text>Process Failed to Suspend</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>