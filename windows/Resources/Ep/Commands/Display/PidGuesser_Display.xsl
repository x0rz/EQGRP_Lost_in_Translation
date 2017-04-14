<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="PidGuesser">
   <xsl:text>Ipid found:</xsl:text>
   <xsl:call-template name="PrintReturn"/>
   <xsl:value-of select="substring(@index, 3)"/>
   <xsl:text>-</xsl:text>
   <xsl:value-of select="substring(@procId, 3)"/>
   <xsl:text>-</xsl:text>
   <xsl:value-of select="substring(@threadId, 3)"/>
   <xsl:text>-</xsl:text>
   <xsl:value-of select="substring(@counter, 3)"/>
   <xsl:call-template name="PrintReturn"/>
 </xsl:template>


</xsl:transform>