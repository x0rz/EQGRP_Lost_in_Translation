<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Language">

  <xsl:variable name="id"    select="@id" />
  <xsl:text>Language Id: </xsl:text>
  <xsl:value-of select="$id" />
  <xsl:call-template name="PrintReturn"/>

  <xsl:text>&#x09;</xsl:text>
  <xsl:value-of select="@name" />
  <xsl:call-template name="PrintReturn"/>

 </xsl:template>
</xsl:transform>