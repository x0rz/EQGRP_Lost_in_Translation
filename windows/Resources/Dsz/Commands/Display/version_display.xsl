<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsXml.xsl"/>

	<xsl:template match="Version">
		<xsl:variable name="VersionElementName">
			<xsl:choose>
			<xsl:when test="(ListeningPost/Compiled/@major = Implant/Compiled/@major) and
							(ListeningPost/Compiled/@minor = Implant/Compiled/@minor) and
							(ListeningPost/Compiled/@fix = Implant/Compiled/@fix)">Good</xsl:when>
			<xsl:otherwise>Warning</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Compiled :</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>    Listening Post : </xsl:text>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="$VersionElementName"/>
			<xsl:with-param name="text">
				<xsl:value-of select="ListeningPost/Compiled/@major"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="ListeningPost/Compiled/@minor"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="ListeningPost/Compiled/@fix"/>
				<xsl:if test="ListeningPost/Compiled/@build">
					<xsl:text>.</xsl:text>
					<xsl:value-of select="ListeningPost/Compiled/@build"/>
				</xsl:if>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>           Implant : </xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="$VersionElementName"/>
			<xsl:with-param name="text">
				<xsl:value-of select="Implant/Compiled/@major"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="Implant/Compiled/@minor"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="Implant/Compiled/@fix"/>
				<xsl:if test="Implant/Compiled/@build">
					<xsl:text>.</xsl:text>
					<xsl:value-of select="Implant/Compiled/@build"/>
				</xsl:if>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Base : </xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>    </xsl:text>
				<xsl:value-of select="ListeningPost/Base"/>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="ListeningPost/Base/@major"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="ListeningPost/Base/@minor"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="ListeningPost/Base/@fix"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="ListeningPost/Base/@build"/>
				<xsl:text>)</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="Success">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
			<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:transform>