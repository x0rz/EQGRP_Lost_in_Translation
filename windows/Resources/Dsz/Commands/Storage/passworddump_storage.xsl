<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Passwords"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Passwords">
		<xsl:apply-templates select="WindowsPassword"/>
		<xsl:apply-templates select="WindowsSecret"/>
		<xsl:apply-templates select="UnixPassword"/>
		<xsl:apply-templates select="DigestPassword"/>
	</xsl:template>
	
	<xsl:template match="UnixPassword">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">UnixPassword</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">User</xsl:attribute>
				<xsl:value-of select="@user"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Hash</xsl:attribute>
				<xsl:value-of select="@hash"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Expired</xsl:attribute>
				<xsl:value-of select="@expired"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="DigestPassword">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DigestPassword</xsl:attribute>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">User</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">Domain</xsl:attribute>
				<xsl:value-of select="Domain"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Password</xsl:attribute>
				<xsl:value-of select="Password"/>
			</xsl:element>

		</xsl:element>
	</xsl:template>

	<xsl:template match="WindowsPassword">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">WindowsPassword</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">User</xsl:attribute>
				<xsl:value-of select="@user"/>
			</xsl:element>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Exception</xsl:attribute>
				<xsl:value-of select="@exception"/>
			</xsl:element>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Expired</xsl:attribute>
				<xsl:value-of select="@expired"/>
			</xsl:element>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Rid</xsl:attribute>
				<xsl:value-of select="@rid"/>
			</xsl:element>
			
			<xsl:apply-templates select="LanmanHash"/>
			<xsl:apply-templates select="NtHash"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="LanmanHash">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LanmanHash</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Present</xsl:attribute>
				<xsl:value-of select="@isPresent"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Empty</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@isEmptyString">
						<xsl:value-of select="@isEmptyString"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="NtHash">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">NtHash</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Present</xsl:attribute>
				<xsl:value-of select="@isPresent"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Empty</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@isEmptyString">
						<xsl:value-of select="@isEmptyString"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="WindowsSecret">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">WindowsSecret</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="Value"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>