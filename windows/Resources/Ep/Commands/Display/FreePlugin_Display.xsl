<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Freed">    Plugin freed&#x0D;&#x0A;</xsl:template>

  <xsl:template match="FreeLocal">Clearing local record of remote plugin&#x0D;&#x0A;</xsl:template>

  <xsl:template match="LoadCount">    Load count reduced to <xsl:value-of select="."/>&#x0D;&#x0A;</xsl:template>

  <xsl:template match="Plugin">Freeing plugin <xsl:value-of select="@id"/> (<xsl:value-of select="@type"/>)&#x0D;&#x0A;</xsl:template>

 
</xsl:transform>