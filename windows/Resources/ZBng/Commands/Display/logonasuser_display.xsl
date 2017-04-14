<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Logon">
		<xsl:text>Specified user logged on:</xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>    User handle = </xsl:text>
		<xsl:value-of select="@handle"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>     User alias = </xsl:text>
		<xsl:value-of select="@alias"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="DeleteEnv"/>

</xsl:transform>