<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>
 <xsl:template match="LotusNotesMailUsers">
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>User                     Mail Database       Email Address </xsl:text>
  <xsl:call-template name="PrintReturn" />
    <xsl:text>--------------------------------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:apply-templates select="User"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:template>
  <xsl:template match="User">

  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:value-of select="FirstName"/>
  <xsl:choose>
     <xsl:when test = "FirstName != ''">
        <xsl:text> </xsl:text>
        <xsl:value-of select="LastName"/>
     </xsl:when>
     <xsl:otherwise>
        <xsl:value-of select="LastName"/>
        <xsl:text> </xsl:text>
     </xsl:otherwise>
  </xsl:choose> 

  <xsl:call-template name="Whitespace">

  <xsl:with-param name="i" select="24 - string-length(LastName) - string-length(FirstName)" /> 

  </xsl:call-template>

  <xsl:value-of select="MailFile"/> 
  <xsl:text> </xsl:text>

  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="15 - string-length(MailFile)" /> 
  </xsl:call-template>
  <xsl:value-of select="InternetAddress"/>

 </xsl:template>

 <xsl:template match="Success" />
</xsl:transform>

