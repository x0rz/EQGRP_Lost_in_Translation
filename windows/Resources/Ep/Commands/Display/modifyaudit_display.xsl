<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="AllDisabled">
   <xsl:text>All auditing has been disabled</xsl:text>
   <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="SecurityDisabled">
   <xsl:text>Security auditing has been disabled</xsl:text>
   <xsl:call-template name="PrintReturn" />
 </xsl:template>

</xsl:transform>