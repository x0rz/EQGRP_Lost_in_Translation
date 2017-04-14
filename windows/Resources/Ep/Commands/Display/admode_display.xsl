<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="AdMode">
   <xsl:text>Current Domain : </xsl:text>
   <xsl:value-of select="." />
   <xsl:call-template name="PrintReturn"/>

   <xsl:text>          Mode : </xsl:text>
   <xsl:choose>
    <xsl:when test="contains(@mixed, 'true')">
     <xsl:text>Mixed</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:text>Native</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
   <xsl:call-template name="PrintReturn"/>

 </xsl:template>


</xsl:transform>