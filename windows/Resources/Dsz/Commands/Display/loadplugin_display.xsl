<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsXml.xsl"/>
  
	<xsl:template match="ModuleLoad">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:choose>
					<xsl:when test="@loadCount">
						<xsl:text>Module </xsl:text>
						<xsl:value-of select="@id"/>
						<xsl:text> already loaded (addr=</xsl:text>
						<xsl:value-of select="@target"/>
						<xsl:text>) - Load count </xsl:text>
						<xsl:value-of select="@loadCount"/>	
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Loading module </xsl:text>
						<xsl:value-of select="@id"/>
						<xsl:text> (addr=</xsl:text>
						<xsl:value-of select="@target"/>
						<xsl:text> | type=</xsl:text>
						<xsl:value-of select="@framework"/>
						<xsl:text> | file=</xsl:text>
						<xsl:call-template name="PrintNameFromPath">
							<xsl:with-param name="path" select="."/>
						</xsl:call-template>
						<xsl:text>)</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	
	</xsl:template>

	<xsl:template match="Success">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:text>Module loaded</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:transform>
