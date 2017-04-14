<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Success">
   <xsl:text>&#x0D;&#x0A;Netmap Listing Complete.&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="Entry">
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="3 * @level" />
  </xsl:call-template>
  <xsl:value-of select="Type" />
  <xsl:text> </xsl:text>
  <xsl:value-of select="RemoteName" />
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="25 - string-length(RemoteName)" />
  </xsl:call-template>
  <xsl:choose>
   <xsl:when test="contains(Type, 'SERVER')">
    <xsl:call-template name="Whitespace">
     <xsl:with-param name="i" select="20 - string-length(LocalName)" />
    </xsl:call-template>
    <xsl:value-of select="LocalName" />
    <xsl:text> (</xsl:text>
    <xsl:value-of select="IPAddr" />
    <xsl:text>)</xsl:text>
   </xsl:when>
   <xsl:otherwise>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:text> : (</xsl:text>
  <xsl:value-of select="Comment" />
  <xsl:text>) - </xsl:text>
  <xsl:value-of select="Provider" />
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="ExtendedError">
  <xsl:text>Extended Error Code                : (</xsl:text>
  <xsl:value-of select="@code" />
  <xsl:text>)</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>Extended Error Message             : (</xsl:text>
  <xsl:value-of select="Error" />
  <xsl:text>)</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>Network Provider Raising the Error : (</xsl:text>
  <xsl:value-of select="Name" />
  <xsl:text>)</xsl:text>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>


</xsl:transform>