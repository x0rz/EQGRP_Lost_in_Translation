<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="NetBios">
  <xsl:text>---------------------------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:apply-templates select="Adapter" />
  <xsl:text>---------------------------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="Adapter">
  <xsl:for-each select="Names">
   <xsl:value-of select="Name" />
   <xsl:call-template name="PrintReturn" />

   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="31 - string-length(NetName)" />
   </xsl:call-template>
   <xsl:value-of select="NetName" />
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="40 - string-length(Type)" />
   </xsl:call-template>
   <xsl:value-of select="Type" />
   <xsl:call-template name="PrintReturn" />
  </xsl:for-each>


  <xsl:call-template name="PrintReturn" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>The address of the adapter.: </xsl:text>
  <xsl:value-of select="@adapter_addr" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>The adapter type.  0xFF=Token Ring; 0xFE=Ethernet adapter.: </xsl:text>
  <xsl:value-of select="@adapter_type" />
  <xsl:call-template name="PrintReturn" />
  <xsl:call-template name="PrintReturn" />
 </xsl:template>
</xsl:transform>