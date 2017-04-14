<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="DomainController"/>
		</xsl:element>
	</xsl:template>
			
	<xsl:template match="DomainController">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DomainController</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">dcName</xsl:attribute>
				<xsl:value-of select="DCName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">dcFullName</xsl:attribute>
				<xsl:value-of select="DCFullName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">dcAddress</xsl:attribute>
				<xsl:value-of select="DCAddress"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">domainGuid</xsl:attribute>
				<xsl:value-of select="DomainGuid"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">domainName</xsl:attribute>
				<xsl:value-of select="DomainName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">dnsForestName</xsl:attribute>
				<xsl:value-of select="DnsForestName"/>
			</xsl:element>	
			<xsl:element name="StringValue">
				<xsl:attribute name="name">dcSiteName</xsl:attribute>
				<xsl:value-of select="DCSiteName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">clientSiteName</xsl:attribute>
				<xsl:value-of select="ClientSiteName"/>
			</xsl:element>
			<xsl:apply-templates select="ExtendedErrorInfo"/>	
			<xsl:apply-templates select="Properties"/>																							
		</xsl:element>
	</xsl:template>

	<xsl:template match="ExtendedErrorInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ExtendedErrorInfo</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">queryError</xsl:attribute>
				<xsl:value-of select="QueryError"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	
	<xsl:template match="Properties">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Properties</xsl:attribute>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Primary</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Primary">
						<xsl:text>true</xsl:text>
					</xsl:when>
				        <xsl:otherwise>
					        <xsl:text>false</xsl:text>
				        </xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Backup</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Backup">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">KerberosKeyDistCenter</xsl:attribute>
				<xsl:choose>
					<xsl:when test="KerberosKeyDistCenter">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">GlobalCatalog</xsl:attribute>
				<xsl:choose>
					<xsl:when test="GlobalCatalog">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">DirectoryService</xsl:attribute>
				<xsl:choose>
					<xsl:when test="DirectoryService">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>	
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">TimeService</xsl:attribute>
				<xsl:choose>
					<xsl:when test="TimeService">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">SAM</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SAM">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>																							
		</xsl:element>
	</xsl:template>

</xsl:transform>