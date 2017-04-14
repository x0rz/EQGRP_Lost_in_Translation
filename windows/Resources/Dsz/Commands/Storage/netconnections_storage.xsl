<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Connections">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="Initial">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">InitialConnectionListItem</xsl:attribute>
				
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Started">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">StartConnectionListItem</xsl:attribute>
			
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Stopped">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">StopConnectionListItem</xsl:attribute>
				
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Connection">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ConnectionItem</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">state</xsl:attribute>
				<xsl:value-of select="@state"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">valid</xsl:attribute>
				<xsl:value-of select="@valid"/>
			</xsl:element>
		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">pid</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Pid">
						<xsl:value-of select="Pid"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			
			<xsl:if test="LocalAddress">
				<xsl:call-template name="IpAddress">
					<xsl:with-param name="ip" select="LocalAddress"/>
					<xsl:with-param name="port" select="LocalPort"/>
					<xsl:with-param name="name" select="'Local'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="RemoteAddress">
					<xsl:call-template name="IpAddress">
						<xsl:with-param name="ip" select="RemoteAddress"/>
						<xsl:with-param name="port" select="RemotePort"/>
						<xsl:with-param name="name" select="'Remote'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- for backwards compatibility add 'Remote' data -->
					<xsl:element name="ObjectValue">
						<xsl:attribute name="name">
							<xsl:text>Remote</xsl:text>
						</xsl:attribute>

						<xsl:element name="StringValue">
							<xsl:attribute name="name">port</xsl:attribute>
							<xsl:text></xsl:text>
						</xsl:element>

						<xsl:choose>
							<xsl:when test="LocalAddress/IPv4Address">
								<xsl:element name="StringValue">
									<xsl:attribute name="name">type</xsl:attribute>
									<xsl:text>ipv4</xsl:text>
								</xsl:element>
								<xsl:element name="StringValue">
									<xsl:attribute name="name">ipv4</xsl:attribute>
									<xsl:text>0.0.0.0</xsl:text>
								</xsl:element>
								<xsl:element name="StringValue">
									<xsl:attribute name="name">address</xsl:attribute>
									<xsl:text>0.0.0.0</xsl:text>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="StringValue">
									<xsl:attribute name="name">type</xsl:attribute>
									<xsl:text>ipv6</xsl:text>
								</xsl:element>
								<xsl:element name="StringValue">
									<xsl:attribute name="name">ipv6</xsl:attribute>
									<xsl:text>::</xsl:text>
								</xsl:element>
								<xsl:element name="StringValue">
									<xsl:attribute name="name">address</xsl:attribute>
									<xsl:text>::</xsl:text>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
			
		</xsl:element>
	</xsl:template>

	<xsl:template name="IpAddress">
		<xsl:param name="ip"/>
		<xsl:param name="port"/>
		<xsl:param name="name"/>
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$name"/>
			</xsl:attribute>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">port</xsl:attribute>
				<xsl:value-of select="$port"/>
			</xsl:element>
			
			<xsl:choose>
				<xsl:when test="$ip/IPv4Address">
					<xsl:element name="StringValue">
						<xsl:attribute name="name">type</xsl:attribute>
						<xsl:text>ipv4</xsl:text>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">ipv4</xsl:attribute>
						<xsl:value-of select="$ip/IPv4Address"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">address</xsl:attribute>
						<xsl:value-of select="$ip/IPv4Address"/>
					</xsl:element>
					<xsl:if test="$port">
						<xsl:element name="StringValue">
							<xsl:attribute name="name">portv4</xsl:attribute>
							<xsl:value-of select="$port"/>
						</xsl:element>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$ip/IPv6Address">
					<xsl:element name="StringValue">
						<xsl:attribute name="name">type</xsl:attribute>
						<xsl:text>ipv6</xsl:text>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">ipv6</xsl:attribute>
						<xsl:value-of select="$ip/IPv6Address"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">address</xsl:attribute>
						<xsl:value-of select="$ip/IPv6Address"/>
					</xsl:element>
					<xsl:if test="$port">
						<xsl:element name="StringValue">
							<xsl:attribute name="name">portv6</xsl:attribute>
							<xsl:value-of select="$port"/>
						</xsl:element>
					</xsl:if>
				</xsl:when>
			</xsl:choose>			
		</xsl:element>
		
	</xsl:template>
	
	<xsl:template name="chopZero">
		<xsl:param name="number"/>
		
		<xsl:choose>
			<xsl:when test="starts-with($number, '0')">
				<xsl:call-template name="chopZero">
					<xsl:with-param name="number" select="substring-after($number, '0')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$number"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="FileTimeFunction">
		<xsl:param name="time"/>
		<xsl:param name="var" />
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">time</xsl:attribute>
				<xsl:value-of select="$time"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">locale</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:transform>
