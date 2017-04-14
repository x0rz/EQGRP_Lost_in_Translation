<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="Languages">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Locale Language:              </xsl:text>
		<xsl:choose>
			<xsl:when test="string-length(LocaleLanguage/English) > 0">
				<xsl:value-of select="LocaleLanguage/English"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="LocaleLanguage/Native"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>User Interface Language:      </xsl:text>
		<xsl:choose>
			<xsl:when test="string-length(UILanguage/English) > 0">
				<xsl:value-of select="UILanguage/English"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="UILanguage/Native"/>
			</xsl:otherwise>
		</xsl:choose>
 		<xsl:call-template name="PrintReturn"/>
		
 		<xsl:text>Installed Language:           </xsl:text>
		<xsl:choose>
			<xsl:when test="string-length(InstalledLanguage/English) > 0">
				<xsl:value-of select="InstalledLanguage/English"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="InstalledLanguage/Native"/>
			</xsl:otherwise>
		</xsl:choose>
 		<xsl:call-template name="PrintReturn"/>
		
 		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Operating System Language(s): </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="OSLanguages"/>
        </xsl:template>

	<xsl:template match="OSLanguages">
		<xsl:choose>
			<xsl:when test="QueryError">
				<xsl:text>   Failed to perform query on </xsl:text>
				<xsl:value-of select="@osFile"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>   </xsl:text>
				<xsl:value-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="OSLanguage"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="OSLanguage">
		<xsl:text>    </xsl:text>
		<xsl:choose>
			<xsl:when test="string-length(English) > 0">
				<xsl:value-of select="English"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="Native"/>
			</xsl:otherwise>
		</xsl:choose>
 		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>