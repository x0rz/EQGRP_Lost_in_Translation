<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	<xsl:include href="include/Math.xsl"/>
	
	<xsl:param name="radix" select="'decimal'"/>
	
  	<xsl:template match="Strings">
  		<xsl:apply-templates select="String"/>
	</xsl:template>
	
	<xsl:template match="String">
		<xsl:variable name="offset">
			<xsl:choose>
				<xsl:when test="$radix = 'hex'">
					<xsl:call-template name="math-convert-base">
						<xsl:with-param name="number" select="@offset"/>
						<xsl:with-param name="from-base" select="'10'"/>
						<xsl:with-param name="to-base" select="'16'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$radix = 'hex'">
					<xsl:call-template name="math-convert-base">
						<xsl:with-param name="number" select="@offset"/>
						<xsl:with-param name="from-base" select="'10'"/>
						<xsl:with-param name="to-base" select="'8'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="math-convert-base">
						<xsl:with-param name="number" select="@offset"/>
						<xsl:with-param name="from-base" select="'10'"/>
						<xsl:with-param name="to-base" select="'10'"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="9 - string-length($offset)"/>
		</xsl:call-template>
		<xsl:value-of select="$offset"/>
		<xsl:text> | </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
</xsl:transform>