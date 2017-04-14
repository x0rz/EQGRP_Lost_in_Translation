<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Drive">
  <xsl:value-of select="@path" />
  <xsl:text> - </xsl:text>

  <xsl:choose>
   <xsl:when test="starts-with(@cdrom,'true')">
    <xsl:text>The drive is a CDROM.</xsl:text>
   </xsl:when>
   <xsl:when test="starts-with(@fixed, 'true')">
    <xsl:text>The disk cannot be removed from the drive.</xsl:text>
   </xsl:when>
   <xsl:when test="starts-with(@noroot, 'true')">
    <xsl:text>No root directory.</xsl:text>
   </xsl:when>
   <xsl:when test="starts-with(@ramdisk, 'true')">
    <xsl:text>The drive is a RAM disk.</xsl:text>
   </xsl:when>
   <xsl:when test="starts-with(@remote, 'true')">
    <xsl:text>The drive is a remote (network) drive.</xsl:text>
   </xsl:when>
   <xsl:when test="starts-with(@removable, 'true')">
    <xsl:text>The disk is REMOVEABLE</xsl:text>
   </xsl:when>
   <xsl:when test="starts-with(@unknown, 'true')">
    <xsl:text>No drive</xsl:text>
   </xsl:when>
  </xsl:choose>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>


 <xsl:template match="Success" />

</xsl:transform>