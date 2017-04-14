<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="StandardTransforms.xsl" />
	<xsl:output method="text" />

<xsl:template match="WMI">
<xsl:apply-templates />
</xsl:template>

	<xsl:template match="TouchResults">
		<xsl:text> EMPTYKEG Touch Results</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>     SYSROOT : </xsl:text>
		<xsl:value-of select="Sysroot"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>          OS : </xsl:text>
		<xsl:value-of select="OS"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>     Version : </xsl:text>
		<xsl:value-of select="Version"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text> ServicePack : </xsl:text>
		<xsl:value-of select="ServicePack"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>    Language : </xsl:text>
		<xsl:value-of select="Language"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>	

	<xsl:template match="ProcessList">
		<xsl:text> EMPTYKEG Remote Process Listing</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>   Id                Name                 Path</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>   ---------------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	
		<xsl:apply-templates select="RemoteProcess"/>
	</xsl:template>

	<xsl:template match="RemoteProcess">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="7 - string-length(@PID)" /> 
		</xsl:call-template>
		<xsl:value-of select="@PID"/>

		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="23 - string-length(@Process)" /> 
		</xsl:call-template>
		<xsl:value-of select="@Process"/>
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="6" /> 
		</xsl:call-template>
		<xsl:value-of select="@Path"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="RunCmd">
		<xsl:text> EMPTYKEG Remote Execute</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>     Command : </xsl:text>
		<xsl:value-of select="Command"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text> ReturnValue : </xsl:text>
		<xsl:value-of select="ReturnValue"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>   RemotePID : </xsl:text>
		<xsl:value-of select="RemotePID"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>