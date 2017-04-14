<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="User"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="User">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute> 
      <xsl:attribute name="name">username</xsl:attribute> 
      <xsl:attribute name="value">
      <xsl:value-of select="Username" /> 
      </xsl:attribute>
    </xsl:element>
 


 <xsl:element name="Storage">
    <xsl:attribute name="type">int</xsl:attribute> 
    <xsl:attribute name="name">rid</xsl:attribute> 
    <xsl:attribute name="value">
    <xsl:value-of select="@rid" /> 
    </xsl:attribute>
  </xsl:element>



  <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute> 
    <xsl:attribute name="name">lanmanHash</xsl:attribute> 
    <xsl:attribute name="value">
    <xsl:value-of select="LanmanHash" /> 
    </xsl:attribute>
  </xsl:element>

  <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute> 
    <xsl:attribute name="name">ntHash</xsl:attribute> 
    <xsl:attribute name="value">
    <xsl:value-of select="NtHash" /> 
    </xsl:attribute>
  </xsl:element>


  <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">isNt</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/IsNtPasswordPresent">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

  <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">isLm</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/IsLmPasswordPresent">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

  <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">isPasswordExpired</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/IsPasswordExpired">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

  <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">isHashException</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/IsHashException">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

  <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">isRegNt</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/IsRegNTcmp">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

  <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">isRegLan</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/IsRegLanmancmp">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
 </xsl:template>
</xsl:transform>