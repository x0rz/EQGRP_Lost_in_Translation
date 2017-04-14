<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Directory">
   <xsl:text>&#x0D;&#x0A;&#x0D;&#x0A;</xsl:text>
   <xsl:text>Directory : </xsl:text>
   <xsl:value-of select="@path"/>
   <xsl:text>&#x0D;&#x0A;&#x0D;&#x0A;</xsl:text>
   <xsl:apply-templates select="File" />
  </xsl:template>

  <xsl:template match="File">
   <xsl:value-of select="@checksum" />
   <xsl:text> </xsl:text>
   <xsl:value-of select="@name" />
   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="MaxEntries">
   <xsl:text>&#x0D;&#x0A;Maximum number of entries exceeded.&#x0D;&#x0A;</xsl:text>
  </xsl:template>

</xsl:transform>