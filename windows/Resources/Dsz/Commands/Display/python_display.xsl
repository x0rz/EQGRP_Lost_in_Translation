<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsXml.xsl"/>
  
	<xsl:template match="CtrlC">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Warning'"/>
			<xsl:with-param name="text">
				<xsl:text>**** Command Interruption occurred ****</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="GetInput">
		<xsl:if test="not(@raw)">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Good'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="."/>
					<xsl:call-template name="PrintReturn"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="Input">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Prompt">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="Response">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="RunningCmd">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:text>Running command '</xsl:text>
				<xsl:value-of select="."/>
				<xsl:text>'</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ignore elements -->
	<xsl:template match="DeleteEnv"/>
	<xsl:template match="SetEnv"/>
	<xsl:template match="Storage"/>
	<xsl:template match="Warning"/>
  
</xsl:transform>