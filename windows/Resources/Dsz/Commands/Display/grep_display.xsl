<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="Success">
		<xsl:text>Grep completed</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="File">
		<xsl:text>--------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="@location" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>--------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:choose>
			<xsl:when test="@error">
				<xsl:text>--</xsl:text>
				<xsl:value-of select="@error"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:when>
			<xsl:when test="Line">
				<xsl:apply-templates select="Line"/>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>--No matching lines found</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:otherwise>
		</xsl:choose>		
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Line">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="9 - string-length(@position)"/>
		</xsl:call-template>
		<xsl:value-of select="@position" />
		<xsl:text> - </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>