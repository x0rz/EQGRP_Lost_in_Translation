<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsXml.xsl"/>

	<xsl:template match="Warning">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Warning'"/>
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ignore types -->
	<xsl:template match="Alias"/>
	<xsl:template match="Command"/>
	<xsl:template match="CommandEnd"/>
	<xsl:template match="CommandInput"/>
	<xsl:template match="CommandInterrupt"/>
	<xsl:template match="CommandLog"/>
	<xsl:template match="CommandStart"/>
	<xsl:template match="CommandXml"/>

</xsl:transform>
