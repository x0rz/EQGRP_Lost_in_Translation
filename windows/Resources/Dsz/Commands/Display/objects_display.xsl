<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

    <xsl:template match='Objects'>
		<xsl:apply-templates select="ObjectDirectory"/>
    </xsl:template>

	<xsl:template match="ObjectDirectory">
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>Directory : </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:choose>
			<xsl:when test="QueryFailure">
				<xsl:text>    ERROR: </xsl:text>
				<xsl:value-of select="QueryFailure"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintReturn"/>
				<xsl:apply-templates select="Object"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Object">
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="20 - string-length(@type)"/>
		</xsl:call-template>
		<xsl:value-of select="@type"/>

		<xsl:text>    </xsl:text>

		<xsl:value-of select="@name"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>	
	
</xsl:transform>