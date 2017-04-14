<?xml version='1.0' ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="include/StandardTransformsXml.xsl"/>

	<xsl:template match="LpModule">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>---------------------------------------</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>  LpModule :</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>        Id : </xsl:text>
				<xsl:value-of select="Id"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>    Script : </xsl:text>
				<xsl:value-of select="TaskingScript"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>      Name : </xsl:text>
				<xsl:value-of select="Name"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>---------------------------------------</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="LocalDependencies">
		<xsl:apply-templates select="ModuleInfo"/>
	</xsl:template>
	
	<xsl:template match="RemoteDependencies">
		<xsl:apply-templates select="ModuleInfo"/>
	</xsl:template>
	
	<xsl:template match="ModuleInfo">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>---------------------------------------</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>  Module : </xsl:text>
				<xsl:value-of select="../@address"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>      Id : </xsl:text>
				<xsl:value-of select="Id"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>    Name : </xsl:text>
				<xsl:value-of select="Name"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>---------------------------------------</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Success">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>Command IS available</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Failure">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Error'"/>
			<xsl:with-param name="text">
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>Command is NOT available</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>