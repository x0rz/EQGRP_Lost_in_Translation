<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
    <xsl:element name="StorageNodes">
      <xsl:apply-templates select="PerformanceInformation"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="PerformanceInformation">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">systemName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@systemName"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">prefFreq</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@prefFreq"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">perfTime</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@perfTime"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">perfTime100nSec</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@perfTime100nSec"/></xsl:attribute>
    </xsl:element>

    <xsl:apply-templates select="ObjectType">
	  <xsl:with-param name="perfTime" select="@perfTime"/>
	  <xsl:with-param name="perfFreq" select="@perfFreq"/>
	  <xsl:with-param name="perfTime100nSec" select="@perfTime100nSec"/>
    </xsl:apply-templates>

		
  </xsl:template>

	
  <xsl:template match="ObjectType">
    <xsl:param name="perfTime"/>
    <xsl:param name="perfFreq"/>
    <xsl:param name="perfTime100nSec"/>
    
    
    <xsl:variable name="prefix" select="concat(@objectNameTitleIndex, '_')"/>
		
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ObjectType</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@objectNameTitleIndex"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$prefix"/>
        <xsl:text>name</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Name"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$prefix"/>
        <xsl:text>help</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Help"/></xsl:attribute>
    </xsl:element>
		
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$prefix"/>
        <xsl:text>nameindex</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@objectNameTitleIndex"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$prefix"/>
        <xsl:text>helpindex</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@objectHelpTitleIndex"/></xsl:attribute>
    </xsl:element>

    <xsl:apply-templates select="Instance">
      <xsl:with-param name="inheritPrefix" select="$prefix"/>
	  <xsl:with-param name="perfTime" select="$perfTime"/>
	  <xsl:with-param name="perfFreq" select="$perfFreq"/>
	  <xsl:with-param name="perfTime100nSec" select="$perfTime100nSec"/>
      
    </xsl:apply-templates>
    <xsl:apply-templates select="Counter">
      <xsl:with-param name="inheritPrefix" select="$prefix"/>
	  <xsl:with-param name="perfTime" select="$perfTime"/>
	  <xsl:with-param name="perfFreq" select="$perfFreq"/>
	  <xsl:with-param name="perfTime100nSec" select="$perfTime100nSec"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="Instance">
    <xsl:param name="inheritPrefix" select="'_'"/>
    <xsl:param name="perfTime"/>
    <xsl:param name="perfFreq"/>
    <xsl:param name="perfTime100nSec"/>
    <xsl:variable name="prefix" select="concat($inheritPrefix, @name, '_')"/>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$inheritPrefix"/>
        <xsl:text>Instance</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@name"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$prefix"/>
        <xsl:text>parent</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@parentInstance"/></xsl:attribute>
    </xsl:element>

    <xsl:apply-templates select="Counter">
      <xsl:with-param name="inheritPrefix" select="$prefix"/>
	  <xsl:with-param name="perfTime" select="$perfTime"/>
	  <xsl:with-param name="perfFreq" select="$perfFreq"/>
	  <xsl:with-param name="perfTime100nSec" select="$perfTime100nSec"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="Counter">
    <xsl:param name="inheritPrefix" select="'_'"/>
    <xsl:param name="perfTime"/>
    <xsl:param name="perfFreq"/>
    <xsl:param name="perfTime100nSec"/>
    <xsl:variable name="prefix" select="concat($inheritPrefix, @nameIndex, '_')"/>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$inheritPrefix"/>
        <xsl:text>Counter</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@nameIndex"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$prefix"/>
        <xsl:text>name</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Name"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$prefix"/>
        <xsl:text>help</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Help"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$prefix"/>
        <xsl:text>calc</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value">
        <xsl:choose>
          <xsl:when test="contains(Value/@type, 'PERF_ELAPSED_TIME')">
            <xsl:value-of select="($perfTime100nSec - Value/@value) div (10*1000*1000)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$prefix"/>
        <xsl:text>value</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value">
        <xsl:value-of select="Value/@value"/>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$prefix"/>
        <xsl:text>type</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Value/@type"/></xsl:attribute>
    </xsl:element>

  </xsl:template>
	
</xsl:transform>
