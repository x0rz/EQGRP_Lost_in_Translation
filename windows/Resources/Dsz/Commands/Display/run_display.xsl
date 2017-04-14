<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="ProcessStatus">
		<xsl:choose>
			<xsl:when test="number(@status) = 259">
				<xsl:text>Not waiting for process termination</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Process terminated with status </xsl:text>
				<xsl:value-of select="@status"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:if test="@normalExit = 'false'">
					<xsl:text>    Process ended abnormally</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="ProcessStarted">
		<xsl:text>Process started with id </xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="ProcessOutput">
		<xsl:value-of select="."/>
	</xsl:template>
	
	<xsl:template match="ProcessInput">
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
</xsl:transform>
