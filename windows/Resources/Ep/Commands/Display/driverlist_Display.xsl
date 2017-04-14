<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Drivers">
   <xsl:text> Base Addr       Size           Image</xsl:text>
   <xsl:call-template name="PrintReturn" />
   <xsl:text>------------------------------------------------------</xsl:text>
   <xsl:call-template name="PrintReturn" />
   <xsl:apply-templates select="Driver" />
  </xsl:template>

  <xsl:template match="Driver">
   <xsl:text> </xsl:text>
   <xsl:value-of select="@base" />
   <xsl:text> </xsl:text>
   
   <xsl:call-template name="Whitespace">
	<xsl:with-param name="i" select="10 - string-length(@size)"/>
   </xsl:call-template>
   <xsl:value-of select="@size" />
   <xsl:text>   </xsl:text>

   <xsl:value-of select="." />
   <xsl:call-template name="PrintReturn" />
  </xsl:template>

</xsl:transform>