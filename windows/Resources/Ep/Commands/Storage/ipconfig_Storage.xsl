<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="FixedData"/>
	    <xsl:apply-templates select="Adapter"/>
	</xsl:element>
  </xsl:template>


  <xsl:template match="FixedData">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipHost</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="HostName"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipDomainName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="DomainName"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipNode</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Type"/></xsl:attribute>
    </xsl:element>
    <xsl:for-each select="DnsServerList">
     <xsl:element name="Storage">
       <xsl:attribute name="type">string</xsl:attribute>
       <xsl:attribute name="name">ipDNS</xsl:attribute>
       <xsl:attribute name="value"><xsl:value-of select="IP"/></xsl:attribute>
     </xsl:element>
    </xsl:for-each>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipRouting</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:choose>
        <xsl:when test="EnableRouting">yes</xsl:when>
        <xsl:otherwise>no</xsl:otherwise>
       </xsl:choose>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipWINSProxy</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:choose>
        <xsl:when test="EnableProxy">yes</xsl:when>
        <xsl:otherwise>no</xsl:otherwise>
       </xsl:choose>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Adapter">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptType</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Type"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Name"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptDesc</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Description"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptPhysAddr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Address"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptDHCPEnab</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:choose>
        <xsl:when test="DhcpEnabled">yes</xsl:when>
        <xsl:otherwise>no</xsl:otherwise>
       </xsl:choose>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">ipAdaptIndex</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@index"/></xsl:attribute>
    </xsl:element>
    <xsl:variable name="index" select="@index" />
    <xsl:for-each select="AdapterIp">
     <xsl:element name="Storage">
       <xsl:attribute name="type">string</xsl:attribute>
       <xsl:attribute name="name"><xsl:value-of select="concat('ipAdaptIP_', $index)" /></xsl:attribute>
       <xsl:attribute name="value"><xsl:value-of select="IP"/></xsl:attribute>
     </xsl:element>
     <xsl:element name="Storage">
       <xsl:attribute name="type">string</xsl:attribute>
       <xsl:attribute name="name"><xsl:value-of select="concat('ipAdaptSubMask_', $index)" /></xsl:attribute>
       <xsl:attribute name="value"><xsl:value-of select="Mask"/></xsl:attribute>
     </xsl:element>
    </xsl:for-each>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptGateway</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Gateway/IP"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptDHCPIP</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="DHCP/IP"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptWINSPri</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="PrimaryWins/IP"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptWINSSec</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="SecondaryWins/IP"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptLeaseOn</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeMDYHMS">
        <xsl:with-param name="i" select="Lease/Obtained"/>
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipAdaptLeaseOff</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeMDYHMS">
        <xsl:with-param name="i" select="Lease/Expires"/>
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>


</xsl:transform>