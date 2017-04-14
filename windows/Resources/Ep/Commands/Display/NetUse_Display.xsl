<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="IntermediateSuccess">

   <xsl:text>Connection to remote host made successfully.</xsl:text>
   <xsl:call-template name="PrintReturn"/>
   <xsl:call-template name="PrintReturn"/>

   <xsl:text>Command </xsl:text>
   <xsl:value-of select="@request"/>
   <xsl:text> will continue to run in the background.</xsl:text>
   <xsl:call-template name="PrintReturn"/>

 </xsl:template>

</xsl:transform>