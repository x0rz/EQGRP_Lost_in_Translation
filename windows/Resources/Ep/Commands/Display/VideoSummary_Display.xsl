<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

  <xsl:template match="Command">
     <xsl:text>&#x0D;&#x0A;</xsl:text> 
     <xsl:text>Processing video file. Please Wait...</xsl:text>
     <xsl:text>&#x0D;&#x0A;</xsl:text> 
     <xsl:text>&#x0D;&#x0A;</xsl:text> 
  </xsl:template>

  <xsl:template match="VideoSummary">
    <xsl:text>JPEG Returned: </xsl:text>
    <xsl:value-of select="@jpegFileName"/>
    <xsl:text>&#x0D;&#x0A;</xsl:text> 
  </xsl:template>

 <xsl:template match="Success">
   	<xsl:text>&#x0D;&#x0A;</xsl:text> 
	<xsl:text>Operation completed successfully.</xsl:text>
    	<xsl:text>&#x0D;&#x0A;</xsl:text> 
        <xsl:text>&#x0D;&#x0A;</xsl:text> 
	<xsl:text>JPEG Files stored in Get_Files directory.</xsl:text>
 </xsl:template>
</xsl:transform>


