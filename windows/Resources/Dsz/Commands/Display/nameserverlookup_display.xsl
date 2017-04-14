<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

    <xsl:template match="TaskingInfo">
		<xsl:choose>
			<xsl:when test="TaskType='IPV4'">
				<xsl:text>Address '</xsl:text>
				<xsl:value-of select="SearchParam"/>
				<xsl:text>' has the following hostnames:</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Hostname '</xsl:text>
				<xsl:value-of select="SearchParam"/>
				<xsl:text>' has the following addresses:</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:template>

	<xsl:template match="Hosts">
		<xsl:apply-templates select="HostInfo"/>
	</xsl:template>
	
	<xsl:template match="HostInfo">
		<xsl:text>	</xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>
