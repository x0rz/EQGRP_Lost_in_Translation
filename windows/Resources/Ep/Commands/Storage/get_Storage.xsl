<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="LocalGetDirectory"/>
	    <xsl:apply-templates select="FileStart"/>
	    <xsl:apply-templates select="FileStop"/>
	    <xsl:apply-templates select="Conclusion"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Conclusion">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">NumSuccess</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@successFiles"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">NumPartial</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@partialFiles"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">NumFailed</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@failedFiles"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">LocalGetDirectory</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@localDir"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="FileStart">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">FileName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@implantName"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="FileStop">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">LocalName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@localName"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">BytesWritten</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@size"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">Successful</xsl:attribute>
      <xsl:choose>
       <xsl:when test="@status = 'SUCCESS'">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="LocalGetDirectory">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">LocalGetDirectory</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>