<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Ifconfig"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Ifconfig">
		<xsl:apply-templates select="FixedData"/>
		<xsl:apply-templates select="Interface"/>
	</xsl:template>
	
	<xsl:template match="FixedData">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FixedDataItem</xsl:attribute>
			
			<xsl:if test="Type">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">type</xsl:attribute>
					<xsl:value-of select="Type"/>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="HostName">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">hostName</xsl:attribute>
					<xsl:value-of select="HostName"/>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="DomainName">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">domainName</xsl:attribute>
					<xsl:value-of select="DomainName"/>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="ScopeId">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">scopeId</xsl:attribute>
					<xsl:value-of select="ScopeId"/>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="EnableDns">
				<xsl:element name="BoolValue">
					<xsl:attribute name="name">enableDns</xsl:attribute>
					<xsl:value-of select="EnableDns"/>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="EnableProxy">
				<xsl:element name="BoolValue">
					<xsl:attribute name="name">enableProxy</xsl:attribute>
					<xsl:value-of select="EnableProxy"/>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="EnableRouting">
				<xsl:element name="BoolValue">
					<xsl:attribute name="name">enableRouting</xsl:attribute>
					<xsl:value-of select="EnableRouting"/>
				</xsl:element>
			</xsl:if>
			
			<xsl:if test="DnsServerList">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">DnsServers</xsl:attribute>
					
					<xsl:for-each select="DnsServerList/DnsServer">
						<xsl:element name="ObjectValue">
							<xsl:attribute name="name">DnsServer</xsl:attribute>
							<xsl:element name="StringValue">
								<xsl:attribute name="name">ip</xsl:attribute>
								<xsl:if test="Ip/IPv4Address">
									<xsl:value-of select="Ip/IPv4Address"/>
								</xsl:if>
								<xsl:if test="Ip/IPv6Address">
									<xsl:value-of select="Ip/IPv6Address"/>
								</xsl:if>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Interface">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">InterfaceItem</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Status</xsl:attribute>
				<xsl:value-of select="Status"/>
			</xsl:element>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">enabled</xsl:attribute>
				<xsl:value-of select="Enabled"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">description</xsl:attribute>
				<xsl:value-of select="Description"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DnsSuffix</xsl:attribute>
				<xsl:value-of select="DnsSuffix"/>
			</xsl:element>
				
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="Type"/>
			</xsl:element>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">DhcpEnabled</xsl:attribute>
				<xsl:value-of select="DhcpEnabled"/>
			</xsl:element>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">HaveWins</xsl:attribute>
				<xsl:value-of select="HaveWins"/>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Wins</xsl:attribute>
					
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Primary</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">ip</xsl:attribute>
						<xsl:if test="Wins/Primary/IPv4Address">
							<xsl:value-of select="Wins/Primary/IPv4Address"/>
						</xsl:if>
						<xsl:if test="Wins/Primary/IPv6Address">
							<xsl:value-of select="Wins/Primary/IPv6Address"/>
						</xsl:if>
					</xsl:element>
				</xsl:element>
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Secondary</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">ip</xsl:attribute>
						<xsl:if test="Wins/Secondary/IPv4Address">
							<xsl:value-of select="Wins/Secondary/IPv4Address"/>
						</xsl:if>
						<xsl:if test="Wins/Secondary/IPv6Address">
							<xsl:value-of select="Wins/Secondary/IPv6Address"/>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">DHCP</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">ip</xsl:attribute>
					<xsl:if test="DHCP/IPv4Address">
						<xsl:value-of select="DHCP/IPv4Address"/>
					</xsl:if>
					<xsl:if test="DHCP/IPv6Address">
						<xsl:value-of select="DHCP/IPv6Address"/>
					</xsl:if>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Gateway</xsl:attribute>
				<xsl:element name="StringValue">
				<xsl:attribute name="name">ip</xsl:attribute>
					<xsl:if test="Gateway/IPv4Address">
						<xsl:value-of select="Gateway/IPv4Address"/>
					</xsl:if>
					<xsl:if test="Gateway/IPv6Address">
						<xsl:value-of select="Gateway/IPv6Address"/>
					</xsl:if>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Address</xsl:attribute>
				<xsl:value-of select="Address"/>
			</xsl:element>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Mtu</xsl:attribute>
				<xsl:value-of select="Mtu"/>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Lease</xsl:attribute>
					
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="Lease/Obtained"/>
					<xsl:with-param name="var" select="'obtained'"/>							
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="Lease/Expires"/>
					<xsl:with-param name="var" select="'expires'"/>							
				</xsl:call-template>
			</xsl:element>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">EnabledArp</xsl:attribute>
				<xsl:value-of select="EnabledArp"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SubnetMask</xsl:attribute>
				<xsl:value-of select="SubnetMask"/>
			</xsl:element>
			
			<xsl:for-each select="AdapterIp">
				<xsl:if test="Ip/IPv4Address">
					<xsl:element name="ObjectValue">
						<xsl:attribute name="name">IpAddress</xsl:attribute>
						<xsl:element name="StringValue">
							<xsl:attribute name="name">ip</xsl:attribute>
							<xsl:value-of select="Ip/IPv4Address"/>
						</xsl:element>
					</xsl:element>						
				</xsl:if>
				<xsl:if test="Ip/IPv6Address">
					<xsl:element name="ObjectValue">
						<xsl:attribute name="name">IpAddressV6</xsl:attribute>
						<xsl:element name="StringValue">
							<xsl:attribute name="name">ip</xsl:attribute>
							<xsl:value-of select="Ip/IPv6Address"/>
						</xsl:element>						
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">DnsServers</xsl:attribute>
					
				<xsl:for-each select="DnsServer">
					<xsl:element name="ObjectValue">
						<xsl:attribute name="name">DnsServer</xsl:attribute>
						<xsl:element name="StringValue">
							<xsl:attribute name="name">ip</xsl:attribute>
							<xsl:if test="Ip/IPv4Address">
								<xsl:value-of select="Ip/IPv4Address"/>
							</xsl:if>
							<xsl:if test="Ip/IPv6Address">
								<xsl:value-of select="Ip/IPv6Address"/>
							</xsl:if>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template name="FileTimeFunction">
		<xsl:param name="time"/>
		<xsl:param name="var" />
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">date</xsl:attribute>
				<xsl:value-of select="substring-before($time, 'T')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">time</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after($time, 'T'), '.')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>