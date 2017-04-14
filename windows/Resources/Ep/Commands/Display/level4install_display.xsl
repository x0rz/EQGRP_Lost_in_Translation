<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Install">
  
  <xsl:text>-------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:text> Level4 implant name: </xsl:text>
  <xsl:value-of select="RemoteFile" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>Timestamp match file: </xsl:text>
  <xsl:value-of select="MatchFile" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>-------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:call-template name="PrintReturn" />

 </xsl:template>

 <xsl:template match="FileSize">
  <xsl:text>Loading level4 implant:  Preparing for transfer</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>&#x09;(</xsl:text>
  <xsl:value-of select="." />
  <xsl:text> bytes written)</xsl:text>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

</xsl:transform>