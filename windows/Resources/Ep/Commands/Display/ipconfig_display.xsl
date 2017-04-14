<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="FixedData">
  <xsl:text>        Host Name . . . . . . . . . : </xsl:text>
  <xsl:value-of select="HostName" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        Primary DNS Suffix. . . . . : </xsl:text>
  <xsl:value-of select="DomainName" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        DNS . . . . . . . . . . . . : </xsl:text>
  <xsl:value-of select="DnsServerList/IP" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        Node Type . . . . . . . . . : </xsl:text>
  <xsl:value-of select="Type" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        IP Routing Enabled. . . . . : </xsl:text>
  <xsl:choose>
   <xsl:when test="EnableRouting"><xsl:text>yes</xsl:text></xsl:when>
   <xsl:otherwise><xsl:text>no</xsl:text></xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        WINS Proxy Enabled. . . . . : </xsl:text>
  <xsl:choose>
   <xsl:when test="EnableProxy"><xsl:text>yes</xsl:text></xsl:when>
   <xsl:otherwise><xsl:text>no</xsl:text></xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="PrintReturn" />
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="Adapter">
  <xsl:text>Ethernet adapter        </xsl:text><xsl:value-of select="Name" /><xsl:text>:</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>        Description . . . . . . . . : </xsl:text>
  <xsl:value-of select="Description" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        Physical Address. . . . . . : </xsl:text>
  <xsl:value-of select="Address" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        DHCP Enabled. . . . . . . . : </xsl:text>
  <xsl:choose>
   <xsl:when test="DhcpEnabled"><xsl:text>yes</xsl:text></xsl:when>
   <xsl:otherwise><xsl:text>no</xsl:text></xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="PrintReturn" />

  <xsl:text>        Adapter Index . . . . . . . : </xsl:text>
  <xsl:value-of select="@index" />
  <xsl:call-template name="PrintReturn" />

  <!-- print each IP -->
  <xsl:for-each select="AdapterIp">
	<xsl:text>        IP Address. . . . . . . . . : </xsl:text>
	<xsl:value-of select="IP" />
	<xsl:call-template name="PrintReturn" />
	<xsl:text>        Subnet Mask . . . . . . . . : </xsl:text>
	<xsl:value-of select="Mask" />
	<xsl:call-template name="PrintReturn" />
  </xsl:for-each>

  <xsl:text>        Default Gateway . . . . . . : </xsl:text>
  <xsl:value-of select="Gateway/IP" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        DHCP Server . . . . . . . . : </xsl:text>
  <xsl:value-of select="DHCP/IP" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        Primary WINS Server . . . . : </xsl:text>
  <xsl:value-of select="PrimaryWins/IP" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        Secondary WINS Server . . . : </xsl:text>
  <xsl:value-of select="SecondaryWins/IP" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        Lease Obtained. . . . . . . : </xsl:text>
  <xsl:call-template name="printTimeMDYHMS">
   <xsl:with-param name="i" select="Lease/Obtained" />
  </xsl:call-template>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        Lease Expires . . . . . . . : </xsl:text>
  <xsl:call-template name="printTimeMDYHMS">
   <xsl:with-param name="i" select="Lease/Expires" />
  </xsl:call-template>
  <xsl:call-template name="PrintReturn" />
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

</xsl:transform>