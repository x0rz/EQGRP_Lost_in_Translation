<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="AddedWrapper">
		<xsl:text>Wrapper script </xsl:text>
		<xsl:value-of select="@script"/>
		<xsl:text> added for command </xsl:text>
		<xsl:value-of select="@command"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="RemovedWrapper">
		<xsl:text>Wrapper script </xsl:text>
		<xsl:value-of select="@script"/>
		<xsl:text> removed for command </xsl:text>
		<xsl:value-of select="@command"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="CommandWrappers">
		<xsl:apply-templates select="CommandWrapper"/>
	</xsl:template>

	<xsl:template match="CommandWrapper">
		<xsl:text>-----------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>       Type : </xsl:text>
		<xsl:value-of select="../@wrapperType"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Command : </xsl:text>
		<xsl:value-of select="@command"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>   Location : </xsl:text>
		<xsl:value-of select="@location"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>     Script : </xsl:text>
		<xsl:value-of select="@script"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Project : </xsl:text>
		<xsl:value-of select="@project"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text> Script Arg : </xsl:text>
		<xsl:value-of select="@scriptArg"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
</xsl:transform>