<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Drive"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Drive">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">drive</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@path"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">is_drive_unknown</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@unknown"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">is_drive_noroot</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@noroot"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">is_drive_removable</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@removable"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">is_drive_fixed</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@fixed"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">is_drive_remote</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@remote"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">is_drive_cdrom</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@cdrom" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">is_drive_ramdisk</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@ramdisk"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>