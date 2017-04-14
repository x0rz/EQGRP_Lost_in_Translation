<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Entry">
  <xsl:variable name="type" select="substring-before(substring-after(Category, 'CN='), ',')" />

  <xsl:value-of select="$type"/>

  <xsl:call-template name="PrintReturn" />
  <xsl:text>&#x09;</xsl:text>
  <xsl:value-of select="Name" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>&#x09;</xsl:text>
  <xsl:value-of select="DistinguishedName" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>-------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />

 </xsl:template>

</xsl:transform>