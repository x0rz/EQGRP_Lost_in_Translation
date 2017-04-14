<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl" />
	
	<xsl:output method="xml" omit-xml-declaration="yes" />
	<xsl:template match="/">
			<xsl:element name="StorageObjects">
				<xsl:apply-templates select="SystemVersion" />
				<xsl:call-template name="TaskingInfo">
					<xsl:with-param name="info" select="TaskingInfo"/>
				</xsl:call-template>
			</xsl:element>
	</xsl:template>
	
	<xsl:template match="SystemVersion">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">VersionInfo</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Arch</xsl:attribute>
				<xsl:value-of select="@architecture" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Platform</xsl:attribute>
				<xsl:value-of select="@platform" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Major</xsl:attribute>
				<xsl:value-of select="@major" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Minor</xsl:attribute>
				<xsl:value-of select="@minor" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">RevisionMajor</xsl:attribute>
				<xsl:value-of select="@revisionMajor" />
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">RevisionMinor</xsl:attribute>
				<xsl:value-of select="@revisionMinor" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Build</xsl:attribute>
				<xsl:value-of select="@build" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ExtraInfo</xsl:attribute>
				<xsl:value-of select="ExtraInfo"/>
			</xsl:element>
			
			<xsl:apply-templates select="Flags"/>	
		</xsl:element>
	</xsl:template>

	<xsl:template match="Flags">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Flags</xsl:attribute>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="@value" />
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">DomainController</xsl:attribute>
				<xsl:choose>
					<xsl:when test="DomainController">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Server</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Server">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Workstation</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Workstation">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">BackOffice</xsl:attribute>
				<xsl:choose>
					<xsl:when test="BackOffice">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Blade</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Blade">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">DataCenter</xsl:attribute>
				<xsl:choose>
					<xsl:when test="DataCenter">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Enterprise</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Enterprise">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">EmbeddedNT</xsl:attribute>
				<xsl:choose>
					<xsl:when test="EmbeddedNT">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Personal</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Personal">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">SingleUserTS</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SingleUserTS">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">SmallBusiness</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SmallBusiness">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">SmallBusinessRestricted</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SmallBusinessRestricted">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Terminal</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Terminal">
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
