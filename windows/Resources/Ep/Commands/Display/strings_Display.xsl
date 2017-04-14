<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Command">
  <xsl:value-of select="@name" />

  <xsl:for-each select="/Command/Argument">
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="1" /> 
   </xsl:call-template>
   <xsl:value-of select="."/>   
  </xsl:for-each>

  <xsl:text>&#x0D;&#x0A;&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="String">
  <xsl:text>offset:</xsl:text>
  <xsl:value-of select="@offset"/>
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="5 - string-length(@offset)" /> 
  </xsl:call-template>
  <xsl:text>type:</xsl:text>
  <xsl:choose>
   <xsl:when test="@unicode = 'false'">
    <xsl:text>ascii</xsl:text>
    <xsl:call-template name="Whitespace">
     <xsl:with-param name="i" select="8" /> 
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>unicode</xsl:text>
    <xsl:call-template name="Whitespace">
     <xsl:with-param name="i" select="5" /> 
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="/String"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>


 <xsl:template match="Success">
  <xsl:text>&#x0D;&#x0A;String listing complete&#x0D;&#x0A;</xsl:text>
 </xsl:template>

</xsl:transform>