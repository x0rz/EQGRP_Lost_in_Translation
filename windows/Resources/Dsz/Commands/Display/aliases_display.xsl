<?xml version='1.0' ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="include/StandardTransformsXml.xsl"/>

	<xsl:template match="UserAlias">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:value-of select="@original"/> 
			</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="20 - string-length(@original)" /> 
				</xsl:call-template>
				<xsl:text> : </xsl:text>
				<xsl:value-of select="@location"/>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="16 - string-length(@location)" /> 
				</xsl:call-template>
				<xsl:text> : </xsl:text>
				<xsl:value-of select="@replace"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:if test="Option">
					<xsl:text>  Options: </xsl:text>
					<xsl:for-each select="Option">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
					<xsl:call-template name="PrintReturn"/>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="AddedAlias">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>Alias '</xsl:text>
				<xsl:value-of select="@original"/>
				<xsl:text>' to '</xsl:text>
				<xsl:value-of select="@replace"/>
				<xsl:text>' added.</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
  
	<xsl:template match="RemoveAlias">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>Alias '</xsl:text>
				<xsl:value-of select="@original"/>
				<xsl:text>' removed.</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
  
</xsl:stylesheet>