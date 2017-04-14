<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Arp">
  <xsl:apply-templates select="Entry" />
 </xsl:template>

 <xsl:template match="Entry">
  <xsl:choose>
   <xsl:when test="position() = 1">
    <xsl:text>Interface: </xsl:text>
    <xsl:value-of select="InterfaceIp" />
    <xsl:text> on Interface </xsl:text>
    <xsl:value-of select="@index" />
    <xsl:call-template name="PrintReturn" />
    <xsl:text>  Internet Address      Physical Address     Type</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:when>
   <xsl:when test="not(preceding-sibling::Entry/@index = @index)">
    <xsl:text>Interface: </xsl:text>
    <xsl:value-of select="InterfaceIp" />
    <xsl:text> on Interface </xsl:text>
    <xsl:value-of select="@index" />
    <xsl:text> (</xsl:text>
    <xsl:value-of select="@index" />
    <xsl:text>)</xsl:text>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="../Entry[position() - 1]/@index" />
    <xsl:text>)</xsl:text>

    <xsl:call-template name="PrintReturn" />
    <xsl:text>  Internet Address      Physical Address     Type</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:when>
  </xsl:choose>
  <xsl:text>  </xsl:text>
  <xsl:value-of select="Ip" />
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="22 - string-length(Ip)" />
  </xsl:call-template>
  <xsl:value-of select="PhysicalAddress" />
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="21 - string-length(PhysicalAddress)" />
  </xsl:call-template>
  <xsl:value-of select="Type" />
  <xsl:call-template name="PrintReturn" />

 </xsl:template>

</xsl:transform>