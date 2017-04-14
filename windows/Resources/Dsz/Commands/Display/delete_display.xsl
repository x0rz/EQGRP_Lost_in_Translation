<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsXml.xsl"/>

	<xsl:template match="Deletions">
		<xsl:apply-templates select="FileDelete"/>
	</xsl:template>
		
	<xsl:template match="FileDelete">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:value-of select="@file" />
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:choose>
			<xsl:when test="@statusValue = '0x00000000'">
				<xsl:call-template name="XmlOutput">
					<xsl:with-param name="type" select="'Good'"/>
					<xsl:with-param name="text">
						<xsl:text>    </xsl:text>
						<xsl:choose>
							<xsl:when test="@delay = 'true'">
								<xsl:text>File marked for deletion</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>File deleted</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:call-template name="PrintReturn"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="XmlOutput">
					<xsl:with-param name="type" select="'Error'"/>
					<xsl:with-param name="text">
						<xsl:text>    </xsl:text>
						<xsl:value-of select="StatusString"/>
						<xsl:call-template name="PrintReturn"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>