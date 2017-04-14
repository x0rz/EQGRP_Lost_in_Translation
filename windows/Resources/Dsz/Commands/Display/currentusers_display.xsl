<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="CurrentUsers">
		<xsl:text>User               Device          Host</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>----------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:apply-templates select="User"/>
	</xsl:template>

	<xsl:template match="User">
		<xsl:value-of select="@name"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="16 - string-length(@name)" /> 
		</xsl:call-template>

		<xsl:value-of select="@device"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="16 - string-length(@device)" /> 
		</xsl:call-template>
		
		<xsl:value-of select="@host"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="25 - string-length(@host)" /> 
		</xsl:call-template>
		
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    Idle Time : </xsl:text>
		<xsl:call-template name="printTime">
			<xsl:with-param name="time" select="IdleTime"/>
			<xsl:with-param name="formatDelta" select="'true'"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>   Login Time : </xsl:text>
		<xsl:call-template name="printTime">
			<xsl:with-param name="time" select="LoginTime"/>
		</xsl:call-template>
		
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>
