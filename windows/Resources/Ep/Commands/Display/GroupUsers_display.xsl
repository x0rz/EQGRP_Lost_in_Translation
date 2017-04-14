<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="User">

  <xsl:text>User : </xsl:text>
  <xsl:value-of select="@user" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>Type (</xsl:text>
  <xsl:value-of select="@attributes" />
  <xsl:text>)</xsl:text>
  
  <xsl:choose>
    <xsl:when test="@attributes = 1">
	<xsl:text> : User Account</xsl:text>
    </xsl:when>
    <xsl:when test="@attributes = 2">
	<xsl:text> : Global Group Account</xsl:text>
    </xsl:when>
    <xsl:when test="@attributes = 3">
	<xsl:text> : Domain Account</xsl:text>
    </xsl:when>
    <xsl:when test="@attributes = 4">
	<xsl:text> : Alias</xsl:text>
    </xsl:when>
    <xsl:when test="@attributes = 5">
	<xsl:text> : Well Known Group (such as Everyone)</xsl:text>
    </xsl:when>
    <xsl:when test="@attributes = 6">
	<xsl:text> : Deleted Account</xsl:text>
    </xsl:when>
    <xsl:when test="@attributes = 7">
	<xsl:text> : Invalid Type</xsl:text>
    </xsl:when>
    <xsl:when test="@attributes = 8">
	<xsl:text> : Unknown Type</xsl:text>
    </xsl:when>
    <xsl:when test="@attributes = 9">
	<xsl:text> : Computer</xsl:text>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>-------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:call-template name="PrintReturn" />

 </xsl:template>
</xsl:transform>