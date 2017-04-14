<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="ProcessHide">
  <xsl:text>Process </xsl:text>
  <xsl:value-of select="@id" />
  <xsl:text> hidden</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>    EPROCESS located at </xsl:text>
  <xsl:value-of select="@eprocess" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

 </xsl:template>

</xsl:transform>