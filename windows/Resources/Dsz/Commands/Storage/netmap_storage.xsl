<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Entries"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Entries">
		<xsl:apply-templates select="ExtendedError"/>
		<xsl:apply-templates select="Entry"/>
	</xsl:template>
	
	<xsl:template match="Entry">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">NetmapEntryItem</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LocalName</xsl:attribute>
				<xsl:value-of select="LocalName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">RemoteName</xsl:attribute>
				<xsl:value-of select="RemoteName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ParentName</xsl:attribute>
				<xsl:value-of select="ParentName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Comment</xsl:attribute>
				<xsl:value-of select="Comment"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Provider</xsl:attribute>
				<xsl:value-of select="Provider"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="Type"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Level</xsl:attribute>
				<xsl:value-of select="@level"/>
			</xsl:element>
			
			<xsl:for-each select="Addr">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Ip</xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:element>
			</xsl:for-each>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">Time</xsl:attribute>
				<xsl:value-of select="TimeOfDay"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">TimezoneOffset</xsl:attribute>
				<xsl:value-of select="TimeZoneOffset"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">OsPlatform</xsl:attribute>
				<xsl:value-of select="OsInfo/@platformType"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">OsVersionMajor</xsl:attribute>
				<xsl:value-of select="OsInfo/@osVersionMajor"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">OsVersionMinor</xsl:attribute>
				<xsl:value-of select="OsInfo/@osVersionMinor"/>
			</xsl:element>
			
			<xsl:for-each select="OsInfo/Software">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Software</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Name</xsl:attribute>
						<xsl:value-of select="@name"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Description</xsl:attribute>
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ExtendedError">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ExtendedError</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">errorCode</xsl:attribute>
				<xsl:value-of select="@errorCode"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">error</xsl:attribute>
				<xsl:value-of select="Error"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
</xsl:transform>