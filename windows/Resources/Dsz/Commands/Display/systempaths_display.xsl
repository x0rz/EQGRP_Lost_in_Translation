<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="Dirs">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="WindowsDir">
		<xsl:text>Windows Directory:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="SystemDir">
		<xsl:text>System Directory:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="TempDir">
		<xsl:text>Temp Directory:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>