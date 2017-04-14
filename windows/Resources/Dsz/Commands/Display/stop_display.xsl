<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="include/StandardTransformsXml.xsl"/>

  <xsl:template match="Success"/>
	
  <xsl:template match="Child">
	<xsl:call-template name="XmlOutput">
		<xsl:with-param name="text">
			<xsl:text>Stopping child </xsl:text>
			<xsl:value-of select="@childRequest"/>
			<xsl:text> for command </xsl:text>
			<xsl:value-of select="@request"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:with-param>
	</xsl:call-template>
  </xsl:template>

  <xsl:template match="Stop">
	<xsl:call-template name="XmlOutput">
		<xsl:with-param name="text">
			<xsl:text>Attempting to stop command </xsl:text>
			<xsl:value-of select="@id"/>
			<xsl:text> (</xsl:text>
			<xsl:value-of select="@type"/>
			<xsl:text>)</xsl:text>
			<xsl:if test="@rpcId">
				<xsl:text> RPC </xsl:text>
				<xsl:value-of select="@rpcId"/>
			</xsl:if>
			<xsl:call-template name="PrintReturn"/>
		</xsl:with-param>
	</xsl:call-template>
  </xsl:template>

  <xsl:template match="Stopped">
	<xsl:call-template name="XmlOutput">
		<xsl:with-param name="type" select="'Good'"/>
		<xsl:with-param name="text">
			<xsl:text>    Stopped</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:with-param>
	</xsl:call-template>
  </xsl:template>

  <xsl:template match="FailedToStop">
	<xsl:call-template name="XmlOutput">
		<xsl:with-param name="type" select="'Error'"/>
		<xsl:with-param name="text">
		<xsl:text>    Stop FAILED</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		</xsl:with-param>
	</xsl:call-template>
  </xsl:template>

</xsl:transform>
