<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="ArpMon">
  <xsl:apply-templates select="Header"/>
  <xsl:apply-templates select="Entry" />
 </xsl:template>

 <xsl:template match="Header">
    <xsl:call-template name="PrintReturn" />
    <xsl:text>  Internet Address      Physical Address     Type      Interface</xsl:text>
    <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="Entry">
  

    
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
  <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="10 - string-length(Type)" />
  </xsl:call-template>
  <xsl:value-of select="Interface" />
  <xsl:call-template name="PrintReturn" />

 </xsl:template>

</xsl:transform>