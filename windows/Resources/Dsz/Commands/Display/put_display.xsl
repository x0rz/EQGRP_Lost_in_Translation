<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="PutFile">
		<xsl:text>Uploading </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@size"/>
		<xsl:text> bytes)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Results">
		<xsl:if test="File">
			<xsl:text>  Opened </xsl:text>
			<xsl:value-of select="File"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="@bytesWritten">
			<xsl:text>    Wrote </xsl:text>
			<xsl:value-of select="@bytesWritten"/>
			<xsl:text> bytes (</xsl:text>
			<xsl:value-of select="@bytesLeft"/>
			<xsl:text> bytes remaining)</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>		
	</xsl:template>
	
	<xsl:template match="Success">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>File uploaded</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>