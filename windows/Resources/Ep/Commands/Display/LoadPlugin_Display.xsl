<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="AlreadyLoaded">Plugin is already loaded<xsl:call-template name="PrintReturn"/></xsl:template>

  <xsl:template match="FindPlugin"><xsl:call-template name="PrintReturn"/>Finding plugin<xsl:call-template name="PrintReturn"/></xsl:template>

  <xsl:template match="Found">    Plugin found<xsl:call-template name="PrintReturn"/></xsl:template>

  <xsl:template match="Increment">    Incrementing plugin load count to <xsl:value-of select="."/><xsl:call-template name="PrintReturn"/></xsl:template>

  <xsl:template match="Loading">Uploading plugin<xsl:call-template name="PrintReturn"/></xsl:template>

  <xsl:template match="Loaded">    Plugin <xsl:value-of select="@id"/> loaded at <xsl:value-of select="@address"/><xsl:call-template name="PrintReturn"/></xsl:template>

</xsl:transform>