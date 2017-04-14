<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">	
	    <xsl:apply-templates select="TargetVersion"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="TargetVersion">
	<xsl:element name="Storage">
	    <xsl:attribute name="type">int</xsl:attribute>
	    <xsl:attribute name="name">sysVerMajor</xsl:attribute>
	    <xsl:attribute name="value"><xsl:value-of select="number(@major)"/></xsl:attribute>
        </xsl:element>
	<xsl:element name="Storage">
	    <xsl:attribute name="type">int</xsl:attribute>
	    <xsl:attribute name="name">sysVerMinor</xsl:attribute>
	    <xsl:attribute name="value"><xsl:value-of select="number(@minor)"/></xsl:attribute>
        </xsl:element>
	<xsl:element name="Storage">
	    <xsl:attribute name="type">int</xsl:attribute>
	    <xsl:attribute name="name">sysBuild</xsl:attribute>
	    <xsl:attribute name="value"><xsl:value-of select="number(@build)"/></xsl:attribute>
        </xsl:element>
	<xsl:element name="Storage">
	    <xsl:attribute name="type">int</xsl:attribute>
	    <xsl:attribute name="name">sysPlatformId</xsl:attribute>
	    <xsl:attribute name="value"><xsl:value-of select="number(@platform)"/></xsl:attribute>
        </xsl:element>
	<xsl:element name="Storage">
	    <xsl:attribute name="type">int</xsl:attribute>
	    <xsl:attribute name="name">sysProduct</xsl:attribute>
	    <xsl:attribute name="value"><xsl:value-of select="number(ProductType)"/></xsl:attribute>
        </xsl:element>

	<xsl:choose>
	    <xsl:when test="TerminalServer">
		<xsl:element name="Storage">
		    <xsl:attribute name="type">bool</xsl:attribute>
		    <xsl:attribute name="name">sysWTS</xsl:attribute>
		    <xsl:attribute name="value">true</xsl:attribute>
	        </xsl:element>
	    </xsl:when>
	    <xsl:otherwise>
		<xsl:element name="Storage">
		    <xsl:attribute name="type">bool</xsl:attribute>
		    <xsl:attribute name="name">sysWTS</xsl:attribute>
		    <xsl:attribute name="value">false</xsl:attribute>
	        </xsl:element>
	    </xsl:otherwise>
	</xsl:choose>

	<xsl:apply-templates select="ServicePack"/>
	<xsl:apply-templates select="Suites"/>

  </xsl:template>

  <xsl:template match="ServicePack">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">sysSP</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">sysSPMajor</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@major"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">sysSPMinor</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="number(@minor)"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Suites">
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysBackoffice</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuiteBackOffice"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysDatacenter</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuiteDataCenter"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysEnterprise</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuiteEnterprise"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysSmallBus</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuiteSmallBusiness"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysSmallBusRestrict</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuiteSmallBusinessRestricted"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysTermServices</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuiteTerminal"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysComms</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuiteCommunications"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysSUTS</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuiteSingleUserTs"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysEmbedNT</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuiteEmbeddedNt"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysPersonal</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuitePersonal"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sysBlade</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@verSuiteBlade"/></xsl:attribute>
    </xsl:element>
  </xsl:template>
</xsl:transform>