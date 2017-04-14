<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Audit">
  <xsl:text>Auditing has been </xsl:text>
  <xsl:value-of select="@status" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="TurnedOn">
  <xsl:text>Auditing has been enabled</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="Status">
  <xsl:text>Auditing: </xsl:text>
  <xsl:value-of select="@current" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:apply-templates select="Event"/>
 </xsl:template>
 
 <xsl:template match="Event">
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="35 - string-length(@category)" />
  </xsl:call-template>
  <xsl:value-of select="@category" />
  <xsl:text> :   </xsl:text>
  <xsl:choose>
   <xsl:when test="OnSuccess">
    <xsl:text>Success</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>       </xsl:text>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:text>     </xsl:text>
  <xsl:choose>
   <xsl:when test="OnFailure">
    <xsl:text>Failure</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>       </xsl:text>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

</xsl:transform>