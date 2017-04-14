<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Local"/>
	    <xsl:apply-templates select="LocalPeer"/>	
	    <xsl:apply-templates select="Remote"/>
	    <xsl:apply-templates select="RemotePeer"/>
	</xsl:element>
  </xsl:template>

  <!-- NOTE: I wanted to do this with a single function with a string
	     prefix that is concatenated to _family, _address, _port, but
	     I couldn't get it to work...
  -->

  <xsl:template match="Local">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">local_family</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Family"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">local_address</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Address"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">local_port</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Port"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="LocalPeer">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">connected_family</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Family"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">connected_address</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Address"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">connected_port</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Port"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Remote">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">remote_family</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Family"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">remote_address</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Address"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">remote_port</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Port"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="RemotePeer">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">remote_peer_family</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Family"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">remote_peer_address</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Address"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">remote_peer_port</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Port"/></xsl:attribute>
    </xsl:element>
  </xsl:template>
</xsl:transform>