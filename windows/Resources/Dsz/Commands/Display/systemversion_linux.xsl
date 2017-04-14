<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:template name="PrintLinuxVersion">
		<xsl:text>      Kernel : </xsl:text>
		<xsl:value-of select="@major" />
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@minor" />
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@revisionMajor" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>  Extra Info : </xsl:text>
		<xsl:value-of select="ExtraInfo" />
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
</xsl:transform>
