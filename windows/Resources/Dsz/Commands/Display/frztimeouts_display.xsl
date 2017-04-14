<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="FrzTimeoutsActionCompleted">
		<xsl:text>Action completed</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="FrzTimeouts">
		<xsl:text> Found </xsl:text>
		<xsl:value-of select="@numTimeouts"/>
		<xsl:text> Timeouts : </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Timeout"/>
	</xsl:template>

	<xsl:template match="Timeout">
		<xsl:text>-------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         Address : </xsl:text>
		<xsl:value-of select="@address"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="@cidrBits"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Send Timeout : </xsl:text>
		<xsl:call-template name="printTime">
			<xsl:with-param name="time" select="SendTimeout"/>
			<xsl:with-param name="formatDelta" select="'true'"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text> Receive Timeout : </xsl:text>
		<xsl:call-template name="printTime">
			<xsl:with-param name="time" select="RecvTimeout"/>
			<xsl:with-param name="formatDelta" select="'true'"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Send Retries : </xsl:text>
		<xsl:value-of select="@sendRetries"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text> Receive Retries : </xsl:text>
		<xsl:value-of select="@recvRetries"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
 
</xsl:transform>