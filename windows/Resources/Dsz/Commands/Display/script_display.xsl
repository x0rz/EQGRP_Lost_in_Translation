<?xml version='1.0' ?>
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

	<xsl:template match="Echo">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="@type"/>
			<xsl:with-param name="text">
				<xsl:text>- </xsl:text>
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="Line">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="SyntaxError">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Error'"/>
			<xsl:with-param name="text">
				<xsl:if test="@display = 'true'">
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>* File: </xsl:text>
					<xsl:value-of select="@file"/>
					<xsl:text> | </xsl:text>
					<xsl:text> Line: </xsl:text>
					<xsl:value-of select="@line"/>
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>*    </xsl:text>
					<xsl:value-of select="."/>
					<xsl:call-template name="PrintReturn"/>
				</xsl:if>
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
	
	<xsl:template match="GetInput">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
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

	<xsl:template match="Input">
		<xsl:call-template name="XmlOutput">
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

	<xsl:template match="Debug" priority="1">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:value-of select="."/>
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
