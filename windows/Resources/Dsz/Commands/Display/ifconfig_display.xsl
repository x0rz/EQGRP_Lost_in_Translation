<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
    <xsl:template match="Ifconfig">
		<xsl:apply-templates/>
    </xsl:template>
    
	<xsl:template match="FixedData">
		<xsl:text>      </xsl:text>
		<xsl:text>Host Name . . . . . . . . . : </xsl:text>
		<xsl:value-of select="HostName"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>        </xsl:text>
		<xsl:text>Primary DNS Suffix. . . . . : </xsl:text>
		<xsl:value-of select="DomainName"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>        </xsl:text>
		<xsl:text>DNS . . . . . . . . . . . . : </xsl:text>
		<xsl:if test="not('DnsServerList/DnsServer')">
			<xsl:text>None</xsl:text>
		</xsl:if>
		<xsl:for-each select="DnsServerList/DnsServer">
			<xsl:if test="not(position() = 1)">
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>        </xsl:text>
				<xsl:text>                              </xsl:text>
			</xsl:if>
			<xsl:value-of select="Ip/IPv4Address"/>
			<xsl:value-of select="Ip/IPv6Address"/>
		</xsl:for-each>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>        </xsl:text>
		<xsl:text>Node Type . . . . . . . . . : </xsl:text>
		<xsl:value-of select="Type"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>        </xsl:text>
		<xsl:text>IP Routing Enabled. . . . . : </xsl:text>
		<xsl:choose>
			<xsl:when test="contains(EnableRouting, 'true')"><xsl:text>yes</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>no</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>        </xsl:text>
		<xsl:text>WINS Proxy Enabled. . . . . : </xsl:text>
		<xsl:choose>
			<xsl:when test="contains(EnableProxy, 'true')"><xsl:text>yes</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>no</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>        </xsl:text>
		<xsl:text>DNS Enabled . . . . . . . . : </xsl:text>
		<xsl:choose>
			<xsl:when test="contains(EnableDns, 'true')"><xsl:text>yes</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>no</xsl:text></xsl:otherwise>
		</xsl:choose>
		
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		
	</xsl:template>
	
	<xsl:template match="Interface">
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="Type"/>
		<xsl:text> adapter     </xsl:text>
		<xsl:value-of select="Name"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>        </xsl:text>
		<xsl:text>Status. . . . . . . . . . . : </xsl:text>
		<xsl:value-of select="Status"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>        </xsl:text>
		<xsl:text>DNS Suffix. . . . . . . . . : </xsl:text>
		<xsl:value-of select="DnsSuffix"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>        </xsl:text>
		<xsl:text>Description . . . . . . . . : </xsl:text>
		<xsl:value-of select="Description"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:if test="Address">
			<xsl:text>        </xsl:text>
			<xsl:text>Physical Address. . . . . . : </xsl:text>
			<xsl:value-of select="Address"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:if test="DhcpEnabled">
			<xsl:text>        </xsl:text>
			<xsl:text>DHCP Enabled. . . . . . . . : </xsl:text>
			<xsl:choose>
				<xsl:when test="contains(DhcpEnabled, 'true')"><xsl:text>yes</xsl:text></xsl:when>
				<xsl:otherwise><xsl:text>no</xsl:text></xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:for-each select="AdapterIp">
			<xsl:if test="Ip/IPv4Address">
				<xsl:text>        </xsl:text>
				<xsl:text>IPv4 Address. . . . . . . . : </xsl:text>
				<xsl:value-of select="Ip/IPv4Address"/>
				<xsl:call-template name="PrintReturn"/>	
			</xsl:if>
			<xsl:if test="Ip/IPv6Address">
				<xsl:text>        </xsl:text>
				<xsl:text>IPv6 Address. . . . . . . . : </xsl:text>
				<xsl:value-of select="Ip/IPv6Address"/>
				<xsl:call-template name="PrintReturn"/>	
			</xsl:if>
		</xsl:for-each>

		<xsl:if test="string-length(SubnetMask) &gt; 0">
			<xsl:text>        </xsl:text>
			<xsl:text>Subnet Mask . . . . . . . . : </xsl:text>
			<xsl:value-of select="SubnetMask"/>
			<xsl:call-template name="PrintReturn"/>	
		</xsl:if>
			
		<xsl:for-each select="DnsServer">
			<xsl:text>        </xsl:text>
			<xsl:text>DNS . . . . . . . . . . . . : </xsl:text>
			<xsl:value-of select="Ip/IPv4Address"/>
			<xsl:value-of select="Ip/IPv6Address"/>
			<xsl:call-template name="PrintReturn"/>	
		</xsl:for-each>
		
		<xsl:if test="Gateway">
			<xsl:text>        </xsl:text>
			<xsl:text>Default Gateway . . . . . . : </xsl:text>
			<xsl:value-of select="Gateway/IPv4Address"/>
			<xsl:value-of select="Gateway/IPv6Address"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:if test="DHCP">
			<xsl:text>        </xsl:text>
			<xsl:text>DHCP Server . . . . . . . . : </xsl:text>
			<xsl:value-of select="DHCP/IPv4Address"/>
			<xsl:value-of select="DHCP/IPv6Address"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:if test="Wins/Primary">
			<xsl:text>        </xsl:text>
			<xsl:text>Primary WINS Server . . . . : </xsl:text>
			<xsl:value-of select="Wins/Primary/IPv4Address"/>
			<xsl:value-of select="Wins/Primary/IPv6Address"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:if test="Wins/Secondary">
			<xsl:text>        </xsl:text>
			<xsl:text>Secondary WINS Server . . . : </xsl:text>
			<xsl:value-of select="Wins/Secondary/IPv4Address"/>
			<xsl:value-of select="Wins/Secondary/IPv6Address"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:if test="contains(DhcpEnabled, 'true')">
			<xsl:text>        </xsl:text>
			<xsl:text>Lease Obtained. . . . . . . : </xsl:text>
			<xsl:value-of select="substring-before(Lease/Obtained, 'T')"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="substring-before(substring-after(Lease/Obtained, 'T'), '.')"/>
			<xsl:call-template name="PrintReturn"/>
			<xsl:text>        </xsl:text>
			<xsl:text>Lease Expires . . . . . . . : </xsl:text>
			<xsl:value-of select="substring-before(Lease/Expires, 'T')"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="substring-before(substring-after(Lease/Expires, 'T'), '.')"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>

</xsl:transform>
