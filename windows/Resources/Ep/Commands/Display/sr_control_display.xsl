<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="StandardTransforms.xsl" />
	<xsl:output method="text" />
	
	<xsl:template match="UninstallSuccess">
		<xsl:text>Driver marked for deletion</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="Available">
		<xsl:text>Driver is running</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="SRIpConfig">
		<xsl:value-of select="RawText"/>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="SRNetstat">
		<xsl:text>  ID    Type  LocalPort  RemotePort       State</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>----------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Connection"/>
	</xsl:template>
	
	<xsl:template match="Connection">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="4 - string-length(@id)" />
		</xsl:call-template>
		<xsl:value-of select="@id" />
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="8 - string-length(@type)" />
		</xsl:call-template>
		<xsl:value-of select="@type" />
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="8 - string-length(@localPort)" />
		</xsl:call-template>
		<xsl:value-of select="@localPort" />
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="11 - string-length(@remotePort)" />
		</xsl:call-template>
		<xsl:value-of select="@remotePort" />
		
		<xsl:text>       </xsl:text>
		<xsl:value-of select="@state" />
		
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
</xsl:transform>