<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="KeyboardUsed">
  <xsl:text>Warning!&#x0D;&#x0A;</xsl:text>
  <xsl:text>Someone is typing at the remote keyboard!&#x0D;&#x0A;</xsl:text>
 </xsl:template>

</xsl:transform>