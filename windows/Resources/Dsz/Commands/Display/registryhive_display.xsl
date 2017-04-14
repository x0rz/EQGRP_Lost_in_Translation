<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="CmdSummary">
		<xsl:apply-templates select="CommandAction"/>
	</xsl:template>
	
	<xsl:variable name="action">
	</xsl:variable>
	
	<xsl:template match="CommandAction">
		<xsl:call-template name="PrintReturn"/>
		<xsl:choose>
			<xsl:when test="@action = 'Load'">Loaded hive </xsl:when>
			<xsl:when test="@action = 'Unload'">Unloaded hive </xsl:when>
			<xsl:when test="@action = 'Save'">Saved </xsl:when>
		</xsl:choose>
    <xsl:apply-templates select="Hive">
      <xsl:with-param name="action" select="@action"></xsl:with-param>
    </xsl:apply-templates>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Hive">
    <xsl:param name="action">?</xsl:param>
		<xsl:value-of select="@key"/>
		<xsl:choose>
			<xsl:when test="$action = 'Load'">
				<xsl:text> from file </xsl:text>
				<xsl:value-of select="@file" />
				<xsl:text> into </xsl:text>
			</xsl:when>
			<xsl:when test="$action = 'Unload'">
				<xsl:text> from </xsl:text>
			</xsl:when>
			<xsl:when test="$action = 'Save'">
				<xsl:text> into file </xsl:text>
				<xsl:value-of select="@file"/>
				<xsl:text> from </xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:value-of select="@hive"/>
	</xsl:template>

</xsl:transform>