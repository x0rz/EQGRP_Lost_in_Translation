<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="ProcessList">
		<xsl:text>   Id                Name                 User</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>--------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	
		<xsl:apply-templates select="Process"/>
	</xsl:template>
	
	<xsl:template match="Process">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="7 - string-length(@id)" /> 
		</xsl:call-template>
		<xsl:value-of select="@id"/>
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="25 - string-length(@name)" /> 
		</xsl:call-template>
		<xsl:value-of select="@name"/>
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="5" /> 
		</xsl:call-template>
		<xsl:value-of select="@user"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Logon">
		<xsl:text>    User handle = </xsl:text>
		<xsl:value-of select="@handle"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>     User alias = </xsl:text>
		<xsl:value-of select="@alias"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="DeleteEnv"/>

</xsl:transform>